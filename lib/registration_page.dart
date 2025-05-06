import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ramimapp/Database/Auth_services/auth_services.dart';
import 'package:ramimapp/textFieldWidget.dart'; // Make sure this is correctly imported.

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService(); // <-- ADD THIS LINE

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  // ... rest of your code

  String _gender = "Male";
  String _address = "Dhaka";
  String? _verificationId;
  bool _isCodeSent = false;

  final _formKey = GlobalKey<FormState>();

  // Replace this method to use AuthService's phone verification
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Send the phone number for verification
        await _authService.verifyPhone(
          phoneNumber: "+880${_phoneController.text}",
          codeSent: (String verificationId) {
            setState(() {
              _verificationId = verificationId;
              _isCodeSent = true;
            });
          },
          verificationCompleted: (String userId, int? resendToken) {
            // If verification completed successfully, navigate to the next screen
            Navigator.pushReplacementNamed(context, '/home');
          },
          onError: (FirebaseAuthException error) {
            // Handle errors
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Error: ${error.message}"),
            ));
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register a New Account"),
        backgroundColor: Colors.green,
        toolbarHeight: 70,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white)),
            child: Column(
              children: [
                buildTextField(Icons.person, "Name",
                    controller: _nameController),
                buildTextField(Icons.phone, "Mobile number",
                    controller: _phoneController),
                buildTextField(Icons.email, "Email",
                    controller: _emailController),
                buildTextField(Icons.credit_card, "National ID Card Number",
                    controller: _idController),
                buildTextField(Icons.calendar_today, "Date of Birth",
                    controller: _dobController),
                buildTextField(Icons.lock, "Password",
                    obscureText: true, controller: _passwordController),
                buildTextField(Icons.vpn_key, "Pin",
                    obscureText: true, controller: _pinController),
                buildGenderDropdown(Icons.person, "Select Gender"),
                buildAutoCompleteField(
                  icon: Icons.map,
                  labelText: "Select Address",
                  options: [
                    'Dhaka',
                    'Chittagong',
                    'Khulna',
                    'Sylhet',
                    'Barisal',
                    'Rajshahi',
                    'Rangpur',
                    'Mymensingh'
                  ],
                  onChanged: (value) {
                    setState(() {
                      _address = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.indigo),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "Register a New Account",
                          style: TextStyle(color: Colors.indigo),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_isCodeSent) ...[
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Enter OTP',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (otp) {
                      // handle OTP input
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Handle OTP submission
                      if (_verificationId != null) {
                        await _authService.signInWithOtp(
                            _verificationId!, 'otp_value');
                      }
                    },
                    child: Text('Verify OTP'),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGenderDropdown(IconData icon, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.withOpacity(0.2),
          prefixIcon: Icon(icon, color: Colors.green),
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.black),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        items: const [
          DropdownMenuItem(value: "Male", child: Text("Male")),
          DropdownMenuItem(value: "Female", child: Text("Female")),
        ],
        onChanged: (value) {
          setState(() {
            _gender = value!;
          });
        },
      ),
    );
  }
}
