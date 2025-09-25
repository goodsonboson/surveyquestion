import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import your custom widgets/pages
import 'thank_you_page.dart';
import 'branding_carousel.dart';

class SurveyForm extends StatefulWidget {
  const SurveyForm({super.key});

  @override
  State<SurveyForm> createState() => _SurveyFormState();
}

class _SurveyFormState extends State<SurveyForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _ageCtrl = TextEditingController();

  String? _gender;
  String? _region;
  String? _education;
  String? _jobs;
  String? _security;
  String? _infrastructure;
  String? _healthcare;
  String? _costOfLiving;
  String? _galamsey;
  String? _expectations;
  String? _improvement;
  String? _corruption;

  bool _isAgeVerified = false;
  bool _isAgeVerificationShown = false;
  bool _isSubmitting = false;

  final List<String> regions = [
    "Greater Accra",
    "Ashanti",
    "Western",
    "Central",
    "Eastern",
    "Volta",
    "Oti",
    "Western North",
    "Northern",
    "Savannah",
    "North East",
    "Upper East",
    "Upper West",
    "Bono",
    "Bono East",
    "Ahafo",
  ];

  // Color scheme
  final Color primaryColor = const Color(0xFF2E7D32); // Green theme
  final Color secondaryColor = const Color(0xFFF5F5F5);
  final Color accentColor = const Color(0xFF4CAF50);

  Future<void> _showAgeVerificationDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 64,
                  color: primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  "Age Verification",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "To ensure the integrity of our survey, we need to verify that you are 18 years or older.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _isAgeVerified = false;
                            _isAgeVerificationShown = true;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: primaryColor),
                        ),
                        child: Text(
                          "No",
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _isAgeVerified = true;
                            _isAgeVerificationShown = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Yes"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitSurvey() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final email = _emailCtrl.text.trim();
      final age = int.tryParse(_ageCtrl.text.trim()) ?? 0;

      if (age < 18) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Survey restricted to 18 years and above."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final existing = await FirebaseFirestore.instance
          .collection('survey_responses')
          .where('email', isEqualTo: email)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("You have already submitted this survey!"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('survey_responses').add({
        'email': email,
        'age': age,
        'gender': _gender,
        'region': _region,
        'education': _education,
        'jobs': _jobs,
        'security': _security,
        'infrastructure': _infrastructure,
        'healthcare': _healthcare,
        'costOfLiving': _costOfLiving,
        'galamsey': _galamsey,
        'expectations': _expectations,
        'improvement': _improvement,
        'corruption': _corruption,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ThankYouPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error submitting survey: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: secondaryColor,
      ),
      items: options
          .map((opt) => DropdownMenuItem<String>(value: opt, child: Text(opt)))
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? "This field is required" : null,
      borderRadius: BorderRadius.circular(8),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: secondaryColor,
      ),
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAgeVerificationDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "News Africa TV Survey",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth > 800
              ? 700
              : constraints.maxWidth * 0.95;

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      // Branding carousel at the top
                      BrandingCarousel(),
                      const SizedBox(height: 24),

                      if (!_isAgeVerificationShown)
                        Container(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  primaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Verifying...",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (!_isAgeVerified)
                        Container(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.block, size: 80, color: Colors.red),
                              const SizedBox(height: 20),
                              Text(
                                "Survey Access Restricted",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "This survey is only available to individuals who are 18 years and above.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, height: 1.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Thank you for your interest!",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Personal Information Section
                              _buildSectionTitle("Personal Information"),
                              const SizedBox(height: 16),

                              _buildTextFormField(
                                label: "Email Address",
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val == null || val.isEmpty)
                                    return "Please enter your email";
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(val)) {
                                    return "Please enter a valid email address";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildTextFormField(
                                label: "Age",
                                controller: _ageCtrl,
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val == null || val.isEmpty)
                                    return "Please enter your age";
                                  final age = int.tryParse(val);
                                  if (age == null)
                                    return "Please enter a valid number";
                                  if (age < 18)
                                    return "You must be 18 or older to participate";
                                  if (age > 120)
                                    return "Please enter a valid age";
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildDropdown(
                                "Gender",
                                _gender,
                                [
                                  "Male",
                                  "Female",
                                  "Other",
                                  "Prefer not to say",
                                ],
                                (val) => setState(() => _gender = val),
                              ),
                              const SizedBox(height: 16),

                              _buildDropdown(
                                "Region",
                                _region,
                                regions,
                                (val) => setState(() => _region = val),
                              ),
                              const SizedBox(height: 24),

                              // Government Performance Section
                              _buildSectionTitle(
                                "Speak up! Rate how the government is doing in the following sectors",
                              ),
                              const SizedBox(height: 16),

                              _buildDropdown(
                                "Education System",
                                _education,
                                ["Good", "Fair", "Poor", "None"],
                                (val) => setState(() => _education = val),
                              ),
                              const SizedBox(height: 16),

                              _buildDropdown(
                                "Jobs & Employment",
                                _jobs,
                                ["Good", "Fair", "Poor", "None"],
                                (val) => setState(() => _jobs = val),
                              ),
                              const SizedBox(height: 16),

                              _buildDropdown(
                                "Security",
                                _security,
                                ["Good", "Fair", "Poor", "None"],
                                (val) => setState(() => _security = val),
                              ),
                              const SizedBox(height: 16),

                              _buildDropdown(
                                "Infrastructure",
                                _infrastructure,
                                ["Good", "Fair", "Poor", "None"],
                                (val) => setState(() => _infrastructure = val),
                              ),
                              const SizedBox(height: 16),

                              _buildDropdown(
                                "Healthcare",
                                _healthcare,
                                ["Good", "Fair", "Poor", "None"],
                                (val) => setState(() => _healthcare = val),
                              ),
                              const SizedBox(height: 16),

                              _buildDropdown(
                                "Cost of Living",
                                _costOfLiving,
                                ["Good", "Fair", "Poor", "None"],
                                (val) => setState(() => _costOfLiving = val),
                              ),
                              const SizedBox(height: 16),

                              _buildDropdown(
                                "Galamsey Fight",
                                _galamsey,
                                ["Good", "Fair", "Poor", "None"],
                                (val) => setState(() => _galamsey = val),
                              ),
                              const SizedBox(height: 16),

                              _buildDropdown(
                                "Corruption Perception",
                                _corruption,
                                ["High", "Medium", "Low"],
                                (val) => setState(() => _corruption = val),
                              ),
                              const SizedBox(height: 24),

                              // Open-ended Questions Section
                              _buildSectionTitle(
                                "Additional Feedback, please don't leave it empty",
                              ),
                              const SizedBox(height: 16),

                              _buildTextFormField(
                                label:
                                    "What are your expectations from now till the end of this government's term?",
                                controller: TextEditingController(),
                                maxLines: 3,
                                onChanged: (val) => _expectations = val,
                              ),
                              const SizedBox(height: 16),

                              _buildTextFormField(
                                label:
                                    "Which areas should the government focus on improving?",
                                controller: TextEditingController(),
                                maxLines: 3,
                                onChanged: (val) => _improvement = val,
                              ),
                              const SizedBox(height: 32),

                              // Submit Button
                              SizedBox(
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting
                                      ? null
                                      : _submitSurvey,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Text(
                                          "Submit Survey",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
