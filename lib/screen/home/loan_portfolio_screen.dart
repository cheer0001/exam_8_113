import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class LoanPortfolioScreen extends StatefulWidget {
  final String role; // Admin หรือ Operator
  const LoanPortfolioScreen({super.key, required this.role});

  @override
  State<LoanPortfolioScreen> createState() => _LoanPortfolioScreenState();
}

class _LoanPortfolioScreenState extends State<LoanPortfolioScreen> {
  final _firestore = FirebaseFirestore.instance;

  Future<void> deleteLoan(String documentId) async {
    await _firestore.collection('loans').doc(documentId).delete();
  }

  Future<void> showDeleteConfirmation(String documentId) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบข้อมูล'),
          content: const Text('คุณต้องการลบข้อมูลจริงๆ ใช่ไหมครับ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                await deleteLoan(documentId);
                Navigator.pop(context);
              },
              child: const Text('ลบ'),
            ),
          ],
        );
      },
    );
  }

  // ===== ส่วนที่เพิ่มจากใบงาน: แก้ไขข้อมูล (Edit) =====
  Future<void> updateLoan(
      String documentId, String principal, String tenure) async {
    await _firestore
        .collection('loans')
        .doc(documentId)
        .update({"principal": principal, "tenure": tenure});
  }

  Future<void> showEditDialog(QueryDocumentSnapshot document) async {
    final editKey = GlobalKey<FormState>();
    final principalController =
        TextEditingController(text: "${document["principal"]}");
    final tenureController =
        TextEditingController(text: "${document["tenure"]}");
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ปรับวงเงิน/โครงสร้างหนี้ ${document["contractId"]}'),
          content: Form(
            key: editKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: principalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'วงเงินกู้ (บาท)'),
                  validator:
                      RequiredValidator(errorText: "กรุณาป้อนวงเงินด้วยครับ"),
                ),
                TextFormField(
                  controller: tenureController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'ระยะเวลาผ่อนชำระ (เดือน)'),
                  validator: RequiredValidator(
                      errorText: "กรุณาป้อนระยะเวลาผ่อนชำระด้วยครับ"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                if (editKey.currentState!.validate()) {
                  await updateLoan(document.id, principalController.text,
                      tenureController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }
  // ===== จบส่วนที่เพิ่ม =====

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("พอร์ตสินเชื่อ (${widget.role})"),
        backgroundColor: const Color.fromARGB(255, 49, 224, 157),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Sign Out",
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("loans").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final document = snapshot.data!.docs[index];
              return Container(
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    child: FittedBox(child: Text("${document["tenure"]}")),
                  ),
                  title: Text(
                      "${document["contractId"]}  ${document["projectName"]}"),
                  subtitle: Text("วงเงิน ${document["principal"]} บาท"),
                  // Operator ดูได้อย่างเดียว: ซ่อนปุ่ม Edit / Delete
                  trailing: widget.role == 'Admin'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                await showEditDialog(document);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await showDeleteConfirmation(document.id);
                              },
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}