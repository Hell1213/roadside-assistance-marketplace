import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import '../jobs/job_offers_screen.dart';
import '../wallet/wallet_screen.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  bool _isOnline = false;
  final double _todayEarnings = 1250.50;
  final int _completedJobs = 8;
  final double _rating = 4.8;

  void _toggleAvailability() {
    setState(() => _isOnline = !_isOnline);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isOnline ? 'You are now online' : 'You are now offline'),
        backgroundColor: _isOnline ? AppColors.success : AppColors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Driver Dashboard',
          style: AppTypography.h5.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
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
                gradient: _isOnline ? AppColors.primaryGradient : 
                  const LinearGradient(
                    colors: [AppColors.grey, AppColors.darkGrey],
                  ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              child: Column(
                children: [
                  Icon(
                    _isOnline ? Icons.radio_button_checked : Icons.radio_button_off,
                    size: 64,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  Text(
                    _isOnline ? 'ONLINE' : 'OFFLINE',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  Text(
                    _isOnline ? 'Ready to accept jobs' : 'Tap to go online',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeightL,
                    child: ElevatedButton(
                      onPressed: _toggleAvailability,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: _isOnline ? AppColors.primaryYellow : AppColors.grey,
                      ),
                      child: Text(
                        _isOnline ? 'Go Offline' : 'Go Online',
                        style: AppTypography.buttonLarge.copyWith(
                          color: _isOnline ? AppColors.primaryYellow : AppColors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingXL),
            
            Text(
              'Today\'s Summary',
              style: AppTypography.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingM),
            
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Earnings',
                    '₹${_todayEarnings.toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: _buildSummaryCard(
                    'Jobs',
                    '$_completedJobs',
                    Icons.work,
                    AppColors.primaryYellow,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.paddingM),
            
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Rating',
                    '$_rating',
                    Icons.star,
                    AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: _buildSummaryCard(
                    'Status',
                    _isOnline ? 'Online' : 'Offline',
                    Icons.circle,
                    _isOnline ? AppColors.success : AppColors.grey,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.paddingXL),
            
            Text(
              'Quick Actions',
              style: AppTypography.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingM),
            
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    'Job Offers',
                    'View available jobs',
                    Icons.work_outline,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JobOffersScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: _buildActionCard(
                    'Wallet',
                    'View earnings',
                    Icons.account_balance_wallet_outlined,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WalletScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
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
            style: AppTypography.h4.copyWith(
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
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: AppDimensions.iconXL,
              color: AppColors.primaryYellow,
            ),
            const SizedBox(height: AppDimensions.paddingM),
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}