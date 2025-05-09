import 'package:flutter/material.dart';
import 'package:ramimapp/AdminPanel/Admin_panel/regularoffer_page_delete.dart';
import 'package:ramimapp/button-pages/regularoffer_page.dart';

class OfferMethodPage extends StatelessWidget {
  const OfferMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey.withOpacity(0.1),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: const Center(
                  child: Text(
                    ' Operator',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Divider(
                thickness: 10,
              ),
              Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OperatorBox(
                              name: "Robi", imagePath: 'images/robi.png'),
                          OperatorBox(
                              name: "Airtel", imagePath: 'images/airtel.png'),
                          OperatorBox(name: "GP", imagePath: 'images/gp.png'),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OperatorBox(
                              name: "Banglalink",
                              imagePath: 'images/banglalink.jpg'),
                          OperatorBox(
                              name: "Skitto", imagePath: 'images/skitto.png'),
                        ],
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OperatorBox extends StatelessWidget {
  final String name;
  final String imagePath;

  const OperatorBox({super.key, required this.name, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegularofferBuyPage(
              operatorName: name,
              operatorImagePath: imagePath,
            ),
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
              color: Colors.white,
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
