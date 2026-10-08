import 'package:flutter/material.dart';
import 'loan_form_screen.dart';
import 'loan_portfolio_screen.dart';

class HomeScreen extends StatefulWidget {
  final String role; // Admin หรือ Operator
  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [
          // บันทึกสำเร็จแล้วสลับไปแท็บที่ 2 (พอร์ตสินเชื่อ)
          LoanFormScreen(onSaved: () => _tabController.animateTo(1)),
          LoanPortfolioScreen(role: widget.role),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 49, 224, 157),
      bottomNavigationBar: SafeArea(
        child: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.assignment_add), // ไอคอนสำหรับยื่นเสนอโครงการ
              text: "ยื่นเสนอโครงการ",
            ),
            Tab(
              icon: Icon(Icons.account_balance_wallet), // ไอคอนสำหรับพอร์ตสินเชื่อ
              text: "พอร์ตสินเชื่อ",
            ),
          ],
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
    );
  }
}