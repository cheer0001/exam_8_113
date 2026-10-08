import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'home/home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = AuthController();

    return StreamBuilder<User?>(
      stream: authController.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder<String>(
          future: authController.getUserRole(user),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.hasError) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text("Error"),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => authController.signOut(),
                    ),
                  ],
                ),
                body: Center(child: Text("${roleSnapshot.error}")),
              );
            }

            if (!roleSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return HomeScreen(role: roleSnapshot.data!);
          },
        );
      },
    );
  }
}