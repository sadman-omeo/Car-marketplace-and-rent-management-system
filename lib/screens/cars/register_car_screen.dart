import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../services/car_service.dart';

class RegisterCarScreen extends StatefulWidget {
  const RegisterCarScreen({super.key});

  @override
  State<RegisterCarScreen> createState() => _RegisterCarScreenState();
}

class _RegisterCarScreenState extends State<RegisterCarScreen> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  final CarService _carService = CarService();

  String? selectedType;
  String? selectedFuelType;
  String? selectedTransmission;

  bool _isLoading = false;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _registrationController.dispose();
    _colorController.dispose();
    _mileageController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _saveCar() async {
    if (_brandController.text.trim().isEmpty ||
        _modelController.text.trim().isEmpty ||
        _yearController.text.trim().isEmpty ||
        selectedType == null ||
        _registrationController.text.trim().isEmpty ||
        _colorController.text.trim().isEmpty ||
        _mileageController.text.trim().isEmpty ||
        selectedFuelType == null ||
        selectedTransmission == null) {
      _showMessage('Please fill in all required fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _carService.addRegisteredCar(
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: _yearController.text.trim(),
        type: selectedType!,
        registrationNumber: _registrationController.text.trim(),
        color: _colorController.text.trim(),
        mileage: _mileageController.text.trim(),
        fuelType: selectedFuelType!,
        transmission: selectedTransmission!,
        imageUrl: _imageUrlController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
      _showMessage('Car registered successfully');
    } catch (e) {
      _showMessage('Failed to register car');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xFF171717),
      decoration: InputDecoration(labelText: label),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (value) => onChanged(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Car'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF171717),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD4AF37)),
          ),
          child: Column(
            children: [
              TextField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Year'),
              ),
              const SizedBox(height: 14),
              _dropdownField(
                label: 'Type',
                value: selectedType,
                items: carTypes,
                onChanged: (value) {
                  setState(() {
                    selectedType = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _registrationController,
                decoration:
                const InputDecoration(labelText: 'Registration Number'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _mileageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Mileage'),
              ),
              const SizedBox(height: 14),
              _dropdownField(
                label: 'Fuel Type',
                value: selectedFuelType,
                items: fuelTypes,
                onChanged: (value) {
                  setState(() {
                    selectedFuelType = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              _dropdownField(
                label: 'Transmission',
                value: selectedTransmission,
                items: transmissionTypes,
                onChanged: (value) {
                  setState(() {
                    selectedTransmission = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional for now)',
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _saveCar,
                child: const Text('Save Registered Car'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}