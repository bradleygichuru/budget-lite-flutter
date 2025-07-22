import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models/categories_data_model.dart';
import 'package:flutter_application_1/data_models/transactions.dart';
import 'package:flutter_application_1/view_models/categories.dart';
import 'package:flutter_application_1/view_models/txs.dart';
import 'package:flutter_application_1/view_models/wallet.dart';
import 'package:provider/provider.dart';

int getDaysRemaining(String date) {
  DateTime today = DateTime.now();
  DateTime goalDate = DateTime.parse(date);
  var dif = goalDate.difference(today);
  return dif.inDays;
}

Map<String, Color> getEnvelopecolor(Category cat) {
  Map<String, Color> y = {
    "textColor": Colors.green.shade600,
    "backgroundColor": Colors.green.shade600,
  };
  double percentageRem = (cat.budget - cat.spent) / cat.budget * 100;
  log("rem percent:$percentageRem");
  if (percentageRem > 50) {
    y["textColor"] = Colors.green.shade600;
    y["backgroundColor"] = Colors.green.shade50;
    return y;
  }
  if (percentageRem > 20) {
    y["textColor"] = Colors.yellow.shade600;
    y["backgroundColor"] = Colors.yellow.shade50;

    return y;
  } else {
    y["textColor"] = Colors.red.shade600;
    y["backgroundColor"] = Colors.red.shade50;

    return y;
  }
  // return y;
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: CustomScrollView(
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
                          child: FutureBuilder<double>(
                            future: Provider.of<WalletModel>(
                              context,
                              listen: true,
                            ).totalBalance,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Text('An error occured');
                              } else if (snapshot.hasData) {
                                return Text(
                                  "KSh ${snapshot.data}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }
                              return Text("Error");
                            },
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
          Consumer<CategoriesModel>(
            builder: (context, ctM, child) {
              return FutureBuilder(
                future: ctM.categories,
                builder: (context, snapshot) {
                  Widget x = SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Text("Error occured fetching categories"),
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    if ((snapshot.data ?? []).isNotEmpty) {
                      List<Widget> gridItems = [];
                      for (final x in snapshot.requireData) {
                        gridItems.add(
                          Wrap(
                            children: [
                              SizedBox(
                                width: 180,
                                child: Card.outlined(
                                  color: Colors.white,

                                  child: Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          trailing: Icon(
                                            Icons.category,
                                            size: 15,
                                          ),
                                          title: Text(
                                            x.categoryName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          subtitle: Text(
                                            'Ksh ${x.budget - x.spent} left',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 0,
                                            horizontal: 10,
                                          ),
                                          child: LinearProgressIndicator(
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.green.shade600,
                                                ),
                                            value: (x.spent / x.budget),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 10,
                                          ),
                                          child: Container(
                                            height: 25,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: getEnvelopecolor(
                                                x,
                                              )["backgroundColor"],
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(3),
                                              child: Text(
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  // backgroundColor: getEnvelopecolor(
                                                  //   x,
                                                  // )["backgroundColor"],
                                                  color: getEnvelopecolor(
                                                    x,
                                                  )['textColor'],
                                                ),
                                                "${((x.budget - x.spent) / x.budget * 100)}% remaining",
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return SliverGrid.count(
                        crossAxisCount: 2,
                        children: gridItems,
                      );
                    }
                  }
                  if ((snapshot.data ?? []).isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(child: Text("No categories found")),
                    );
                  }

                  return x;
                },
              );
            },
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
                      Widget cont = SliverToBoxAdapter(child: Text(""));
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        cont = SliverToBoxAdapter(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        if (snapshot.hasError) {
                          cont = SliverToBoxAdapter(
                            child: Center(
                              child: Text(
                                'Error Occured fetching Transactions',
                              ),
                            ),
                          );
                        } else {
                          if (snapshot.hasData) {
                            if ((snapshot.data ?? []).isNotEmpty) {
                              cont = SliverList.builder(
                                itemCount: snapshot.data!.length,
                                //shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final String sign =
                                      snapshot.data![index].type ==
                                          TxType.spend.val
                                      ? '-'
                                      : '+';
                                  final double amount =
                                      snapshot.data![index].amount;
                                  Icon iconsToUse =
                                      snapshot.data![index].type ==
                                          TxType.spend.val
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
                                            title: Text(
                                              snapshot.data![index].category ??
                                                  "Pending category",
                                            ),
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
      ),
    );
  }
}
