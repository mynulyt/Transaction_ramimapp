import 'package:flutter/material.dart';

class SubmitOfferPage extends StatelessWidget {
  const SubmitOfferPage({super.key});

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
            // Operator Section
            _buildSectionHeader('Operator'),
            const SizedBox(height: 8),
            _buildOperatorGrid(),
            const SizedBox(height: 24),

            // Offer Type Section
            _buildSectionHeader('Offer Type'),
            const SizedBox(height: 8),
            _buildOfferTypeGrid(),
            const SizedBox(height: 24),

            // Internet
            _buildSectionHeader('Internet'),
            const SizedBox(height: 8),
            _buildTextField(hintText: 'Enter internet amount (e.g. 5GB)'),
            const SizedBox(height: 24),

            // Minutes
            _buildSectionHeader('Minutes'),
            const SizedBox(height: 8),
            _buildTextField(hintText: 'Enter minutes (e.g. 100)'),
            const SizedBox(height: 24),

            // SMS
            _buildSectionHeader('SMS'),
            const SizedBox(height: 8),
            _buildTextField(hintText: 'Enter SMS count (e.g. 50)'),
            const SizedBox(height: 24),

            // Term
            _buildSectionHeader('Term'),
            const SizedBox(height: 8),
            _buildTextField(hintText: 'Enter offer term (e.g. 7 days)'),
            const SizedBox(height: 32),

            // Submit Button
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: ElevatedButton(
                onPressed: () {
                  // Handle submit action
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 16,
                  ),
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
    List<String> operators = ['Robi', 'GP', 'TLK', 'BLK'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: operators.length,
      itemBuilder: (context, index) {
        return ElevatedButton(
          onPressed: () {
            // Handle operator selection
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.blue[800],
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.blue[300]!),
            ),
            elevation: 2,
          ),
          child: Text(
            operators[index],
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
        return ElevatedButton(
          onPressed: () {
            // Handle offer type selection
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.teal[800],
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.teal[300]!),
            ),
            elevation: 2,
          ),
          child: Text(
            offerTypes[index],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({required String hintText}) {
    return TextField(
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
