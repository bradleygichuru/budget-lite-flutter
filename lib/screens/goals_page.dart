import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/constants/globals.dart';
import 'package:flutter_application_1/data_models/goal_data_model.dart';
import 'package:flutter_application_1/screens/handle_savings.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:flutter_application_1/view_models/goals.dart';
import 'package:showcaseview/showcaseview.dart';
import 'dart:developer';

import 'package:watch_it/watch_it.dart';

class GoalsPage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const GoalsPage({super.key});
  @override
  GoalsPageState createState() => GoalsPageState();
}

class GoalsPageState extends State<GoalsPage> {
  GoalModel gM = di.get<GoalModel>();
  TextEditingController newGoalNameController = TextEditingController();

  TextEditingController newGoalAmountController = TextEditingController();

  TextEditingController newCurrentAmountController = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? selectedDate;
  double goalPercentageComplete(Goal goal) {
    if (goal.currentAmount != null) {
      return (goal.currentAmount! / goal.targetAmount * 100).roundToDouble();
    }

    return 0;
  }

  double remainingAmount(Goal goal) {
    return goal.currentAmount != null
        ? goal.targetAmount - goal.currentAmount!
        : 0;
  }

  final _formKey = GlobalKey<FormState>();
  Future<void> _selectDate() async {
    DateTime today = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(today.year + 100),
    );

    setState(() {
      selectedDate = pickedDate;
    });
  }

  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback(
    //   (_) => di<AuthModel>().shouldShowCase
    //       ? ShowCaseWidget.of(
    //           context,
    //         ).startShowCase([AppGlobal.addFinancialGoals])
    //       : null,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        key: scaffoldKey,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(10),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Financial Goals",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Showcase(
                        key: AppGlobal.addFinancialGoals,
                        description: "Add financial Goals",

                        onBarrierClick: () {
                          ShowCaseWidget.of(
                            context,
                          ).hideFloatingActionWidgetForKeys([
                            AppGlobal.addFinancialGoals,
                          ]);

                          // di<AuthModel>().completeShowcase();
                          // log(
                          //   "Complete Showcase: ${di<AuthModel>().shouldShowCase}",
                          // );
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
                            builder: (context) => SafeArea(
                              child: SingleChildScrollView(
                                child: AlertDialog(
                                  title: Text(
                                    "Add New Goal",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  content: SafeArea(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
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
                                                    newGoalNameController,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter valid goal name';
                                                  }
                                                  return null;
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      hintText:
                                                          'e.g Vacation Fund',
                                                      labelText: "Goal Name",
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
                                                    newGoalAmountController,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  hintText: "e.g 5000",
                                                  labelText: 'Target Amount',
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
                                                keyboardType:
                                                    TextInputType.number,
                                                controller:
                                                    newCurrentAmountController,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  hintText: "e.g 5000",
                                                  labelText:
                                                      'Current Amount (Optional)',
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(3),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: OutlinedButton(
                                                  onPressed: () {
                                                    _selectDate();
                                                  },
                                                  child: Text(
                                                    selectedDate != null
                                                        ? selectedDate
                                                              .toString()
                                                        : "Selected date",
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // padding: EdgeInsets.all(10),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    SafeArea(
                                      child: FilledButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll<Color>(
                                                Colors.grey.shade600,
                                              ),
                                        ),
                                        onPressed: () {
                                          newGoalNameController.text = '';

                                          newGoalNameController.text =
                                              newCurrentAmountController.text =
                                                  "";
                                          newCurrentAmountController.text = '';

                                          selectedDate = null;
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    SafeArea(
                                      child: FilledButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll<Color>(
                                                Colors.blue.shade600,
                                              ),
                                        ),
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            int? accountId = await di
                                                .get<AuthModel>()
                                                .getAccountId();
                                            if (selectedDate != null &&
                                                accountId != null) {
                                              gM
                                                  .insertGoal(
                                                    Goal(
                                                      targetDate: selectedDate
                                                          .toString(),
                                                      currentAmount:
                                                          newCurrentAmountController
                                                              .text
                                                              .isNotEmpty
                                                          ? double.parse(
                                                              newCurrentAmountController
                                                                  .text,
                                                            )
                                                          : 0,
                                                      name:
                                                          newGoalNameController
                                                              .text,
                                                      targetAmount: double.parse(
                                                        newGoalAmountController
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
                                                            "Goal created",
                                                          ),
                                                        ),
                                                      );

                                                      Navigator.pop(context);
                                                    }
                                                  });
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: const Text(
                                                    "No date selected or account id missing",
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: Text(
                                          "Add Goal",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          icon: Icon(Icons.add_box),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FutureBuilder<List<Goal>>(
                future: watchPropertyValue((GoalModel m) => m.goals),
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
                                        borderRadius: BorderRadius.circular(2),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.blue.shade600,
                                            ),
                                        value:
                                            (snapshot
                                                .data![index]
                                                .currentAmount! /
                                            snapshot.data![index].targetAmount),
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
                                                    padding: EdgeInsets.all(3),
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
                                                    padding: EdgeInsets.all(3),
                                                    child: Text(
                                                      '${DateTime.now().isBefore(DateTime.parse(snapshot.data![index].targetDate)) ? '' : 'Past due'}',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Colors.red.shade600,
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
                                                    padding: EdgeInsets.all(3),
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
                                                  // Padding(
                                                  //   padding: EdgeInsets.all(3),
                                                  //   child: Text(
                                                  //     'Goal overdue',
                                                  //     style: TextStyle(
                                                  //       fontSize: 14,
                                                  //       color:
                                                  //           Colors.grey.shade600,
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const HandleSavings(),
                                          ),
                                        );
                                      },

                                      style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                          Colors.blue.shade600,
                                        ),
                                      ),
                                      child: Text("Add Money to Goal"),
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
              ),

              SliverPadding(
                padding: EdgeInsetsGeometry.all(15),
                sliver: SliverToBoxAdapter(child: Text(' ')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
