import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ramimapp/AdminPanel/Admin_panel/transactionhistory_page.dart';
import 'package:ramimapp/button-pages/addbalancemethod_page.dart';
import 'package:ramimapp/button-pages/adduser_page.dart';
import 'package:ramimapp/button-pages/myusermethod.dart';
import 'package:ramimapp/button-pages/offermethod_page.dart';
import 'package:ramimapp/button-pages/rechargepage.dart';
import 'package:ramimapp/button-pages/sendmoney_page.dart';
import 'package:ramimapp/button-pages/tallykhata_page.dart';
import 'package:ramimapp/button-pages/transferconfirm_page.dart';
import 'package:ramimapp/button-pages/users_my_user.dart';

import 'package:ramimapp/login_page.dart';
import 'package:ramimapp/widgets/balance_toggole.dart';
import 'package:ramimapp/widgets/drawer.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool showBalance = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
          "RamimPay",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: buildDrawer(context),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          user != null
              ? buildHomeScreen(user.uid)
              : const Center(child: Text('Please log in.')),
          const TransactionHistoryPage(),
          const TallyKhataPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Tally Khata'),
        ],
      ),
    );
  }

  Widget buildHomeScreen(String uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("No user data found."));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final double balance = _parseDouble(data['main']);
        final double advance = _parseDouble(data['advance']);
        final double due = _parseDouble(data['due']);
        final String name = data['name'] ?? 'User Name';
        final String phone = data['phone'] ?? 'Unknown';

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.indigo),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.indigo,
                    child: Text(
                      _getInitials(name),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("Account No: $phone",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 15.0, bottom: 5),
                  child: Text("Account Balance",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    BalanceToggleButton(balance: balance),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.trending_up, color: Colors.green),
                            const SizedBox(width: 5),
                            Text("Advance: ৳${advance.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.redAccent),
                            const SizedBox(width: 5),
                            Text("Due: ৳${due.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.all(10),
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                children: [
                  buildGridButton("Taka Send", Icons.send, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SendMoneyPage()));
                  }),
                  buildGridButton("Recharge", Icons.phone_android, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RechargePage()));
                  }),
                  buildGridButton("Add Balance", Icons.account_balance_wallet,
                      () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AddBalanceMethodPage()));
                  }),
                  buildGridButton("Add User", Icons.person_add, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddUserPage()));
                  }),
                  buildGridButton("My User", Icons.group, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UsersMyUser()));
                  }),
                  buildGridButton("Transfer", Icons.sync_alt, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TransferConfirmPage()));
                  }),
                  buildGridButton("Regular Offer", Icons.local_offer, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OfferMethodPage()));
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _getInitials(String name) {
    List<String> parts = name.trim().split(" ");
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    } else {
      return "U"; // Default fallback
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

Widget buildGridButton(String label, IconData icon, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.indigo.shade100,
          child: Icon(icon, size: 30, color: Colors.indigo),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}
