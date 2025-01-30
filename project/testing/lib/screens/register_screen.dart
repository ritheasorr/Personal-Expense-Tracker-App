import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding
import 'package:testing/Hexcolor.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController =
      TextEditingController(); // Username field
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _ishidden = true;

  // Function to handle registration
  register() async {
    String email = _emailController.text;
    String username = _usernameController.text; // Username input
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Check if email, username, and passwords are filled and match
    if (email.isNotEmpty &&
        email.contains('@') &&
        email.contains('.com') &&
        username.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty) {
      if (password == confirmPassword) {
        try {
          var response = await registerRequest(email, username, password);

          if (response != null && response['success'] == true) {
            // Successfully registered, navigate to login page or home screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Registered successfully')),
            );
          } else {
            String errorMessage =
                response['message'] ?? 'Registration failed, please try again';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Network error: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passwords do not match')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required')),
      );
    }
  }

  Future<Map<String, dynamic>> registerRequest(
      String email, String username, String password) async {
    final url =
        'http://10.0.2.2:3000/api/auth/register'; // Your backend URL for registration
    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        'email': email,
        'username': username, // Adding username to the request
        'hashed_pass': password,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    // Log the response to see what is returned from the server
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      // Return a more specific error message from the backend response if available
      return {
        'success': true,
        'message': 'Failed to register, please try again. Error:',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Hexcolor.lavender,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 20),
                      child: Form(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: buildFormBox(
                                'Username',
                                TextInputType.text,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your username';
                                  } else {
                                    return null;
                                  }
                                },
                                _usernameController, // Pass the controller here
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: buildFormBox(
                                'Email',
                                TextInputType.text,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  } else if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  } else {
                                    return null;
                                  }
                                },
                                _emailController, // Pass the controller here
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: buildFormBox(
                                'Password',
                                TextInputType.text,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  } else {
                                    return null;
                                  }
                                },
                                _passwordController, // Pass the controller here
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: buildFormBox(
                                'Confirm password',
                                TextInputType.text,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password again';
                                  } else {
                                    return null;
                                  }
                                },
                                _confirmPasswordController, // Pass the controller here
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  register();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Hexcolor.plum,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                side:
                                    BorderSide(color: Hexcolor.plum, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text(
                                'Back to login',
                                style: TextStyle(
                                  color: Hexcolor.plum,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFormBox(
    String label,
    TextInputType keyboardType,
    String? Function(String?)? validator,
    TextEditingController controller, {
    // Pass the controller here
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller, // Set the controller here
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Hexcolor.deepPurple,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(color: Colors.black),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
    );
  }
}
