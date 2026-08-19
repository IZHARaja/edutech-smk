import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/user_role.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? nisnOrNip;
  final String? kelas;
  final String? avatarUrl;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.nisnOrNip,
    this.kelas,
    this.avatarUrl,
    this.createdAt,
  });

  /// Factory untuk membuat UserModel dari Map Firestore
  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parsedCreatedAt;
    if (map['createdAt'] is Timestamp) {
      parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedCreatedAt = DateTime.tryParse(map['createdAt']);
    }

    return UserModel(
      uid: docId,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: UserRole.fromString(map['role']),
      nisnOrNip: map['nisnOrNip'] ?? map['nip'] ?? map['nisn'],
      kelas: map['kelas'],
      avatarUrl: map['avatarUrl'],
      createdAt: parsedCreatedAt,
    );
  }

  /// Factory dari Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, doc.id);
  }

  /// Konversi UserModel ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role.toValue(),
      'nisnOrNip': nisnOrNip,
      'kelas': kelas,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    UserRole? role,
    String? nisnOrNip,
    String? kelas,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      nisnOrNip: nisnOrNip ?? this.nisnOrNip,
      kelas: kelas ?? this.kelas,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
