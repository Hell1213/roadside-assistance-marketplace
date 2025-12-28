import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'payment_processing_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final double amount;

  const PaymentMethodScreen({
    super.key,
    required this.amount,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String? _selectedMethod;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'card',
      'title': 'Credit/Debit Card',
      'subtitle': 'Visa, Mastercard, Rupay',
      'icon': Icons.credit_card,
    },
    {
      'id': 'upi',
      'title': 'UPI',
      'subtitle': 'Google Pay, PhonePe, Paytm',
      'icon': Icons.account_balance_wallet,
    },
    {
      'id': 'wallet',
      'title': 'Digital Wallet',
      'subtitle': 'Paytm, Amazon Pay',
      'icon': Icons.wallet,
    },
    {
      'id': 'cash',
      'title': 'Cash',
      'subtitle': 'Pay after service completion',
      'icon': Icons.money,
    },
  ];

  void _proceedToPayment() {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentProcessingScreen(
          amount: widget.amount,
          paymentMethod: _selectedMethod!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment Method'),
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
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Amount to Pay',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingS),
                          Text(
                            '₹${widget.amount.toStringAsFixed(2)}',
                            style: AppTypography.h2.copyWith(
                              color: AppColors.primaryYellow,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.paddingXL),
                    
                    Text(
                      'Select Payment Method',
                      style: AppTypography.h5.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.paddingM),
                    
                    ..._paymentMethods.map((method) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                        child: _buildPaymentMethodCard(
                          method['id'],
                          method['title'],
                          method['subtitle'],
                          method['icon'],
                        ),
                      );
                    }),
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
                  onPressed: _proceedToPayment,
                  child: Text(
                    'Proceed to Pay',
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

  Widget _buildPaymentMethodCard(
    String id,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedMethod == id;
    
    return InkWell(
      onTap: () => setState(() => _selectedMethod = id),
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primaryYellow : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryYellow.withOpacity(0.1)
                    : AppColors.lightGrey,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Icon(
                icon,
                size: AppDimensions.iconL,
                color: isSelected ? AppColors.primaryYellow : AppColors.grey,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.h6.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primaryYellow,
                size: AppDimensions.iconM,
              ),
          ],
        ),
      ),
    );
  }
}
