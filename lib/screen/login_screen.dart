import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text);
      // เมื่อ Login สำเร็จ AuthGate จะสลับไปหน้า HomeScreen เอง
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เข้าสู่ระบบไม่สำเร็จ: ${e.message}")),
      );
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MicroFund - เข้าสู่ระบบ"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 49, 224, 157),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("อีเมล", style: TextStyle(fontSize: 20)),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    hintText: "กรอกอีเมลของคุณ",
                  ),
                  validator: MultiValidator([
                    EmailValidator(errorText: "รูปแบบอีเมลไม่ถูกต้อง"),
                    RequiredValidator(errorText: "กรุณาป้อนอีเมลด้วยครับ"),
                  ]),
                ),
                const SizedBox(height: 15),
                const Text("รหัสผ่าน", style: TextStyle(fontSize: 20)),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    hintText: "กรอกรหัสผ่านของคุณ",
                  ),
                  validator: RequiredValidator(
                      errorText: "กรุณาป้อนรหัสผ่านด้วยครับ"),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: loading
                        ? const SizedBox.shrink()
                        : const Icon(Icons.login),
                    onPressed: loading ? null : login,
                    label: loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Text(
                            "เข้าสู่ระบบ",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 15),
                // ปุ่มช่วยกรอกบัญชีทดสอบ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                                            onPressed: () {
                        emailController.text = "admin@test.com";
                        passwordController.text = "123456";
                      },
                      label: const Text("กรอกบัญชี Admin"),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        emailController.text = "operator@test.com";
                        passwordController.text = "123456";
                      },
                      label: const Text("กรอกบัญชี Operator"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}