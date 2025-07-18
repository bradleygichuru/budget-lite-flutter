import 'package:flutter/material.dart';
import 'package:flutter_application_1/data-models/wallet.dart';
import 'package:provider/provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Align(
                child: Column(
                  children: [
                    Text("Wallet Overview"),
                    Text("How your money is distributed"),
                  ],
                ),
              ),
            ),
            Consumer<WalletModel>(
              builder: (context, wM, child) {
                return FutureBuilder<double>(
                  future: wM.savings,
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
                        child: Center(
                          child: Text('Error occured fetching wallet'),
                        ),
                      );
                    }
                    if (snapshot.hasData) {
                      return SliverToBoxAdapter(
                        child: Card(
                          child: Column(
                            children: [
                              Icon(Icons.wallet_outlined),
                              Text("Total Balance"),
                              Text('Ksh ${snapshot.data}'),
                            ],
                          ),
                        ),
                      );
                    }
                    return x;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
