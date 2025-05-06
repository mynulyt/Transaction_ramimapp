import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ramimapp/textFieldWidget.dart'; // Ensure updated buildTextField is used

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  String _gender = "Male";
  String _address = "Dhaka";

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = userCredential.user;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'email': _emailController.text.trim(),
            'national_id': _idController.text.trim(),
            'dob': _dobController.text.trim(),
            'gender': _gender,
            'address': _address,
            'pin': _pinController.text.trim(),
            'uid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );

          Navigator.pushReplacementNamed(context, '/login');
        }
      } on FirebaseAuthException catch (e) {
        String message = "An error occurred";
        if (e.code == 'email-already-in-use') {
          message = 'This email is already registered';
        } else if (e.code == 'weak-password') {
          message = 'Password should be at least 6 characters';
        } else if (e.code == 'invalid-email') {
          message = 'Invalid email format';
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register a New Account"),
        backgroundColor: Colors.green,
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
            ),
            child: Column(
              children: [
                buildTextField(Icons.person, "Name",
                    controller: _nameController, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                }),
                buildTextField(Icons.phone, "Mobile number",
                    controller: _phoneController, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mobile number is required';
                  }
                  return null;
                }),
                buildTextField(Icons.email, "Email",
                    controller: _emailController, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                }),
                buildTextField(Icons.credit_card, "National ID",
                    controller: _idController, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ID is required';
                  }
                  return null;
                }),
                buildTextField(Icons.calendar_today, "Date of Birth",
                    controller: _dobController, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'DOB is required';
                  }
                  return null;
                }),
                buildTextField(Icons.lock, "Password",
                    controller: _passwordController,
                    obscureText: true, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                }),
                buildTextField(Icons.vpn_key, "Pin",
                    controller: _pinController,
                    obscureText: true, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pin is required';
                  }
                  return null;
                }),
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
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                  ),
                  child: const Text("Register",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildGenderDropdown(IconData person, String s) {}

  buildAutoCompleteField(
      {required IconData icon,
      required String labelText,
      required List<String> options,
      required Null Function(dynamic value) onChanged}) {}
}
