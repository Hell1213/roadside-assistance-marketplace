import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import '../location/location_choice_screen.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Roadside Assistance',
          style: AppTypography.h5.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need Help?',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  Text(
                    'Get roadside assistance in minutes',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingXL),
            
            Text(
              'Select Service',
              style: AppTypography.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingM),
            
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppDimensions.paddingM,
                mainAxisSpacing: AppDimensions.paddingM,
                children: [
                  _buildServiceCard(
                    context,
                    'Tow Service',
                    Icons.local_shipping,
                    'Vehicle towing and transport',
                    'tow',
                  ),
                  _buildServiceCard(
                    context,
                    'Jump Start',
                    Icons.battery_charging_full,
                    'Battery jump start service',
                    'jumpstart',
                  ),
                  _buildServiceCard(
                    context,
                    'Fuel Delivery',
                    Icons.local_gas_station,
                    'Emergency fuel delivery',
                    'fuel',
                  ),
                  _buildServiceCard(
                    context,
                    'Flat Tire',
                    Icons.tire_repair,
                    'Tire repair and replacement',
                    'tire',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    String serviceType,
  ) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: InkWell(
        onTap: () {
          if (serviceType == 'tow') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocationChoiceScreen(
                  serviceType: serviceType,
                  serviceTitle: title,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title service coming soon!'),
                backgroundColor: AppColors.primaryYellow,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                ),
                child: Icon(
                  icon,
                  size: AppDimensions.iconXL,
                  color: AppColors.primaryYellow,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                title,
                style: AppTypography.h6.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
