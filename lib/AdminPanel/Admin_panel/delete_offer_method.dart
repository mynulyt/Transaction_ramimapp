import 'package:flutter/material.dart';
import 'package:ramimapp/AdminPanel/Admin_panel/regularoffer_page_delete.dart';
import 'package:ramimapp/Database/Auth_services/database_services.dart';

class DeleteOfferMethod extends StatefulWidget {
  const DeleteOfferMethod(
      {super.key, required operatorName, required operatorImagePath});

  @override
  State<DeleteOfferMethod> createState() => _DeleteOfferMethodState();
}

class _DeleteOfferMethodState extends State<DeleteOfferMethod> {
  List<Map<String, String>> operators = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadOperators();
  }

  Future<void> loadOperators() async {
    try {
      final data = await DatabaseService().fetchUniqueOperators();
      setState(() {
        operators = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error loading operators: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey.withOpacity(0.1),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                    const Divider(thickness: 10),
                    Container(
                      decoration: const BoxDecoration(color: Colors.white),
                      padding: const EdgeInsets.only(top: 20, bottom: 40),
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: operators
                            .map((op) => OperatorBox(
                                  name: op['name']!,
                                  imagePath: op['image']!,
                                ))
                            .toList(),
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
            builder: (context) => RegularofferDeletePage(
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
