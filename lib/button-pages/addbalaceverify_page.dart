import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AddBalanceVerifyPage extends StatefulWidget {
  final String method; // e.g., "bKash", "Nagad", etc.
  final String amount; // Amount passed from previous page

  const AddBalanceVerifyPage({
    super.key,
    required this.method,
    required this.amount,
  });

  @override
  State<AddBalanceVerifyPage> createState() => _AddBalanceVerifyPageState();
}

class _AddBalanceVerifyPageState extends State<AddBalanceVerifyPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _trxIdController = TextEditingController();
  final TextEditingController _senderNumberController = TextEditingController();
  bool _showError = false;

  Future<void> _launchPhoneDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  String getLogoPath() {
    switch (widget.method.toLowerCase()) {
      case 'nagad':
        return 'images/nagad_logo.png';
      case 'rocket':
        return 'images/rocket_logo.png';
      case 'upay':
        return 'images/upay_logo.png';
      default:
        return 'images/bkash_logo.png';
    }
  }

  String getReceiverNumber() {
    switch (widget.method.toLowerCase()) {
      case 'nagad':
        return '01888888888';
      case 'rocket':
        return '01777777777';
      case 'upay':
        return '01666666666';
      default:
        return '01887225454';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// Header with back and logo
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          size: 30, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              /// Info card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage: AssetImage('images/logo.jpg'),
                          radius: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${widget.method} Pay",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          "৳${widget.amount}",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Make sure the transaction is successful.\nIncorrect or empty information will fail the request.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildInputField(_trxIdController, "Enter Transaction ID"),
                    const SizedBox(height: 10),
                    buildInputField(
                        _senderNumberController, "Enter Sender Number"),
                    if (_showError)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Please fill all fields correctly!',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Instructions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Go to ${widget.method} App and send money.'),
                    Text(
                      'Receiver Number: ${getReceiverNumber()}',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Amount: ৳${widget.amount}'),
                    const Text('Enter the Transaction ID & your number.'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'For any query, call us at ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        InkWell(
                          onTap: () => _launchPhoneDialer("01795248887"),
                          child: const Text(
                            "01795248887",
                            style: TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// Verify Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_trxIdController.text.trim().isEmpty ||
                        _senderNumberController.text.trim().isEmpty) {
                      setState(() => _showError = true);
                    } else {
                      setState(() => _showError = false);

                      /// ✅ Handle verification logic
                      print("Method: ${widget.method}");
                      print("Amount: ${widget.amount}");
                      print("Transaction ID: ${_trxIdController.text}");
                      print("Sender Number: ${_senderNumberController.text}");

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Submitted for verification")),
                      );

                      // TODO: Save to database or call API
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'VERIFY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField(TextEditingController controller, String hint) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
        ),
      ),
    );
  }
}
