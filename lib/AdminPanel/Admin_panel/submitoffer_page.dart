import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ramimapp/Database/Auth_services/database_services.dart';

class SubmitOfferPage extends StatefulWidget {
  const SubmitOfferPage({super.key});

  @override
  State<SubmitOfferPage> createState() => _SubmitOfferPageState();
}

class _SubmitOfferPageState extends State<SubmitOfferPage> {
  final TextEditingController internetController = TextEditingController();
  final TextEditingController minutesController = TextEditingController();
  final TextEditingController smsController = TextEditingController();
  final TextEditingController termController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String? selectedOperator;
  String? selectedOfferType;

  final DatabaseService dbService = DatabaseService();

  void handleSubmit() async {
    if (selectedOperator == null || selectedOfferType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Operator and Offer Type")),
      );
      return;
    }

    final offerData = {
      'operator': selectedOperator!,
      'offerType': selectedOfferType!,
      'internet': internetController.text.trim(),
      'minutes': minutesController.text.trim(),
      'sms': smsController.text.trim(),
      'term': termController.text.trim(),
      'price': priceController.text.trim(),
      'submittedAt': Timestamp.now(),
    };

    try {
      await dbService.submitOffer(offerData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Offer submitted successfully!")),
      );
      internetController.clear();
      minutesController.clear();
      smsController.clear();
      termController.clear();
      priceController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Submit Offer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Operator'),
            const SizedBox(height: 8),
            _buildOperatorGrid(),
            const SizedBox(height: 24),
            _buildSectionHeader('Offer Type'),
            const SizedBox(height: 8),
            _buildOfferTypeGrid(),
            const SizedBox(height: 24),
            _buildSectionHeader('Internet'),
            const SizedBox(height: 8),
            _buildTextField(
              hintText: 'Enter internet amount (e.g. 5GB)',
              controller: internetController,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Minutes'),
            const SizedBox(height: 8),
            _buildTextField(
              hintText: 'Enter minutes (e.g. 100)',
              controller: minutesController,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('SMS'),
            const SizedBox(height: 8),
            _buildTextField(
              hintText: 'Enter SMS count (e.g. 50)',
              controller: smsController,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Term'),
            const SizedBox(height: 8),
            _buildTextField(
              hintText: 'Enter offer term (e.g. 7 days)',
              controller: termController,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Price'),
            const SizedBox(height: 8),
            _buildTextField(
              hintText: 'Enter price (e.g. 49)',
              controller: priceController,
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                onPressed: handleSubmit,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'SUBMIT OFFER',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue[800],
      ),
    );
  }

  Widget _buildOperatorGrid() {
    List<String> operators = ['Robi', 'GP', 'TLK', 'BLK', 'Airtel', 'Skitto'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // updated to 3 for better layout with more items
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2,
      ),
      itemCount: operators.length,
      itemBuilder: (context, index) {
        final operator = operators[index];
        final isSelected = selectedOperator == operator;

        return ElevatedButton(
          onPressed: () {
            setState(() {
              selectedOperator = operator;
            });
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: isSelected ? Colors.white : Colors.blue[800],
            backgroundColor: isSelected ? Colors.blue[700] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.blue[300]!),
            ),
            elevation: 2,
          ),
          child: Text(
            operator,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOfferTypeGrid() {
    List<String> offerTypes = [
      'Bundle',
      'Minutes',
      'Internet',
      'Call Rate',
      'SMS'
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2,
      ),
      itemCount: offerTypes.length,
      itemBuilder: (context, index) {
        final type = offerTypes[index];
        final isSelected = selectedOfferType == type;

        return ElevatedButton(
          onPressed: () {
            setState(() {
              selectedOfferType = type;
            });
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: isSelected ? Colors.white : Colors.teal[800],
            backgroundColor: isSelected ? Colors.teal[700] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.teal[300]!),
            ),
            elevation: 2,
          ),
          child: Text(
            type,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
      {required String hintText, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
