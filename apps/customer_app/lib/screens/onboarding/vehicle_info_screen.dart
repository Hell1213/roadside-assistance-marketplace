import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import '../service/tow_questions_screen.dart';

class VehicleInfoScreen extends StatefulWidget {
  final String serviceType;
  final String serviceTitle;
  final String pickupLocation;
  final String dropLocation;
  final Map<String, String> contactInfo;

  const VehicleInfoScreen({
    super.key,
    required this.serviceType,
    required this.serviceTitle,
    required this.pickupLocation,
    required this.dropLocation,
    required this.contactInfo,
  });

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  String? _selectedYear;
  String? _selectedMake;
  String? _selectedModel;
  String? _selectedColor;

  final List<String> _years = List.generate(30, (index) => (2025 - index).toString());
  
  final Map<String, List<String>> _makes = {
    'Toyota': ['Camry', 'Corolla', 'RAV4', 'Highlander'],
    'Honda': ['Accord', 'Civic', 'CR-V', 'Pilot'],
    'Ford': ['F-150', 'Mustang', 'Explorer', 'Escape'],
    'Chevrolet': ['Silverado', 'Malibu', 'Equinox', 'Tahoe'],
    'BMW': ['3 Series', '5 Series', 'X5', 'X3'],
    'Mercedes': ['C-Class', 'E-Class', 'GLE', 'GLC'],
  };

  final List<String> _colors = [
    'Black',
    'White',
    'Silver',
    'Gray',
    'Red',
    'Blue',
    'Green',
    'Brown',
  ];

  void _proceed() {
    if (_selectedYear == null ||
        _selectedMake == null ||
        _selectedModel == null ||
        _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all vehicle information'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TowQuestionsScreen(
          serviceType: widget.serviceType,
          serviceTitle: widget.serviceTitle,
          pickupLocation: widget.pickupLocation,
          dropLocation: widget.dropLocation,
          contactInfo: widget.contactInfo,
          vehicleInfo: {
            'year': _selectedYear!,
            'make': _selectedMake!,
            'model': _selectedModel!,
            'color': _selectedColor!,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Vehicle Information',
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
            'Vehicle Details',
            style: AppTypography.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            'Tell us about your vehicle',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          DropdownButtonFormField<String>(
            value: _selectedYear,
            decoration: InputDecoration(
              labelText: 'Year',
              prefixIcon: Icon(Icons.calendar_today, color: AppColors.primaryYellow),
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
            items: _years.map((year) {
              return DropdownMenuItem(value: year, child: Text(year));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedYear = value;
              });
            },
          ),
          const SizedBox(height: AppDimensions.paddingL),
          DropdownButtonFormField<String>(
            value: _selectedMake,
            decoration: InputDecoration(
              labelText: 'Made By',
              prefixIcon: Icon(Icons.directions_car, color: AppColors.primaryYellow),
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
            items: _makes.keys.map((make) {
              return DropdownMenuItem(value: make, child: Text(make));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMake = value;
                _selectedModel = null;
              });
            },
          ),
          const SizedBox(height: AppDimensions.paddingL),
          DropdownButtonFormField<String>(
            value: _selectedModel,
            decoration: InputDecoration(
              labelText: 'Model',
              prefixIcon: Icon(Icons.car_rental, color: AppColors.primaryYellow),
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
            items: _selectedMake != null && _makes.containsKey(_selectedMake)
                ? _makes[_selectedMake]!.map((model) {
                    return DropdownMenuItem(value: model, child: Text(model));
                  }).toList()
                : [],
            onChanged: _selectedMake != null
                ? (value) {
                    setState(() {
                      _selectedModel = value;
                    });
                  }
                : null,
          ),
          const SizedBox(height: AppDimensions.paddingL),
          DropdownButtonFormField<String>(
            value: _selectedColor,
            decoration: InputDecoration(
              labelText: 'Color',
              prefixIcon: Icon(Icons.palette, color: AppColors.primaryYellow),
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
            items: _colors.map((color) {
              return DropdownMenuItem(value: color, child: Text(color));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedColor = value;
              });
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
