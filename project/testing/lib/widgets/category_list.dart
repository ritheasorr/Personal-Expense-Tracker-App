import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:hive/hive.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

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

  Future<List<String>> fetchCategories() async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token not found');
    }

    // Extract userId from the token
    String userId = getUserIdFromToken(token);
    print('UserId: $userId');

    // Append userId to the API URL
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/expenses?userId=$userId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Check if 'expense' exists and is not null
      if (data.containsKey('expenses') && data['expenses'] != null) {
        List expenses = data['expenses'];

        // Use a Set to store unique categories
        Set<String> uniqueCategories = {};

        // Add categories to the Set (duplicates are automatically ignored)
        for (var expense in expenses) {
          if (expense['CATEGORY'] != null) {
            uniqueCategories.add(expense['CATEGORY'] as String);
          }
        }

        // Convert the Set back to a List
        return uniqueCategories.toList();
      } else {
        throw Exception('No expense data found in the response');
      }
    } else {
      throw Exception('Failed to load expenses: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
    ];

    return Expanded(
      flex: 3,
      child: FutureBuilder<List<String>>(
        future: fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No categories available.'));
          } else {
            List<String> categories = snapshot.data!;
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        height: 7,
                        width: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors[
                              index % colors.length], // Cycle through colors
                        ),
                      ),
                      SizedBox(width: 20),
                      Text(categories[index]),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
