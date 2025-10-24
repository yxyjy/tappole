import 'package:flutter/material.dart';
import 'package:tappolev1/pages/auth/otploginflow.dart';
import 'package:tappolev1/pages/auth/emailloginflow.dart';

enum AuthFlow { emailLogin, otpLogin }

class MainAuth extends StatefulWidget {
  final AuthFlow authFlow;

  const MainAuth({super.key, this.authFlow = AuthFlow.emailLogin});

  @override
  State<MainAuth> createState() => _MainAuthState();
}

class _MainAuthState extends State<MainAuth> {
  @override
  Widget build(BuildContext context) {
    switch (widget.authFlow) {
      case AuthFlow.emailLogin:
        return const Emailloginflow();
      case AuthFlow.otpLogin:
        return const Otploginflow();
    }
  }
}
