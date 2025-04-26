import 'package:flutter/material.dart';
import 'package:ramimapp/textFieldWidget.dart';

class AddUserPage extends StatelessWidget {
  const AddUserPage({super.key});

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
            buildTextField(Icons.person, "Name"),
            buildTextField(Icons.phone, "Mobile number"),
            buildTextField(Icons.email, "Email"),
            buildTextField(Icons.credit_card, "National ID Card Number"),
            buildTextField(Icons.calendar_today, "Date of Birth"),
            buildTextField(Icons.lock, "Password", obscureText: true),
            buildTextField(Icons.vpn_key, "Pin", obscureText: true),
            buildDropdown(Icons.map, "Select Division", items: []),
            buildTextField(null, "VIP(Fee: ৳.0)", enabled: false),
            buildTextField(null, "লিঙ্গ"),
            buildTextField(Icons.vpn_key, "My Pin", obscureText: true),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.green)),
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
}
