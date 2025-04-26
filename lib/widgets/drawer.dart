import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  final String firstName = "John";
  final String lastName = "Doe";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drawer Example'),
      ),
      drawer: buildDrawer(firstName, lastName),
      body: Center(
        child: Text('Home Page Content'),
      ),
    );
  }
}

Widget buildDrawer(String firstName, String lastName) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.indigo),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile avatar
              CircleAvatar(
                radius: 35, // Increased size
                backgroundColor: Colors.white,
                child: Text(
                  '${firstName[0]}${lastName[0]}', // First letter of first and last name
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "$firstName $lastName", // Displaying full name
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text("Account.No:", style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Home'),
          onTap: () {
            // Handle Home click
            print("Home clicked");
          },
        ),
        ListTile(
          leading: Icon(Icons.live_tv),
          title: Text('Live Recharge'),
          onTap: () {
            // Handle Live Recharge click
            print("Live Recharge clicked");
          },
        ),
        ListTile(
          leading: Icon(Icons.notifications),
          title: Text('Notification'),
          onTap: () {
            // Handle Notification click
            print("Notification clicked");
          },
        ),
        ListTile(
          leading: Icon(Icons.security),
          title: Text('Two Step'),
          onTap: () {
            // Handle Two Step click
            print("Two Step clicked");
          },
        ),
        ListTile(
          leading: Icon(Icons.pin),
          title: Text('Change PIN'),
          onTap: () {
            // Handle Change PIN click
            print("Change PIN clicked");
          },
        ),
        ListTile(
          leading: Icon(Icons.lock_open),
          title: Text('Change Password'),
          onTap: () {
            // Handle Change Password click
            print("Change Password clicked");
          },
        ),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('Log Out'),
          onTap: () {
            // Handle Log Out click
            print("Log Out clicked");
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.language),
          title: Text('Language'),
          onTap: () {
            // Handle Language click
            print("Language clicked");
          },
        ),
        ListTile(
          leading: Icon(Icons.send),
          title: Text('Refer'),
          onTap: () {
            // Handle Refer click
            print("Refer clicked");
          },
        ),
        ListTile(
          leading: Icon(Icons.share),
          title: Text('Share'),
          onTap: () {
            // Handle Share click
            print("Share clicked");
          },
        ),
        ListTile(
          leading: Icon(Icons.report_problem),
          title: Text('Complain'),
          onTap: () {
            // Handle Complain click
            print("Complain clicked");
          },
        ),
        ListTile(
          leading: Icon(Icons.phone),
          title: Text('Helpline'),
          onTap: () {
            // Handle Helpline click
            print("Helpline clicked");
          },
        ),
        ListTile(
          leading: Icon(Icons.privacy_tip),
          title: Text('Privacy Policy'),
          onTap: () {
            // Handle Privacy Policy click
            print("Privacy Policy clicked");
          },
        ),
      ],
    ),
  );
}
