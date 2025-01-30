import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:hive/hive.dart';

class ExpensePieChart extends StatefulWidget {
  @override
  _ExpensePieChartState createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  List<PieChartSectionData> pieChartSections = [];
  bool isLoading = true;
  Timer? _timer;

  List<Color> colors = [
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
  ];

  String getUserIdFromToken(String token) {
    try {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      print('Token Payload: $payload');
      if (payload.containsKey('id')) {
        return payload['id'].toString();
      } else {
        throw Exception('UserId not found in token');
      }
    } catch (e) {
      throw Exception('Invalid token: $e');
    }
  }

  Future<String?> getToken() async {
    var authBox = Hive.box('authBox');
    return authBox.get('token');
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      loadChartData(); // Refresh data every 5 seconds
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchAmountByCategory() async {
    // Replace the token with the actual token
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token not found');
    }

    String userId = getUserIdFromToken(token); // Extract user ID

    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:3000/expenses/amountByCategory?userId=$userId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data.containsKey('expenses') && data['expenses'] != null) {
        List expenses = data['expenses'];

        return expenses.map((expense) {
          return {
            'CATEGORY':
                expense['CATEGORY'] ?? 'Unknown', // Ensure category exists
            'total': expense['total'] ?? 0,
          };
        }).toList();
      } else {
        throw Exception('No expense data found in the response');
      }
    } else {
      throw Exception('Failed to load expenses: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    loadChartData();
    _startTimer();
  }

  Future<void> loadChartData() async {
    setState(() {
      isLoading = true; // Indicate loading state before fetching data
    });

    try {
      List<Map<String, dynamic>> expenseData = await fetchAmountByCategory();

      setState(() {
        pieChartSections = expenseData.asMap().entries.map((entry) {
          int index = entry.key;
          var expense = entry.value;

          return PieChartSectionData(
            color: colors[index % colors.length],
            value: (expense['total']).toDouble(),
            title:
                '${expense['CATEGORY']}\n${expense['total']}', // Title should now appear
            radius: 50,
            titleStyle: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList();

        isLoading = false;
      });
    } catch (error) {
      print('Error loading chart data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : PieChart(PieChartData(
            sections: pieChartSections,
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    return;
                  }
                  final touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;

                  pieChartSections[touchedIndex] =
                      pieChartSections[touchedIndex].copyWith(
                    titleStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                });
              },
            ),
          ));
  }
}
