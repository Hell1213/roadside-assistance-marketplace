import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final double _currentBalance = 2450.75;
  final double _weeklyEarnings = 3200.50;
  final double _pendingPayout = 1500.25;

  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TXN001',
      'type': 'credit',
      'amount': 150.0,
      'description': 'Job completed - Tow Service',
      'date': 'Today, 2:30 PM',
    },
    {
      'id': 'TXN002',
      'type': 'credit',
      'amount': 80.0,
      'description': 'Job completed - Jump Start',
      'date': 'Today, 11:45 AM',
    },
    {
      'id': 'TXN003',
      'type': 'debit',
      'amount': 500.0,
      'description': 'Payout to bank account',
      'date': 'Yesterday, 6:00 PM',
    },
    {
      'id': 'TXN004',
      'type': 'credit',
      'amount': 120.0,
      'description': 'Job completed - Fuel Delivery',
      'date': 'Yesterday, 3:15 PM',
    },
  ];

  void _requestPayout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text('Request Payout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Balance: ₹${_currentBalance.toStringAsFixed(2)}',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              'Funds will be transferred to your registered bank account within 24 hours.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payout request submitted'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingXL),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              child: Column(
                children: [
                  Text(
                    'Current Balance',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  Text(
                    '₹${_currentBalance.toStringAsFixed(2)}',
                    style: AppTypography.h1.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeightL,
                    child: ElevatedButton(
                      onPressed: _requestPayout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.primaryYellow,
                      ),
                      child: Text(
                        'Request Payout',
                        style: AppTypography.buttonLarge.copyWith(
                          color: AppColors.primaryYellow,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingXL),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatsCard(
                    'Weekly Earnings',
                    '₹${_weeklyEarnings.toStringAsFixed(2)}',
                    Icons.trending_up,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: _buildStatsCard(
                    'Pending Payout',
                    '₹${_pendingPayout.toStringAsFixed(2)}',
                    Icons.schedule,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.paddingXL),
            
            Text(
              'Recent Transactions',
              style: AppTypography.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingM),
            
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _transactions.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final transaction = _transactions[index];
                  return _buildTransactionItem(transaction);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
            ),
            child: Icon(
              icon,
              size: AppDimensions.iconL,
              color: color,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            value,
            style: AppTypography.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final isCredit = transaction['type'] == 'credit';
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingS,
      ),
      leading: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingS),
        decoration: BoxDecoration(
          color: (isCredit ? AppColors.success : AppColors.error).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Icon(
          isCredit ? Icons.add : Icons.remove,
          color: isCredit ? AppColors.success : AppColors.error,
          size: AppDimensions.iconM,
        ),
      ),
      title: Text(
        transaction['description'],
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        transaction['date'],
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Text(
        '${isCredit ? '+' : '-'}₹${transaction['amount'].toStringAsFixed(2)}',
        style: AppTypography.bodyMedium.copyWith(
          color: isCredit ? AppColors.success : AppColors.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}