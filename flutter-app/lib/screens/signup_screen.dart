import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'chatbot_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _pageController = PageController();
  final _apiService = ApiService();
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: Basic Info
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();

  // Step 2: Education & Occupation
  String _educationLevel = "Bachelor's";
  final _occupationController = TextEditingController();

  // Step 3: Learning Preferences
  final _learningGoalsController = TextEditingController();
  final List<String> _selectedSubjects = [];
  String _learningStyle = 'Visual';

  // Step 4: Experience & Challenges
  final _previousExperienceController = TextEditingController();
  final _strengthsController = TextEditingController();
  final _weaknessesController = TextEditingController();
  final _specificChallengesController = TextEditingController();

  // Step 5: Time & Pace
  double _availableHoursPerWeek = 10;
  String _learningPace = 'Medium';
  String _motivationLevel = 'Medium';

  final List<String> _allSubjects = [
    'Web Development',
    'Mobile Development',
    'Machine Learning',
    'Deep Learning',
    'Data Science',
    'Cloud Computing',
    'DevOps',
    'Cybersecurity',
    'UI/UX Design',
    'Game Development',
    'Blockchain',
    'Database Design',
    'System Design',
    'Python',
    'JavaScript',
    'Digital Marketing',
    'Business Analytics',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _learningGoalsController.dispose();
    _previousExperienceController.dispose();
    _strengthsController.dispose();
    _weaknessesController.dispose();
    _specificChallengesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitSignup();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitSignup() async {
    setState(() => _isLoading = true);

    try {
      await _apiService.signup(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        educationLevel: _educationLevel,
        occupation: _occupationController.text.trim(),
        learningGoals: _learningGoalsController.text.trim(),
        subjects: _selectedSubjects,
        learningStyle: _learningStyle,
        previousExperience: _previousExperienceController.text.trim(),
        strengths: _strengthsController.text.trim(),
        weaknesses: _weaknessesController.text.trim(),
        specificChallenges: _specificChallengesController.text.trim(),
        availableHoursPerWeek: _availableHoursPerWeek.round(),
        learningPace: _learningPace,
        motivationLevel: _motivationLevel,
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ChatbotScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
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
        title: const Text('Sign Up'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
            backgroundColor: Colors.grey[200],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Step ${_currentStep + 1} of 5',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          // Page view
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
                _buildStep5(),
              ],
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_currentStep == 4 ? 'Complete' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Education & Occupation',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _educationLevel,
            decoration: const InputDecoration(
              labelText: 'Education Level',
              border: OutlineInputBorder(),
            ),
            items: ["High School", "Bachelor's", "Master's", "PhD", "Other"]
                .map((level) => DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _educationLevel = value!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _occupationController,
            decoration: const InputDecoration(
              labelText: 'Current Occupation',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Preferences',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _learningGoalsController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Learning Goals',
              hintText: 'What do you want to achieve?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Subjects of Interest',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _allSubjects.map((subject) {
              final isSelected = _selectedSubjects.contains(subject);
              return FilterChip(
                label: Text(subject),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSubjects.add(subject);
                    } else {
                      _selectedSubjects.remove(subject);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _learningStyle,
            decoration: const InputDecoration(
              labelText: 'Learning Style',
              border: OutlineInputBorder(),
            ),
            items: ['Visual', 'Auditory', 'Kinesthetic', 'Reading-Writing']
                .map((style) => DropdownMenuItem(
                      value: style,
                      child: Text(style),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _learningStyle = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Experience & Challenges',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _previousExperienceController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Previous Experience',
              hintText: 'Describe your background...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _strengthsController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Strengths',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _weaknessesController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Weaknesses',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _specificChallengesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Specific Challenges',
              hintText: 'What challenges do you face?',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time & Pace',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          Text(
            'Available Hours per Week: ${_availableHoursPerWeek.round()} hours',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _availableHoursPerWeek,
            min: 1,
            max: 40,
            divisions: 39,
            onChanged: (value) =>
                setState(() => _availableHoursPerWeek = value),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _learningPace,
            decoration: const InputDecoration(
              labelText: 'Preferred Learning Pace',
              border: OutlineInputBorder(),
            ),
            items: ['Slow', 'Medium', 'Fast']
                .map((pace) => DropdownMenuItem(
                      value: pace,
                      child: Text(pace),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _learningPace = value!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _motivationLevel,
            decoration: const InputDecoration(
              labelText: 'Motivation Level',
              border: OutlineInputBorder(),
            ),
            items: ['Low', 'Medium', 'High']
                .map((level) => DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _motivationLevel = value!),
          ),
        ],
      ),
    );
  }
}
