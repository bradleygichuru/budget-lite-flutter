import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({super.key});
  @override
  TermsAndConditionsState createState() => TermsAndConditionsState();
}

class TermsAndConditionsState extends State<TermsAndConditions> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.all(7),
                      child: Icon(Icons.article_outlined, size: 40),
                    ),

                    Padding(
                      padding: EdgeInsetsGeometry.all(7),
                      child: Text(
                        'BudgetLite Terms and Conditions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.all(7),
                      child: Text(
                        'Please review our terms before creating your account',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 300,
                      child: Card.outlined(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsetsGeometry.all(5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsetsGeometry.all(4),
                                  child: Text(
                                    "Welcome to BudgetLite! We're here to make budgeting effortless for Kenyans. These terms explain how our service works and your rights when using our app.",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsGeometry.all(4),
                                  child: ListTile(
                                    isThreeLine: true,
                                    title: Text(
                                      '1. What BudgetLite Does',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "BudgetLite automatically reads your M-Pesa and bank SMS alerts to track your spending and help you budget better. No more manual entry - we handle the boring stuff so you can focus on your financial goals.",
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsGeometry.all(4),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          '2. Your SMS Data - We Take This Seriously',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                          'What We Access:',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        subtitle: Column(
                                          children: [
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "SMS messages from M-Pesa (21329)",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "SMS alerts from your bank(s)",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Only transaction-related messages (we ignore personal texts, OTPs, etc.)",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      ListTile(
                                        title: Text(
                                          'What We Do With It:',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        subtitle: Column(
                                          children: [
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Extract transaction amounts, dates, and merchant names",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Categorize your spending automatically",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Create budgets and spending insights",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: RichText(
                                                text: TextSpan(
                                                  style: DefaultTextStyle.of(
                                                    context,
                                                  ).style,
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          "We NEVER store your actual SMS content",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          " - only the financial data we extract",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                          "What We DON'T Do:",
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        subtitle: Column(
                                          children: [
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Read your personal messages",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Categorize your spending automatically",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Share your transaction data with third parties (except anonymous analytics)",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Send messages from your phone",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Store your PIN numbers or passwords",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsGeometry.all(4),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          '3. Data Protection & Privacy',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                          'Your Data Security:',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        subtitle: Column(
                                          children: [
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "All your transaction data stays on YOUR device - we don't store it on our servers",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Your financial information never leaves your phone",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Only anonymous usage patterns are sent to our servers (no personal data)",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "App data is protected by your phone's security (screen lock, encryption)",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "We comply with Kenya Data Protection Act requirements",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                          "What's Stored Where:",
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ),

                                      ListTile(
                                        title: Text(
                                          "On Your Device (Private):",
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        subtitle: Column(
                                          children: [
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "All your transaction history",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Personal budgets and categories",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Spending patterns and insights",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Account balances and financial data",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                          "On Our Servers (Secure):",
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        subtitle: Column(
                                          children: [
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "User authentication data (email, phone number, encrypted password)",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Account creation date and basic profile information",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "App usage statistics (no personal transaction info)",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "General feature usage patterns",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Anonymous spending trends for service improvement",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsGeometry.all(4),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          '4. What You Need to Do',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                          'Requirements:',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        subtitle: Column(
                                          children: [
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "You must be 18+ years old",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Provide accurate information during registration",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Grant SMS reading permission for the app to work",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Use the app legally and responsibly",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      ListTile(
                                        title: Text(
                                          'Your Responsibilities:',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        subtitle: Column(
                                          children: [
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Keep your phone secure (we recommend screen lock)",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Don't share your account with others",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Report any suspicious activity immediately",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Backup your data if needed - since it's stored on your device, uninstalling the app will delete your transaction history",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                          "What We DON'T Do:",
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        subtitle: Column(
                                          children: [
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Read your personal messages",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Categorize your spending automatically",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Share your transaction data with third parties (except anonymous analytics)",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Send messages from your phone",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Store your PIN numbers or passwords",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsGeometry.all(4),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          '5. Free vs Premium Features',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                          'Always Free:',
                                          style: TextStyle(
                                            fontSize: 15,

                                            fontWeight: FontWeight.w500,
                                            color: Colors.green.shade600,
                                          ),
                                        ),
                                        subtitle: Column(
                                          children: [
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Basic spending tracking",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Simple budgeting tools",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "M-Pesa and bank integration",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Basic spending categories",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      ListTile(
                                        title: Text(
                                          'Premium Features:',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blue.shade600,
                                          ),
                                        ),
                                        subtitle: Column(
                                          children: [
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Advanced analytics and insights",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Spending predictions and alerts",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Multiple account management",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),

                                            ListTile(
                                              leading: Icon(
                                                Icons.circle,
                                                size: 5,
                                              ),
                                              title: Text(
                                                "Data export and detailed reports",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            Card(
                                              color: Colors.blue.shade50,
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    leading: Icon(
                                                      Icons.shield_outlined,
                                                      color:
                                                          Colors.blue.shade600,
                                                    ),
                                                    title: Text(
                                                      'Simple Summary',
                                                    ),
                                                    subtitle: Text(
                                                      'Because legal stuff can be confusing:',
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: Icon(
                                                      Icons.checklist_sharp,
                                                      color:
                                                          Colors.green.shade600,
                                                    ),
                                                    title: Text(
                                                      'What we do:',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .green
                                                            .shade600,
                                                      ),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: Icon(
                                                      Icons.circle,
                                                      size: 5,
                                                    ),
                                                    title: Text(
                                                      "Read your M-Pesa and bank SMS to track spending",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: Icon(
                                                      Icons.circle,
                                                      size: 5,
                                                    ),
                                                    title: Text(
                                                      "ALL your transaction data stays on YOUR phone",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),

                                                  ListTile(
                                                    leading: Icon(
                                                      Icons.circle,
                                                      size: 5,
                                                    ),
                                                    title: Text(
                                                      "Only store basic account info (email, phone, password)",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),

                                                  ListTile(
                                                    leading: Icon(
                                                      Icons.circle,
                                                      size: 5,
                                                    ),
                                                    title: Text(
                                                      "Follow Kenyan privacy laws",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),

                                                  ListTile(
                                                    leading: Icon(
                                                      Icons.circle,
                                                      size: 5,
                                                    ),
                                                    title: Text(
                                                      "Basic features are free forever",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: Icon(
                                                      Icons.checklist_sharp,
                                                      color:
                                                          Colors.red.shade600,
                                                    ),
                                                    title: Text(
                                                      "What We Don't Do:",
                                                      style: TextStyle(
                                                        color:
                                                            Colors.red.shade600,
                                                      ),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: Icon(
                                                      Icons.circle,
                                                      size: 5,
                                                    ),
                                                    title: Text(
                                                      " Read personal messages",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: Icon(
                                                      Icons.circle,
                                                      size: 5,
                                                    ),
                                                    title: Text(
                                                      "Store your transaction data on our servers",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),

                                                  ListTile(
                                                    leading: Icon(
                                                      Icons.circle,
                                                      size: 5,
                                                    ),
                                                    title: Text(
                                                      "Give financial advice",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),

                                                  ListTile(
                                                    leading: Icon(
                                                      Icons.circle,
                                                      size: 5,
                                                    ),
                                                    title: Text(
                                                      "Share your personal data",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),

                                                  ListTile(
                                                    leading: Icon(
                                                      Icons.circle,
                                                      size: 5,
                                                    ),
                                                    title: Text(
                                                      "Basic features are free forever",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
