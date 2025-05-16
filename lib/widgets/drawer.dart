import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ramimapp/Database/Auth_services/auth_services.dart';
import 'package:ramimapp/button-pages/rechargepage.dart';
import 'package:ramimapp/login_page.dart';
import 'package:ramimapp/main.dart';

Widget buildDrawer(BuildContext context) {
  final currentUser = FirebaseAuth.instance.currentUser;

  return Drawer(
    child: FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.data!.exists) {
          return const Center(child: Text('User not found.'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final fullName = data['name'] ?? 'User Name';
        final phone = data['phone'] ?? 'N/A';

        final nameParts = fullName.split(" ");
        final initials = nameParts.length >= 2
            ? "${nameParts[0][0]}${nameParts[1][0]}"
            : fullName.substring(0, 1);

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigo),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Text(
                      initials.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    fullName,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text("Account.No: $phone",
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.live_tv),
              title: const Text('Live Recharge'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RechargePage()),
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
              onTap: () => print("Two Step clicked"),
            ),
            ListTile(
              leading: const Icon(Icons.pin),
              title: const Text('Change PIN'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final TextEditingController pinController =
                        TextEditingController();
                    return AlertDialog(
                      title: const Text('Change PIN'),
                      content: TextField(
                        controller: pinController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          labelText: 'Enter New PIN',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            String uid = FirebaseAuth.instance.currentUser!.uid;
                            String newPin = pinController.text.trim();
                            if (newPin.isEmpty) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("PIN cannot be empty")),
                              );
                              return;
                            }
                            try {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .update({'pin': newPin});
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("PIN updated successfully")),
                              );
                            } catch (e) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("Error: ${e.toString()}")),
                              );
                            }
                          },
                          child: const Text('Update'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_open),
              title: const Text('Change Password'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final TextEditingController passwordController =
                        TextEditingController();
                    return AlertDialog(
                      title: const Text('Change Password'),
                      content: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'New Password',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            String result = await AuthService()
                                .changePassword(passwordController.text.trim());
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result)),
                            );
                          },
                          child: const Text('Change'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () async {
                await AuthService().signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              onTap: () => print("Language clicked"),
            ),
            ListTile(
              leading: const Icon(Icons.send),
              title: const Text('Refer'),
              onTap: () => print("Refer clicked"),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () => print("Share clicked"),
            ),
            ListTile(
              leading: const Icon(Icons.report_problem),
              title: const Text('Complain'),
              onTap: () => print("Complain clicked"),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Helpline'),
              onTap: () => print("Helpline clicked"),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              onTap: () => print("Privacy Policy clicked"),
            ),
          ],
        );
      },
    ),
  );
}
