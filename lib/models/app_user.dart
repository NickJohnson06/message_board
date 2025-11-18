import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String role;
  final DateTime? createdAt;
  final DateTime? dob;

  AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.createdAt,
    this.dob,
  });

  String get displayName => '$firstName $lastName';

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    final dob = data['dob'];

    return AppUser(
      uid: uid,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      role: data['role'] ?? 'user',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      dob: dob is Timestamp ? dob.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'displayName': displayName,
    };
  }
}
