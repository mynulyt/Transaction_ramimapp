import 'package:flutter/material.dart';

class ForggetPassword extends StatelessWidget {
  const ForggetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 35),
            child: Text(
              "Forgget Password",
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.indigo,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.withOpacity(0.2),
                labelStyle: const TextStyle(color: Colors.black),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.withOpacity(0.2),
                labelStyle: const TextStyle(color: Colors.black),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
