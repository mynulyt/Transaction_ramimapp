import 'package:flutter/material.dart';
import 'package:ramimapp/button-pages/moneyrecharge_page.dart';

class RechargePage extends StatelessWidget {
  const RechargePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recharge")),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OperatorBox(name: "Robi", imagePath: 'images/robi.png'),
                OperatorBox(name: "Airtel", imagePath: 'images/airtel.png'),
                OperatorBox(name: "GP", imagePath: 'images/gp.png'),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OperatorBox(
                    name: "Banglalink", imagePath: 'images/banglalink.jpg'),
                OperatorBox(name: "Skitto", imagePath: 'images/skitto.png'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OperatorBox extends StatelessWidget {
  final String name;
  final String imagePath;

  const OperatorBox({Key? key, required this.name, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MoneyRechargePage(operatorName: name),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(name),
        ],
      ),
    );
  }
}
