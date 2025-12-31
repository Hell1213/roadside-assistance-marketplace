import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class JobOffersScreen extends StatefulWidget {
  const JobOffersScreen({super.key});

  @override
  State<JobOffersScreen> createState() => _JobOffersScreenState();
}

class _JobOffersScreenState extends State<JobOffersScreen> {
  final List<Map<String, dynamic>> _jobOffers = [
    {
      'id': 'JOB001',
      'service': 'Tow Service',
      'location': 'MG Road, Bangalore',
      'distance': '2.5 km',
      'earnings': 150.0,
      'customerRating': 4.5,
      'urgency': 'High',
    },
    {
      'id': 'JOB002',
      'service': 'Jump Start',
      'location': 'Koramangala, Bangalore',
      'distance': '1.8 km',
      'earnings': 80.0,
      'customerRating': 4.2,
      'urgency': 'Medium',
    },
    {
      'id': 'JOB003',
      'service': 'Fuel Delivery',
      'location': 'Whitefield, Bangalore',
      'distance': '5.2 km',
      'earnings': 120.0,
      'customerRating': 4.8,
      'urgency': 'Low',
    },
  ];

  void _acceptJob(Map<String, dynamic> job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 64,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            Text(
              'Job Accepted!',
              style: AppTypography.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              'Navigate to customer location',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingL),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Later'),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening navigation...'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    child: const Text('Navigate'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _declineJob(Map<String, dynamic> job) {
    setState(() {
      _jobOffers.remove(job);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Job declined'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Job Offers'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _jobOffers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_off,
                    size: 80,
                    color: AppColors.grey,
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  Text(
                    'No job offers available',
                    style: AppTypography.h5.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  Text(
                    'Make sure you are online to receive jobs',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              itemCount: _jobOffers.length,
              itemBuilder: (context, index) {
                final job = _jobOffers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                  child: _buildJobCard(job),
                );
              },
            ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    Color urgencyColor = AppColors.success;
    if (job['urgency'] == 'High') urgencyColor = AppColors.error;
    if (job['urgency'] == 'Medium') urgencyColor = AppColors.warning;

    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  job['service'],
                  style: AppTypography.h5.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                  decoration: BoxDecoration(
                    color: urgencyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    job['urgency'],
                    style: AppTypography.bodySmall.copyWith(
                      color: urgencyColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.paddingM),
            
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: AppDimensions.iconS,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Expanded(
                  child: Text(
                    job['location'],
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  job['distance'],
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.paddingM),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: AppDimensions.iconS,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${job['customerRating']}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${job['earnings'].toStringAsFixed(0)}',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.paddingL),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _declineJob(job),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptJob(job),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}