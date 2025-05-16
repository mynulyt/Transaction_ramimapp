import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ramimapp/Database/Auth_services/auth_services.dart';
import 'package:ramimapp/textFieldWidget.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _referenceController =
      TextEditingController(); // ✅ New controller

  String _gender = "Male";
  String _address = "Dhaka";

  final _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        String result = await _authService.signUpWithEmail(email, password);
        if (result == "success") {
          // Get UID
          String uid = FirebaseAuth.instance.currentUser!.uid;

          // Build user data map
          Map<String, dynamic> userData = {
            "name": _nameController.text.trim(),
            "phone": _phoneController.text.trim(),
            "email": email,
            "nid": _idController.text.trim(),
            "dob": _dobController.text.trim(),
            "gender": _gender,
            "address": _address,
            "pin": _pinController.text.trim(),
            "uid": uid,
            "createdAt": Timestamp.now(),
          };

          // Optional: Add reference if not empty
          String reference = _referenceController.text.trim();
          if (reference.isNotEmpty) {
            userData["reference"] = reference;
          }

          // Save user data in Firestore
          await FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .set(userData);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registration successful!")),
          );

          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error: $e"),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a New User Account"),
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
              border: Border.all(color: Colors.white),
            ),
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
                buildTextField(Icons.person_add, "Reference Code (optional)",
                    controller: _referenceController), // ✅ UI field added
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
          ),
        ),
      ),
    );
  }

  Widget buildGenderDropdown(IconData icon, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _gender,
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
