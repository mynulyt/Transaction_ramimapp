import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

class AddBalanceVerifyPage extends StatefulWidget {
  const AddBalanceVerifyPage({Key? key}) : super(key: key);

  @override
  State<AddBalanceVerifyPage> createState() => _AddBalanceVerifyPageState();
}

class _AddBalanceVerifyPageState extends State<AddBalanceVerifyPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _trxIdController = TextEditingController();
  bool _showError = false;

  // Function to handle the phone number click
  Future<void> _launchPhoneDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Padding(
        padding:
            const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// bkash logo and back button part
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 30,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Spacer(),
                        Image.asset(
                          "images/bkash_logo.png",
                          height: 60,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.pink,
                  thickness: 3,
                ),

                /// pink container part
                Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 229, 33, 131),
                  ),
                  child: Column(
                    children: [
                      /// User and amount part
                      Container(
                        height: 150,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        AssetImage('images/logo.jpg'),
                                    radius: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Ramim Pay",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    "৳500",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                              ),
                              child: const Center(
                                child: Text(
                                  "Payment failed: Incorrect Transaction Id or empty user\nTry again from back",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Form Part
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 70, vertical: 0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: TextFormField(
                                controller: _trxIdController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter Transaction Id',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                            if (_showError) ...[
                              const SizedBox(height: 6),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 30,
                                    width: 200,
                                    decoration: const BoxDecoration(
                                        color: Colors.white),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Container(
                                            height: 20,
                                            width: 20,
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Colors.yellow,
                                            ),
                                            child: Image.asset(
                                              "images/error.png",
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Center(
                                          child: const Text(
                                            'Please fill out this field.',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// Instruction Texts
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('*247# ডায়াল করে bKash App এ যান।',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                            const Text('যেখানে আপনার bKash অ্যাকাউন্ট আছে।',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                            const Text('"Send Money" এ ক্লিক করুন।',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                            const Text(
                                'প্রাপক নম্বর হিসাবে এই নম্বরটি লিখুন\n01887225454',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 10),
                            const Text('টাকা পরিমাণ: 500',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const Text(
                                'এখন প্রেরিত করার পর আপনার bKash পিন লিখুন।',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                            const Text(
                                'সবকিছু ঠিক থাকলে, আপনি bKash থেকে একটি\nকনফার্মেশন মেসেজ পাবেন।',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                            const Text(
                                'মেসেজের উপরে প্রদত্ত আপনার Transaction ID দিন\nএবং নিচের "VERIFY" বাটনে ক্লিক করুন।',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'For any query, call us at ',
                                  style: TextStyle(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                InkWell(
                                  onTap: () {
                                    _launchPhoneDialer("01795248887");
                                  },
                                  child: const Text(
                                    "01795248887",
                                    style: TextStyle(
                                        color: Colors.yellow,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.yellow),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () {
                          if (_trxIdController.text.trim().isEmpty) {
                            setState(() {
                              _showError = true;
                            });
                          } else {
                            setState(() {
                              _showError = false;
                            });
                            print("Transaction ID: ${_trxIdController.text}");
                            // Verification logic here
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: const RoundedRectangleBorder(),
                        ),
                        child: const Text(
                          'VERIFY',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
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
}
