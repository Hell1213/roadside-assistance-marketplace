import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/location_service.dart';
import 'drop_location_screen.dart';

class ManualPickupLocationScreen extends StatefulWidget {
  final String serviceType;
  final String serviceTitle;

  const ManualPickupLocationScreen({
    super.key,
    required this.serviceType,
    required this.serviceTitle,
  });

  @override
  State<ManualPickupLocationScreen> createState() => _ManualPickupLocationScreenState();
}

class _ManualPickupLocationScreenState extends State<ManualPickupLocationScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _addressController = TextEditingController();
  String? _selectedAddress;
  LatLng? _selectedPosition;
  bool _showDropdown = false;
  bool _isSearching = false;
  List<String> _suggestedAddresses = [];
  Set<Marker> _markers = {};

  @override
  void dispose() {
    _addressController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _onAddressChanged(String value) async {
    if (value.isEmpty) {
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
      List<String> results = await LocationService.searchPlaces(value);
      setState(() {
        _suggestedAddresses = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _suggestedAddresses = [];
      });
    }
  }

  Future<void> _selectAddress(String address) async {
    setState(() {
      _addressController.text = address;
      _selectedAddress = address;
      _showDropdown = false;
    });

    // Get coordinates for the selected address
    LatLng? position = await LocationService.getCoordinatesFromAddress(address);
    if (position != null) {
      setState(() {
        _selectedPosition = position;
        _markers = {
          Marker(
            markerId: const MarkerId('selected_location'),
            position: position,
            infoWindow: InfoWindow(title: 'Pickup Location', snippet: address),
          ),
        };
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(position, 15),
      );
    }
  }

  void _confirmLocation() {
    if (_selectedAddress == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Select Address',
            style: AppTypography.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Please type address manually and select from dropdown',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: AppTypography.buttonLarge.copyWith(
                  color: AppColors.primaryYellow,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DropLocationScreen(
          serviceType: widget.serviceType,
          serviceTitle: widget.serviceTitle,
          pickupLocation: _selectedAddress!,
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
          'Pickup Location',
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
                    'Enter Pickup Location',
                    style: AppTypography.h5.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  TextField(
                    controller: _addressController,
                    onChanged: _onAddressChanged,
                    decoration: InputDecoration(
                      hintText: 'Type your address...',
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
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        border: Border.all(color: AppColors.primaryYellow),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _suggestedAddresses.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.location_on, color: AppColors.primaryYellow),
                            title: Text(
                              _suggestedAddresses[index],
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            onTap: () => _selectAddress(_suggestedAddresses[index]),
                          );
                        },
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
