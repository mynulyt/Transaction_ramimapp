import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ramimapp/AdminPanel/Admin_panel/adminpanel_page.dart';
import 'package:ramimapp/AdminPanel/admin_auth.dart';

class AdminLoginPage extends StatelessWidget {
  AdminLoginPage({super.key});
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController UseerNameController = TextEditingController();
  TextEditingController PasswordController = TextEditingController();
  TextEditingController PinController = TextEditingController();
  TextEditingController PhoneController = TextEditingController();

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
                    const SizedBox(
                      height: 50.0,
                    ),
                    //Input user name
                    Container(
                      padding: const EdgeInsets.only(
                          left: 20.0, top: 5.0, bottom: 5.0),
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 53, 51, 51),
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: TextFormField(
                          controller: UseerNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Useer Name';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Username",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 160, 160, 147),
                            ),
                          ),
                        ),
                      ),
                    ),
                    //Input admin password
                    const SizedBox(
                      height: 40.0,
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 20.0, top: 5.0, bottom: 5.0),
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 53, 51, 51),
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: TextFormField(
                          controller: PasswordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Password';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Password",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 160, 160, 147),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                    //Input admin pin
                    Container(
                      padding: const EdgeInsets.only(
                          left: 20.0, top: 5.0, bottom: 5.0),
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 53, 51, 51),
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: TextFormField(
                          controller: PinController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Your Pin';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "PIN",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 160, 160, 147),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                    //Input phone number
                    Container(
                      padding: const EdgeInsets.only(
                          left: 20.0, top: 5.0, bottom: 5.0),
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 53, 51, 51),
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: TextFormField(
                          controller: PhoneController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Phone Number';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Phone",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 160, 160, 147),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),

                    GestureDetector(
                      onTap: () {
                        LoginAdmin(context);
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
    );
  }

  // Widget _buildTextField(IconData icon, String label, {bool obscure = false}) {
  //   return TextField(
  //     obscureText: obscure,
  //     decoration: InputDecoration(
  //       filled: true,
  //       fillColor: Colors.grey.shade200,
  //       prefixIcon: Icon(icon, color: Colors.blue[700]),
  //       labelText: label,
  //       labelStyle: const TextStyle(color: Colors.grey),
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(15),
  //         borderSide: BorderSide.none,
  //       ),
  //       contentPadding:
  //           const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  //     ),
  //   );
  // }

  LoginAdmin(context) {
    FirebaseFirestore.instance.collection("AdminPanel").get().then((snapshot) {
      for (var result in snapshot.docs) {
        if (result.data()['id'] != UseerNameController.text.trim()) {
          ScaffoldMessenger.of(context).showSnackBar((const SnackBar(
              backgroundColor: Colors.orange,
              content: Text(
                "Your id is wrong!",
                style: TextStyle(fontSize: 18.0),
              ))));
        } else if (result.data()['password'] !=
            PasswordController.text.trim()) {
          ScaffoldMessenger.of(context).showSnackBar((const SnackBar(
              backgroundColor: Colors.orange,
              content: Text(
                "Your password is wrong!",
                style: TextStyle(fontSize: 18.0),
              ))));
        } else {
          Route route =
              MaterialPageRoute(builder: (context) => const AdminPanelPage());
          Navigator.pushReplacement(context, route);
        }
      }
    });
  }
}
