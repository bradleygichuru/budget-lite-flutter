import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/categories.dart';
import 'package:flutter_application_1/models/txs.dart';
import 'package:flutter_application_1/screens/dashboard_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EnvelopesView extends StatefulWidget {
  const EnvelopesView({super.key});
  @override
  EnvelopeViewState createState() => EnvelopeViewState();
}

class EnvelopeViewState extends State<EnvelopesView> {
  TextEditingController newCategoryNameController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController newBudgetAmountController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 25, 143, 240),
      ),
      home: SafeArea(
        child: Scaffold(
          key: scaffoldKey,
          // Widget x = SliverToBoxAdapter(child:  Center( child:CircularProgressIndicator() ));
          body: CustomScrollView(
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
                          colors: [Colors.green.shade500, Color(0xFF008000)],
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Ready to Assign",
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

                              child: Consumer<TransactionsModel>(
                                builder: (context, txM, child) {
                                  return FutureBuilder<double>(
                                    future: txM.readyToAssign,
                                    builder: (context, snapshot) {
                                      Widget x = Center(
                                        child: CircularProgressIndicator(),
                                      );
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else if (snapshot.hasError) {
                                        return SliverToBoxAdapter(
                                          child: Text(
                                            "Error occured fetching value",
                                          ),
                                        );
                                      } else if (snapshot.hasData) {
                                        return Text(
                                          "Ksh ${snapshot.data}",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      }
                                      return x;
                                    },
                                  );
                                },
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Budget Envelopes",
                          style: GoogleFonts.notoSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      IconButton(
                        iconSize: 25,
                        color: Colors.blue.shade600,
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (context) => Dialog(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Add New Envelope",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 16,
                                      ),
                                      child: TextFormField(
                                        controller: newCategoryNameController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter valid Email';
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'e.g Entertainment',
                                          labelText: "Category Name",
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 16,
                                      ),
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter valid amount';
                                          }
                                          return null;
                                        },
                                        keyboardType: TextInputType.number,
                                        controller: newBudgetAmountController,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Budget Amount',
                                        ),
                                      ),
                                    ),
                                    SafeArea(
                                      // padding: EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          FilledButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStatePropertyAll<Color>(
                                                    Colors.grey.shade600,
                                                  ),
                                            ),
                                            onPressed: () {
                                              newBudgetAmountController.text =
                                                  '';

                                              newCategoryNameController.text =
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
                                          Consumer<CategoriesModel>(
                                            builder: (context, ctM, child) {
                                              return FilledButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStatePropertyAll<
                                                        Color
                                                      >(Colors.blue.shade600),
                                                ),
                                                onPressed: () {
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    ctM
                                                        .handleCategoryAdd(
                                                          Category(
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
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        icon: Icon(Icons.add_box),
                      ),
                    ],
                  ),
                ),
              ),
              Consumer<CategoriesModel>(
                builder: (context, ctM, child) {
                  return FutureBuilder<List<Category>>(
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
                                              snapshot
                                                  .data![index]
                                                  .categoryName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            IconButton(
                                              iconSize: 18,
                                              onPressed: () {
                                                showDialog<String>(
                                                  context: context,
                                                  builder: (context) => Dialog(
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                        10,
                                                      ),
                                                      child: Form(
                                                        key: _formKey,
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              "Edit Envelope",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
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
                                                            SafeArea(
                                                              // padding: EdgeInsets.all(10),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  FilledButton(
                                                                    style: ButtonStyle(
                                                                      backgroundColor:
                                                                          WidgetStatePropertyAll<
                                                                            Color
                                                                          >(
                                                                            Colors.grey.shade600,
                                                                          ),
                                                                    ),
                                                                    onPressed: () {
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
                                                                  Consumer<
                                                                    CategoriesModel
                                                                  >(
                                                                    builder:
                                                                        (
                                                                          context,
                                                                          ctM,
                                                                          child,
                                                                        ) {
                                                                          return FilledButton(
                                                                            style: ButtonStyle(
                                                                              backgroundColor:
                                                                                  WidgetStatePropertyAll<
                                                                                    Color
                                                                                  >(
                                                                                    Colors.blue.shade600,
                                                                                  ),
                                                                            ),
                                                                            onPressed: () {
                                                                              if (_formKey.currentState!.validate()) {
                                                                                ctM
                                                                                    .editCategoryBudget(
                                                                                      snapshot.data![index],
                                                                                      double.parse(
                                                                                        budgetAmountController.text,
                                                                                      ),
                                                                                    )
                                                                                    .then(
                                                                                      (
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

                                                                                          Navigator.pop(
                                                                                            context,
                                                                                          );
                                                                                        }
                                                                                      },
                                                                                    );
                                                                              }
                                                                            },
                                                                            child: Text(
                                                                              "Edit envelope",
                                                                              style: TextStyle(
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: Icon(Icons.edit_document),
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
                                                  Colors.green.shade600,
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
                                                "${(snapshot.data![index].spent / snapshot.data![index].budget) * 100}% used",
                                              ),
                                              Text("100% remaining"),
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
