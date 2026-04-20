import 'package:equatable/equatable.dart';

enum UserRole { admin, auditor, preparer, departmentHead, branchManager, districtManager }

class AppUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String language; // 'de' or 'hr'
  final String countryCode; // 'DE', 'AT', 'HR', etc.

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.language = 'de',
    this.countryCode = 'DE',
  });

  /// Whether this user can create/edit audits.
  bool get canEditAudit =>
      role == UserRole.admin ||
      role == UserRole.auditor ||
      role == UserRole.preparer ||
      role == UserRole.departmentHead;

  /// Whether this user can release audits.
  bool get canReleaseAudit =>
      role == UserRole.admin || role == UserRole.auditor;

  /// Whether this user can only view released audits.
  bool get viewReleasedOnly =>
      role == UserRole.branchManager || role == UserRole.districtManager;

  @override
  List<Object?> get props => [id, name, email, role, language, countryCode];
}
