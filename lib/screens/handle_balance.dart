import 'dart:collection';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models/transactions.dart';
import 'package:flutter_application_1/data_models/wallet_data_model.dart';
import 'package:flutter_application_1/view_models/categories.dart';
import 'package:flutter_application_1/view_models/txs.dart';
import 'package:flutter_application_1/view_models/wallet.dart';
import 'package:provider/provider.dart';

class HandleBalance extends StatefulWidget {
  const HandleBalance({super.key});
  @override
  HandleBalanceState createState() => HandleBalanceState();
}

class HandleBalanceState extends State<HandleBalance>
    with TickerProviderStateMixin {
  final _creditfFormKey = GlobalKey<FormState>();

  final _debitfFormKey = GlobalKey<FormState>();

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
                    "Balance Manager",
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
                          "Current Balance",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Align(
                          child: Consumer<WalletModel>(
                            builder: (context, wM, child) {
                              return FutureBuilder<double>(
                                future: wM.totalBalance,
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
                                        Consumer<CategoriesModel>(
                                          builder: (context, ctM, child) {
                                            final List<
                                              DropdownMenuEntry<String>
                                            >
                                            menuEntries =
                                                UnmodifiableListView<
                                                  DropdownMenuEntry<String>
                                                >(
                                                  ctM.knownCategoryEntries.map<
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
                                                dropdownMenuEntries:
                                                    menuEntries,
                                              ),
                                            );
                                          },
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
                                        Consumer3<
                                          WalletModel,
                                          CategoriesModel,
                                          TransactionsModel
                                        >(
                                          builder: (context, wM, ctM, txM, child) {
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
                                                    TransactionObj
                                                    tx = TransactionObj(
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
                                                      wM.debitDefaultWallet(tx).then((
                                                        updateCols,
                                                      ) {
                                                        if (updateCols !=
                                                            null) {
                                                          // Category candidate = cats.firstWhere((cat)=> cat.categoryName == category);
                                                          ctM.handleCatBalanceCompute(
                                                            category,
                                                            tx,
                                                          );
                                                          txM.refreshTx();
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: const Text(
                                                                "Wallet updated",
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      });
                                                    } on NotEnoughException {
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
                                                  "Add Expense",
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
                                        Consumer2<
                                          WalletModel,
                                          TransactionsModel
                                        >(
                                          builder: (context, wM, txM, child) {
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
                                                      wM
                                                          .creditDefaultWallet(
                                                            TransactionObj(
                                                              type: TxType
                                                                  .credit
                                                                  .val,
                                                              desc:
                                                                  descController
                                                                      .value
                                                                      .text,
                                                              source:
                                                                  sourceController
                                                                      .value
                                                                      .text,
                                                              category:
                                                                  'credit',
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
                                                              txM.refreshTx();
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
                                                  "Add Income",
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
