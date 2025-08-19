import 'dart:convert';
import 'dart:math';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models/weekly_reports_data_model.dart';
import 'package:flutter_application_1/view_models/weekly_reports.dart';
import 'package:watch_it/watch_it.dart';

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class ReportsScreen extends StatefulWidget with WatchItStatefulWidgetMixin {
  const ReportsScreen({super.key});
  @override
  ReportsScreenState createState() => ReportsScreenState();
}

class ReportsScreenState extends State<ReportsScreen> {
  String dropdownValue = di<WeeklyReportsModel>().firstDropDownValue;
  int touchedIndex = -1;
  List<Color> pieChartColors = List.generate(20, (i) {
    return RandomColor.getColorObject(Options(luminosity: Luminosity.light));
  });

  List<Widget> makeGraphLegend() {
    WeeklyReport weeklyReport = watchPropertyValue(
      (WeeklyReportsModel m) => m.currentReports,
    ).where((report) => report.key == dropdownValue).first;
    Map<String, dynamic> reportData = jsonDecode(weeklyReport.reportData);
    int currIndex = 0;
    return reportData.entries.map((entry) {
      currIndex++;
      return Indicator(
        color: pieChartColors[currIndex],
        text: entry.key,
        isSquare: true,
        // size: touchedIndex == 0 ? 18 : 16,
        // textColor: touchedIndex == 0 ? Colors.white : Colors.white38,
      );
    }).toList();
  }

  List<PieChartSectionData> makeGraphData() {
    // Color widgetColor = RandomColor.getColorObject(
    //   Options(colorType: ColorType.blue, luminosity: Luminosity.light),
    // );
    WeeklyReport weeklyReport = watchPropertyValue(
      (WeeklyReportsModel m) => m.currentReports,
    ).where((report) => report.key == dropdownValue).first;
    Map<String, dynamic> reportData = jsonDecode(weeklyReport.reportData);
    int currIndex = 0;
    return reportData.entries.map((entry) {
      final isTouched = currIndex == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      currIndex++;
      return PieChartSectionData(
        color: pieChartColors[currIndex],
        value: entry.value,
        title: entry.key,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          shadows: shadows,
        ),
      );
    }).toList();
  }

  Iterable<Widget> makeCards() {
    int currIndex = 0;
    WeeklyReport weeklyReport = watchPropertyValue(
      (WeeklyReportsModel m) => m.currentReports,
    ).where((report) => report.key == dropdownValue).first;
    Map<String, dynamic> reportData = jsonDecode(weeklyReport.reportData);

    int indexOfCurr = watchPropertyValue(
      (WeeklyReportsModel m) => m.currentReports,
    ).indexOf(weeklyReport);
    int indexOfPrev = indexOfCurr > 0 ? indexOfCurr - 1 : 0;

    Map<String, dynamic>? prevReportData = jsonDecode(
      watchPropertyValue(
        (WeeklyReportsModel m) => m.currentReports,
      )[indexOfPrev].reportData,
    );
    String percentageChange(String key) {
      if (prevReportData != null && reportData != null) {
        double x =
            (reportData[key] - prevReportData[key]) / reportData[key] * 100;
        return x.isNegative
            ? '${x.toStringAsPrecision(2)}% decrease'
            : '${x.toStringAsPrecision(2)}% increase';
      } else {
        return 'No change';
      }
    }

    return reportData.entries.map((entry) {
      currIndex++;
      return Padding(
        padding: EdgeInsets.all(7),
        child: Card(
          color: Colors.grey.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ListTile(
                  leading: Icon(
                    size: 12,
                    Icons.circle_rounded,
                    color: pieChartColors[currIndex],
                  ),
                  title: Text(
                    entry.key,
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 14),
                  ),
                  subtitle: Text(
                    'Ksh${entry.value} this week',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ),
              ),
              // Text(percentageChange(entry.key)),
            ],
          ),
        ),
      );
    });
  }

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
                    mainAxisSize: MainAxisSize.min,
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
                                : Text(''),
                          ],
                        ),
                        subtitle: Text(
                          'Category spending',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      watchPropertyValue(
                            (WeeklyReportsModel m) => m.currentReports,
                          ).isNotEmpty
                          ? Column(children: makeCards().toList())
                          : Text('No reports to show'),
                      watchPropertyValue(
                            (WeeklyReportsModel m) => m.currentReports,
                          ).isNotEmpty
                          ? Padding(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,

                                    children: makeGraphLegend(),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    height: 200,
                                    child: PieChart(
                                      PieChartData(
                                        sections: makeGraphData(),
                                        pieTouchData: PieTouchData(
                                          touchCallback:
                                              (
                                                FlTouchEvent event,
                                                pieTouchResponse,
                                              ) {
                                                setState(() {
                                                  if (!event
                                                          .isInterestedForInteractions ||
                                                      pieTouchResponse ==
                                                          null ||
                                                      pieTouchResponse
                                                              .touchedSection ==
                                                          null) {
                                                    touchedIndex = -1;
                                                    return;
                                                  }
                                                  touchedIndex =
                                                      pieTouchResponse
                                                          .touchedSection!
                                                          .touchedSectionIndex;
                                                });
                                              },
                                        ),
                                        borderData: FlBorderData(show: false),
                                        sectionsSpace: 5,
                                        centerSpaceRadius: 40,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(7),
                            )
                          : Text('No reports to show'),
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
