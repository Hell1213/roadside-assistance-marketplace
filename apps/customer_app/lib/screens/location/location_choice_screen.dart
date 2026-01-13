import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'confirm_current_location_screen.dart';
import 'manual_pickup_location_screen.dart';

class LocationChoiceScreen extends StatelessWidget {
  final String serviceType;
  final String serviceTitle;

  const LocationChoiceScreen({
    super.key,
    required this.serviceType,
    required this.serviceTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          serviceTitle,
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
                children: [
                  Text(
                    'Where is your vehicle?',
                    style: AppTypography.h4.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  Text(
                    'Choose how to provide your location',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXL),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConfirmCurrentLocationScreen(
                            serviceType: serviceType,
                            serviceTitle: serviceTitle,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.my_location),
                        const SizedBox(width: AppDimensions.paddingS),
                        Text(
                          'Share Location',
                          style: AppTypography.buttonLarge.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManualPickupLocationScreen(
                            serviceType: serviceType,
                            serviceTitle: serviceTitle,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryYellow,
                      side: BorderSide(color: AppColors.primaryYellow, width: 2),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingL,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.edit_location_alt),
                        const SizedBox(width: AppDimensions.paddingS),
                        Text(
                          'Manual Location',
                          style: AppTypography.buttonLarge.copyWith(
                            color: AppColors.primaryYellow,
                          ),
                        ),
                      ],
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
