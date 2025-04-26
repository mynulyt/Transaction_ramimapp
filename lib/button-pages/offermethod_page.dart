import 'package:flutter/material.dart';
import 'package:ramimapp/button-pages/regularoffer_page.dart';

class OfferMethodPage extends StatelessWidget {
  const OfferMethodPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color:Colors.grey.withOpacity(0.1), // Full page background color
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

              Divider(thickness: 10,),


             
             Container(
              decoration: BoxDecoration(
                color: Colors.white
              ),
               child: Padding(
                 padding: const EdgeInsets.only(top: 20),
                 child: Column(
                  children: [
                     Row(
                    
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      OperatorBox(name: "Robi", imagePath: 'images/robi.png'),
                      OperatorBox(name: "Airtel", imagePath: 'images/airtel.png'),
                      OperatorBox(name: "GP", imagePath: 'images/gp.png'),
                    ],
                  ),
                 
                  const SizedBox(height: 20),
                 
                  // Second row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      OperatorBox(name: "Banglalink", imagePath: 'images/banglalink.jpg'),
                      OperatorBox(name: "Skitto", imagePath: 'images/skitto.png'),
                    ],
                  ),
                  SizedBox(height: 40,)
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

  const OperatorBox({Key? key, required this.name, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegularofferPage(operatorName: name),
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
