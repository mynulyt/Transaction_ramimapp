import 'package:flutter/material.dart';

Widget buildDrawer() {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: const [
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.indigo),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.account_circle, size: 50, color: Colors.white),
              SizedBox(height: 10),
              Text("Mobile Number", style: TextStyle(color: Colors.white)),
              Text("Account.No:", style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        ListTile(leading: Icon(Icons.home), title: Text('Home')),
        ListTile(leading: Icon(Icons.live_tv), title: Text('Live Recharge')),
        ListTile(
            leading: Icon(Icons.card_membership), title: Text('Membership')),
        ListTile(
            leading: Icon(Icons.notifications), title: Text('Notification')),
        ListTile(leading: Icon(Icons.devices), title: Text('My Device')),
        ListTile(leading: Icon(Icons.lock), title: Text('Device Lock')),
        ListTile(leading: Icon(Icons.security), title: Text('Two Step')),
        ListTile(leading: Icon(Icons.vpn_key), title: Text('API Key')),
        ListTile(leading: Icon(Icons.pin), title: Text('Change PIN')),
        ListTile(
            leading: Icon(Icons.lock_open), title: Text('Change Password')),
        ListTile(leading: Icon(Icons.logout), title: Text('Log Out')),
        Divider(),
        ListTile(leading: Icon(Icons.language), title: Text('Language')),
        ListTile(leading: Icon(Icons.send), title: Text('Refer')),
        ListTile(leading: Icon(Icons.share), title: Text('Share')),
        ListTile(leading: Icon(Icons.report_problem), title: Text('Complain')),
        ListTile(leading: Icon(Icons.phone), title: Text('Helpline')),
        ListTile(
            leading: Icon(Icons.privacy_tip), title: Text('Privacy Policy')),
      ],
    ),
  );
}
