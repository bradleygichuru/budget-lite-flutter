import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:flutter_application_1/view_models/wallet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/watch_it.dart';

class InitialBalance extends StatefulWidget with WatchItStatefulWidgetMixin {
  const InitialBalance({super.key});
  @override
  InitialBalanceState createState() => InitialBalanceState();
}

class InitialBalanceState extends State<InitialBalance> {
  @override
  void initState() {
    di<AuthModel>().setLastOnboardingStep('intial_balance');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController balanceEC = TextEditingController();

    TextEditingController savingsEC = TextEditingController();
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.blue.shade50, Colors.indigo.shade50],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Colors.blue.shade600, Colors.purple.shade600],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Text(
                  'Set Initial Balances',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Text(
                    'Set your current wallet and savings balances to get started, or continue with empty balances.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(6),
                  child: SizedBox(
                    child: Card(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: Colors.blue,
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Text(
                                    'Wallet Balance',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsGeometry.all(8),
                            child: Text(
                              'Your current available spending money',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.all(10),
                            child: TextField(
                              controller: balanceEC,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '1000',
                                labelText: "Amount (Ksh)",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(6),
                  child: SizedBox(
                    child: Card(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.savings_outlined,
                                    color: Colors.green,
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Text(
                                    'Savings Balance',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsGeometry.all(8),
                            child: Text(
                              'Your current total savings amount',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.all(10),
                            child: TextField(
                              controller: savingsEC,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '1000',
                                labelText: "Amount (Ksh)",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Colors.blue.shade600, Colors.purple.shade600],
                      ),
                    ),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        fixedSize: Size.fromWidth(double.infinity),
                      ),
                      onPressed: () {
                        di
                            .get<WalletModel>()
                            .onBoaringWalletInit(
                              double.parse(savingsEC.value.text) ?? 0,
                              double.parse(balanceEC.value.text) ?? 0,
                            )
                            .then((updated) {
                              if (updated != null) {
                                if (updated > 0) {
                                  if (mounted) {
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   SnackBar(
                                    //     content: const Text(
                                    //       "Intialized wallet values",
                                    //     ),
                                    //   ),
                                    // );

                                    Navigator.pop(context);
                                  }
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginForm(),
                                    ),
                                  );
                                }
                              }
                            });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Continue with balances'),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(Icons.arrow_right_alt),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ButtonTheme(
                  height: 30,
                  child: OutlinedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                    onPressed: () async {
                      try {
                        di.get<AuthModel>().completeOnboarding();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginForm(),
                          ),
                        );
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                "Error intializing wallet values",
                              ),
                            ),
                          );

                          Navigator.pop(context);
                        }
                        log('Error occured intializing wallet figures:$e');
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.skip_next, color: Colors.black),
                        ),
                        Text(
                          'Skip & Start Empty',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
