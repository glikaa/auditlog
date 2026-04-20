import 'package:equatable/equatable.dart';

import '../../domain/entities/audit.dart';

abstract class AuditListState extends Equatable {
  const AuditListState();

  @override
  List<Object?> get props => [];
}

class AuditListInitial extends AuditListState {
  const AuditListInitial();
}

class AuditListLoading extends AuditListState {
  const AuditListLoading();
}

class AuditListLoaded extends AuditListState {
  final List<Audit> audits;

  const AuditListLoaded(this.audits);

  @override
  List<Object?> get props => [audits];
}

class AuditListError extends AuditListState {
  final String message;

  const AuditListError(this.message);

  @override
  List<Object?> get props => [message];
}
