import 'package:flutter/material.dart';

Widget buildTextField(IconData? icon, String labelText,
    {bool obscureText = false, bool enabled = true}) {
  return Container(
    height: 65,
    margin: const EdgeInsets.symmetric(vertical: 5),
    child: TextField(
      obscureText: obscureText,
      enabled: enabled,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.withOpacity(0.2),
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
  );
}

Widget buildDropdown(IconData icon, String labelText,
    {required List<String> items}) {
  return DropdownButtonFormField<String>(
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.grey.withOpacity(0.2),
      prefixIcon: Icon(icon, color: Colors.green),
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.black),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),
    items: items
        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
        .toList(),
    onChanged: (value) {},
  );
}
