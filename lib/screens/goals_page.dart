import 'package:flutter/material.dart';
import 'package:flutter_application_1/data-models/goals.dart';
import 'package:flutter_application_1/models/categories.dart';
import 'package:provider/provider.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});
  @override
  GoalsPageState createState() => GoalsPageState();
}

class GoalsPageState extends State<GoalsPage> {
  TextEditingController newGoalNameController = TextEditingController();

  TextEditingController newGoalAmountController = TextEditingController();

  TextEditingController newCurrentAmountController = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? selectedDate;

  final _formKey = GlobalKey<FormState>();
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2021, 7, 25),
      firstDate: DateTime(2021),
      lastDate: DateTime(2022),
    );

    setState(() {
      selectedDate = pickedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalModel>(
      builder: (context, gM, child) {
        return MaterialApp(
          theme: ThemeData(colorSchemeSeed: Colors.blue),
          home: Scaffold(
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
                          IconButton(
                            iconSize: 25,
                            color: Colors.blue.shade600,
                            onPressed: () => showDialog<String>(
                              context: context,
                              builder: (context) => SafeArea(
                                child: Dialog(
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Add New Goal",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 5,
                                            ),
                                            child: TextFormField(
                                              controller: newGoalNameController,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter valid goal name';
                                                }
                                                return null;
                                              },
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                hintText: 'e.g Vacation Fund',
                                                labelText: "Goal Name",
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
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
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
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
                                                      ? selectedDate.toString()
                                                      : "Selected date",
                                                ),
                                              ),
                                            ),
                                          ),
                                          // padding: EdgeInsets.all(10),
                                          SafeArea(
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
                                                        >(Colors.grey.shade600),
                                                  ),
                                                  onPressed: () {
                                                    newGoalNameController.text =
                                                        '';

                                                    newGoalNameController.text =
                                                        newCurrentAmountController
                                                                .text =
                                                            "";
                                                    newCurrentAmountController
                                                            .text =
                                                        '';

                                                    selectedDate = null;
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
                                                        WidgetStatePropertyAll<
                                                          Color
                                                        >(Colors.blue.shade600),
                                                  ),
                                                  onPressed: () {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      gM
                                                          .insertGoal(
                                                            Goal(
                                                              targetDate:
                                                                  selectedDate
                                                                      .toString(),
                                                              initialAmount:
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
                                                              targetAmount:
                                                                  double.parse(
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
                                                                  content:
                                                                      const Text(
                                                                        "Goal created",
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
                            ),
                            icon: Icon(Icons.add_box),
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
      },
    );
  }
}
