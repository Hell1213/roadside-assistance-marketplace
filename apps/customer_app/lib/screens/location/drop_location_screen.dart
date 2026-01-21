import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/location_service.dart';
import '../onboarding/contact_info_screen.dart';

class DropLocationScreen extends StatefulWidget {
  final String serviceType;
  final String serviceTitle;
  final String pickupLocation;

  const DropLocationScreen({
    super.key,
    required this.serviceType,
    required this.serviceTitle,
    required this.pickupLocation,
  });

  @override
  State<DropLocationScreen> createState() => _DropLocationScreenState();
}

class _DropLocationScreenState extends State<DropLocationScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _dropController = TextEditingController();
  String? _selectedDropLocation;
  LatLng? _selectedPosition;
  bool _showDropdown = false;
  bool _isSearching = false;
  List<Map<String, String>> _suggestedAddresses = [];
  Set<Marker> _markers = {};

  @override
  void dispose() {
    _dropController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _onAddressChanged(String value) async {
    if (value.isEmpty || value.length < 3) {
      setState(() {
        _showDropdown = false;
        _suggestedAddresses = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showDropdown = true;
    });

    try {
      List<Map<String, String>> results = await LocationService.searchPlaces(value);
      setState(() {
        _suggestedAddresses = results;
        _isSearching = false;
      });
    } catch (e) {
      print('Error searching: $e');
      setState(() {
        _isSearching = false;
        _suggestedAddresses = [];
      });
    }
  }

  Future<void> _selectAddress(Map<String, String> place) async {
    final description = place['description']!;
    final placeId = place['place_id']!;
    
    setState(() {
      _dropController.text = description;
      _selectedDropLocation = description;
      _showDropdown = false;
    });

    // Get coordinates for the selected place
    LatLng? position = await LocationService.getPlaceDetails(placeId);
    if (position != null) {
      setState(() {
        _selectedPosition = position;
        _markers = {
          Marker(
            markerId: const MarkerId('drop_location'),
            position: position,
            infoWindow: InfoWindow(title: 'Drop Location', snippet: description),
          ),
        };
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(position, 15),
      );
    }
  }

  void _confirmLocation() {
    if (_selectedDropLocation == null || _selectedDropLocation!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a drop-off location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactInfoScreen(
          serviceType: widget.serviceType,
          serviceTitle: widget.serviceTitle,
          pickupLocation: widget.pickupLocation,
          dropLocation: _selectedDropLocation!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Drop Location',
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
                    'Enter Drop Location',
                    style: AppTypography.h5.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  Text(
                    'Where do you want to take your vehicle?',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  TextField(
                    controller: _dropController,
                    onChanged: _onAddressChanged,
                    decoration: InputDecoration(
                      hintText: 'Type drop location...',
                      prefixIcon: Icon(Icons.search, color: AppColors.primaryYellow),
                      suffixIcon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        borderSide: BorderSide(color: AppColors.primaryYellow),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        borderSide: BorderSide(color: AppColors.primaryYellow),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        borderSide: BorderSide(color: AppColors.primaryYellow, width: 2),
                      ),
                    ),
                  ),
                  if (_showDropdown && _suggestedAddresses.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.paddingS),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 250),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        border: Border.all(color: AppColors.primaryYellow, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _suggestedAddresses.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: AppColors.primaryYellow.withOpacity(0.2),
                          ),
                          itemBuilder: (context, index) {
                            final place = _suggestedAddresses[index];
                            return ListTile(
                              dense: false,
                              leading: Icon(Icons.location_on, color: AppColors.primaryYellow, size: 24),
                              title: Text(
                                place['description']!,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () => _selectAddress(place),
                              hoverColor: AppColors.primaryYellow.withOpacity(0.1),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppDimensions.paddingXL),
                  ElevatedButton(
                    onPressed: _confirmLocation,
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
                      'Confirm',
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
}
