import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import '../payment/payment_authorization_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String serviceType;
  final String serviceTitle;
  final String pickupLocation;
  final String dropLocation;
  final Map<String, String> contactInfo;
  final Map<String, String> vehicleInfo;
  final Map<String, dynamic> towAnswers;

  const LoadingScreen({
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
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentAuthorizationScreen(
              serviceType: widget.serviceType,
              serviceTitle: widget.serviceTitle,
              pickupLocation: widget.pickupLocation,
              dropLocation: widget.dropLocation,
              contactInfo: widget.contactInfo,
              vehicleInfo: widget.vehicleInfo,
              towAnswers: widget.towAnswers,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _controller,
              child: Icon(
                Icons.local_shipping,
                size: 100,
                color: AppColors.primaryYellow,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            Text(
              'Processing...',
              style: AppTypography.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              'Please wait while we prepare your service',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryYellow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
