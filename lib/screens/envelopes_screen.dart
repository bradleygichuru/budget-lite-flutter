import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/data_models/categories_data_model.dart';
import 'package:flutter_application_1/screens/dashboard_screen.dart';
import 'package:flutter_application_1/util/result_wraper.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:flutter_application_1/view_models/categories.dart';
import 'package:flutter_application_1/view_models/txs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:watch_it/watch_it.dart';
import 'package:flutter_application_1/constants/globals.dart';

class EnvelopesView extends StatefulWidget with WatchItStatefulWidgetMixin {
  const EnvelopesView({super.key});
  @override
  EnvelopeViewState createState() => EnvelopeViewState();
}

class EnvelopeViewState extends State<EnvelopesView> {
  TransactionsModel txM = di.get<TransactionsModel>();
  CategoriesModel ctM = di.get<CategoriesModel>();
  TextEditingController newCategoryNameController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController newBudgetAmountController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => di<AuthModel>().shouldShowCase
          ? ShowCaseWidget.of(context).startShowCase([
              AppGlobal.resetBudgetEnvelope,
              AppGlobal.addBudgetEnvelope,
            ])
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldMessengerState> scaffoldKey =
        GlobalKey<ScaffoldMessengerState>();
    return SafeArea(
      child: ScaffoldMessenger(
        key: scaffoldKey,
        child: AnnotatedRegion(
          value: SystemUiOverlayStyle(statusBarColor: Colors.white),
          child: Scaffold(
            // Widget x = SliverToBoxAdapter(child:  Center( child:CircularProgressIndicator() ));
            body: CustomScrollView(
              slivers: [
                // SliverPadding(
                //   padding: const EdgeInsets.all(8),
                //   sliver: SliverToBoxAdapter(
                //     child: Card(
                //       child: Container(
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(10.0),
                //           gradient: LinearGradient(
                //             begin: Alignment.centerLeft,
                //             end: Alignment.centerRight,
                //             colors: [Colors.green.shade500, Color(0xFF008000)],
                //           ),
                //         ),
                //         child: Column(
                //           children: [
                //             Padding(
                //               padding: EdgeInsets.all(10),
                //               child: Align(
                //                 alignment: Alignment.topLeft,
                //                 child: Text(
                //                   "Ready to Assign",
                //                   style: TextStyle(
                //                     fontSize: 20,
                //                     fontWeight: FontWeight.w600,
                //                     color: Colors.white,
                //                   ),
                //                 ),
                //               ),
                //             ),
                //             Padding(
                //               padding: EdgeInsets.all(10),
                //               child: Align(
                //                 alignment: Alignment.topLeft,
                //
                //                 child: FutureBuilder<double>(
                //                   future: watchPropertyValue(
                //                     (TransactionsModel m) => m.readyToAssign,
                //                   ),
                //                   builder: (context, snapshot) {
                //                     Widget x = Center(
                //                       child: CircularProgressIndicator(),
                //                     );
                //                     if (snapshot.connectionState ==
                //                         ConnectionState.waiting) {
                //                       return Center(
                //                         child: CircularProgressIndicator(),
                //                       );
                //                     } else if (snapshot.hasError) {
                //                       return SliverToBoxAdapter(
                //                         child: Text("Error occured fetching value"),
                //                       );
                //                     } else if (snapshot.hasData) {
                //                       return Text(
                //                         "Ksh ${snapshot.data}",
                //                         style: TextStyle(
                //                           color: Colors.white,
                //                           fontSize: 30,
                //                           fontWeight: FontWeight.w600,
                //                         ),
                //                       );
                //                     }
                //                     return x;
                //                   },
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                SliverPadding(
                  padding: EdgeInsets.all(10),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Budget Envelopes",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Showcase(
                              key: AppGlobal.resetBudgetEnvelope,
                              onBarrierClick: () {
                                ShowCaseWidget.of(
                                  context,
                                ).hideFloatingActionWidgetForKeys([
                                  AppGlobal.resetBudgetEnvelope,
                                ]);
                              },
                              tooltipActionConfig: const TooltipActionConfig(
                                alignment: MainAxisAlignment.end,
                                position: TooltipActionPosition.outside,
                                gapBetweenContentAndAction: 10,
                              ),
                              description: "Tap to Reset your budgets",
                              child: IconButton(
                                iconSize: 25,
                                color: Colors.blue.shade600,
                                onPressed: () => showDialog<String>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Reset Budget'),
                                    actions: [
                                      FilledButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () async {
                                          Result res =
                                              await di<CategoriesModel>()
                                                  .resetBudgets();
                                          switch (res) {
                                            case Ok():
                                              {
                                                scaffoldKey.currentState!
                                                    .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Categories have be reset',
                                                        ),
                                                      ),
                                                    );
                                                di<AuthModel>()
                                                    .removePendingBudgetReset();
                                                Navigator.pop(context);
                                                break;
                                              }
                                            case Error():
                                              {
                                                scaffoldKey.currentState!
                                                    .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Error Reseting budget',
                                                        ),
                                                      ),
                                                    );

                                                break;
                                              }
                                            default:
                                              {
                                                scaffoldKey.currentState!
                                                    .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Error Reseting budget',
                                                        ),
                                                      ),
                                                    );
                                                break;
                                              }
                                          }
                                        },
                                        child: Text('Continue with Reset'),
                                      ),
                                    ],
                                    content: Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        'Your budget will be reset, Are you sure ?',
                                      ),
                                    ),
                                  ),
                                ),
                                icon: Icon(Icons.refresh),
                              ),
                            ),
                            Showcase(
                              key: AppGlobal.addBudgetEnvelope,
                              description: "Tap to add a budget envelope",

                              onBarrierClick: () {
                                ShowCaseWidget.of(
                                  context,
                                ).hideFloatingActionWidgetForKeys([
                                  AppGlobal.addBudgetEnvelope,
                                ]);
                              },

                              tooltipActionConfig: const TooltipActionConfig(
                                alignment: MainAxisAlignment.end,
                                position: TooltipActionPosition.outside,
                                gapBetweenContentAndAction: 10,
                              ),
                              child: IconButton(
                                iconSize: 25,
                                color: Colors.blue.shade600,
                                onPressed: () => showDialog<String>(
                                  context: context,
                                  builder: (context) => SingleChildScrollView(
                                    child: AlertDialog(
                                      actions: [
                                        FilledButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll<Color>(
                                                  Colors.grey.shade600,
                                                ),
                                          ),
                                          onPressed: _isLoading
                                              ? null
                                              : () {
                                                  newBudgetAmountController
                                                          .text =
                                                      '';

                                                  newCategoryNameController
                                                          .text =
                                                      '';
                                                  Navigator.pop(context);
                                                },
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        FilledButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll<Color>(
                                                  Colors.blue.shade600,
                                                ),
                                          ),
                                          onPressed: _isLoading
                                              ? null
                                              : () {
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    setState(() {
                                                      _isLoading = true;
                                                    });
                                                    ctM
                                                        .handleCategoryAdd(
                                                          Category(
                                                            accountId: null,
                                                            spent: 0,
                                                            categoryName:
                                                                newCategoryNameController
                                                                    .text,
                                                            budget: double.parse(
                                                              newBudgetAmountController
                                                                  .text,
                                                            ),
                                                          ),
                                                        )
                                                        .then((_) {
                                                          if (mounted) {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: const Text(
                                                                  "Category created",
                                                                ),
                                                              ),
                                                            );
                                                            setState(() {
                                                              _isLoading =
                                                                  false;
                                                            });

                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          }
                                                        });
                                                  }
                                                },
                                          child: Text(
                                            "Add envelope",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                      title: Text(
                                        "Add New Envelope",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      content: Padding(
                                        padding: EdgeInsets.all(0),
                                        child: Form(
                                          key: _formKey,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 0,
                                                      vertical: 5,
                                                    ),
                                                child: TextFormField(
                                                  controller:
                                                      newCategoryNameController,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter valid category name';
                                                    }
                                                    return null;
                                                  },
                                                  decoration:
                                                      const InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        hintText:
                                                            'e.g Entertainment',
                                                        labelText:
                                                            "Category Name",
                                                      ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 0,
                                                      vertical: 5,
                                                    ),
                                                child: TextFormField(
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter valid amount';
                                                    }
                                                    return null;
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller:
                                                      newBudgetAmountController,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText: 'Budget Amount',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                icon: Icon(Icons.add_box),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                FutureBuilder<List<Category>>(
                  future: watchPropertyValue(
                    (CategoriesModel m) => m.categories,
                  ),
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
                        return SliverList.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            TextEditingController budgetAmountController =
                                TextEditingController();
                            budgetAmountController.text = snapshot
                                .data![index]
                                .budget
                                .toString();

                            return SizedBox(
                              child: Card.outlined(
                                color: getEnvelopecolor(
                                  snapshot.data![index],
                                )["backgroundColor"],
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            snapshot.data![index].categoryName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                iconSize: 18,
                                                onPressed: () {
                                                  showDialog<String>(
                                                    context: context,
                                                    builder: (context) => SingleChildScrollView(
                                                      child: AlertDialog(
                                                        title: Text(
                                                          "Edit Envelope",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),

                                                        content: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                10,
                                                              ),
                                                          child: Form(
                                                            key: _formKey,
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            16,
                                                                      ),
                                                                  child: TextFormField(
                                                                    validator: (value) {
                                                                      if (value ==
                                                                              null ||
                                                                          value
                                                                              .isEmpty) {
                                                                        return 'Please enter valid amount';
                                                                      }
                                                                      return null;
                                                                    },
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    controller:
                                                                        budgetAmountController,
                                                                    obscureText:
                                                                        false,
                                                                    decoration: InputDecoration(
                                                                      border:
                                                                          OutlineInputBorder(),
                                                                      labelText:
                                                                          'Budget Amount',
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        actions: [
                                                          FilledButton(
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  WidgetStatePropertyAll<
                                                                    Color
                                                                  >(
                                                                    Colors
                                                                        .grey
                                                                        .shade600,
                                                                  ),
                                                            ),
                                                            onPressed:
                                                                _isLoading
                                                                ? null
                                                                : () {
                                                                    Navigator.pop(
                                                                      context,
                                                                    );
                                                                  },
                                                            child: Text(
                                                              "Cancel",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                          FilledButton(
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  WidgetStatePropertyAll<
                                                                    Color
                                                                  >(
                                                                    Colors
                                                                        .blue
                                                                        .shade600,
                                                                  ),
                                                            ),
                                                            onPressed:
                                                                _isLoading
                                                                ? null
                                                                : () {
                                                                    if (_formKey
                                                                        .currentState!
                                                                        .validate()) {
                                                                      setState(() {
                                                                        _isLoading =
                                                                            true;
                                                                      });
                                                                      ctM
                                                                          .editCategoryBudget(
                                                                            snapshot.data![index],
                                                                            double.parse(
                                                                              budgetAmountController.text,
                                                                            ),
                                                                          )
                                                                          .then((
                                                                            updates,
                                                                          ) {
                                                                            if (updates ==
                                                                                1) {
                                                                              ScaffoldMessenger.of(
                                                                                context,
                                                                              ).showSnackBar(
                                                                                SnackBar(
                                                                                  content: const Text(
                                                                                    "Category edited",
                                                                                  ),
                                                                                ),
                                                                              );

                                                                              setState(
                                                                                () {
                                                                                  _isLoading = false;
                                                                                },
                                                                              );

                                                                              Navigator.pop(
                                                                                context,
                                                                              );
                                                                            }
                                                                          });
                                                                    }
                                                                  },
                                                            child: Text(
                                                              "Edit envelope",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                icon: Icon(Icons.edit_document),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        content: Text(
                                                          'Are you sure you want to delete this category',
                                                        ),
                                                        title: Text(
                                                          'Deleting category',
                                                        ),
                                                        actions: [
                                                          FilledButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                            },
                                                            child: Text(
                                                              'Cancel',
                                                            ),
                                                          ),

                                                          FilledButton(
                                                            onPressed: () {
                                                              try {
                                                                di<
                                                                      CategoriesModel
                                                                    >()
                                                                    .deletingCategory(
                                                                      snapshot
                                                                          .data![index]
                                                                          .id!,
                                                                    );
                                                                Navigator.pop(
                                                                  context,
                                                                );

                                                                di<
                                                                      CategoriesModel
                                                                    >()
                                                                    .refreshCats();
                                                              } catch (e) {
                                                                scaffoldKey
                                                                    .currentState!
                                                                    .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text(
                                                                              'Error deleting category',
                                                                            ),
                                                                      ),
                                                                    );
                                                              }
                                                            },
                                                            child: Text(
                                                              'Delete',
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.delete_outline,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Ksh ${snapshot.data![index].spent} of Ksh ${snapshot.requireData[index].budget}",
                                          ),
                                          Text(
                                            "Ksh ${(snapshot.requireData[index].budget - snapshot.requireData[index].spent)} left",
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: LinearProgressIndicator(
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                getEnvelopecolor(
                                                  snapshot.data![index],
                                                )["textColor"]!,
                                              ),
                                          value:
                                              (snapshot.data![index].spent /
                                              snapshot.data![index].budget),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${((snapshot.data![index].spent / snapshot.data![index].budget) * 100).toStringAsFixed(1)}% used",
                                            ),
                                            Text(
                                              "${(((snapshot.data![index].budget - snapshot.data![index].spent) / snapshot.data![index].budget) * 100).toStringAsFixed(1)}% remaining",
                                            ),
                                          ],
                                        ),
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
                    if ((snapshot.data ?? []).isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(child: Text("No categories found")),
                      );
                    }
                    return x;
                  },
                ),
                SliverPadding(
                  padding: EdgeInsetsGeometry.all(15),
                  sliver: SliverToBoxAdapter(child: Text(' ')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
