import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ramimapp/AdminPanel/Admin_panel/adminpanel_page.dart';

class AdminLoginPage extends StatelessWidget {
  AdminLoginPage({super.key});

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController UseerNameController = TextEditingController();
  final TextEditingController PinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: AppBar(
        title: const Text("Admin Login", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                const SizedBox(height: 90),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 50.0),
                      // Username
                      buildInputField(
                        controller: UseerNameController,
                        hintText: "Username",
                        errorText: "Please Enter User Name",
                      ),
                      const SizedBox(height: 40.0),
                      // PIN
                      buildInputField(
                        controller: PinController,
                        hintText: "PIN",
                        errorText: "Please Enter Your Pin",
                      ),
                      const SizedBox(height: 40.0),
                      GestureDetector(
                        onTap: () {
                          if (_formkey.currentState?.validate() ?? false) {
                            LoginAdmin(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          margin: const EdgeInsets.symmetric(horizontal: 20.0),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              "Log in",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String hintText,
    required String errorText,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, top: 5.0, bottom: 5.0),
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 53, 51, 51)),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Center(
        child: TextFormField(
          controller: controller,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return errorText;
            }
            return null;
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color.fromARGB(255, 160, 160, 147),
            ),
          ),
        ),
      ),
    );
  }

  void LoginAdmin(BuildContext context) async {
    final String inputId = UseerNameController.text.trim().toLowerCase();
    final String inputPin = PinController.text.trim();

    try {
      final DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection("AdminPanel")
          .doc(inputId)
          .get();

      if (!adminDoc.exists) {
        showSnack(context, "Your ID is wrong!");
        return;
      }

      final data = adminDoc.data() as Map<String, dynamic>;

      if (data['pin'] != inputPin) {
        showSnack(context, "Your PIN is wrong!");
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPanelPage()),
        );
      }
    } catch (e) {
      showSnack(context, "Login failed: ${e.toString()}");
    }
  }

  void showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.orange,
        content: Text(
          message,
          style: const TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}
