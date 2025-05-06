import 'package:flutter/material.dart';
import 'package:ramimapp/textFieldWidget.dart';

class AddUserPage extends StatelessWidget {
  const AddUserPage({super.key});

  // Controllers for all text fields
  static final TextEditingController nameController = TextEditingController();
  static final TextEditingController mobileController = TextEditingController();
  static final TextEditingController emailController = TextEditingController();
  static final TextEditingController nidController = TextEditingController();
  static final TextEditingController dobController = TextEditingController();
  static final TextEditingController passwordController =
      TextEditingController();
  static final TextEditingController pinController = TextEditingController();
  static final TextEditingController myPinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add user"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildTextField(Icons.person, "Name", controller: nameController),
            buildTextField(Icons.phone, "Mobile number",
                controller: mobileController),
            buildTextField(Icons.email, "Email", controller: emailController),
            buildTextField(Icons.credit_card, "National ID Card Number",
                controller: nidController),
            buildTextField(Icons.calendar_today, "Date of Birth",
                controller: dobController),
            buildTextField(Icons.lock, "Password",
                obscureText: true, controller: passwordController),
            buildTextField(Icons.vpn_key, "Pin",
                obscureText: true, controller: pinController),
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
              onChanged: (value) {},
            ),
            buildTextField(Icons.vpn_key, "My Pin",
                obscureText: true, controller: myPinController),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // You can collect all data here using controllers
                    // Example: print(nameController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    child: Text(
                      "Add user",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
