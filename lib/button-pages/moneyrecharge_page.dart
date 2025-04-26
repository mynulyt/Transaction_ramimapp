import 'package:flutter/material.dart';

class MoneyRechargePage extends StatefulWidget {
  final String operatorName;

  const MoneyRechargePage({Key? key, required this.operatorName})
      : super(key: key);

  @override
  _MoneyRechargePageState createState() => _MoneyRechargePageState();
}

class _MoneyRechargePageState extends State<MoneyRechargePage> {
  final TextEditingController numberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.operatorName} Recharge"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 70.0, left: 16.0, right: 16.0),
        child: Column(
          children: [
            TextField(
              controller: numberController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "Enter your ${widget.operatorName} number",
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "Amount",
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              keyboardType: TextInputType.multiline,
              textAlign: TextAlign.center,
              maxLines: 6,
              minLines: 4,
              decoration: InputDecoration(
                hintText: "Description",
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // You can handle recharge logic here
              },
              child: Text("Confirm"),
            ),
          ],
        ),
      ),
    );
  }
}
