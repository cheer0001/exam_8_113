class LoanProject {
  String contractId;
  String projectName;
  String officerEmail;
  String principal;
  String tenure;

  LoanProject({
    required this.contractId,
    required this.projectName,
    required this.officerEmail,
    required this.principal,
    required this.tenure,
  });

  // แปลงจาก Object เป็น Map เพื่อบันทึกลง Cloud Firestore
  Map<String, dynamic> toMap() {
    return {
      'contractId': contractId,
      'projectName': projectName,
      'officerEmail': officerEmail,
      'principal': principal,
      'tenure': tenure,
    };
  }

  // ดึงข้อมูลจาก Map (Firestore Document) มาสร้างเป็น LoanProject Object
  factory LoanProject.fromMap(Map<String, dynamic> map) {
    return LoanProject(
      contractId: map['contractId'] ?? '',
      projectName: map['projectName'] ?? '',
      officerEmail: map['officerEmail'] ?? '',
      principal: map['principal'] ?? '',
      tenure: map['tenure'] ?? '',
    );
  }
}