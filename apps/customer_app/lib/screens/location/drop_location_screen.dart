import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
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
  final TextEditingController _dropController = TextEditingController();
  String? _selectedDropLocation;
  bool _showDropdown = false;

  final List<String> _suggestedAddresses = [
    '100 Service Center Blvd, City, State 12350',
    '200 Repair Shop Ave, City, State 12351',
    '300 Garage Street, City, State 12352',
    '400 Workshop Road, City, State 12353',
  ];

  @override
  void dispose() {
    _dropController.dispose();
    super.dispose();
  }

  void _onAddressChanged(String value) {
    setState(() {
      _showDropdown = value.isNotEmpty;
    });
  }

  void _selectAddress(String address) {
    setState(() {
      _dropController.text = address;
      _selectedDropLocation = address;
      _showDropdown = false;
    });
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
          Container(
            color: Colors.grey[200],
            child: Center(
              child: Icon(
                Icons.map,
                size: 100,
                color: Colors.grey[400],
              ),
            ),
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
                  if (_showDropdown) ...[
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
