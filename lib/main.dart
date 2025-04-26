import 'package:flutter/material.dart';
import 'package:ramimapp/AdminPanel/admin_login.dart';
import 'package:ramimapp/button-pages/addbalancemethod_page.dart';
import 'package:ramimapp/button-pages/adduser_page.dart';
import 'package:ramimapp/button-pages/myusermethod.dart';
import 'package:ramimapp/button-pages/offermethod_page.dart';
import 'package:ramimapp/button-pages/rechargepage.dart';
import 'package:ramimapp/button-pages/sendmoney_page.dart';
import 'package:ramimapp/button-pages/tallykhata_page.dart';
import 'package:ramimapp/button-pages/transfermethod_page.dart';
import 'package:ramimapp/login_page.dart';
import 'package:ramimapp/widgets/drawer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RamimPay',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: LoginPage(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool showBalance = false;
  double balance = 1234.56;

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TallyKhataPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RamimPay"),
      ),
      drawer: buildDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          buildHomeScreen(),
          Center(child: Text("History Screen")),
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

  Widget buildHomeScreen() {
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
              CircleAvatar(radius: 30, backgroundColor: Colors.indigo),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Name",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("Gold",
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showBalance = !showBalance;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 40),
                    backgroundColor: Colors.indigo,
                  ),
                  child: Text(
                    showBalance
                        ? "\$${balance.toStringAsFixed(2)}"
                        : "Tap to\nShow Balance",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(value: false, onChanged: (_) {}),
                        const Text("Advance", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(value: false, onChanged: (_) {}),
                        const Text("Due", style: TextStyle(fontSize: 14)),
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SendMoneyPage()));
              }),
              buildGridButton("Recharge", Icons.phone_android, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RechargePage()));
              }),
              buildGridButton("Add Balance", Icons.account_balance_wallet, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddBalanceMethodPage()));
              }),
              buildGridButton("Add User", Icons.person_add, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddUserPage()));
              }),
              buildGridButton("My User", Icons.group, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyUserMethod()));
              }),
              buildGridButton("Transfer", Icons.sync_alt, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TransferMethodPage()));
              }),
              buildGridButton("Regular Offer", Icons.local_offer, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => OfferMethodPage()));
              }),
            ],
          ),
        ),
      ],
    );
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
}
