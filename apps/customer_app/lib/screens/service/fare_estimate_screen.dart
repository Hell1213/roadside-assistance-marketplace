import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'booking_confirmation_screen.dart';

class FareEstimateScreen extends StatelessWidget {
  final String serviceType;
  final String serviceTitle;
  final String vehicleModel;
  final String location;

  const FareEstimateScreen({
    super.key,
    required this.serviceType,
    required this.serviceTitle,
    required this.vehicleModel,
    required this.location,
  });

  Map<String, double> _calculateFare() {
    double baseFare = 50.0;
    double distanceCharge = 25.0;
    double timeCharge = 15.0;
    double platformFee = 10.0;
    
    switch (serviceType) {
      case 'tow':
        baseFare = 100.0;
        distanceCharge = 50.0;
        break;
      case 'jumpstart':
        baseFare = 40.0;
        distanceCharge = 20.0;
        break;
      case 'fuel':
        baseFare = 30.0;
        distanceCharge = 15.0;
        break;
      case 'tire':
        baseFare = 60.0;
        distanceCharge = 25.0;
        break;
    }
    
    double subtotal = baseFare + distanceCharge + timeCharge;
    double tax = subtotal * 0.18;
    double total = subtotal + platformFee + tax;
    
    return {
      'baseFare': baseFare,
      'distanceCharge': distanceCharge,
      'timeCharge': timeCharge,
      'platformFee': platformFee,
      'tax': tax,
      'total': total,
    };
  }

  @override
  Widget build(BuildContext context) {
    final fare = _calculateFare();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fare Estimate'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
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
                        children: [
                          Text(
                            'Estimated Fare',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingS),
                          Text(
                            '₹${fare['total']!.toStringAsFixed(2)}',
                            style: AppTypography.h1.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.paddingXL),
                    
                    Text(
                      'Service Details',
                      style: AppTypography.h5.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.paddingM),
                    
                    _buildDetailRow('Service', serviceTitle),
                    _buildDetailRow('Vehicle', vehicleModel),
                    _buildDetailRow('Location', location),
                    
                    const SizedBox(height: AppDimensions.paddingXL),
                    
                    Text(
                      'Fare Breakdown',
                      style: AppTypography.h5.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.paddingM),
                    
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: Column(
                        children: [
                          _buildFareRow('Base Fare', fare['baseFare']!),
                          _buildFareRow('Distance Charge', fare['distanceCharge']!),
                          _buildFareRow('Time Charge', fare['timeCharge']!),
                          _buildFareRow('Platform Fee', fare['platformFee']!),
                          _buildFareRow('Tax (18%)', fare['tax']!),
                          const Divider(height: AppDimensions.paddingL),
                          _buildFareRow(
                            'Total',
                            fare['total']!,
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: const BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeightL,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingConfirmationScreen(
                          serviceTitle: serviceTitle,
                          vehicleModel: vehicleModel,
                          location: location,
                          totalFare: fare['total']!,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Confirm Booking',
                    style: AppTypography.buttonLarge.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFareRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTypography.h6.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  )
                : AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: isTotal
                ? AppTypography.h6.copyWith(
                    color: AppColors.primaryYellow,
                    fontWeight: FontWeight.w700,
                  )
                : AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ],
      ),
    );
  }
}
