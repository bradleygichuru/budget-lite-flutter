import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/auto_import_info.dart';

class SelectRegion extends StatefulWidget {
  const SelectRegion({super.key});
  @override
  State<SelectRegion> createState() => SelectRegionState();
}

class SelectRegionState extends State<SelectRegion> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 25, 143, 240),
      ),
      home: SafeArea(
        child: Scaffold(
          body: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEFF6FF), Color(0xFFF3E8FF)],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Center(
                      child: Icon(
                        size: 50,
                        Icons.chat_bubble,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  Center(
                    child: const Text(
                      "Select Your Country",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  Center(
                    child: const Text(
                      "Choose your country to customize your experience",
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    child: Center(
                      child: FilledButton(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll<Color>(
                            Colors.white,
                          ),
                        ),
                        onPressed: () {
                          // Navigate back to first route when tapped.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AutoImportInfoScreen(),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Kenya  🇰🇪',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    child: Center(
                      child: FilledButton(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll<Color>(
                            Colors.white,
                          ),
                        ),
                        onPressed: () {
                          // Navigate back to first route when tapped.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AutoImportInfoScreen(),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Other  🌍',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
