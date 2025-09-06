import 'dart:async';
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

@RoutePage()
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  // Map Controllers
  GoogleMapController? _mapController;
  final Completer<GoogleMapController> _controllerCompleter = Completer();

  // Location & Map State
  LatLng? _currentLocation;
  String? _errorMessage;
  bool _isFollowingUser = false;
  double _currentZoom = 17.0;
  MapType _currentMapType = MapType.normal;

  // UI State
  bool _isSearching = false;
  bool _showLocationDetails = false;
  bool _isLoading = false;
  bool _showTraffic = false;

  // Search & Places
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Location> _searchResults = [];
  LatLng? _selectedLocation;
  String? _selectedLocationName;

  // Markers & UI
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  // Animations
  late AnimationController _fabAnimationController;
  late AnimationController _searchAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _searchSlideAnimation;
  late Animation<double> _pulseAnimation;

  // Stream subscriptions
  StreamSubscription<Position>? _positionStreamSubscription;

  // UI Constants
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
    _fabAnimationController.dispose();
    _searchAnimationController.dispose();
    _pulseAnimationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  void _initializeAnimations() {
    _fabAnimationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );

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

  Future<void> initLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage =
              'Location services are disabled. Please enable them in settings.';
          _isLoading = false;
        });
        return;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      // Request permission if it's denied or not determined
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

      // Handle permanently denied permissions
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Location permissions are permanently denied. Please enable them in app settings.';
          _isLoading = false;
        });
        return;
      }

      // Get current position if permission is granted
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

      // Add current location marker
      await _addCurrentLocationMarker();

      // Start location tracking
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
            distanceFilter: 5, // Reduced for smoother tracking
          ),
        ).listen(
          (Position position) {
            final newLocation = LatLng(position.latitude, position.longitude);
            setState(() {
              _currentLocation = newLocation;
            });

            // Update current location marker
            _addCurrentLocationMarker();

            // Follow user if enabled with smooth animation
            if (_isFollowingUser && _mapController != null) {
              _mapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: newLocation,
                    zoom: _currentZoom,
                    bearing: 0,
                    tilt: 0,
                  ),
                ),
              );
            }
          },
          onError: (error) {
            debugPrint('Location stream error: $error');
          },
        );
  }

  Future<void> _addCurrentLocationMarker() async {
    if (_currentLocation == null) return;

    final marker = Marker(
      markerId: const MarkerId('current_location'),
      position: _currentLocation!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: const InfoWindow(
        title: 'Your Location',
        snippet: 'You are here',
      ),
    );

    // Add animated accuracy circle
    final circle = Circle(
      circleId: const CircleId('current_location_accuracy'),
      center: _currentLocation!,
      radius: 30,
      fillColor: Colors.blue.withValues(alpha: 0.15),
      strokeColor: Colors.blue.withValues(alpha: 0.8),
      strokeWidth: 2,
    );

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'current_location');
      _circles.removeWhere(
        (c) => c.circleId.value == 'current_location_accuracy',
      );
      _markers.add(marker);
      _circles.add(circle);
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

        // Add search result marker
        await _addSearchMarker(latLng, query);

        // Move camera to the location with smooth animation
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

        // Hide search after successful search
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
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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
  }

  void _toggleLocationFollow() {
    setState(() {
      _isFollowingUser = !_isFollowingUser;
    });

    if (_isFollowingUser &&
        _currentLocation != null &&
        _mapController != null) {
      _mapController!.animateCamera(
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

    // Animate FAB
    if (_isFollowingUser) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
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

  void _toggleTraffic() {
    setState(() {
      _showTraffic = !_showTraffic;
    });

    _showCustomSnackBar(
      _showTraffic ? 'Traffic layer enabled' : 'Traffic layer disabled',
    );
  }

  void _findNearbyPlaces() {
    _showCustomSnackBar('Finding nearby places...');
    // TODO: Implement nearby places search
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

    // Set map style (optional)
    _setMapStyle();
  }

  Future<void> _setMapStyle() async {
    try {
      final String style = await rootBundle.loadString('assets/map_style.json');
      _mapController?.setMapStyle(style);
    } catch (e) {
      // Map style file not found, continue with default style
      debugPrint('Map style not found: $e');
    }
  }

  void _onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;

    // Stop following user if camera is moved manually
    if (_isFollowingUser) {
      setState(() {
        _isFollowingUser = false;
      });
      _fabAnimationController.reverse();
    }
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
        locationName = [
          placemark.name,
          placemark.locality,
          placemark.administrativeArea,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(isDark),
      body: Stack(
        children: [
          // Main Map View
          if (_errorMessage != null)
            _buildErrorView()
          else if (_currentLocation != null)
            _buildMapView()
          else
            _buildLoadingView(),

          // Search Bar Overlay
          if (_isSearching) _buildSearchOverlay(),

          // Quick Actions Panel
          _buildQuickActionsPanel(),

          // Location Details Bottom Sheet
          if (_showLocationDetails) _buildLocationDetails(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
        IconButton(
          icon: Icon(_showTraffic ? Icons.traffic : Icons.traffic_outlined),
          onPressed: _toggleTraffic,
          tooltip: 'Toggle traffic',
        ),
      ],
    );
  }

  Widget _buildQuickActionsPanel() {
    return Positioned(
      top: 120,
      left: 16,
      child: Column(
        children: [
          _buildQuickActionButton(
            icon: Icons.near_me,
            label: 'Near Me',
            onPressed: _findNearbyPlaces,
          ),
          const SizedBox(height: 8),
          _buildQuickActionButton(
            icon: Icons.directions,
            label: 'Directions',
            onPressed: _showDirections,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: _defaultBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: _defaultBorderRadius,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24, color: Colors.blue[700]),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
      myLocationEnabled: true,
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
        // Location Follow FAB
        AnimatedBuilder(
          animation: _fabScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _fabScaleAnimation.value,
              child: FloatingActionButton(
                heroTag: "follow_location",
                onPressed: _toggleLocationFollow,
                backgroundColor: _isFollowingUser
                    ? Colors.blue[600]
                    : Colors.white,
                foregroundColor: _isFollowingUser
                    ? Colors.white
                    : Colors.blue[600],
                elevation: 4,
                child: Icon(
                  _isFollowingUser
                      ? Icons.my_location
                      : Icons.location_searching,
                  size: 28,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),

        // Current Location FAB
        FloatingActionButton(
          heroTag: "current_location",
          onPressed: _goToCurrentLocation,
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue[600],
          elevation: 4,
          child: const Icon(Icons.gps_fixed, size: 28),
        ),
        const SizedBox(height: 12),

        // Map Type FAB
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                children: [
                  const Text(
                    'Map Type',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                      Text(
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
