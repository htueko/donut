import 'package:flutter/material.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({required this.isLogin, super.key});

  final bool isLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('Otp (login: $isLogin, C10)')),
    );
  }
}
