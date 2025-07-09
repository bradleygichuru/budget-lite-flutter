import 'package:flutter/material.dart';
import 'package:flutter_application_1/data-models/transactions.dart';
import 'package:flutter_application_1/models/txs.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(8),
          sliver: SliverToBoxAdapter(
            child: Card(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.blue.shade500, Colors.indigo.shade600],
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
        ),

        SliverPadding(
          padding: EdgeInsets.all(10),
          sliver: SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Budget Overview",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Wrap(
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
        ),
        SliverPadding(
          padding: EdgeInsets.all(10),
          sliver: SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Recent Transactions",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
            ),
          ),
        ),
        Consumer<TransactionsModel>(
          builder: (context, txsM, child) {
            return FutureBuilder<List<TransactionObj>>(
              future: txsM.transactions,
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<TransactionObj>> snapshot,
                  ) {
                    Widget cont = Text("");
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      cont = SliverToBoxAdapter(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      if (snapshot.hasError) {
                        cont = SliverToBoxAdapter(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        if (snapshot.hasData) {
                          if ((snapshot.data ?? []).isNotEmpty) {
                            cont = SliverList.builder(
                              itemCount: snapshot.data!.length,
                              //shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final String sign =
                                    snapshot.data![index].type == "spend"
                                    ? '-'
                                    : '+';
                                final double amount =
                                    snapshot.data![index].amount;
                                Icon iconsToUse =
                                    snapshot.data![index].type == "spend"
                                    ? Icon(
                                        size: 15,
                                        Icons.outbound,
                                        color: Colors.red,
                                      )
                                    : Icon(
                                        size: 15,
                                        Icons.call_received,
                                        color: Colors.green,
                                      );
                                return SizedBox(
                                  child: Card.outlined(
                                    color: Colors.white,

                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: iconsToUse,
                                          title: Text('Cat x'),
                                          subtitle: Text(
                                            '$sign KSh $amount',
                                            style: TextStyle(
                                              color:
                                                  snapshot
                                                          .data![index]
                                                          .type ==
                                                      "spend"
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        }
                      }
                    }
                    return cont;
                  },
            );
          },
        ),
      ],
    );
  }
}
