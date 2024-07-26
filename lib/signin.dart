import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _ipController = TextEditingController();
  String _email = "";
  bool _isSignedIn = false;
  String accessToken = "";
  String idToken = "";
  String refreshToken = "";
  String expiry = "";

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/gmail.readonly',
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Sign-In')),
      body: SingleChildScrollView(
        child: Center(
          child: _isSignedIn
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _ipController,
                      decoration: InputDecoration(
                        labelText: 'Enter Server IP Address',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _signOut,
                      child: Text('Sign Out'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        String ipAddress = _ipController.text.isNotEmpty
                            ? _ipController.text
                            : '192.168.1.37'; // Default IP if none is provided
                        await _sendTokensToServer(ipAddress);
                      },
                      child: Text('Send Token to Go Server'),
                    ),
                    SizedBox(height: 16),
                    Text('Signed in as: $_email'),
                    SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Access Token: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          TextSpan(
                            text: accessToken,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'ID Token: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          TextSpan(
                            text: idToken,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Refresh Token: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          TextSpan(
                            text: refreshToken,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Expiry: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          TextSpan(
                            text: expiry,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : ElevatedButton(
                  onPressed: _signInWithGoogle,
                  child: Text('Sign in with Google'),
                ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      setState(() {
        accessToken = googleAuth.accessToken!;
        idToken = googleAuth.idToken!;
        // refreshToken and expiry are not provided by google_sign_in
        _email = googleUser.email;
        _isSignedIn = true;
      });

      // Fetch user's email
      // You already have the email from googleUser.email
    } catch (error) {
      print('Sign-in failed: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sign-in failed: $error')));
    }
  }

  Future<void> _sendTokensToServer(String ipAddress) async {
    final Map<String, dynamic> tokenData = {
      'access_token': accessToken,
      'token_type': 'Bearer',
      'id_token': idToken,
    };

    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress:8080/store-tokens'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(tokenData),
      );
      if (response.statusCode == 200) {
        print('Tokens sent to server successfully');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tokens sent to server successfully')));
      } else {
        print('Failed to send tokens to server');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to send tokens to server')));
      }
    } catch (e) {
      print('Error sending tokens to server: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error sending tokens to server: $e')));
    }
  }

  Future<void> _signOut() async {
    await _googleSignIn.signOut();
    setState(() {
      _email = "";
      _isSignedIn = false;
      accessToken = "";
      idToken = "";
      refreshToken = "";
      expiry = "";
    });
  }
}
