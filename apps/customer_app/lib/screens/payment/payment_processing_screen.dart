import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'payment_receipt_screen.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final double amount;
  final String paymentMethod;

  const PaymentProcessingScreen({
    super.key,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  State<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  bool _isProcessing = true;
  bool _paymentSuccess = false;

  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  Future<void> _processPayment() async {
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isProcessing = false;
      _paymentSuccess = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentReceiptScreen(
            amount: widget.amount,
            paymentMethod: widget.paymentMethod,
            transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isProcessing) ...[
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingXL),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryYellow,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXXL),
                  Text(
                    'Processing Payment',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  Text(
                    'Please wait...',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else if (_paymentSuccess) ...[
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingXL),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 80,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXXL),
                  Text(
                    'Payment Successful!',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  Text(
                    '₹${widget.amount.toStringAsFixed(2)}',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
