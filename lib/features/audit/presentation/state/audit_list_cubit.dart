import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/audit_repository.dart';
import 'audit_list_state.dart';

class AuditListCubit extends Cubit<AuditListState> {
  final AuditRepository repository;

  AuditListCubit({required this.repository}) : super(const AuditListInitial());

  Future<void> loadAudits() async {
    emit(const AuditListLoading());
    final result = await repository.getAudits();
    result.fold(
      (failure) => emit(AuditListError(failure.message)),
      (audits) => emit(AuditListLoaded(audits)),
    );
  }

  /// Create a Nachrevision for the given audit. Returns the new audit ID or null.
  Future<String?> createNachrevision(String auditId) async {
    final result = await repository.createNachrevision(auditId);
    return result.fold(
      (_) => null,
      (audit) {
        loadAudits(); // Refresh list
        return audit.id;
      },
    );
  }
}
