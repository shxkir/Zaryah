import 'package:flutter/material.dart';
import '../services/housing_service.dart';
import '../theme/neon_palette.dart';
import 'location_picker_screen.dart';

class CreateHousingScreen extends StatefulWidget {
  const CreateHousingScreen({super.key});

  @override
  State<CreateHousingScreen> createState() => _CreateHousingScreenState();
}

class _CreateHousingScreenState extends State<CreateHousingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _localityController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _sqFeetController = TextEditingController();
  final _descriptionController = TextEditingController();

  double? _latitude;
  double? _longitude;
  String _propertyType = 'apartment';
  List<String> _selectedAmenities = [];
  bool _isLoading = false;

  final List<String> _amenityOptions = [
    'Parking',
    'Gym',
    'Swimming Pool',
    'Security',
    'Power Backup',
    'Elevator',
    'Garden',
    'Playground',
    'Wi-Fi',
    'Air Conditioning',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _localityController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _sqFeetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LocationPickerScreen(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
      });
    }
  }

  Future<void> _createListing() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await HousingService.createListing(
        title: _titleController.text,
        monthlyPrice: double.parse(_priceController.text),
        locality: _localityController.text,
        fullAddress: _addressController.text,
        latitude: _latitude!,
        longitude: _longitude!,
        contactInfo: _contactController.text,
        bedrooms: _bedroomsController.text.isNotEmpty ? int.parse(_bedroomsController.text) : null,
        bathrooms: _bathroomsController.text.isNotEmpty ? int.parse(_bathroomsController.text) : null,
        squareFeet: _sqFeetController.text.isNotEmpty ? int.parse(_sqFeetController.text) : null,
        propertyType: _propertyType,
        amenities: _selectedAmenities,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Housing Listing'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: '2 BHK Apartment in Anna Nagar',
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Monthly Rent (₹) *',
                hintText: '15000',
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _localityController,
              decoration: const InputDecoration(
                labelText: 'Locality *',
                hintText: 'Anna Nagar',
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Full Address *',
                hintText: 'Complete address with landmarks',
              ),
              maxLines: 2,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _pickLocation,
              icon: Icon(_latitude != null ? Icons.check_circle : Icons.location_on),
              label: Text(_latitude != null ? 'Location Selected' : 'Pick Location on Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _latitude != null ? NeonColors.cyan : NeonColors.surface,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: 'Contact Number *',
                hintText: '+91 1234567890',
              ),
              keyboardType: TextInputType.phone,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _propertyType,
              decoration: const InputDecoration(labelText: 'Property Type'),
              items: const [
                DropdownMenuItem(value: 'apartment', child: Text('Apartment')),
                DropdownMenuItem(value: 'house', child: Text('House')),
                DropdownMenuItem(value: 'villa', child: Text('Villa')),
                DropdownMenuItem(value: 'studio', child: Text('Studio')),
              ],
              onChanged: (v) => setState(() => _propertyType = v!),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bedroomsController,
                    decoration: const InputDecoration(labelText: 'Bedrooms'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _bathroomsController,
                    decoration: const InputDecoration(labelText: 'Bathrooms'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _sqFeetController,
              decoration: const InputDecoration(labelText: 'Square Feet'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            const Text('Amenities', style: TextStyle(fontSize: 16, color: NeonColors.text)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _amenityOptions.map((amenity) {
                final isSelected = _selectedAmenities.contains(amenity);
                return FilterChip(
                  label: Text(amenity),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAmenities.add(amenity);
                      } else {
                        _selectedAmenities.remove(amenity);
                      }
                    });
                  },
                  selectedColor: NeonColors.cyan.withOpacity(0.3),
                  checkmarkColor: NeonColors.cyan,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Additional details about the property...',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createListing,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Create Listing', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
