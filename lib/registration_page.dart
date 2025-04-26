import 'package:flutter/material.dart';
import 'package:ramimapp/textFieldWidget.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

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
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white)),
          child: Column(
            children: [
              buildTextField(Icons.person, "Name"),
              buildTextField(Icons.phone, "Mobile number"),
              buildTextField(Icons.email, "Email"),
              buildTextField(Icons.credit_card, "National ID Card Number"),
              buildTextField(Icons.calendar_today, "Date of Birth"),
              buildTextField(Icons.lock, "Password", obscureText: true),
              buildTextField(Icons.vpn_key, "Pin", obscureText: true),
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
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
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
            ],
          ),
        ),
      ),
    );
  }
}
