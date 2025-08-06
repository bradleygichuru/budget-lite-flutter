import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/sms_perms_request.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:watch_it/watch_it.dart';

class AutoImportInfoScreen extends StatefulWidget {
  const AutoImportInfoScreen({super.key});
  @override
  AutoImportInfoScreenState createState() => AutoImportInfoScreenState();
}

class AutoImportInfoScreenState extends State<AutoImportInfoScreen> {
  @override
  void initState() {
    di<AuthModel>().setLastOnboardingStep('auto_import_info');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 25, 143, 240),
      ),
      home: SafeArea(
        child: Scaffold(
          body: Container(
            padding: const EdgeInsets.all(8),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Center(
                      child: Icon(
                        size: 50,
                        Icons.chat,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                  Center(
                    child: const Text(
                      "Auto-Import Transactions",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: const Text(
                        "BudgetLite automatically imports your transactions from SMS notifications",
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: Icon(
                        Icons.bolt,
                        size: 30,
                        color: Color(0xFFA3E635),
                      ),
                      title: Text(
                        'Zero Manual Entry',
                        style: TextStyle(
                          color: Colors.grey.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Automatically capture M-Pesa and bank transaction SMS messages',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Center(
                      child: ListTile(
                        leading: Icon(
                          Icons.shield,
                          color: Color(0xFF1E88E5),
                          size: 30,
                        ),
                        title: Text(
                          'Secure & Private',
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'SMS data is processed locally on your device and encrypted',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Center(
                      child: ListTile(
                        leading: Icon(Icons.bolt, size: 30),
                        title: Text(
                          'Smart Categorization',
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Automatically categorize transactions',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Card(
                      child: Column(
                        children: [
                          ListTile(title: Text('How it works:')),
                          ListTile(
                            leading: Text(
                              '1.',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            title: Text(
                              'Grant SMS reading permission',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Text(
                              '2.',

                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            title: Text(
                              'BudgetLite scans for bank/M-Pesa messages',

                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Text(
                              '3.',

                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            title: Text(
                              'Transactions are automatically imported',

                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Text(
                              '4.',

                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),

                            title: Text(
                              'Smart categorization keeps your budget updated',

                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Center(
                      child: FilledButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll<Color>(
                            Color(0xFF2563EB),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SmsPermsRequest(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Enable Auto-Import'),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: const Icon(Icons.arrow_right_alt),
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
