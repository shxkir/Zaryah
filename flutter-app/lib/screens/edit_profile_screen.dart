import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _bioController;
  late TextEditingController _occupationController;
  late TextEditingController _educationController;
  late TextEditingController _learningGoalsController;
  late TextEditingController _strengthsController;
  late TextEditingController _weaknessesController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.profile?.name ?? '');
    _ageController = TextEditingController(text: widget.user.profile?.age.toString() ?? '');
    _bioController = TextEditingController(text: widget.user.profile?.bio ?? '');
    _occupationController = TextEditingController(text: widget.user.profile?.occupation ?? '');
    _educationController = TextEditingController(text: widget.user.profile?.educationLevel ?? '');
    _learningGoalsController = TextEditingController(text: widget.user.profile?.learningGoals ?? '');
    _strengthsController = TextEditingController(text: widget.user.profile?.strengths ?? '');
    _weaknessesController = TextEditingController(text: widget.user.profile?.weaknesses ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _occupationController.dispose();
    _educationController.dispose();
    _learningGoalsController.dispose();
    _strengthsController.dispose();
    _weaknessesController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final profileData = {
        'name': _nameController.text,
        'age': int.parse(_ageController.text),
        'bio': _bioController.text,
        'occupation': _occupationController.text,
        'educationLevel': _educationController.text,
        'learningGoals': _learningGoalsController.text,
        'strengths': _strengthsController.text,
        'weaknesses': _weaknessesController.text,
      };

      await _apiService.updateProfile(profileData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context, true); // Return true to indicate update
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFFFD700),
                    child: Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text.substring(0, 1).toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF000000), width: 2),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Color(0xFF000000)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Photo upload coming soon!')),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
                prefixIcon: Icon(Icons.cake),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Age is required';
                if (int.tryParse(value!) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                prefixIcon: Icon(Icons.info),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _occupationController,
              decoration: const InputDecoration(
                labelText: 'Occupation',
                prefixIcon: Icon(Icons.work),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _educationController,
              decoration: const InputDecoration(
                labelText: 'Education Level',
                prefixIcon: Icon(Icons.school),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _learningGoalsController,
              decoration: const InputDecoration(
                labelText: 'Learning Goals',
                prefixIcon: Icon(Icons.flag),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _strengthsController,
              decoration: const InputDecoration(
                labelText: 'Strengths',
                prefixIcon: Icon(Icons.star),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weaknessesController,
              decoration: const InputDecoration(
                labelText: 'Areas to Improve',
                prefixIcon: Icon(Icons.trending_up),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
