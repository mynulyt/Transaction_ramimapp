import 'package:flutter/material.dart';
import 'package:ramimapp/textFieldWidget.dart';
// Import custom widgets

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
            border: Border.all(color: Colors.white),
          ),
          child: Column(
            children: [
              buildTextField(Icons.person, "Name"),
              buildTextField(Icons.phone, "Mobile Number"),
              buildTextField(Icons.email, "Email"),
              buildTextField(Icons.credit_card, "National ID Card Number"),
              buildTextField(Icons.calendar_today, "Date of Birth"),
              buildTextField(Icons.lock, "Password", obscureText: true),
              buildTextField(Icons.vpn_key, "Pin", obscureText: true),
              const SizedBox(height: 10),
              buildDropdown(Icons.person_2, "Select Gender",
                  items: ["Male", "Female"]),
              const SizedBox(height: 10),
              buildDropdown(Icons.map, "Select Division",
                  items: ["Dhaka", "Chittagong", "Khulna", "Sylhet"]),
              const SizedBox(height: 10),
              buildDropdown(Icons.location_city, "Select District",
                  items: ["District 1", "District 2"]),
              const SizedBox(height: 10),
              buildDropdown(Icons.location_on, "Select Thana",
                  items: ["Thana 1", "Thana 2"]),
              const SizedBox(height: 10),
              buildDropdown(Icons.home, "Select Union",
                  items: ["Union 1", "Union 2"]),
              const SizedBox(height: 10),
              buildTextField(Icons.monetization_on, "Gold (Fee: ৳0)"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Colors.indigo),
                      ),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Text(
                        "Register New Account",
                        style: TextStyle(color: Colors.indigo, fontSize: 16),
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
