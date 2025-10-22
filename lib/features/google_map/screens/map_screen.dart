import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/provider/common_provider.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/loading_service.dart';
import '../../../core/supabase/client.dart';
import '../../../core/transfer_object/address.dto.dart';

class PlaceSearchResult {
  final String name;
  final String address;
  final LatLng location;
  final String placeId;

  PlaceSearchResult({
    required this.name,
    required this.address,
    required this.location,
    required this.placeId,
  });
}

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

  bool _isMapMoving = false;
  bool isLoading = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  LatLng? _selectedLocation;
  CameraPosition? _cameraPosition;

  // Enhanced search functionality
  List<PlaceSearchResult> _searchResults = [];
  List<String> _searchHistory = [];
  Timer? _searchDebouncer;
  bool _showSearchResults = false;

  final GlobalKey<FormState> _addressFormKey = GlobalKey<FormState>();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  StreamSubscription<Position>? _positionStreamSubscription;

  // Bottom sheet controller
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    initLocation();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _searchFocusNode.dispose();
    _searchDebouncer?.cancel();
    _positionStreamSubscription?.cancel();
    _sheetController.dispose();
    super.dispose();
  }

  // Load search history from SharedPreferences
  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('search_history') ?? [];
      setState(() {
        _searchHistory = history.take(10).toList(); // Keep only recent 10
      });
    } catch (e) {
      debugPrint('Error loading search history: $e');
    }
  }

  // Save search to history
  Future<void> _saveSearchToHistory(String searchTerm) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _searchHistory.remove(searchTerm); // Remove if exists
      _searchHistory.insert(0, searchTerm); // Add to top
      _searchHistory = _searchHistory.take(10).toList(); // Keep only 10
      await prefs.setStringList('search_history', _searchHistory);
      setState(() {});
    } catch (e) {
      debugPrint('Error saving search history: $e');
    }
  }

  Future<void> _handleAddAddress() async {
    final result = await LoadingService.showWhileExecuting(
      context,
      CommonProvider().addAddress(
        AddAddressDTO(
          street: _streetController.text,
          city: _cityController.text,
          state: _stateController.text,
          zipCode: _zipController.text,
          latitude: _selectedLocation?.latitude ?? 0.0,
          longitude: _selectedLocation?.longitude ?? 0.0,
          user: USER_ID ?? '',
        ),
      ),
      message: 'Saving address...',
    );

    if (result.isError) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.error)));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address saved successfully')),
        );
        context.router.pop();
      }
    }
  }

  Future<void> initLocation() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage =
              'Location services are disabled. Please enable them in settings.';
          isLoading = false;
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
            isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Location permissions are permanently denied. Please enable them in app settings.';
          isLoading = false;
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
        isLoading = false;
      });

      // Set initial selected location
      setState(() {
        _selectedLocation = _currentLocation;
      });

      _startLocationTracking();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: ${e.toString()}';
        isLoading = false;
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
          },
          onError: (error) {
            debugPrint('Location stream error: $error');
          },
        );
  }

  // Debounced search for autocomplete
  void _onSearchChanged(String query) {
    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(const Duration(milliseconds: 500), () {
      if (query.length > 2) {
        _searchPlacesAutocomplete(query);
      } else {
        setState(() {
          _searchResults.clear();
          _showSearchResults = false;
        });
      }
    });
  }

  // Search places with autocomplete-like functionality
  Future<void> _searchPlacesAutocomplete(String query) async {
    try {
      final locations = await locationFromAddress(query);

      List<PlaceSearchResult> results = [];

      for (int i = 0; i < locations.length && i < 5; i++) {
        final location = locations[i];
        final latLng = LatLng(location.latitude, location.longitude);

        // Get detailed address info
        try {
          final placemarks = await placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          );

          if (placemarks.isNotEmpty) {
            final placemark = placemarks.first;
            final name = placemark.name ?? placemark.street ?? 'Unknown Place';
            final address = [
              placemark.street,
              placemark.locality,
              placemark.administrativeArea,
              placemark.country,
            ].where((s) => s?.isNotEmpty == true).join(', ');

            results.add(
              PlaceSearchResult(
                name: name,
                address: address,
                location: latLng,
                placeId: '${location.latitude}_${location.longitude}',
              ),
            );
          }
        } catch (e) {
          // Fallback if reverse geocoding fails
          results.add(
            PlaceSearchResult(
              name: query,
              address:
                  'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}',
              location: latLng,
              placeId: '${location.latitude}_${location.longitude}',
            ),
          );
        }
      }

      setState(() {
        _searchResults = results;
        _showSearchResults = results.isNotEmpty;
      });
    } catch (e) {
      debugPrint('Error searching places: $e');
      setState(() {
        _searchResults.clear();
        _showSearchResults = false;
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      _showSearchResults = false;
    });

    try {
      final locations = await locationFromAddress(query);

      setState(() {
        isLoading = false;
      });

      if (locations.isNotEmpty) {
        final location = locations.first;
        final latLng = LatLng(location.latitude, location.longitude);

        // Save to search history
        await _saveSearchToHistory(query);

        if (_mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: latLng, zoom: 18.0, bearing: 0, tilt: 0),
            ),
          );
        }

        // Search complete
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        _showCustomSnackBar(
          'Location not found. Please try another search term.',
        );
      }
    }
  }

  // Navigate to selected search result
  Future<void> _selectSearchResult(PlaceSearchResult result) async {
    _searchController.text = result.name;

    await _saveSearchToHistory(result.name);

    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: result.location,
            zoom: 18.0,
            bearing: 0,
            tilt: 0,
          ),
        ),
      );
    }

    // Navigation complete
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
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

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
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
    setState(() {
      _cameraPosition = position;
    });
  }

  void _onCameraMoveStarted() {
    setState(() {
      _isMapMoving = true;
    });
  }

  void _onCameraIdle() async {
    setState(() {
      _isMapMoving = false;
    });

    // Auto-populate address from current camera position
    if (_cameraPosition != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _cameraPosition!.target.latitude,
          _cameraPosition!.target.longitude,
        );

        if (placemarks.isNotEmpty && mounted) {
          setState(() {
            _selectedLocation = _cameraPosition!.target;
          });

          // Auto-populate address form with the new location
          final placemark = placemarks.first;
          _populateAddressFromPlacemark(
            '${placemark.street ?? placemark.name ?? ''}, ${placemark.locality ?? ''}, ${placemark.administrativeArea ?? ''} ${placemark.postalCode ?? ''}'
                .trim(),
          );
        }
      } catch (e) {
        debugPrint('Error getting address from coordinates: $e');
      }
    }
  }

  Widget _buildAddressForm() {
    return Form(
      key: _addressFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for places...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontSize: 15),
                    onChanged: _onSearchChanged,
                    onSubmitted: _searchLocation,
                  ),
                ),
                if (_showSearchResults) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults.clear();
                        _showSearchResults = false;
                      });
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.grey.shade400,
                      size: 18,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Search results
          if (_showSearchResults && _searchResults.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                    title: Text(
                      result.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: result.address.isNotEmpty
                        ? Text(
                            result.address,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          )
                        : null,
                    onTap: () => _selectSearchResult(result),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Address details header
          const Text(
            'Address Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Street address
          const Text(
            'Street Address *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          PawsTextField(
            hint: 'Enter street address',
            controller: _streetController,
            validator: (v) =>
                v?.trim().isEmpty ?? true ? 'Street is required' : null,
          ),
          const SizedBox(height: 16),

          // City and State
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'City *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    PawsTextField(
                      hint: 'Enter city',
                      controller: _cityController,
                      validator: (v) =>
                          v?.trim().isEmpty ?? true ? 'City is required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'State *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    PawsTextField(
                      hint: 'State',
                      controller: _stateController,
                      validator: (v) => v?.trim().isEmpty ?? true
                          ? 'State is required'
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Zip code
          const Text(
            'Zip Code *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          PawsTextField(
            hint: 'Enter zip code',
            controller: _zipController,
            keyboardType: TextInputType.number,
            validator: (v) =>
                v?.trim().isEmpty ?? true ? 'Zip code is required' : null,
          ),
          const SizedBox(height: 32),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_addressFormKey.currentState?.validate() ?? false) {
                  _handleAddAddress();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PawsColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Address',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Map view
            if (_errorMessage != null)
              _buildErrorView()
            else if (_currentLocation != null)
              _buildMapView()
            else
              _buildLoadingView(),

            // Close button
            if (_currentLocation != null)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    color: Colors.black87,
                    onPressed: () => context.router.pop(),
                  ),
                ),
              ),

            // Map controls (My location and Map type)
            if (_currentLocation != null)
              Positioned(
                top: 16,
                right: 16,
                child: Column(
                  children: [
                    // My location button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.my_location, size: 20),
                        color: PawsColors.primary,
                        onPressed: _goToCurrentLocation,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Map type toggle button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _currentMapType == MapType.normal
                              ? Icons.map
                              : LucideIcons.satellite,
                          size: 20,
                        ),
                        color: PawsColors.primary,
                        onPressed: _toggleMapType,
                      ),
                    ),
                  ],
                ),
              ),

            // Sliding bottom sheet
            if (_currentLocation != null)
              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0.25,
                minChildSize: 0.25,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Handle bar
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(20),
                            child: _buildAddressForm(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Location Access Needed',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                  });
                  initLocation();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PawsColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _currentLocation!,
            zoom: _currentZoom,
          ),
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          zoomGesturesEnabled: true,
          trafficEnabled: false,
          onCameraMove: _onCameraMove,
          onCameraMoveStarted: _onCameraMoveStarted,
          onCameraIdle: _onCameraIdle,
          mapType: _currentMapType,
        ),
        // Center pin that stays in the middle of the map
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            transform: Matrix4.translationValues(0, _isMapMoving ? -15 : 0, 0)
              ..scale(_isMapMoving ? 1.1 : 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: PawsColors.primary.withValues(alpha: 0.3),
                    blurRadius: _isMapMoving ? 16 : 12,
                    offset: const Offset(0, 4),
                    spreadRadius: _isMapMoving ? 2 : 0,
                  ),
                ],
              ),
              child: Icon(
                Icons.location_pin,
                size: _isMapMoving ? 52 : 48,
                color: _isMapMoving ? PawsColors.primary : PawsColors.primary,
                shadows: [
                  Shadow(
                    color: Colors.white.withValues(alpha: 0.8),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Finding your location...',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
