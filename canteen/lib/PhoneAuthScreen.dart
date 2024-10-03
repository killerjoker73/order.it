import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String _verificationId = '';
  bool _isLoading = false;

  // Initialize Firebase App Check
  @override
  void initState() {
    super.initState();
    _initializeFirebaseAppCheck(); // Call to initialize App Check
  }

  Future<void> _initializeFirebaseAppCheck() async {
    await Firebase.initializeApp(); // Initialize Firebase if not done
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          AndroidProvider.debug, // For Android, use debug in development
      // iosProvider: ... // Configure for iOS if needed
    );
  }

  // Method to send OTP
  void _verifyPhoneNumber() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: '+91${_phoneController.text}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        setState(() {
          _isLoading = false;
        });
        print("Phone number automatically verified");
        Navigator.pushReplacementNamed(
            context, '/menu'); // Navigate after verification
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _isLoading = false;
        });
        print("Verification failed: ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification failed: ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isLoading = false;
        });
        print("OTP has been successfully sent.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP sent successfully.")),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
        print("Auto retrieval timeout.");
      },
      timeout: Duration(seconds: 2),
    );
  }

  // Method to sign in with the received OTP
  void _signInWithOTP() async {
    try {
      setState(() {
        _isLoading = true;
      });
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text,
      );
      await _auth.signInWithCredential(credential);
      setState(() {
        _isLoading = false;
      });
      print("Successfully signed in with OTP.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Successfully signed in with OTP.")),
      );
      Navigator.pushReplacementNamed(
          context, '/menu'); // Navigate after signing in
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error signing in with OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing in with OTP: $e")),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phone Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _verifyPhoneNumber,
                    child: Text('Verify Phone Number'),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Enter OTP'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _signInWithOTP,
                    child: Text('Sign In with OTP'),
                  ),
                ],
              ),
      ),
    );
  }
}
