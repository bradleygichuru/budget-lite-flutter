import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/screens/handle_balance.dart';
import 'package:flutter_application_1/screens/handle_savings.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:flutter_application_1/view_models/wallet.dart';
import 'package:watch_it/watch_it.dart';

class WalletScreen extends StatefulWidget with WatchItStatefulWidgetMixin {
  const WalletScreen({super.key});
  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> {
  WalletModel wM = di.get<WalletModel>();
  AuthModel aM = di.get<AuthModel>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Align(
                child: Column(
                  children: [
                    Text(
                      "Wallet Overview",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      "How your money is distributed",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ),
          FutureBuilder<double>(
            future: watchPropertyValue((WalletModel m) => m.totalBalance),
            builder: (context, snapshot) {
              Widget x = SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('Error occured fetching wallet')),
                );
              }
              if (snapshot.hasData) {
                return SliverToBoxAdapter(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      fixedSize: Size.fromWidth(double.infinity),
                    ),
                    onPressed: () async {
                      // if (aM.region == Country.kenya.name) {
                      //   return showDialog<void>(
                      //     context: context,
                      //     barrierDismissible: false,
                      //     builder: (context) {
                      //       return AlertDialog(
                      //         title: Text('Auto import on'),
                      //         content: Text(
                      //           'Transaction auto import is automatically enabled in your region.Be careful of transaction duplication on auto imported transactions',
                      //         ),
                      //         actions: [
                      //           FilledButton(
                      //             onPressed: () {
                      //               Navigator.of(context).pop();
                      //             },
                      //             child: Text('Cancel'),
                      //           ),
                      //           FilledButton(
                      //             onPressed: () {
                      //               Navigator.of(context).pop();
                      //               Navigator.push(
                      //                 context,
                      //                 MaterialPageRoute(
                      //                   builder: (context) =>
                      //                       const HandleBalance(),
                      //                 ),
                      //               );
                      //             },
                      //             child: Text('Continue'),
                      //           ),
                      //         ],
                      //       );
                      //     },
                      //   );
                      // } else {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => const HandleBalance(),
                      //     ),
                      //   );
                      // }
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Card(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.indigo.shade500,
                                Colors.purple.shade600,
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 32,
                                  color: Colors.white,
                                ),
                                Text(
                                  "Total Balance",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Ksh ${snapshot.data}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return x;
            },
          ),

          FutureBuilder<double>(
            future: watchPropertyValue((WalletModel m) => m.savings),
            builder: (context, snapshot) {
              Widget x = SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('Error occured fetching wallet')),
                );
              }
              if (snapshot.hasData) {
                return SliverToBoxAdapter(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      fixedSize: Size.fromWidth(double.infinity),
                    ),
                    onPressed: () async {
                      // if (aM.region == Country.kenya.name) {
                      //   return showDialog<void>(
                      //     context: context,
                      //     barrierDismissible: false,
                      //     builder: (context) {
                      //       return AlertDialog(
                      //         title: Text('Auto import on'),
                      //         content: Text(
                      //           'Transaction auto import is automatically enabled in your region.Be careful on transaction duplication on auto iported transactions',
                      //         ),
                      //         actions: [
                      //           FilledButton(
                      //             onPressed: () {
                      //               Navigator.of(context).pop();
                      //             },
                      //             child: Text('Cancel'),
                      //           ),
                      //           FilledButton(
                      //             onPressed: () {
                      //               Navigator.of(context).pop();
                      //               Navigator.push(
                      //                 context,
                      //                 MaterialPageRoute(
                      //                   builder: (context) =>
                      //                       const HandleSavings(),
                      //                 ),
                      //               );
                      //             },
                      //             child: Text('Continue'),
                      //           ),
                      //         ],
                      //       );
                      //     },
                      //   );
                      // } else {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => const HandleSavings(),
                      //     ),
                      //   );
                      // }
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Card(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.green.shade500,
                                Colors.green.shade600,
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 32,
                                  color: Colors.white,
                                ),
                                Text(
                                  "Savings",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Ksh ${snapshot.data}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return x;
            },
          ),
        ],
      ),
    );
  }
}
