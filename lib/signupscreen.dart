import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'loginscreen.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  Future<void> registerUser(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://143.244.131.156:8000/signup'),
        headers: <String, String>{"content-type": 'application/json'},
        body: jsonEncode(<String, String>{
          'email': emailController.text,
          'password': passwordController.text,
          'name': nameController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody == null) {
          _showSnackBar(context, 'Invalid response from server.');
          return;
        }

        final accessToken = responseBody['access_token'];

        if (accessToken == null) {
          _showSnackBar(context, 'Access token is missing.');
          print('Access token: $accessToken');
          return;
        }

        if (accessToken != null) {
          await storage.write(key: 'access_token', value: accessToken.toString());
        } else {
          _showSnackBar(context, 'Access token is null.');
        }

        if (emailController.text != null && passwordController.text != null) {
          await storage.write(key: 'email', value: emailController.text);
          await storage.write(key: 'password', value: passwordController.text);
        } else {
          _showSnackBar(context, 'Email or password is null.');
        }

        _showSnackBar(context, 'Signup successful!');

        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        });
      } else {
        final responseBody = jsonDecode(response.body);

        // Log the entire response body for debugging
        print('Response body: $responseBody');

        final errorMessage = responseBody['error'] ?? responseBody['message'] ?? 'Unknown error occurred';
        _showSnackBar(context, 'Failed to signup: $errorMessage');
      }
    } catch (e) {
      _showSnackBar(context, 'An error occurred: ${e.toString()}');
    }
  }


  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name',border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20,),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email',border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20,),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password',border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.limeAccent)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      registerUser(context);
                    }
                  },
                  child: Text('Sign Up',style: TextStyle(color: Colors.black),),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}