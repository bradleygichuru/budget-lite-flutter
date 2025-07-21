import 'dart:collection';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models/goal_data_model.dart';
import 'package:flutter_application_1/data_models/transactions.dart';
import 'package:flutter_application_1/data_models/wallet_data_model.dart';
import 'package:flutter_application_1/view_models/goals.dart';
import 'package:flutter_application_1/view_models/txs.dart';
import 'package:flutter_application_1/view_models/wallet.dart';
import 'package:provider/provider.dart';

class HandleSavings extends StatefulWidget {
  const HandleSavings({super.key});
  @override
  HandleBalanceState createState() => HandleBalanceState();
}

double goalPercentageComplete(Goal goal) {
  if (goal.currentAmount != null) {
    return (goal.currentAmount! / goal.targetAmount * 100).roundToDouble();
  }

  return 0;
}

class HandleBalanceState extends State<HandleSavings>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  final _creditfFormKey = GlobalKey<FormState>();

  final _debitfFormKey = GlobalKey<FormState>();

  TextEditingController amountController = TextEditingController();

  TextEditingController sourceController = TextEditingController();
  String goal = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ListTile(
                  leading: IconButton.outlined(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_sharp),
                  ),
                  title: Text(
                    "Savings Manager",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  width: double.infinity,

                  height: 150,
                  child: Card.outlined(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Total Savings",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Align(
                          child: Consumer<WalletModel>(
                            builder: (context, wM, child) {
                              return FutureBuilder<double>(
                                future: wM.savings,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text(
                                      "Error occured fetching balance",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  } else if (snapshot.hasData) {
                                    return Text(
                                      snapshot.data.toString(),
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                  return Text(
                                    'Error',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
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
                      "Your saving goals",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              Consumer<GoalModel>(
                builder: (context, gM, child) {
                  return FutureBuilder<List<Goal>>(
                    future: gM.goals,
                    builder: (context, snapshot) {
                      Widget x = SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        log('${snapshot.error}');
                        return SliverToBoxAdapter(
                          child: Center(
                            child: Text("Error occured fetching goals"),
                          ),
                        );
                      }
                      if ((snapshot.data ?? []).isEmpty) {
                        return SliverToBoxAdapter(
                          child: Center(child: Text("No Goals found")),
                        );
                      }

                      if (snapshot.hasData) {
                        if (snapshot.data!.isNotEmpty) {
                          return SliverList.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              // TextEditingController budgetAmountController =
                              //     TextEditingController();
                              // budgetAmountController.text = snapshot
                              //     .data![index]
                              //     .budget
                              //     .toString();

                              return SizedBox(
                                width: 200,
                                child: Card.outlined(
                                  color: Colors.white,
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: ListTile(
                                                leading: Icon(
                                                  Icons.adjust_outlined,
                                                  color: Colors.blue.shade600,
                                                ),
                                                title: Text(
                                                  snapshot.data![index].name,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  'Ksh ${snapshot.data![index].currentAmount ?? 0} of Ksh ${snapshot.data![index].targetAmount}',
                                                ),
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  '${goalPercentageComplete(snapshot.data![index]).toString()}%',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                    color: Colors.blue.shade600,
                                                  ),
                                                ),
                                                Text(
                                                  'Complete',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 10,
                                          ),
                                          child: LinearProgressIndicator(
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.blue.shade600,
                                                ),
                                            value:
                                                (snapshot
                                                    .data![index]
                                                    .currentAmount! /
                                                snapshot
                                                    .data![index]
                                                    .targetAmount),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: SizedBox(
                                                height: 120,
                                                child: Card(
                                                  color: Colors.grey.shade50,
                                                  child: Column(
                                                    children: [
                                                      ListTile(
                                                        title: Text(
                                                          'Target date',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey
                                                                .shade700,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        leading: Icon(
                                                          size: 14,
                                                          Icons
                                                              .calendar_today_outlined,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.all(
                                                          3,
                                                        ),
                                                        child: Text(
                                                          '${snapshot.data![index].targetDate.split(" ")[0]}',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey
                                                                .shade600,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.all(
                                                          3,
                                                        ),
                                                        child: Text(
                                                          'Past Due',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .red
                                                                .shade600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Flexible(
                                              child: SizedBox(
                                                height: 120,
                                                child: Card(
                                                  color: Colors.grey.shade50,
                                                  child: Column(
                                                    children: [
                                                      ListTile(
                                                        title: Text(
                                                          'Remaining',
                                                          style: TextStyle(
                                                            fontSize: 14,

                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        leading: Icon(
                                                          size: 14,
                                                          Icons.moving,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.all(
                                                          3,
                                                        ),
                                                        child: Text(
                                                          '${snapshot.data![index].currentAmount != null ? snapshot.data![index].targetAmount - snapshot.data![index].currentAmount! : 0}',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey
                                                                .shade600,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.all(
                                                          3,
                                                        ),
                                                        child: Text(
                                                          'Goal overdue',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey
                                                                .shade600,
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
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      }
                      return x;
                    },
                  );
                },
              ),

              SliverToBoxAdapter(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: 'Add  to goal'),
                          Tab(text: 'Remove from goal'),
                        ],
                      ),
                      SizedBox(
                        height: 300.0,
                        child: TabBarView(
                          children: [
                            Padding(
                              padding: EdgeInsetsGeometry.all(4),
                              child: Card.outlined(
                                color: Colors.white,
                                child: Form(
                                  key: _creditfFormKey,
                                  child: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              "Add to Goal",
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Consumer<GoalModel>(
                                          builder: (context, gM, child) {
                                            final List<
                                              DropdownMenuEntry<String>
                                            >
                                            menuEntries =
                                                UnmodifiableListView<
                                                  DropdownMenuEntry<String>
                                                >(
                                                  gM.knownGoalNames.map<
                                                    DropdownMenuEntry<String>
                                                  >(
                                                    (String name) =>
                                                        DropdownMenuEntry<
                                                          String
                                                        >(
                                                          value: name,
                                                          label: name,
                                                        ),
                                                  ),
                                                );
                                            return Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: DropdownMenu<String>(
                                                width: double.infinity,
                                                hintText: "Select Goal",
                                                onSelected: (value) {
                                                  if (value != null) {
                                                    goal = value;
                                                  }
                                                  // This is called when the user selects an item.

                                                  log("selected_goal:$goal");
                                                },
                                                dropdownMenuEntries:
                                                    menuEntries,
                                              ),
                                            );
                                          },
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 10,
                                          ),
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            controller: amountController,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter valid amount';
                                              }
                                              return null;
                                            },
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: '1000',
                                              labelText: "Amount (Ksh)",
                                            ),
                                          ),
                                        ),
                                        Consumer<GoalModel>(
                                          builder: (context, gM, child) {
                                            return Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  fixedSize:
                                                      WidgetStatePropertyAll(
                                                        Size.fromWidth(
                                                          double.infinity,
                                                        ),
                                                      ),
                                                  backgroundColor:
                                                      WidgetStatePropertyAll(
                                                        Colors.black,
                                                      ),
                                                ),
                                                onPressed: () {
                                                  if (_debitfFormKey
                                                      .currentState!
                                                      .validate()) {
                                                    try {
                                                      gM
                                                          .addCurrentAmount(
                                                            goal,
                                                            double.parse(
                                                              amountController
                                                                  .value
                                                                  .text,
                                                            ),
                                                          )
                                                          .then((updateCols) {
                                                            if (updateCols !=
                                                                null) {
                                                              Provider.of<
                                                                    TransactionsModel
                                                                  >(
                                                                    context,
                                                                    listen:
                                                                        false,
                                                                  )
                                                                  .refreshTx();
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content:
                                                                      const Text(
                                                                        "Goal updated",
                                                                      ),
                                                                ),
                                                              );
                                                            }
                                                          });
                                                    } on NotEnoughSavingsException {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: const Text(
                                                            "Not enough savings in wallet",
                                                          ),
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      log(
                                                        'Error ${e.toString()}',
                                                      );

                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: const Text(
                                                            "Error Occured",
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  } else {
                                                    if (mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: const Text(
                                                            "Error in submitted values",
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: Text(
                                                  "Add to goal",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsGeometry.all(4),
                              child: Card.outlined(
                                color: Colors.white,
                                child: Form(
                                  key: _debitfFormKey,
                                  child: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              "Remove from Goal",
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Consumer<GoalModel>(
                                          builder: (context, gM, child) {
                                            final List<
                                              DropdownMenuEntry<String>
                                            >
                                            menuEntries =
                                                UnmodifiableListView<
                                                  DropdownMenuEntry<String>
                                                >(
                                                  gM.knownGoalNames.map<
                                                    DropdownMenuEntry<String>
                                                  >(
                                                    (String name) =>
                                                        DropdownMenuEntry<
                                                          String
                                                        >(
                                                          value: name,
                                                          label: name,
                                                        ),
                                                  ),
                                                );
                                            return Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: DropdownMenu<String>(
                                                width: double.infinity,
                                                hintText: "Select Goal",
                                                onSelected: (value) {
                                                  if (value != null) {
                                                    goal = value;
                                                  }
                                                  // This is called when the user selects an item.

                                                  log("selected_goal:$goal");
                                                },
                                                dropdownMenuEntries:
                                                    menuEntries,
                                              ),
                                            );
                                          },
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 10,
                                          ),
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            controller: amountController,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter valid amount';
                                              }
                                              return null;
                                            },
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: '1000',
                                              labelText: "Amount (Ksh)",
                                            ),
                                          ),
                                        ),
                                        Consumer<GoalModel>(
                                          builder: (context, gM, child) {
                                            return Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  fixedSize:
                                                      WidgetStatePropertyAll(
                                                        Size.fromWidth(
                                                          double.infinity,
                                                        ),
                                                      ),
                                                  backgroundColor:
                                                      WidgetStatePropertyAll(
                                                        Colors.black,
                                                      ),
                                                ),
                                                onPressed: () {
                                                  if (_debitfFormKey
                                                      .currentState!
                                                      .validate()) {
                                                    try {
                                                      gM
                                                          .deductCurrentAmount(
                                                            goal,
                                                            double.parse(
                                                              amountController
                                                                  .value
                                                                  .text,
                                                            ),
                                                          )
                                                          .then((updateCols) {
                                                            if (updateCols !=
                                                                null) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content:
                                                                      const Text(
                                                                        "Wallet updated",
                                                                      ),
                                                                ),
                                                              );
                                                            }
                                                          });
                                                    } on GoalAmountError {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: const Text(
                                                            "Not enough balance in wallet",
                                                          ),
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      log(
                                                        'Error ${e.toString()}',
                                                      );

                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: const Text(
                                                            "Error Occured",
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  } else {
                                                    if (mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: const Text(
                                                            "Error in submitted values",
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: Text(
                                                  "Remove from Goal",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
