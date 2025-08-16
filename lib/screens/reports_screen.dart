import 'package:flutter/material.dart';
import 'package:flutter_application_1/view_models/weekly_reports.dart';
import 'package:watch_it/watch_it.dart';

class ReportsScreen extends StatefulWidget with WatchItStatefulWidgetMixin {
  const ReportsScreen({super.key});
  @override
  ReportsScreenState createState() => ReportsScreenState();
}

class ReportsScreenState extends State<ReportsScreen> {
  String? dropdownValue = di<WeeklyReportsModel>().weeks.first;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(3),
              sliver: SliverToBoxAdapter(
                child: ListTile(
                  title: Text(
                    'Financial Reports',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  subtitle: Text('Your spending insights'),
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.all(3),
              sliver: SliverToBoxAdapter(
                child: Card.outlined(
                  color: Colors.white,
                  child: Column(
                    children: [
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Weekly Insights',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            watchPropertyValue(
                                  (WeeklyReportsModel m) => m.weeks,
                                ).isNotEmpty
                                ? DropdownButton<String>(
                                    value: dropdownValue,
                                    icon: Icon(Icons.arrow_downward),
                                    elevation: 16,
                                    style: TextStyle(color: Colors.deepPurple),
                                    underline: Container(
                                      height: 2,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                    onChanged: (String? value) {
                                      // This is called when the user selects an item.
                                      setState(() {
                                        dropdownValue = value!;
                                      });
                                    },
                                    items:
                                        watchPropertyValue(
                                          (WeeklyReportsModel m) => m.weeks,
                                        ).map<DropdownMenuItem<String>>((
                                          String value,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                  )
                                : Text('no reports'),
                          ],
                        ),
                        subtitle: Text(
                          'Category spending vs last week',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Card(
                        color: Colors.grey.shade50,
                        child: ListTile(
                          title: Text('Transport'),
                          subtitle: Text('KSh 3,200 this week'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
