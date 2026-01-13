import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'rescue_details_screen.dart';

class TowQuestionsScreen extends StatefulWidget {
  final String serviceType;
  final String serviceTitle;
  final String pickupLocation;
  final String dropLocation;
  final Map<String, String> contactInfo;
  final Map<String, String> vehicleInfo;

  const TowQuestionsScreen({
    super.key,
    required this.serviceType,
    required this.serviceTitle,
    required this.pickupLocation,
    required this.dropLocation,
    required this.contactInfo,
    required this.vehicleInfo,
  });

  @override
  State<TowQuestionsScreen> createState() => _TowQuestionsScreenState();
}

class _TowQuestionsScreenState extends State<TowQuestionsScreen> {
  bool? _hasKey;
  bool? _withVehicle;
  bool? _canNeutral;
  bool? _is4WD;
  bool? _hadAccident;
  bool? _rideWithTruck;
  bool? _inParkingGarage;
  String? _parkingGarageHeight;
  String? _breakdownLocationType;
  String? _towReason;

  final List<String> _locationTypes = [
    'Parking Lot',
    'Street',
    'Impound/Storage',
    'Driveway',
    'Home Garage',
    'Parking Garage',
    'Highway',
    'Off the Road',
  ];

  final List<String> _towReasons = [
    'Flat Tire (No Spare)',
    'Engine/Mechanical',
    'Brakes',
    'Steering Issues',
    'Severe Noise',
    'Transmission Problem',
    'Fluid Leak or Warning Light',
    'Lost or Broken Key',
    'Electrical Issues',
  ];

  final List<String> _garageHeights = [
    '6 feet',
    '7 feet',
    '8 feet',
    '9 feet',
    '10 feet',
    '11 feet',
    '12 feet',
  ];

  void _showParkingGarageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Parking Garage Height',
          style: AppTypography.h5.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please provide the height clearance of the parking garage in feet',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            DropdownButtonFormField<String>(
              value: _parkingGarageHeight,
              decoration: InputDecoration(
                labelText: 'Height',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
              ),
              items: _garageHeights.map((height) {
                return DropdownMenuItem(value: height, child: Text(height));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _parkingGarageHeight = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTypography.buttonLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
            ),
            child: Text(
              'Save',
              style: AppTypography.buttonLarge.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _proceed() {
    if (_hasKey == null ||
        _withVehicle == null ||
        _canNeutral == null ||
        _is4WD == null ||
        _hadAccident == null ||
        _rideWithTruck == null ||
        _inParkingGarage == null ||
        _breakdownLocationType == null ||
        _towReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please answer all questions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_inParkingGarage == true && _parkingGarageHeight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please provide parking garage height'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RescueDetailsScreen(
          serviceType: widget.serviceType,
          serviceTitle: widget.serviceTitle,
          pickupLocation: widget.pickupLocation,
          dropLocation: widget.dropLocation,
          contactInfo: widget.contactInfo,
          vehicleInfo: widget.vehicleInfo,
          towAnswers: {
            'hasKey': _hasKey!,
            'withVehicle': _withVehicle!,
            'canNeutral': _canNeutral!,
            'is4WD': _is4WD!,
            'hadAccident': _hadAccident!,
            'rideWithTruck': _rideWithTruck!,
            'inParkingGarage': _inParkingGarage!,
            'parkingGarageHeight': _parkingGarageHeight ?? '',
            'breakdownLocationType': _breakdownLocationType!,
            'towReason': _towReason!,
          },
        ),
      ),
    );
  }

