import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ui3/pages/login_page.dart';
import 'home_page.dart';
import 'login_or_register_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return TimeTable(
              isHOD: snapshot.data?.email == "hod@vit.edu",
            );
          } else {
            return const LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
