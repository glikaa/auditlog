import 'package:equatable/equatable.dart';

import '../../../../features/auth/domain/entities/app_user.dart';
import '../../domain/entities/audit_catalog.dart';
import '../../domain/entities/branch.dart';

abstract class CreateAuditState extends Equatable {
  const CreateAuditState();

  @override
  List<Object?> get props => [];
}

class CreateAuditInitial extends CreateAuditState {
  const CreateAuditInitial();
}

class CreateAuditLoading extends CreateAuditState {
  const CreateAuditLoading();
}

/// Branches loaded; user selects branch first.
/// After branch selection catalogs are loaded for that country.
class CreateAuditFormReady extends CreateAuditState {
  final List<Branch> branches;
  final Branch? selectedBranch;
  final List<AuditCatalog> catalogs;
  final bool isCatalogsLoading;
  final List<AppUser> auditors;
  final AppUser? selectedAuditor;
  final bool isSubmitting;
  final String? errorMessage;

  const CreateAuditFormReady({
    required this.branches,
    this.selectedBranch,
    this.catalogs = const [],
    this.isCatalogsLoading = false,
    this.auditors = const [],
    this.selectedAuditor,
    this.isSubmitting = false,
    this.errorMessage,
  });

  CreateAuditFormReady copyWith({
    List<Branch>? branches,
    Branch? selectedBranch,
    bool clearBranch = false,
    List<AuditCatalog>? catalogs,
    bool? isCatalogsLoading,
    List<AppUser>? auditors,
    AppUser? selectedAuditor,
    bool clearAuditor = false,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CreateAuditFormReady(
      branches: branches ?? this.branches,
      selectedBranch: clearBranch ? null : (selectedBranch ?? this.selectedBranch),
      catalogs: catalogs ?? this.catalogs,
      isCatalogsLoading: isCatalogsLoading ?? this.isCatalogsLoading,
      auditors: auditors ?? this.auditors,
      selectedAuditor: clearAuditor ? null : (selectedAuditor ?? this.selectedAuditor),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        branches,
        selectedBranch,
        catalogs,
        isCatalogsLoading,
        auditors,
        selectedAuditor,
        isSubmitting,
        errorMessage,
      ];
}

class CreateAuditSuccess extends CreateAuditState {
  final String auditId;

  const CreateAuditSuccess(this.auditId);

  @override
  List<Object?> get props => [auditId];
}

class CreateAuditLoadError extends CreateAuditState {
  final String message;

  const CreateAuditLoadError(this.message);

  @override
  List<Object?> get props => [message];
}
