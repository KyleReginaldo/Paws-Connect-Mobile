import 'dart:async';
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paws_connect/core/provider/common_provider.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/core/widgets/text_field.dart';

import '../../../core/supabase/client.dart';
import '../../../core/transfer_object/address.dto.dart';

@RoutePage()
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  final Completer<GoogleMapController> _controllerCompleter = Completer();

  LatLng? _currentLocation;
  String? _errorMessage;
  double _currentZoom = 17.0;
  MapType _currentMapType = MapType.normal;

  bool _isSearching = false;
  bool _showLocationDetails = false;
  bool _isLoading = false;
  final bool _showTraffic = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Location> _searchResults = [];
  LatLng? _selectedLocation;
  String? _selectedLocationName;

  final GlobalKey<FormState> _addressFormKey = GlobalKey<FormState>();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  late AnimationController _searchAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<Offset> _searchSlideAnimation;
  late Animation<double> _pulseAnimation;

  StreamSubscription<Position>? _positionStreamSubscription;

  static const EdgeInsets _defaultPadding = EdgeInsets.all(16.0);
  static const BorderRadius _defaultBorderRadius = BorderRadius.all(
    Radius.circular(12.0),
  );
  static const Duration _animationDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    initLocation();
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _pulseAnimationController.dispose();
    _searchController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _searchFocusNode.dispose();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  void _initializeAnimations() {
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _searchSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _searchAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void handleAddAddress() async {
    EasyLoading.show(status: 'Saving address...', dismissOnTap: false);
    final result = await CommonProvider().addAddress(
      AddAddressDTO(
        street: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipController.text,
        latitude: _selectedLocation?.latitude ?? 0.0,
        longitude: _selectedLocation?.longitude ?? 0.0,
        user: USER_ID,
      ),
    );
    if (result.isError) {
      EasyLoading.dismiss();
      EasyLoading.showError(result.error);
    } else {
      EasyLoading.dismiss();
      EasyLoading.showSuccess(result.value);
      if (mounted) {
        context.router.pop();
      }
    }
  }

  Future<void> initLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage =
              'Location services are disabled. Please enable them in settings.';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage =
                'Location permissions are denied. Please grant location access to use this feature.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Location permissions are permanently denied. Please enable them in app settings.';
          _isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _errorMessage = null;
        _isLoading = false;
      });

      await _addCurrentLocationMarker();

      // Reverse-geocode the initial location and show the address sheet
      try {
        if (_currentLocation != null) {
          final placemarks = await placemarkFromCoordinates(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
          );

          String locationName = 'Current Location';
          if (placemarks.isNotEmpty) {
            final placemark = placemarks.first;

            // Prefer the street field (thoroughfare) and include postal code for better parsing
            final street = placemark.street ?? placemark.name ?? '';
            final city = placemark.locality ?? '';
            final state = placemark.administrativeArea ?? '';
            final postal = placemark.postalCode ?? '';

            locationName = [
              street,
              city,
              [state, postal].where((s) => s.isNotEmpty).join(' '),
            ].where((e) => e.isNotEmpty).join(', ');
          }

          // Add a marker for the detected area and open the address form
          await _addSearchMarker(_currentLocation!, locationName);

          setState(() {
            _selectedLocation = _currentLocation;
            _selectedLocationName = locationName;
          });
        }
      } catch (e) {
        debugPrint('Reverse geocoding for initial location failed: $e');
      }

      _startLocationTracking();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: ${e.toString()}';
        _isLoading = false;
      });
      debugPrint('Failed to get location: ${e.toString()}');
    }
  }

  void _startLocationTracking() {
    _positionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen(
          (Position position) {
            final newLocation = LatLng(position.latitude, position.longitude);
            setState(() {
              _currentLocation = newLocation;
            });

            _addCurrentLocationMarker();
          },
          onError: (error) {
            debugPrint('Location stream error: $error');
          },
        );
  }

  Future<void> _addCurrentLocationMarker() async {
    // Intentionally remove the automatic current-location marker and circle
    // to avoid showing a blue marker for the device location.
    if (_currentLocation == null) return;

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'current_location');
      _circles.removeWhere(
        (c) => c.circleId.value == 'current_location_accuracy',
      );
    });
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final locations = await locationFromAddress(query);

      setState(() {
        _searchResults = locations;
        _isLoading = false;
      });

      if (locations.isNotEmpty) {
        final location = locations.first;
        final latLng = LatLng(location.latitude, location.longitude);

        await _addSearchMarker(latLng, query);

        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: latLng, zoom: 16.0, bearing: 0, tilt: 0),
            ),
          );
        }

        setState(() {
          _selectedLocation = latLng;
          _selectedLocationName = query;
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _toggleSearch();
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        _showCustomSnackBar(
          'Failed to find location: Please try another search term',
        );
      }
    }
  }

  void _showCustomSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.deepOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: _defaultBorderRadius),
        margin: _defaultPadding,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _addSearchMarker(LatLng position, String title) async {
    final marker = Marker(
      markerId: const MarkerId('search_result'),
      position: position,
      // Change search-result color from red to blue per request
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(title: title, snippet: 'Tap for details'),
      onTap: () {
        setState(() {
          _showLocationDetails = true;
        });
      },
    );

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'search_result');
      _markers.add(marker);
    });

    _populateAddressFromPlacemark(title);
    _showAddressFormSheet();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });

    if (_isSearching) {
      _searchAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _searchFocusNode.requestFocus();
      });
    } else {
      _searchAnimationController.reverse();
      _searchController.clear();
      _searchFocusNode.unfocus();
      setState(() {
        _searchResults.clear();
      });
    }
  }

  void _populateAddressFromPlacemark(String placemarkText) {
    final parts = placemarkText.split(',').map((s) => s.trim()).toList();
    if (parts.isEmpty) return;
    _streetController.text = parts.isNotEmpty ? parts[0] : '';
    _cityController.text = parts.length > 1 ? parts[1] : '';
    if (parts.length > 2) {
      final stateZip = parts.sublist(2).join(', ');

      final match = RegExp(r"([A-Za-z ]+)\s*(\d{5})?").firstMatch(stateZip);
      if (match != null) {
        _stateController.text = match.group(1)?.trim() ?? '';
        _zipController.text = match.group(2) ?? '';
      } else {
        _stateController.text = stateZip;
      }
    } else {
      _stateController.text = '';
      _zipController.text = '';
    }
  }

  void _showAddressFormSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Form(
                  key: _addressFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(top: 8, bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      PawsText(
                        'Address Details',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(height: 8),
                      PawsText(
                        'Street',
                        color: PawsColors.textSecondary,
                        fontSize: 15,
                      ),
                      PawsTextField(
                        hint: 'Street',
                        controller: _streetController,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter street'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      PawsText(
                        'City',
                        color: PawsColors.textSecondary,
                        fontSize: 15,
                      ),

                      PawsTextField(
                        hint: 'City',
                        controller: _cityController,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter city'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      PawsText(
                        'State',
                        color: PawsColors.textSecondary,
                        fontSize: 15,
                      ),

                      PawsTextField(
                        hint: 'State',
                        controller: _stateController,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter state'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      PawsText(
                        'Zip Code',
                        color: PawsColors.textSecondary,
                        fontSize: 15,
                      ),
                      PawsTextField(
                        hint: 'Zip Code',
                        controller: _zipController,
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter zip code'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _markers.removeWhere(
                                    (m) => m.markerId.value == 'search_result',
                                  );
                                  _selectedLocation = null;
                                  _selectedLocationName = null;
                                });
                                Navigator.of(context).pop();
                              },
                              child: const Text('Remove Marker'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_addressFormKey.currentState?.validate() ??
                                    false) {
                                  Navigator.of(context).pop();
                                  handleAddAddress();
                                }
                              },
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDirections() {
    if (_selectedLocation != null) {
      _showCustomSnackBar('Directions feature coming soon!');
    } else {
      _showCustomSnackBar('Please select a destination first');
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentLocation != null && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentLocation!,
            zoom: _currentZoom,
            bearing: 0,
            tilt: 0,
          ),
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _controllerCompleter.complete(controller);

    _setMapStyle();
  }

  Future<void> _setMapStyle() async {
    try {
      final String style = await rootBundle.loadString('assets/map_style.json');
      _mapController?.setMapStyle(style);
    } catch (e) {
      debugPrint('Map style not found: $e');
    }
  }

  void _onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;
  }

  Future<void> _onMapTap(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String locationName = 'Unknown Location';
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final street = placemark.street ?? placemark.name ?? '';
        final city = placemark.locality ?? '';
        final state = placemark.administrativeArea ?? '';
        final postal = placemark.postalCode ?? '';

        locationName = [
          street,
          city,
          [state, postal].where((s) => s.isNotEmpty).join(' '),
        ].where((e) => e.isNotEmpty).join(', ');
      }

      await _addSearchMarker(position, locationName);

      setState(() {
        _selectedLocation = position;
        _selectedLocationName = locationName;
      });
    } catch (e) {
      debugPrint('Failed to get place details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(isDark),
        body: Stack(
          children: [
            if (_errorMessage != null)
              _buildErrorView()
            else if (_currentLocation != null)
              _buildMapView()
            else
              _buildLoadingView(),

            if (_isSearching) _buildSearchOverlay(),

            if (_showLocationDetails) _buildLocationDetails(),
          ],
        ),
        floatingActionButton: _buildFloatingActionButtons(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      title: const Text(
        'Explore',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      ),
      backgroundColor: isDark
          ? Colors.black.withValues(alpha: 0.8)
          : Colors.white.withValues(alpha: 0.95),
      foregroundColor: isDark ? Colors.white : Colors.black,
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      actions: [
        IconButton(
          icon: AnimatedSwitcher(
            duration: _animationDuration,
            child: Icon(
              _isSearching ? Icons.close : Icons.search,
              key: ValueKey(_isSearching),
            ),
          ),
          onPressed: _toggleSearch,
          tooltip: _isSearching ? 'Close search' : 'Search places',
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.red[50]!, Colors.red[100]!],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: 48,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: _defaultPadding,
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
                initLocation();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: _defaultBorderRadius,
                ),
                elevation: 4,
              ),
            ),
            if (_errorMessage!.contains('permanently denied') ||
                _errorMessage!.contains('app settings')) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async {
                  await Geolocator.openAppSettings();
                },
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
                style: TextButton.styleFrom(foregroundColor: Colors.red[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _currentLocation!,
        zoom: _currentZoom,
      ),
      // myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomGesturesEnabled: true,
      trafficEnabled: _showTraffic,
      markers: _markers,
      circles: _circles,
      onCameraMove: _onCameraMove,
      onTap: _onMapTap,
      mapType: _currentMapType,
      style: '''
        [
          {
            "featureType": "poi",
            "elementType": "labels",
            "stylers": [{"visibility": "off"}]
          },
          {
            "featureType": "transit",
            "elementType": "labels",
            "stylers": [{"visibility": "off"}]
          }
        ]
      ''',
    );
  }

  Widget _buildLoadingView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[50]!, Colors.blue[100]!],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 80 + (_pulseAnimation.value * 20),
                      height: 80 + (_pulseAnimation.value * 20),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(
                          alpha: 0.2 - (_pulseAnimation.value * 0.1),
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Finding your location...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a few moments',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchOverlay() {
    return SlideTransition(
      position: _searchSlideAnimation,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 100, 16, 0),
        child: Card(
          elevation: 12,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(borderRadius: _defaultBorderRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: _defaultBorderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey[50]!],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: _defaultPadding,
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Where do you want to go?',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixIcon: Icon(Icons.search, color: Colors.blue[600]),
                      suffixIcon: _isLoading
                          ? Container(
                              width: 20,
                              height: 20,
                              padding: const EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue[600]!,
                                ),
                              ),
                            )
                          : _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[600]),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults.clear();
                                });
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                    onSubmitted: _searchLocation,
                    textInputAction: TextInputAction.search,
                  ),
                ),
                if (_searchResults.isNotEmpty) ...[
                  const Divider(height: 1),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final location = _searchResults[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final latLng = LatLng(
                                location.latitude,
                                location.longitude,
                              );
                              await _addSearchMarker(
                                latLng,
                                'Search Result ${index + 1}',
                              );
                              if (_mapController != null) {
                                _mapController!.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: latLng,
                                      zoom: 16.0,
                                      bearing: 0,
                                      tilt: 0,
                                    ),
                                  ),
                                );
                              }
                              _toggleSearch();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.place,
                                      size: 20,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Search Result ${index + 1}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationDetails() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[50]!],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedLocationName ?? 'Selected Location',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (_selectedLocation != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                        onPressed: () {
                          setState(() {
                            _showLocationDetails = false;
                          });
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedLocation != null) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (_mapController != null &&
                                  _selectedLocation != null) {
                                await _mapController!.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: _selectedLocation!,
                                      zoom: 18.0,
                                      bearing: 0,
                                      tilt: 45,
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.zoom_in),
                            label: const Text('Zoom In'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showDirections,
                            icon: const Icon(Icons.directions),
                            label: const Text('Directions'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _markers.removeWhere(
                              (m) => m.markerId.value == 'search_result',
                            );
                            _selectedLocation = null;
                            _selectedLocationName = null;
                            _showLocationDetails = false;
                          });
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Remove Marker'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[600],
                          side: BorderSide(color: Colors.red[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "current_location",
          onPressed: _goToCurrentLocation,
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue[600],
          elevation: 4,
          child: const Icon(Icons.gps_fixed, size: 28),
        ),
        const SizedBox(height: 12),

        FloatingActionButton(
          heroTag: "map_type",
          onPressed: _showMapTypeDialog,
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue[600],
          elevation: 4,
          child: const Icon(Icons.layers, size: 28),
        ),
      ],
    );
  }

  void _showMapTypeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[50]!],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PawsText(
                    'Map Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildMapTypeOption(
                    title: 'Normal',
                    subtitle: 'Default map view',
                    icon: Icons.map,
                    isSelected: _currentMapType == MapType.normal,
                    onTap: () {
                      setState(() {
                        _currentMapType = MapType.normal;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  _buildMapTypeOption(
                    title: 'Satellite',
                    subtitle: 'Aerial imagery',
                    icon: Icons.satellite_alt,
                    isSelected: _currentMapType == MapType.satellite,
                    onTap: () {
                      setState(() {
                        _currentMapType = MapType.satellite;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  _buildMapTypeOption(
                    title: 'Terrain',
                    subtitle: 'Topographic view',
                    icon: Icons.terrain,
                    isSelected: _currentMapType == MapType.terrain,
                    onTap: () {
                      setState(() {
                        _currentMapType = MapType.terrain;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  _buildMapTypeOption(
                    title: 'Hybrid',
                    subtitle: 'Satellite with labels',
                    icon: Icons.layers,
                    isSelected: _currentMapType == MapType.hybrid,
                    onTap: () {
                      setState(() {
                        _currentMapType = MapType.hybrid;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTypeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.transparent,
        borderRadius: _defaultBorderRadius,
        border: Border.all(
          color: isSelected ? Colors.blue[300]! : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: _defaultBorderRadius,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[100] : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.blue[700] : Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PawsText(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.blue[700] : Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: Colors.blue[600], size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
