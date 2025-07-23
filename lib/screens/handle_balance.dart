import 'dart:collection';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models/transactions.dart';
import 'package:flutter_application_1/view_models/categories.dart';
import 'package:flutter_application_1/view_models/txs.dart';
import 'package:flutter_application_1/view_models/wallet.dart';
import 'package:watch_it/watch_it.dart';

class HandleBalance extends StatefulWidget with WatchItStatefulWidgetMixin {
  const HandleBalance({super.key});
  @override
  HandleBalanceState createState() => HandleBalanceState();
}

class HandleBalanceState extends State<HandleBalance> {
  final _creditfFormKey = GlobalKey<FormState>();

  final _debitfFormKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldMessengerState> handleBlScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  TextEditingController amountController = TextEditingController();

  TextEditingController descController = TextEditingController();

  TextEditingController categoryController = TextEditingController();

  TextEditingController sourceController = TextEditingController();
  String category = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    descController.dispose();
    categoryController.dispose();
    sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScaffoldMessenger(
        key: handleBlScaffoldMessengerKey,
        child: Scaffold(
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
                      "Balance Manager",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
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
                            "Current Balance",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Align(
                            child: FutureBuilder<double>(
                              future: watchPropertyValue(
                                (WalletModel m) => m.totalBalance,
                              ),
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          tabs: [
                            Tab(text: 'Debit (expense)'),
                            Tab(text: 'Credit (income)'),
                          ],
                        ),
                        SizedBox(
                          height: 400,
                          child: TabBarView(
                            children: [
                              Padding(
                                padding: EdgeInsetsGeometry.all(4),
                                child: Card.outlined(
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
                                                "Add Expense",
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 10,
                                            ),
                                            child: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
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
                                          Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: TextFormField(
                                              keyboardType: TextInputType.text,
                                              controller: descController,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter valid desc';
                                                }
                                                return null;
                                              },
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                hintText: 'Enter description',
                                                labelText: "Description",
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: DropdownMenu<String>(
                                              width: double.infinity,
                                              hintText: "select category",
                                              onSelected: (value) {
                                                if (value != null) {
                                                  category = value;
                                                }
                                                // This is called when the user selects an item.

                                                log(
                                                  "selected_category:$category",
                                                );
                                              },
                                              dropdownMenuEntries: watchPropertyValue(
                                                (CategoriesModel m) =>
                                                    UnmodifiableListView<
                                                      DropdownMenuEntry<String>
                                                    >(
                                                      m.knownCategoryEntries.map<
                                                        DropdownMenuEntry<
                                                          String
                                                        >
                                                      >(
                                                        (String name) =>
                                                            DropdownMenuEntry<
                                                              String
                                                            >(
                                                              value: name,
                                                              label: name,
                                                            ),
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: TextFormField(
                                              keyboardType: TextInputType.text,
                                              controller: sourceController,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter valid source';
                                                }
                                                return null;
                                              },
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                hintText: 'eg Mpesa or Bank',
                                                labelText: "source",
                                              ),
                                            ),
                                          ),
                                          Padding(
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
                                                if (_debitfFormKey.currentState!
                                                        .validate() &&
                                                    category.isNotEmpty) {
                                                  TransactionObj tx =
                                                      TransactionObj(
                                                        type: TxType.spend.val,
                                                        desc: descController
                                                            .value
                                                            .text,
                                                        category: category,
                                                        source: sourceController
                                                            .value
                                                            .text,
                                                        amount: double.parse(
                                                          amountController
                                                              .value
                                                              .text,
                                                        ),
                                                        date: DateTime.now()
                                                            .toString(),
                                                      );
                                                  try {
                                                    di.get<WalletModel>().debitDefaultWallet(tx).then((
                                                      updateCols,
                                                    ) {
                                                      log(
                                                        'On page Wallet cols updated:$updateCols',
                                                      );
                                                      if (updateCols == 1) {
                                                        // Category candidate = cats.firstWhere((cat)=> cat.categoryName == category);
                                                        amountController
                                                            .clear();
                                                        descController.clear();

                                                        di
                                                            .get<WalletModel>()
                                                            .refresh();
                                                        di
                                                            .get<
                                                              TransactionsModel
                                                            >()
                                                            .refreshTx();

                                                        if (context.mounted) {
                                                          handleBlScaffoldMessengerKey
                                                              .currentState!
                                                              .showSnackBar(
                                                                SnackBar(
                                                                  content:
                                                                      const Text(
                                                                        "Wallet updated",
                                                                      ),
                                                                ),
                                                              );
                                                        }
                                                      } else {
                                                        if (context.mounted) {
                                                          handleBlScaffoldMessengerKey
                                                              .currentState!
                                                              .showSnackBar(
                                                                SnackBar(
                                                                  content:
                                                                      const Text(
                                                                        "Failed updating wallet",
                                                                      ),
                                                                ),
                                                              );
                                                        }
                                                      }
                                                    });
                                                  } catch (e) {
                                                    log(
                                                      'Error ${e.toString()}',
                                                    );

                                                    handleBlScaffoldMessengerKey
                                                        .currentState!
                                                        .showSnackBar(
                                                          SnackBar(
                                                            content: const Text(
                                                              "Error Occured",
                                                            ),
                                                          ),
                                                        );
                                                  }
                                                } else {
                                                  if (mounted) {
                                                    handleBlScaffoldMessengerKey
                                                        .currentState!
                                                        .showSnackBar(
                                                          SnackBar(
                                                            content: const Text(
                                                              "Confirm form values",
                                                            ),
                                                          ),
                                                        );
                                                  }
                                                }
                                              },
                                              child: Text(
                                                "Add Expense",
                                                style: TextStyle(
                                                  color: Colors.white,
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
                              Padding(
                                padding: EdgeInsetsGeometry.all(4),
                                child: Card.outlined(
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
                                                "Add Income",
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 10,
                                            ),
                                            child: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
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
                                          Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: TextFormField(
                                              keyboardType: TextInputType.text,
                                              controller: descController,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter valid desc';
                                                }
                                                return null;
                                              },
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                hintText: 'Enter description',
                                                labelText: "Description",
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: TextFormField(
                                              keyboardType: TextInputType.text,
                                              controller: sourceController,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter valid source';
                                                }
                                                return null;
                                              },
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                hintText: 'eg Mpesa or Bank',
                                                labelText: "source",
                                              ),
                                            ),
                                          ),
                                          Padding(
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
                                                if (_creditfFormKey
                                                    .currentState!
                                                    .validate()) {
                                                  try {
                                                    di
                                                        .get<WalletModel>()
                                                        .creditDefaultWallet(
                                                          TransactionObj(
                                                            type: TxType
                                                                .credit
                                                                .val,
                                                            desc: descController
                                                                .value
                                                                .text,
                                                            source:
                                                                sourceController
                                                                    .value
                                                                    .text,
                                                            category: 'credit',
                                                            amount: double.parse(
                                                              amountController
                                                                  .value
                                                                  .text,
                                                            ),
                                                            date: DateTime.now()
                                                                .toString(),
                                                          ),
                                                        )
                                                        .then((updateCols) {
                                                          if (updateCols !=
                                                              null) {
                                                            amountController
                                                                .clear();
                                                            descController
                                                                .clear();
                                                            di
                                                                .get<
                                                                  TransactionsModel
                                                                >()
                                                                .refreshTx();
                                                            di
                                                                .get<
                                                                  WalletModel
                                                                >()
                                                                .refresh();

                                                            if (context
                                                                .mounted) {
                                                              handleBlScaffoldMessengerKey
                                                                  .currentState!
                                                                  .showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          const Text(
                                                                            "Wallet updated",
                                                                          ),
                                                                    ),
                                                                  );
                                                            }
                                                          }
                                                        });
                                                  } catch (e) {
                                                    log(
                                                      'Error ${e.toString()}',
                                                    );

                                                    handleBlScaffoldMessengerKey
                                                        .currentState!
                                                        .showSnackBar(
                                                          SnackBar(
                                                            content: const Text(
                                                              "Error Occured",
                                                            ),
                                                          ),
                                                        );
                                                  }
                                                } else {
                                                  if (mounted) {
                                                    handleBlScaffoldMessengerKey
                                                        .currentState!
                                                        .showSnackBar(
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
                                                "Add Income",
                                                style: TextStyle(
                                                  color: Colors.white,
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
      ),
    );
  }
}
