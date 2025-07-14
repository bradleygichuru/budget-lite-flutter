import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/categories.dart';
import 'package:provider/provider.dart';

class CategoryWithClickState extends Category {
  bool clicked = false;
  CategoryWithClickState({
    required this.clicked,
    required super.categoryName,
    required super.budget,
    required super.spent,
    super.id,
  });
}

class SetupBudget extends StatefulWidget {
  const SetupBudget({super.key});
  @override
  SetupBudgetState createState() => SetupBudgetState();
}

class SetupBudgetState extends State<SetupBudget> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController newCategoryNameController = TextEditingController();

  TextEditingController newBudgetAmountController = TextEditingController();

  List<Category> categories = [
    Category(categoryName: "Groceries", budget: 8000, spent: 0),
    Category(categoryName: "Rent", budget: 15000, spent: 0),
    Category(categoryName: "Transport", budget: 3000, spent: 0),
  ];
  List<CategoryWithClickState> commonCategories = [
    CategoryWithClickState(
      clicked: false,
      categoryName: "Entertainment",
      budget: 5000,
      spent: 0,
    ),

    CategoryWithClickState(
      clicked: false,
      categoryName: "Airtime",
      budget: 1000,
      spent: 0,
    ),

    CategoryWithClickState(
      clicked: false,
      categoryName: "Emergency Fund",
      budget: 5000,
      spent: 0,
    ),

    CategoryWithClickState(
      clicked: false,
      categoryName: "Health",
      budget: 3000,
      spent: 0,
    ),

    CategoryWithClickState(
      clicked: false,
      categoryName: "Education",
      budget: 2000,
      spent: 0,
    ),

    CategoryWithClickState(
      clicked: false,
      categoryName: "Shopping",
      budget: 4000,
      spent: 0,
    ),
  ];

  List<Widget> generateCommonCategories() {
    List<Widget> x = [];
    for (CategoryWithClickState cat in commonCategories) {
      x.add(
        Padding(
          padding: EdgeInsets.all(0),
          child: SizedBox(
            width: 180,
            height: 100,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                fixedSize: Size.fromWidth(60),
              ),
              onPressed: () {
                setState(() {
                  cat.clicked = true;
                  categories.add(
                    Category(
                      categoryName: cat.categoryName,
                      budget: cat.budget,
                      spent: cat.spent,
                    ),
                  );
                });
              },
              child: Card(
                color: (cat.clicked ? Colors.green.shade50 : Colors.white),
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SafeArea(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            cat.categoryName,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      SafeArea(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "ksh ${cat.budget}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
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
        ),
      );
    }

    return x;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade700,
          title: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(7),
                child: Text(
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,

                    color: Colors.white,
                  ),
                  "Set up your budget",
                ),
              ),
              Center(
                child: Text(
                  style: TextStyle(fontSize: 14, color: Colors.white),
                  "Choose categories that match your spending",
                ),
              ),
            ],
          ),
        ),
        body: Container(
          color: Colors.white,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(10),
                sliver: SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Your Budget Categories",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  TextEditingController monthlyBudget = TextEditingController(
                    text: categories[index].budget.toString(),
                  );
                  return Card(
                    color: Colors.grey.shade50,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                categories[index].categoryName,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    for (CategoryWithClickState item
                                        in commonCategories) {
                                      if (categories[index].categoryName ==
                                          item.categoryName) {
                                        item.clicked = false;
                                      }
                                    }
                                    categories.removeWhere(
                                      (item) =>
                                          item.categoryName ==
                                          categories[index].categoryName,
                                    );
                                  });
                                },
                                icon: Icon(
                                  Icons.close_outlined,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 10,
                          ),
                          child: TextField(
                            controller: monthlyBudget,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),

                              labelText: "Monthly budget",
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              SliverPadding(
                padding: EdgeInsets.all(10),
                sliver: SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Add Common Categories",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Wrap(children: generateCommonCategories()),
              ),

              SliverPadding(
                padding: EdgeInsets.all(10),
                sliver: SliverToBoxAdapter(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Colors.blue.shade600,
                      ),
                    ),

                    onPressed: () {
                      showDialog<String>(
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
                                    "Add New Category",
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
                                          return 'Please enter valid Category';
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
                                            newBudgetAmountController.text = '';

                                            newCategoryNameController.text = '';
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
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              setState(() {
                                                categories.add(
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
                                                );
                                              });

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: const Text(
                                                    "Category created",
                                                  ),
                                                ),
                                              );

                                              newBudgetAmountController.text =
                                                  '';

                                              newCategoryNameController.text =
                                                  '';
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: Text(
                                            "Add Category",
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
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.add),
                        Text(
                          "Add Custom Category",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(10),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Colors.blue.shade600, Colors.indigo.shade700],
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        fixedSize: Size.fromWidth(60),
                      ),
                      onPressed: () {},
                      child: Row(
                        children: [
                          Icon(Icons.add),
                          Text(
                            "Continue to App with (${categories.length} categories)",
                            style: TextStyle(color: Colors.white),
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
      ),
    );
  }
}
