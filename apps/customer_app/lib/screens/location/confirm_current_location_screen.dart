import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import 'drop_location_screen.dart';

class ConfirmCurrentLocationScreen extends StatefulWidget {
  final String serviceType;
  final String serviceTitle;

  const ConfirmCurrentLocationScreen({
    super.key,
    required this.serviceType,
    required this.serviceTitle,
  });

  @override
  State<ConfirmCurrentLocationScreen> createState() => _ConfirmCurrentLocationScreenState();
}

class _ConfirmCurrentLocationScreenState extends State<ConfirmCurrentLocationScreen> {
  GoogleMapController? _mapController;
  String _currentAddress = 'Fetching location...';
  bool _isLoading = true;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      print('Requesting current location...');
      Position? position = await LocationService.getCurrentLocation();
      
      if (position != null) {
        print('Got position: ${position.latitude}, ${position.longitude}');
        final latLng = LatLng(position.latitude, position.longitude);
        final address = await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (mounted) {
          setState(() {
            _currentPosition = latLng;
            _currentAddress = address;
            _isLoading = false;
            _markers = {
              Marker(
                markerId: const MarkerId('current_location'),
                position: latLng,
                infoWindow: const InfoWindow(title: 'Your Location'),
              ),
            };
          });

          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(latLng, 15),
          );
        }
      } else {
        print('Position is null - location permission denied or unavailable');
        if (mounted) {
          setState(() {
            _currentAddress = 'Unable to get location. Please allow location access in your browser.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error in _getCurrentLocation: $e');
      if (mounted) {
        setState(() {
          _currentAddress = 'Error getting location. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Confirm Location',
          style: AppTypography.h5.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(28.6139, 77.2090),
              zoom: 12,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (_currentPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(_currentPosition!, 15),
                );
              }
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingXL),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusXL),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Location',
                    style: AppTypography.h5.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(color: AppColors.primaryYellow),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _currentPosition == null ? Icons.error_outline : Icons.location_on,
                          color: _currentPosition == null ? Colors.red : AppColors.primaryYellow,
                        ),
                        const SizedBox(width: AppDimensions.paddingM),
                        Expanded(
                          child: _isLoading
                              ? Row(
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    const SizedBox(width: AppDimensions.paddingM),
                                    Text(
                                      'Getting your location...',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  _currentAddress,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                        ),
                        if (!_isLoading && _currentPosition == null)
                          IconButton(
                            icon: Icon(Icons.refresh, color: AppColors.primaryYellow),
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                                _currentAddress = 'Fetching location...';
                              });
                              _getCurrentLocation();
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXL),
                  ElevatedButton(
                    onPressed: _isLoading || _currentPosition == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DropLocationScreen(
                                  serviceType: widget.serviceType,
                                  serviceTitle: widget.serviceTitle,
                                  pickupLocation: _currentAddress,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingL,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: Text(
                      'Confirm Location',
                      style: AppTypography.buttonLarge.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
