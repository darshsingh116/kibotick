// sign_in_screen.dart
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';

class SignInScreen2 extends StatefulWidget {
  @override
  _SignInScreen2State createState() => _SignInScreen2State();
}

class _SignInScreen2State extends State<SignInScreen2> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Dio _dio = Dio(); // Create a Dio instance
  String _email = "";
  bool _isSignedIn = false;
  String accessToken="";
  String idToken ="";
  String refreshToken ="";
  final TextEditingController _ipController = TextEditingController();




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
                      await _sendTokensToServer(ipAddress, accessToken, idToken, refreshToken);
                    },
                    child: Text('Send Token to go server'),
                  ),
                  SizedBox(height: 16),
                  Text('Signed in as: $_email'),
                  SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Access Token: ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        TextSpan(
                          text: refreshToken,
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
      final GoogleSignInAccount? user = await _googleSignIn.signIn();
      if (user != null) {
        final GoogleSignInAuthentication auth = await user.authentication;
        
        final String myrefreshToken = await _googleSignIn.currentUser?.serverAuthCode ?? '';
        
        setState(() {
        accessToken = auth.accessToken!;
        idToken = auth.idToken!;
        refreshToken = myrefreshToken;
          _email = user.email;
          _isSignedIn = true;
        });
        // await _sendTokensToServer(accessToken, idToken, refreshToken);
      }
    } catch (error) {
      print('Sign-in failed: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-in failed: $error')));
    }
  }

  Future<void> _sendTokensToServer(String ipAddress,String accessToken, String idToken, String refreshToken) async {
    try {
      final response = await _dio.post(
        'http://$ipAddress:8080/store-tokens',
        data: {
          'accessToken': accessToken,
          'idToken': idToken,
          'refreshToken': refreshToken,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode == 200) {
        print('Tokens sent to server successfully');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tokens sent to server successfully')));

      } else {
        print('Failed to send tokens to server');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send tokens to server')));
      }
    } catch (e) {
      print('Error sending tokens to server: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sending tokens to server: $e')));
    }
  }


  Future<void> _signOut() async {
    await _googleSignIn.signOut();
    setState(() {
      _email = "";
      _isSignedIn = false;
    });
  }
}
