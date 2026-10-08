import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'login_screen.dart';

/// ตัดสินว่าจะแสดงหน้า Login หรือหน้าหลัก ตามสถานะการเข้าสู่ระบบ
/// และอ่าน role ของผู้ใช้จาก collection "users"
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // อ่าน role จาก users/{uid} ถ้ายังไม่มีเอกสารจะสร้างให้อัตโนมัติ
  // (admin@test.com = Admin, นอกนั้น = Operator)
  Future<String> loadRole(User user) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await ref.get();
    if (doc.exists) {
      return doc['role'];
    }
    final email = user.email ?? '';
    final role = email == 'admin@test.com' ? 'Admin' : 'Operator';
    await ref.set({
      "uid": user.uid,
      "name": email.split('@').first,
      "email": email,
      "role": role,
    });
    return role;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }
        return FutureBuilder<String>(
          future: loadRole(user),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.hasError) {
              return Scaffold(
                appBar: AppBar(title: const Text("Error"), actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => FirebaseAuth.instance.signOut(),
                  ),
                ]),
                body: Center(child: Text("${roleSnapshot.error}")),
              );
            }
            if (!roleSnapshot.hasData) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            return HomeScreen(role: roleSnapshot.data!);
          },
        );
      },
    );
  }
}