import 'package:flutter/material.dart';

Widget buildTextField(
  IconData? icon,
  String labelText, {
  bool obscureText = false,
  bool enabled = true,
  required TextEditingController controller,
}) {
  return Container(
    height: 65,
    margin: const EdgeInsets.symmetric(vertical: 6),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
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
      onChanged: (value) {},
    ),
  );
}

Widget buildAutoCompleteField({
  required IconData icon,
  required String labelText,
  required List<String> options,
  required Function(String?) onChanged,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return options.where((String option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        onChanged(selection);
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
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
        );
      },
    ),
  );
}
