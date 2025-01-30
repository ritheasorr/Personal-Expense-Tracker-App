import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AuthService {
  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final response = await http.post(
      Uri.parse(registerEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'hashed_pass': password,
      }),
    );

    if (response.statusCode == 201) {
      return {'success': true, 'message': jsonDecode(response.body)['message']};
    } else {
      final error = jsonDecode(response.body)['message'];
      return {'success': false, 'message': error};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(loginEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'token': data['token'],
        'message': data['message'],
      };
    } else {
      final error = jsonDecode(response.body)['message'];
      return {'success': false, 'message': error};
    }
  }
}
