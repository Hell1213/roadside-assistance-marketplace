import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class PaymentReceiptScreen extends StatelessWidget {
  final double amount;
  final String paymentMethod;
  final String transactionId;

  const PaymentReceiptScreen({
    super.key,
    required this.amount,
    required this.paymentMethod,
    required this.transactionId,
  });

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'card':
        return 'Credit/Debit Card';
      case 'upi':
        return 'UPI';
      case 'wallet':
        return 'Digital Wallet';
      case 'cash':
        return 'Cash';
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateTime = '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment Receipt'),
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  children: [
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
                    
                    const SizedBox(height: AppDimensions.paddingL),
                    
                    Text(
                      'Payment Successful',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.paddingS),
                    
                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: AppTypography.h2.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.paddingXXL),
                    
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: Column(
                        children: [
                          _buildReceiptRow('Transaction ID', transactionId),
                          const Divider(height: AppDimensions.paddingL),
                          _buildReceiptRow('Date & Time', dateTime),
                          const Divider(height: AppDimensions.paddingL),
                          _buildReceiptRow('Payment Method', _getPaymentMethodName(paymentMethod)),
                          const Divider(height: AppDimensions.paddingL),
                          _buildReceiptRow('Status', 'Success', isSuccess: true),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.paddingL),
                    
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.textSecondary,
                            size: AppDimensions.iconM,
                          ),
                          const SizedBox(width: AppDimensions.paddingM),
                          Expanded(
                            child: Text(
                              'A copy of this receipt has been sent to your registered email',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
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
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeightL,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: Text(
                        'Back to Home',
                        style: AppTypography.buttonLarge.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeightL,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Receipt downloaded'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      child: const Text('Download Receipt'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isSuccess = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: isSuccess ? AppColors.success : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
