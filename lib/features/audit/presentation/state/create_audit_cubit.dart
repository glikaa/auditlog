import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/audit.dart';
import '../../domain/entities/branch.dart';
import '../../domain/repositories/audit_repository.dart';
import '../../../../features/auth/domain/entities/app_user.dart';
import 'create_audit_state.dart';

class CreateAuditCubit extends Cubit<CreateAuditState> {
  final AuditRepository repository;

  CreateAuditCubit({required this.repository}) : super(const CreateAuditInitial());

  /// Step 1: load branches and auditors in parallel.
  Future<void> loadFormData() async {
    emit(const CreateAuditLoading());
    // Kick off both requests in parallel, then await each with its own type.
    final branchesFuture = repository.getBranches();
    final auditorsFuture = repository.getAuditors();

    final branchesResult = await branchesFuture;
    final auditorsResult = await auditorsFuture;

    // If branches failed, show error.
    if (branchesResult.isLeft()) {
      branchesResult.fold(
        (failure) => emit(CreateAuditLoadError(failure.message)),
        (_) {},
      );
      return;
    }

    final branches = branchesResult.getOrElse(() => []);
    final auditors = auditorsResult.fold((_) => <AppUser>[], (a) => a);

    emit(CreateAuditFormReady(branches: branches, auditors: auditors));
  }

  /// Step 2: branch selected → load catalogs filtered by that country.
  Future<void> selectBranch(Branch branch) async {
    final currentState = state;
    if (currentState is! CreateAuditFormReady) return;

    emit(currentState.copyWith(
      selectedBranch: branch,
      catalogs: [],
      isCatalogsLoading: true,
      clearError: true,
    ));

    final result = await repository.getCatalogs(country: branch.countryCode);
    result.fold(
      (failure) {
        final s = state;
        if (s is CreateAuditFormReady) {
          emit(s.copyWith(
            isCatalogsLoading: false,
            errorMessage: failure.message,
          ));
        }
      },
      (catalogs) {
        final s = state;
        if (s is CreateAuditFormReady) {
          emit(s.copyWith(
            catalogs: catalogs,
            isCatalogsLoading: false,
          ));
        }
      },
    );
  }

  /// Select an auditor from the list.
  void selectAuditor(AppUser auditor) {
    final currentState = state;
    if (currentState is! CreateAuditFormReady) return;
    emit(currentState.copyWith(selectedAuditor: auditor));
  }

  /// Step 3: submit the form.
  Future<void> createAudit({
    required String catalogId,
  }) async {
    final currentState = state;
    if (currentState is! CreateAuditFormReady) return;
    if (currentState.selectedBranch == null) return;
    if (currentState.selectedAuditor == null) return;

    emit(currentState.copyWith(isSubmitting: true));

    final branch = currentState.selectedBranch!;
    final auditor = currentState.selectedAuditor!;
    final audit = Audit(
      id: '',
      type: AuditType.filialrevision,
      catalogId: catalogId,
      branchId: branch.id,
      branchName: branch.name,
      auditorId: auditor.id,
      auditorName: auditor.name,
      status: AuditStatus.draft,
      createdAt: DateTime.now(),
    );

    final result = await repository.createAudit(audit);
    result.fold(
      (failure) {
        final s = state;
        if (s is CreateAuditFormReady) {
          emit(s.copyWith(isSubmitting: false, errorMessage: failure.message));
        }
      },
      (createdAudit) => emit(CreateAuditSuccess(createdAudit.id)),
    );
  }
}
