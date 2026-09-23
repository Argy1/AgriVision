import 'enums.dart';

class Profile {
  const Profile({
    required this.id,
    required this.fullName,
    required this.role,
    this.phone,
  });

  final String id;
  final String fullName;
  final UserRole role;
  final String? phone;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    fullName: json['full_name'] as String,
    role: UserRole.fromJson(json['role'] as String),
    phone: json['phone'] as String?,
  );

  Profile copyWith({String? fullName, String? phone}) => Profile(
    id: id,
    fullName: fullName ?? this.fullName,
    role: role,
    phone: phone ?? this.phone,
  );

  /// Inisial nama untuk avatar chip, mis. "Argy Fawwaz" -> "AF".
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  /// Nama depan saja, untuk sapaan dashboard.
  String get firstName => fullName.trim().split(RegExp(r'\s+')).first;
}
