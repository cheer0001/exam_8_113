import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authController = AuthController();
  bool loading = false;
  bool _obscurePassword = true;

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      await authController.signIn(
        email: emailController.text,
        password: passwordController.text,
      );
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
    // ธีมสีแอป MicroFund
    const primaryGreen = Color(0xFF31E09D); // สีเขียวสว่างโทน MicroFund
    const darkGreenButton = Color(0xFF238B61); // สีเขียวเข้มสำหรับปุ่ม
    const bgLight = Color(0xFFF7F9F8);

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ===== โลโก้แบรนด์ MicroFund =====
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 45,
                      color: darkGreenButton,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ===== ชื่อระบบ MicroFund =====
                  const Text(
                    "MicroFund",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "เข้าสู่ระบบเพื่อจัดการกองทุนและสินเชื่อ",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 28),

                  // ===== ช่องกรอกอีเมล =====
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "อีเมล",
                      hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.black54, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black26),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black26),
                      ),
                    ),
                    validator: MultiValidator([
                      EmailValidator(errorText: "รูปแบบอีเมลไม่ถูกต้อง"),
                      RequiredValidator(errorText: "กรุณาป้อนอีเมลด้วยครับ"),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  // ===== ช่องกรอกรหัสผ่าน =====
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: "รหัสผ่าน",
                      hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.black54, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.black54,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black26),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black26),
                      ),
                    ),
                    validator: RequiredValidator(
                        errorText: "กรุณาป้อนรหัสผ่านด้วยครับ"),
                  ),
                  const SizedBox(height: 20),

                  // ===== ปุ่มเข้าสู่ระบบ =====
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkGreenButton,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: loading ? null : login,
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "เข้าสู่ระบบ",
                                  style: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===== ลิงก์ช่วยเหลือ =====
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "ลืมรหัสผ่าน?",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "ยังไม่มีบัญชี? ",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "สมัครสมาชิก",
                          style: TextStyle(
                            fontSize: 13,
                            color: darkGreenButton,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ===== บัญชีทดสอบ =====
                  const Divider(color: Colors.black12, height: 1),
                  const SizedBox(height: 16),
                  const Text(
                    "บัญชีทดสอบ (สำหรับตรวจงาน)",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black26),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: const Icon(Icons.admin_panel_settings_outlined,
                              size: 16, color: darkGreenButton),
                          label: const Text(
                            "ทดสอบ Admin",
                            style: TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                          onPressed: () {
                            emailController.text = "admin@test.com";
                            passwordController.text = "123456";
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black26),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: const Icon(Icons.person_outline,
                              size: 16, color: darkGreenButton),
                          label: const Text(
                            "ทดสอบ Operator",
                            style: TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                          onPressed: () {
                            emailController.text = "operator@test.com";
                            passwordController.text = "123456";
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}