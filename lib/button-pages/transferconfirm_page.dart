import 'package:flutter/material.dart';
import 'package:ramimapp/textFieldWidget.dart';

class TransferConfirmPage extends StatelessWidget {
  TransferConfirmPage({super.key});

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController mainController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transfer"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildTextField(Icons.phone, "01936......",
                controller: phoneController),
            buildTextField(Icons.person_2, "Name", controller: nameController),
            buildTextField(Icons.money, "Amount", controller: amountController),
            buildTextField(Icons.home, "Main", controller: mainController),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              keyboardType: TextInputType.multiline,
              textAlign: TextAlign.start,
              maxLines: 6,
              minLines: 4,
              decoration: InputDecoration(
                hintText: "Description",
                filled: true,
                fillColor: Colors.grey.withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 20.0),
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            buildTextField(Icons.key, "Enter Pin Code",
                obscureText: true, controller: pinController),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Add your transfer logic here
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.indigo),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    child:
                        Text("Confirm", style: TextStyle(color: Colors.indigo)),
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
