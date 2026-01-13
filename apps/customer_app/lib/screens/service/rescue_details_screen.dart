import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'loading_screen.dart';

class RescueDetailsScreen extends StatelessWidget {
  final String serviceType;
  final String serviceTitle;
  final String pickupLocation;
  final String dropLocation;
  final Map<String, String> contactInfo;
  final Map<String, String> vehicleInfo;
  final Map<String, dynamic> towAnswers;

  const RescueDetailsScreen({
    super.key,
    required this.serviceType,
    required this.serviceTitle,
    required this.pickupLocation,
    required this.dropLocation,
    required this.contactInfo,
    required this.vehicleInfo,
    required this.towAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Rescue Details',
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
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        children: [
          Text(
            'Review Your Details',
            style: AppTypography.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            'Please confirm your information',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          _buildDetailCard(
            icon: Icons.person,
            title: 'Name',
            value: contactInfo['name'] ?? '',
          ),
          const SizedBox(height: AppDimensions.paddingM),
          _buildDetailCard(
            icon: Icons.local_shipping,
            title: 'Service Type',
            value: serviceTitle,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          _buildDetailCard(
            icon: Icons.phone,
            title: 'Phone',
            value: contactInfo['phone'] ?? '',
          ),
          const SizedBox(height: AppDimensions.paddingM),
          _buildDetailCard(
            icon: Icons.directions_car,
            title: 'Vehicle',
            value: '${vehicleInfo['year']} ${vehicleInfo['make']} ${vehicleInfo['model']}',
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoadingScreen(
                    serviceType: serviceType,
                    serviceTitle: serviceTitle,
                    pickupLocation: pickupLocation,
                    dropLocation: dropLocation,
                    contactInfo: contactInfo,
                    vehicleInfo: vehicleInfo,
                    towAnswers: towAnswers,
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
              'Confirm',
              style: AppTypography.buttonLarge.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryYellow,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
