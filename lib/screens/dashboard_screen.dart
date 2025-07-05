import 'package:flutter/material.dart';
import 'package:flutter_application_1/funcs/transactions.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Card(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3b82f6), Color(0xFF4f46e5)],
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Total Balance",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "KSh 32,000",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Card(
                      //color: Colors.white,
                      elevation: 0,

                      child: Column(
                        children: [
                          ListTile(
                            //leading: Icon(Icons.album),
                            title: Text('Ready to Assign'),
                            subtitle: Text('KSh 0'),
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

        Padding(
          padding: EdgeInsets.all(10),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Budget Overview",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ),
        ),
        Wrap(
          children: [
            SizedBox(
              width: 180,
              height: 160,
              child: Card.outlined(
                color: Colors.white,

                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.category, size: 15),
                      title: Text('Rent'),
                      subtitle: Text('KSh 15,000 left'),
                    ),
                    ListTile(subtitle: Text("100% remaining")),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 180,
              height: 160,
              child: Card.outlined(
                color: Colors.white,

                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.category, size: 15),
                      title: Text('Rent'),
                      subtitle: Text('KSh 15,000 left'),
                    ),
                    ListTile(subtitle: Text("100% remaining")),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 180,
              height: 160,
              child: Card.outlined(
                color: Colors.white,

                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.category, size: 15),
                      title: Text('Rent'),
                      subtitle: Text('KSh 15,000 left'),
                    ),
                    ListTile(subtitle: Text("100% remaining")),
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Recent Transactions",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ),
        ),
        Consumer<TransactionsModel>(
          builder: (context, transactionsM, child) {
            return Column(children: transactionsM.composeTransactions());
          },
        ),
      ],
    );
  }
}
