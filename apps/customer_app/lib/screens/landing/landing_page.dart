import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import '../auth/phone_input_screen.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

// Conditional import for web
import 'landing_page_web.dart' if (dart.library.io) 'landing_page_mobile.dart' as web_utils;

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isServicesHovered = false;

  void _scrollToSection(String sectionId) {
    web_utils.scrollToSection(sectionId);
  }

  void _openAppStore() {
    web_utils.openAppStore();
  }

  void _openPlayStore() {
    web_utils.openPlayStore();
  }

  void _navigateToLogin() async {
    // Check if user is already authenticated
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      // User is already logged in, navigate to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CustomerHomePage()),
      );
      return;
    }
    
    // User is not authenticated, navigate to login
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PhoneInputScreen(role: 'CUSTOMER'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Navigation Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: AppColors.white,
            elevation: 2,
            shadowColor: AppColors.black.withOpacity(0.1),
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryYellow.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'RAS',
                    style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            title: isDesktop
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NavButton(
                        label: 'HOME',
                        onTap: () => _scrollToSection('home'),
                        isActive: true,
                      ),
                      const SizedBox(width: 32),
                      _NavButton(
                        label: 'ABOUT US',
                        onTap: () => _scrollToSection('about'),
                      ),
                      const SizedBox(width: 32),
                      MouseRegion(
                        onEnter: (_) => setState(() => _isServicesHovered = true),
                        onExit: (_) => setState(() => _isServicesHovered = false),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _NavButton(
                              label: 'SERVICES',
                              onTap: () {},
                              hasDropdown: true,
                            ),
                            if (_isServicesHovered)
                              Positioned(
                                top: 50,
                                left: -40,
                                child: _ServicesDropdown(),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      _NavButton(
                        label: 'TRACK RESCUE',
                        onTap: () => _scrollToSection('track'),
                      ),
                    ],
                  )
                : null,
            actions: [
              if (isDesktop) ...[
                TextButton(
                  onPressed: _navigateToLogin,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    'Login',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _navigateToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Sign Up',
                    style: AppTypography.buttonMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
              ] else
                IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                  onPressed: () {
                    // Mobile menu
                  },
                ),
            ],
          ),

          // Hero Section
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A4D5C),
                    const Color(0xFF0D2E3A),
                    AppColors.black,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Background Illustrations
                  Positioned(
                    top: -50,
                    left: -50,
                    child: Opacity(
                      opacity: 0.15,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryYellow,
                            width: 3,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.help_outline,
                            size: 150,
                            color: AppColors.primaryYellow,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100,
                    right: -80,
                    child: Opacity(
                      opacity: 0.12,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryYellow,
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.build,
                            size: 120,
                            color: AppColors.primaryYellow,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    right: 50,
                    child: Opacity(
                      opacity: 0.1,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryYellow,
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.access_time,
                            size: 100,
                            color: AppColors.primaryYellow,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Main Content
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 120 : isTablet ? 60 : 24,
                        vertical: 60,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          // Central Icon
                          Container(
                            width: isDesktop ? 140 : 120,
                            height: isDesktop ? 140 : 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2196F3).withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.car_repair,
                              size: 70,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Main Heading
                          Text(
                            'RAS',
                            style: TextStyle(
                              fontSize: isDesktop ? 96 : isTablet ? 72 : 64,
                              fontWeight: FontWeight.w900,
                              color: AppColors.white,
                              letterSpacing: 4,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Tagline
                          Text(
                            'Help is just a click away',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.white,
                              fontSize: isDesktop ? 28 : isTablet ? 24 : 20,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 60),
                          // App Store Buttons
                          Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            alignment: WrapAlignment.center,
                            children: [
                              _AppStoreButton(
                                icon: Icons.phone_iphone,
                                label: 'Available on the\nApp Store',
                                onTap: _openAppStore,
                                isPrimary: true,
                              ),
                              _AppStoreButton(
                                icon: Icons.android,
                                label: 'ANDROID APP ON\nGoogle play',
                                onTap: _openPlayStore,
                                isPrimary: false,
                              ),
                            ],
                          ),
                          const SizedBox(height: 50),
                          // Get Help Button
                          ElevatedButton(
                            onPressed: _navigateToLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 80 : 60,
                                vertical: isDesktop ? 22 : 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                            ),
                            child: Text(
                              'Get Help',
                              style: AppTypography.buttonLarge.copyWith(
                                color: AppColors.white,
                                fontSize: isDesktop ? 20 : 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Services Section
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 120 : isTablet ? 60 : 24,
                vertical: 100,
              ),
              color: AppColors.white,
              child: Column(
                children: [
                  Text(
                    'Our Services',
                    style: AppTypography.h2.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: isDesktop ? 48 : 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Professional roadside assistance services available 24/7',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: isDesktop ? 18 : 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 64),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isDesktop ? 4 : isTablet ? 2 : 1,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: isDesktop ? 0.85 : 1.2,
                    children: [
                      _ServiceCard(
                        icon: Icons.local_shipping_rounded,
                        title: 'Tow Service',
                        description: 'Professional vehicle towing and transport to your preferred location',
                      ),
                      _ServiceCard(
                        icon: Icons.battery_charging_full_rounded,
                        title: 'Jump Start',
                        description: 'Quick battery jump start service to get you back on the road',
                      ),
                      _ServiceCard(
                        icon: Icons.local_gas_station_rounded,
                        title: 'Fuel Delivery',
                        description: 'Emergency fuel delivery to your exact location within minutes',
                      ),
                      _ServiceCard(
                        icon: Icons.tire_repair_rounded,
                        title: 'Flat Tire',
                        description: 'Expert tire repair and replacement service at your location',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // About Us Section
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 120 : isTablet ? 60 : 24,
                vertical: 100,
              ),
              color: AppColors.background,
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'About Us',
                                style: AppTypography.h2.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 48,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                'We are India\'s leading roadside assistance platform, connecting customers with professional service providers in minutes.',
                                style: AppTypography.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 18,
                                  height: 1.7,
                                ),
                              ),
                              const SizedBox(height: 40),
                              _FeatureItem(
                                icon: Icons.access_time_rounded,
                                text: '24/7 Availability',
                                description: 'Round-the-clock service whenever you need help',
                              ),
                              const SizedBox(height: 24),
                              _FeatureItem(
                                icon: Icons.location_on_rounded,
                                text: 'Real-time Tracking',
                                description: 'Track your service provider\'s location in real-time',
                              ),
                              const SizedBox(height: 24),
                              _FeatureItem(
                                icon: Icons.verified_rounded,
                                text: 'Verified Professionals',
                                description: 'All service providers are verified and background checked',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 80),
                        Expanded(
                          child: Container(
                            height: 500,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryYellow.withOpacity(0.2),
                                  AppColors.primaryYellow.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.primaryYellow.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.support_agent_rounded,
                                size: 120,
                                color: AppColors.primaryYellow,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About Us',
                          style: AppTypography.h2.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 36,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'We are India\'s leading roadside assistance platform, connecting customers with professional service providers in minutes.',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _FeatureItem(
                          icon: Icons.access_time_rounded,
                          text: '24/7 Availability',
                          description: 'Round-the-clock service whenever you need help',
                        ),
                        const SizedBox(height: 16),
                        _FeatureItem(
                          icon: Icons.location_on_rounded,
                          text: 'Real-time Tracking',
                          description: 'Track your service provider\'s location in real-time',
                        ),
                        const SizedBox(height: 16),
                        _FeatureItem(
                          icon: Icons.verified_rounded,
                          text: 'Verified Professionals',
                          description: 'All service providers are verified and background checked',
                        ),
                      ],
                    ),
            ),
          ),

          // Track Rescue Section
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 120 : isTablet ? 60 : 24,
                vertical: 100,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryYellow,
                    const Color(0xFFFFD54F),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.location_searching_rounded,
                    size: 64,
                    color: AppColors.black,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Track Your Rescue',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: isDesktop ? 48 : 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Real-time tracking of your service provider',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.black.withOpacity(0.8),
                      fontSize: isDesktop ? 20 : 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _navigateToLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 56 : 40,
                        vertical: isDesktop ? 20 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Track Now',
                      style: AppTypography.buttonLarge.copyWith(
                        color: AppColors.white,
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(60),
              color: AppColors.black,
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'RAS',
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '© 2025 Roadside Assistance. All rights reserved.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final bool hasDropdown;

  const _NavButton({
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.hasDropdown = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isActive ? AppColors.primaryYellow : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
            if (hasDropdown) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: isActive ? AppColors.primaryYellow : AppColors.textPrimary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ServicesDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: AppColors.white,
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            _ServiceMenuItem(
              icon: Icons.local_shipping_rounded,
              label: 'Tow Service',
            ),
            const Divider(height: 1),
            _ServiceMenuItem(
              icon: Icons.battery_charging_full_rounded,
              label: 'Jump Start',
            ),
            const Divider(height: 1),
            _ServiceMenuItem(
              icon: Icons.local_gas_station_rounded,
              label: 'Fuel Delivery',
            ),
            const Divider(height: 1),
            _ServiceMenuItem(
              icon: Icons.tire_repair_rounded,
              label: 'Flat Tire',
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ServiceMenuItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryYellow,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppStoreButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _AppStoreButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.white : AppColors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.white.withOpacity(isPrimary ? 0.3 : 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isPrimary ? const Color(0xFF2196F3) : AppColors.white,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isPrimary ? AppColors.black : AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 32,
              color: AppColors.primaryYellow,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTypography.h5.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.text,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryYellow.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryYellow,
            size: 24,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: AppTypography.h6.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
