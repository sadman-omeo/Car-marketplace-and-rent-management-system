import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

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

  final CarService _carService = CarService();
  final ImagePicker _picker = ImagePicker();

  String? selectedType;
  String? selectedFuelType;
  String? selectedTransmission;

  File? _selectedImageFile;
  String _imageBase64 = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _registrationController.dispose();
    _colorController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedImage == null) return;

      final file = File(pickedImage.path);
      final bytes = await file.readAsBytes();

      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        _showMessage('Could not process image');
        return;
      }

      final resized = img.copyResize(decodedImage, width: 600);
      final compressedBytes = Uint8List.fromList(
        img.encodeJpg(resized, quality: 55),
      );

      final base64String = base64Encode(compressedBytes);

      setState(() {
        _selectedImageFile = file;
        _imageBase64 = base64String;
      });
    } catch (e) {
      _showMessage('Failed to pick image');
    }
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

    if (_imageBase64.isEmpty) {
      _showMessage('Please select a car image');
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
        imageBase64: _imageBase64,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car registered successfully')),
      );
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
        return DropdownMenuItem<String>(
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
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD4AF37)),
                  ),
                  child: _selectedImageFile != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _selectedImageFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        color: Color(0xFFD4AF37),
                        size: 40,
                      ),
                      SizedBox(height: 10),
                      Text('Tap to select car image'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
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