import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared/shared.dart';
import 'otp_verification_screen.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedCountryCode = '+1';
  bool _isLoading = false;

  final List<Map<String, String>> _countryCodes = [
    {'code': '+1', 'country': 'US'},
    {'code': '+91', 'country': 'IN'},
    {'code': '+44', 'country': 'UK'},
    {'code': '+61', 'country': 'AU'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(
            phoneNumber: '$_selectedCountryCode${_phoneController.text}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.paddingXL),
                
                Text(
                  'Enter Your Phone Number',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.paddingM),
                
                Text(
                  'We\'ll send you a verification code',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.paddingXXL),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 110,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCountryCode,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingS,
                          ),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          isExpanded: true,
                          items: _countryCodes.map((country) {
                            return DropdownMenuItem(
                              value: country['code'],
                              child: Text(
                                '${country['country']} ${country['code']}',
                                style: AppTypography.bodySmall,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedCountryCode = value!);
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: AppDimensions.paddingM),
                    
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        style: AppTypography.bodyLarge,
                        decoration: const InputDecoration(
                          hintText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: _validatePhone,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeightL,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOTP,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.textOnPrimary,
                              ),
                            ),
                          )
                        : Text(
                            'Send Code',
                            style: AppTypography.buttonLarge.copyWith(
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: AppDimensions.paddingL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
