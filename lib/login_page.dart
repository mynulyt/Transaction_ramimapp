import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import for launching phone/URLs
import 'package:ramimapp/AdminPanel/Admin_panel/admin_login_page.dart';
import 'package:ramimapp/Database/Auth_services/auth_services.dart';
import 'package:ramimapp/button-pages/Forgget_pass.dart';
import 'package:ramimapp/main.dart';
import 'package:ramimapp/registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailController.text = AuthService.lastUsedEmail ?? "";
  }

  void _loginWithEmail() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final result = await AuthService().signInWithEmail(email, password);

    if (result == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      String errorMessage;

      if (result.toLowerCase().contains('wrong-password')) {
        errorMessage = "Wrong password";
      } else if (result.toLowerCase().contains('user-not-found')) {
        errorMessage = "User not found";
      } else if (result.toLowerCase().contains('invalid-email')) {
        errorMessage = "Invalid email";
      } else {
        errorMessage = "Wrong Password ! Please Try Again";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.red),
          ),
        )),
      );
    }
  }

  // Helper method to launch URLs
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not launch URL")),
      );
    }
  }

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
                    _buildTextField(Icons.email, "Email",
                        controller: emailController),
                    const SizedBox(height: 20),
                    _buildTextField(Icons.lock, "Enter password",
                        controller: passwordController, obscure: true),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _loginWithEmail,
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
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegistrationPage()),
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
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ForggetPassword()));
                      },
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SocialIcon(
                      icon: Icons.call_end,
                      label: "Whatsapp",
                      onTap: () {
                        // Open WhatsApp chat with number
                        _launchUrl("https://wa.me/01883834205");
                      },
                    ),
                    _SocialIcon(
                      icon: Icons.send,
                      label: "Telegram",
                      onTap: () {
                        // Open Telegram chat with number (Telegram username required ideally, fallback to phone dial)
                        _launchUrl(
                            "tg://resolve?domain=01883834205"); // may not work, alternative is dialer
                        // If doesn't work, fallback to dial
                        // _launchUrl("tel:01883834205");
                      },
                    ),
                    _SocialIcon(
                      icon: Icons.facebook,
                      label: "Facebook",
                      onTap: () {
                        // Facebook profile/page URL or dial number
                        _launchUrl("https://www.facebook.com/01883834205");
                      },
                    ),
                    _SocialIcon(
                      icon: Icons.call,
                      label: "Helpline",
                      onTap: () {
                        // Dial the helpline number
                        _launchUrl("tel:01883834205");
                      },
                    ),
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
                      MaterialPageRoute(builder: (context) => AdminLoginPage()),
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
      keyboardType: label.contains("Email")
          ? TextInputType.emailAddress
          : TextInputType.text,
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
  final VoidCallback? onTap;

  const _SocialIcon({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.indigo,
              radius: 24,
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
