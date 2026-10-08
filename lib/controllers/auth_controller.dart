import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ดึง User ปัจจุบัน
  User? get currentUser => _auth.currentUser;

  // Stream คอยตรวจสถานะการเปลี่ยน Login / Logout
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ฟังก์ชันเข้าสู่ระบบด้วย อีเมล และ รหัสผ่าน
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // ฟังก์ชันออกจากระบบ
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ดึงสิทธิ์ (Role) จาก Firestore หรือกำหนดจากอีเมล
  Future<String> getUserRole(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null && doc.data()!.containsKey('role')) {
        return doc.data()!['role'] as String;
      }

      // หากยังไม่มีข้อมูลใน Firestore ให้กำหนดตามอีเมล
      final role = user.email == 'admin@test.com' ? 'Admin' : 'Operator';

      // สร้างเอกสารผู้ใช้ใหม่ใน Firestore อัตโนมัติ
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? '',
        'name': user.email?.split('@').first ?? 'User',
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return role;
    } catch (e) {
      debugPrint("Error fetching user role: $e");
      return 'Operator'; // บทบาทเริ่มต้นเมื่อเกิดข้อผิดพลาด
    }
  }
}