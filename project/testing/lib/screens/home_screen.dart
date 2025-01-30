import 'package:flutter/material.dart';

import 'package:testing/widgets/category_list.dart';
import 'package:testing/widgets/add_expense.dart';
import 'package:testing/widgets/pie_chart.dart';
import 'package:testing/Hexcolor.dart';
import 'package:testing/widgets/menu_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        backgroundColor: Hexcolor.deepPurple,
        title: Text('Personal Expenses'),
      ),
      drawer: MenuButton(),
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Column(
        children: <Widget>[
          SizedBox(
            height: height * 0.35,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: height * 0.025,
                  ),
                  Text(
                    'Personal Expenses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                      child: Row(
                    children: <Widget>[
                      Expanded(flex: 3, child: CategoryList()),
                      Expanded(flex: 4, child: ExpensePieChart())
                    ],
                  ))
                ],
              ),
            ),
          ),
          Expanded(
            child: AddExpense(),
          )
        ],
      )),
    );
  }
}
