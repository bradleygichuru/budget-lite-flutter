import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/screens/auto_import_info.dart';
import 'package:flutter_application_1/screens/setup_budget.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:watch_it/watch_it.dart';

class AutoImportAvailabilityScreen extends StatefulWidget {
  const AutoImportAvailabilityScreen({super.key});
  @override
  State<AutoImportAvailabilityScreen> createState() =>
      AutoImportAvailabilityState();
}

class AutoImportAvailabilityState extends State<AutoImportAvailabilityScreen> {
  @override
  void initState() {
    di<AuthModel>().setLastOnboardingStep('auto_import_availability');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 25, 143, 240),
      ),
      home: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade50, Colors.purple.shade50],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Center(
                      child: Icon(
                        size: 50,
                        Icons.account_circle,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),

                  Center(
                    child: Text(
                      "Transaction Auto-Import",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  Center(
                    child: Text(
                      "Availability in your region",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Card(
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.location_on),
                            title: Text(
                              'Current Availability',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Available in ${WidgetsBinding.instance.platformDispatcher.locale.countryCode} region',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color:
                                    WidgetsBinding
                                            .instance
                                            .platformDispatcher
                                            .locale
                                            .countryCode ==
                                        'KE'
                                    ? Colors.green.shade500
                                    : Colors.red.shade500,
                              ),
                            ),
                          ),
                          WidgetsBinding
                                      .instance
                                      .platformDispatcher
                                      .locale
                                      .countryCode ==
                                  'KE'
                              ? Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    'Great news! Transaction auto-import from SMS is fully supported in ${WidgetsBinding.instance.platformDispatcher.locale.countryCode}. You will be able to automatically import your transactions from supported banks.',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    'Transaction auto-import is not available in your region. However, you can still manually track your expenses and manage your budget effectively.',
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

                  WidgetsBinding
                              .instance
                              .platformDispatcher
                              .locale
                              .countryCode ==
                          'KE'
                      ? Padding(
                          padding: EdgeInsets.all(8),
                          child: Card(
                            color: Colors.white,
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    'Supported banks',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Currently supported financial institutions',
                                  ),
                                ),

                                ListTile(
                                  leading: Icon(Icons.account_balance_sharp),
                                  title: Text('M-Pesa'),
                                ),
                                ListTile(
                                  title: Text(
                                    'In progress',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Development of parsers for statements for the following financial institutions is underway',
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(Icons.account_balance_sharp),
                                  title: Text('Equity Bank'),
                                ),

                                ListTile(
                                  leading: Icon(Icons.account_balance_sharp),
                                  title: Text('NCBA'),
                                ),

                                ListTile(
                                  leading: Icon(Icons.account_balance_sharp),
                                  title: Text('ABSA'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Text(''),

                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Card(
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.timer),
                            title: Text(
                              'Expansion Plans',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'We are actively working to expand transaction auto-import to more countries. Stay tuned for updates as we roll out support for additional regions.',

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
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Center(
                      child: FilledButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll<Color>(
                            Colors.black,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WidgetsBinding
                                          .instance
                                          .platformDispatcher
                                          .locale
                                          .countryCode ==
                                      'KE'
                                  ? AutoImportInfoScreen()
                                  : SetupBudget(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Continue'),
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
