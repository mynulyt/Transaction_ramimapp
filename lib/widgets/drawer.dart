import 'package:flutter/material.dart';
import 'package:ramimapp/button-pages/sendmoney_page.dart';

import 'package:ramimapp/main.dart';

void main() {
  runApp(const MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  final String firstName = "John";
  final String lastName = "Doe";

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawer Example'),
      ),
      drawer: buildDrawer(firstName, lastName, context),
      body: const Center(
        child: Text('Home Page Content'),
      ),
    );
  }
}

Widget buildDrawer(String firstName, String lastName, BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: Colors.indigo),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile avatar
              CircleAvatar(
                radius: 35, // Increased size
                backgroundColor: Colors.white,
                child: Text(
                  '${firstName[0]}${lastName[0]}', // First letter of first and last name
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "$firstName $lastName", // Displaying full name
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const Text("Account.No:",
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.live_tv),
          title: const Text('Live Recharge'),
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SendMoneyPage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notification'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('Two Step'),
          onTap: () {
            // Handle Two Step click
            print("Two Step clicked");
          },
        ),
        ListTile(
          leading: const Icon(Icons.pin),
          title: const Text('Change PIN'),
          onTap: () {
            // Handle Change PIN click
            print("Change PIN clicked");
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock_open),
          title: const Text('Change Password'),
          onTap: () {
            // Handle Change Password click
            print("Change Password clicked");
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Log Out'),
          onTap: () {
            // Handle Log Out click
            print("Log Out clicked");
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          onTap: () {
            // Handle Language click
            print("Language clicked");
          },
        ),
        ListTile(
          leading: const Icon(Icons.send),
          title: const Text('Refer'),
          onTap: () {
            // Handle Refer click
            print("Refer clicked");
          },
        ),
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('Share'),
          onTap: () {
            // Handle Share click
            print("Share clicked");
          },
        ),
        ListTile(
          leading: const Icon(Icons.report_problem),
          title: const Text('Complain'),
          onTap: () {
            // Handle Complain click
            print("Complain clicked");
          },
        ),
        ListTile(
          leading: const Icon(Icons.phone),
          title: const Text('Helpline'),
          onTap: () {
            // Handle Helpline click
            print("Helpline clicked");
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Privacy Policy'),
          onTap: () {
            // Handle Privacy Policy click
            print("Privacy Policy clicked");
          },
        ),
      ],
    ),
  );
}
