import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'fare_estimate_screen.dart';

class ServiceRequestScreen extends StatefulWidget {
  final String serviceType;
  final String serviceTitle;

  const ServiceRequestScreen({
    super.key,
    required this.serviceType,
    required this.serviceTitle,
  });

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleModelController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _vehicleType;
  bool _isLoading = false;

  @override
  void dispose() {
    _vehicleModelController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<Widget> _buildServiceSpecificFields() {
    switch (widget.serviceType) {
      case 'tow':
        return [
          DropdownButtonFormField<String>(
            value: _vehicleType,
            decoration: const InputDecoration(
              labelText: 'Vehicle Type',
              prefixIcon: Icon(Icons.directions_car),
            ),
            items: ['Sedan', 'SUV', 'Truck', 'Motorcycle']
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) => setState(() => _vehicleType = value),
            validator: (value) => value == null ? 'Select vehicle type' : null,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Destination',
              hintText: 'Where to tow?',
              prefixIcon: Icon(Icons.location_on),
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Enter destination' : null,
          ),
        ];
      
      case 'jumpstart':
        return [
          DropdownButtonFormField<String>(
            value: _vehicleType,
            decoration: const InputDecoration(
              labelText: 'Vehicle Type',
              prefixIcon: Icon(Icons.directions_car),
            ),
            items: ['Sedan', 'SUV', 'Truck', 'Motorcycle']
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) => setState(() => _vehicleType = value),
            validator: (value) => value == null ? 'Select vehicle type' : null,
          ),
        ];
      
      case 'fuel':
        return [
          DropdownButtonFormField<String>(
            value: _vehicleType,
            decoration: const InputDecoration(
              labelText: 'Fuel Type',
              prefixIcon: Icon(Icons.local_gas_station),
            ),
            items: ['Petrol', 'Diesel', 'Electric']
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) => setState(() => _vehicleType = value),
            validator: (value) => value == null ? 'Select fuel type' : null,
          ),
        ];
      
      case 'tire':
        return [
          DropdownButtonFormField<String>(
            value: _vehicleType,
            decoration: const InputDecoration(
              labelText: 'Vehicle Type',
              prefixIcon: Icon(Icons.directions_car),
            ),
            items: ['Sedan', 'SUV', 'Truck', 'Motorcycle']
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) => setState(() => _vehicleType = value),
            validator: (value) => value == null ? 'Select vehicle type' : null,
          ),
        ];
      
      default:
        return [];
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FareEstimateScreen(
            serviceType: widget.serviceType,
            serviceTitle: widget.serviceTitle,
            vehicleModel: _vehicleModelController.text,
            location: _locationController.text,
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
        title: Text(widget.serviceTitle),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vehicle Details',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.paddingL),
                
                TextFormField(
                  controller: _vehicleModelController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Model',
                    hintText: 'e.g., Toyota Camry 2020',
                    prefixIcon: Icon(Icons.directions_car),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Enter vehicle model' : null,
                ),
                
                const SizedBox(height: AppDimensions.paddingM),
                
                ..._buildServiceSpecificFields(),
                
                const SizedBox(height: AppDimensions.paddingM),
                
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Current Location',
                    hintText: 'Enter your location',
                    prefixIcon: Icon(Icons.my_location),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Enter location' : null,
                ),
                
                const SizedBox(height: AppDimensions.paddingM),
                
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Additional Notes (Optional)',
                    hintText: 'Any specific instructions',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
                
                const SizedBox(height: AppDimensions.paddingXXL),
                
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeightL,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitRequest,
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
                            'Get Fare Estimate',
                            style: AppTypography.buttonLarge.copyWith(
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
