import 'package:flutter/material.dart';

Widget buildTextField(IconData? icon, String labelText,
    {bool obscureText = false,
    bool enabled = true,
    required TextEditingController controller,
    String? Function(String?)? validator}) {
  // Added validator parameter
  return Container(
    height: 65,
    margin: const EdgeInsets.symmetric(vertical: 6),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        // Changed to TextFormField
        obscureText: obscureText,
        enabled: enabled,
        controller: controller,
        validator: validator, // Validation callback
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.withOpacity(0.3),
          prefixIcon: icon != null ? Icon(icon, color: Colors.green) : null,
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.black, fontSize: 18),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ),
  );
}
