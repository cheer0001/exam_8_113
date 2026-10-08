import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../../model/loan_project.dart';


class LoanFormScreen extends StatefulWidget {
  final VoidCallback? onSaved; // เรียกหลังบันทึกสำเร็จ (ใช้สลับไปแท็บรายการ)
  const LoanFormScreen({super.key, this.onSaved});

  @override
  State<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends State<LoanFormScreen> {
  final formKey = GlobalKey<FormState>();
  LoanProject myLoan = LoanProject(
      contractId: '', projectName: '', officerEmail: '', principal: '', tenure: '');

  @override
  Widget build(BuildContext context) {
    CollectionReference loanCollection =
        FirebaseFirestore.instance.collection('loans');

    return Scaffold(
      appBar: AppBar(
        title: const Text("แบบฟอร์มยื่นเสนอโครงการเพื่อระดมทุน"),
        backgroundColor: const Color.fromARGB(255, 49, 224, 157),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Sign Out",
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("รหัสสัญญาเงินกู้", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.description), // ไอคอนรหัสสัญญา
                  ),
                  validator: RequiredValidator(
                      errorText: "กรุณาป้อนรหัสสัญญาเงินกู้ด้วยครับ"),
                  onSaved: (contractId) {
                    myLoan.contractId = contractId!;
                  },
                ),
                const SizedBox(height: 15),
                const Text("ชื่อโครงการ / สหกรณ์ผู้กู้", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.business), // ไอคอนชื่อโครงการ/สหกรณ์
                  ),
                  validator: RequiredValidator(
                      errorText: "กรุณาป้อนชื่อโครงการด้วยครับ"),
                  onSaved: (projectName) {
                    myLoan.projectName = projectName!;
                  },
                ),
                const SizedBox(height: 15),
                const Text("อีเมลเจ้าหน้าที่สินเชื่อ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email), // ไอคอนอีเมล
                  ),
                  validator: MultiValidator([
                    EmailValidator(errorText: "รูปแบบอีเมลไม่ถูกต้อง"),
                    RequiredValidator(
                        errorText: "กรุณาป้อนอีเมลด้วยครับ"),
                  ]),
                  onSaved: (officerEmail) {
                    myLoan.officerEmail = officerEmail!;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                const Text("วงเงินที่ต้องการขอกู้ (บาท)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.attach_money), // ไอคอนจำนวนเงิน
                  ),
                  validator: MultiValidator([
                    RequiredValidator(
                        errorText: "กรุณาป้อนวงเงินด้วยครับ"),
                    PatternValidator(r'^[1-9][0-9]*$',
                        errorText: "วงเงินต้องเป็นตัวเลขจำนวนเต็มมากกว่า 0"),
                  ]),
                  onSaved: (principal) {
                    myLoan.principal = principal!;
                  },
                ),
                const SizedBox(height: 15),
                const Text("ระยะเวลาผ่อนชำระ (เดือน)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today), // ไอคอนระยะเวลาผ่อนชำระ
                    hintText: "เช่น 3, 6, 12, 24 เดือน",
                  ),
                  validator: MultiValidator([
                    RequiredValidator(
                        errorText: "กรุณาป้อนระยะเวลาผ่อนชำระด้วยครับ"),
                    PatternValidator(r'^[1-9][0-9]*$',
                        errorText: "ระยะเวลาต้องเป็นตัวเลขจำนวนเต็ม เช่น 3, 6, 12, 24"),
                  ]),
                  onSaved: (tenure) {
                    myLoan.tenure = tenure!;
                  },
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save), // ไอคอนปุ่มบันทึก
                    label: const Text(
                      "บันทึกข้อมูล",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState?.save();
                        await loanCollection.add(myLoan.toMap());
                        formKey.currentState?.reset();
                        widget.onSaved?.call();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}