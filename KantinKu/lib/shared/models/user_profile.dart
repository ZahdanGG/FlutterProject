class UserProfile {
  const UserProfile({required this.id, required this.name, required this.email,
    this.phone = '', this.role = 'Mahasiswa', this.institution = '', this.department = '',
    this.studentId = '', this.staffId = ''});
  final String id, name, email, phone, role, institution, department, studentId, staffId;
  UserProfile copyWith({String? name, String? email, String? phone, String? role,
    String? institution, String? department, String? studentId, String? staffId}) =>
    UserProfile(id: id, name: name ?? this.name, email: email ?? this.email,
      phone: phone ?? this.phone, role: role ?? this.role,
      institution: institution ?? this.institution, department: department ?? this.department,
      studentId: studentId ?? this.studentId, staffId: staffId ?? this.staffId);
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email, 'phone': phone,
    'role': role, 'institution': institution, 'department': department,
    'studentId': studentId, 'staffId': staffId};
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String, name: json['name'] as String, email: json['email'] as String,
    phone: json['phone'] as String? ?? '', role: json['role'] as String? ?? 'Mahasiswa',
    institution: json['institution'] as String? ?? '', department: json['department'] as String? ?? '',
    studentId: json['studentId'] as String? ?? '', staffId: json['staffId'] as String? ?? '');
}
