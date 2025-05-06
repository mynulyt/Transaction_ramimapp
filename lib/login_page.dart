import 'package:flutter/material.dart';
import 'package:ramimapp/AdminPanel/Admin_panel/admin_login_page.dart';
import 'package:ramimapp/Database/Auth_services/auth_services.dart';
import 'package:ramimapp/button-pages/adduser_page.dart';
import 'package:ramimapp/registration_page.dart';
import 'package:ramimapp/widgets/otp_verify.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const SizedBox(
                height: 100,
                width: 100,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('images/logo.jpg'),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.5))),
                child: Column(
                  children: [
                    _buildTextField(Icons.phone, "Mobile number",
                        controller: phoneController),
                    SizedBox(
                      height: 20,
                    ),
                    _buildTextField(Icons.password, "Enter password",
                        controller: passwordController, obscure: true),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 390,
                      child: OutlinedButton(
                        onPressed: () {
                          String phone = phoneController.text.trim();
                          if (phone.isEmpty || phone.length != 11) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Enter a valid 11-digit number")),
                            );
                            return;
                          }
                          String fullPhone = '+88$phone'; // Bangladesh code
                          AuthService().verifyPhone(
                            phoneNumber: fullPhone,
                            codeSent: (verificationId) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OtpVerifyPage(
                                      verificationId: verificationId),
                                ),
                              );
                            },
                            verificationCompleted: (uid, _) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Logged in successfully!")),
                              );
                            },
                            onError: (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        e.message ?? "Verification failed")),
                              );
                            },
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          side: const BorderSide(color: Colors.indigo),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.indigo, fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 390,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegistrationPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                        ),
                        child: const Text(
                          "Registration Now",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 3),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(color: Colors.indigo, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "By logging in, you agree to our ",
                            style: TextStyle(fontSize: 13, color: Colors.red),
                          ),
                          TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.indigo,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SocialIcon(icon: Icons.call_end, label: "Whatsapp"),
                    _SocialIcon(icon: Icons.send, label: "Telegram"),
                    _SocialIcon(icon: Icons.facebook, label: "Facebook"),
                    _SocialIcon(icon: Icons.call, label: "Helpline"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 180,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminLoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                  ),
                  child: const Text(
                    "Admin Panel",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String label,
      {bool obscure = false, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade200,
        prefixIcon: Icon(icon, color: Colors.indigo),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SocialIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.indigo,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