  Widget _buildYesNoQuestion(String question, bool? value, Function(bool) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => onChanged(true),
                style: OutlinedButton.styleFrom(
                  backgroundColor: value == true ? AppColors.primaryYellow : AppColors.white,
                  foregroundColor: value == true ? AppColors.white : AppColors.primaryYellow,
                  side: BorderSide(color: AppColors.primaryYellow, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                ),
                child: Text('Yes', style: AppTypography.buttonLarge),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: OutlinedButton(
                onPressed: () => onChanged(false),
                style: OutlinedButton.styleFrom(
                  backgroundColor: value == false ? AppColors.primaryYellow : AppColors.white,
                  foregroundColor: value == false ? AppColors.white : AppColors.primaryYellow,
                  side: BorderSide(color: AppColors.primaryYellow, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                ),
                child: Text('No', style: AppTypography.buttonLarge),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Service Questions',
          style: AppTypography.h5.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        children: [
          Text(
            'Tow Service Questions',
            style: AppTypography.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            'Please answer the following questions',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          _buildYesNoQuestion('1. Is the key with the vehicle?', _hasKey, (value) {
            setState(() => _hasKey = value);
          }),
          const SizedBox(height: AppDimensions.paddingXL),
          _buildYesNoQuestion('2. Are you with the vehicle?', _withVehicle, (value) {
            setState(() => _withVehicle = value);
          }),
          const SizedBox(height: AppDimensions.paddingXL),
          _buildYesNoQuestion('3. Can the vehicle put in neutral?', _canNeutral, (value) {
            setState(() => _canNeutral = value);
          }),
          const SizedBox(height: AppDimensions.paddingXL),
          _buildYesNoQuestion('4. Is your vehicle 4WD?', _is4WD, (value) {
            setState(() => _is4WD = value);
          }),
          const SizedBox(height: AppDimensions.paddingXL),
          _buildYesNoQuestion('5. Has your vehicle been involved in an accident?', _hadAccident, (value) {
            if (value == true) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Service Unavailable',
                    style: AppTypography.h5.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  content: Text(
                    'Sorry, we can\'t proceed to give you service at this time. This could be a police matter. Better to call 100.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        'OK',
                        style: AppTypography.buttonLarge.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            setState(() => _hadAccident = value);
          }),
          const SizedBox(height: AppDimensions.paddingXL),
          _buildYesNoQuestion('6. Are you going to ride with the tow truck?', _rideWithTruck, (value) {
            setState(() => _rideWithTruck = value);
          }),
          const SizedBox(height: AppDimensions.paddingXL),
          _buildYesNoQuestion('7. Is the vehicle located in a parking garage?', _inParkingGarage, (value) {
            setState(() => _inParkingGarage = value);
            if (value == true) {
              Future.delayed(Duration(milliseconds: 300), () {
                _showParkingGarageDialog();
              });
            }
          }),
          if (_inParkingGarage == true && _parkingGarageHeight != null) ...[
            const SizedBox(height: AppDimensions.paddingS),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: AppColors.primaryYellow),
              ),
              child: Row(
                children: [
                  Icon(Icons.height, color: AppColors.primaryYellow),
                  const SizedBox(width: AppDimensions.paddingM),
                  Text(
                    'Height: $_parkingGarageHeight',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.edit, color: AppColors.primaryYellow),
                    onPressed: _showParkingGarageDialog,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.paddingXL),
          Text(
            '8. Select the breakdown location type',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          DropdownButtonFormField<String>(
            value: _breakdownLocationType,
            decoration: InputDecoration(
              hintText: 'Select location type',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: BorderSide(color: AppColors.primaryYellow, width: 2),
              ),
            ),
            items: _locationTypes.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) {
              setState(() => _breakdownLocationType = value);
            },
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          Text(
            '9. Select the reason for your tow request',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          DropdownButtonFormField<String>(
            value: _towReason,
            decoration: InputDecoration(
              hintText: 'Select reason',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: BorderSide(color: AppColors.primaryYellow, width: 2),
              ),
            ),
            items: _towReasons.map((reason) {
              return DropdownMenuItem(value: reason, child: Text(reason));
            }).toList(),
            onChanged: (value) {
              setState(() => _towReason = value);
            },
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          ElevatedButton(
            onPressed: _proceed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingL,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              minimumSize: const Size(double.infinity, 56),
            ),
            child: Text(
              'Next',
              style: AppTypography.buttonLarge.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
