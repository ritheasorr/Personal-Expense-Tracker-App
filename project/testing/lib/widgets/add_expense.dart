import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'pie_chart.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  @override
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // Categories list
  final List<String> _categories = [
    'Groceries',
    'Utilities',
    'Entertainment',
    'Food',
    'Transport'
  ];
  String? _selectedCategory;

  // Date picker logic
  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue, // Header background color
              onPrimary: Colors.white, // Header text color
              surface: Colors.white, // Background color of the calendar
              onSurface: Colors.black, // Text color of the calendar
            ),
            dialogBackgroundColor:
                Colors.white, // Background color of the dialog
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<String?> getToken() async {
    var authBox = Hive.box('authBox');
    return authBox.get('token');
  }

  // Submit the form data
  submitExpense() async {
    // Get user input
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    String category = _categoryController.text;
    String date = _dateController.text;
    String note = _noteController.text;

    // Check if the amount is valid and the other fields are not empty
    if (amount.isNaN || amount <= 0 || category.isEmpty || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Please fill in all the fields and provide a valid amount!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Get the response from the API
      var response = await AddExpense(amount, category, date, note);

      // Check if the response is successful (status code 200)
      if (response['message'] == 'Expense added successfully.') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // reload the page
      } else {
        // Handle failed response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add expense!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Catch network errors or any other errors
      print('Error: $e'); // Print the error for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add expense. Please try again!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> AddExpense(
      double amount, String category, String date, String note) async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/expenses'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Use the actual token here
      },
      body: jsonEncode(<String, dynamic>{
        'amount': amount,
        'category': category,
        'date': date,
        'note': note,
      }),
    );

    print(response.statusCode);

    if (response.statusCode == 201) {
      print("success");
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add expense from api');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount'),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter the amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text('Category'),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _categoryController.text = value!;
                });
              },
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                filled: true, // Enable background fill
                fillColor: Colors.white,
              ),
              dropdownColor: Colors.white,
              hint: Text('Select category'),
            ),
            SizedBox(height: 16),
            Text('Date'),
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Pick a date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 16),
            Text('Note'),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Enter a note',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await submitExpense();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Button background color
                  foregroundColor: Colors.blue, // Button text color
                ),
                child: Text('Add Expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
