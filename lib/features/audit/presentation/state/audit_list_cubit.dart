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
}
