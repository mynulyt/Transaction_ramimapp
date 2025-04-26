import 'package:flutter/material.dart';
import 'package:ramimapp/button-pages/addbalanceamount_page.dart';

class AddBalanceMethodPage extends StatefulWidget {
  const AddBalanceMethodPage({super.key});

  @override
  _AddBalanceMethodPageState createState() => _AddBalanceMethodPageState();
}

class _AddBalanceMethodPageState extends State<AddBalanceMethodPage> {
  void _onPaymentMethodSelected(String method, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBalanceAmountPage(
          paymentMethod: method,
          imagePath: imagePath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned.fill(
            top: 140,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('images/logo.jpg'),
                ),
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            width: double.infinity,
                            color: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: const Center(
                              child: Text(
                                'নরমাল পেমেন্ট',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 20,
                              childAspectRatio: 1.7,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                PaymentImage(
                                  imagePath: 'images/rocket.png',
                                  methodName: 'Rocket Personal',
                                  onTap: _onPaymentMethodSelected,
                                ),
                                PaymentImage(
                                  imagePath: 'images/nagad.jpg',
                                  methodName: 'Nagad Personal',
                                  onTap: _onPaymentMethodSelected,
                                ),
                                PaymentImage(
                                  imagePath: 'images/upay.png',
                                  methodName: 'Upay Personal',
                                  onTap: _onPaymentMethodSelected,
                                ),
                                PaymentImage(
                                  imagePath: 'images/bkash.jpg',
                                  methodName: 'Bkash Personal',
                                  onTap: _onPaymentMethodSelected,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 50),
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20)),
                            ),
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: () {},
                              icon: const Icon(Icons.ads_click),
                              label: const Text("Pay BDT",
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "© Copyright 2025. Powered by Mynul Dev",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentImage extends StatelessWidget {
  final String imagePath;
  final String methodName;
  final Function(String, String) onTap;

  const PaymentImage({
    required this.imagePath,
    required this.methodName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(methodName, imagePath),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      ),
    );
  }
}
