import 'package:equatable/equatable.dart';

import '../../domain/entities/audit.dart';
import '../../domain/entities/audit_response.dart';
import '../../domain/entities/question.dart';

abstract class AuditDetailState extends Equatable {
  const AuditDetailState();

  @override
  List<Object?> get props => [];
}

class AuditDetailInitial extends AuditDetailState {
  const AuditDetailInitial();
}

class AuditDetailLoading extends AuditDetailState {
  const AuditDetailLoading();
}

class AuditDetailLoaded extends AuditDetailState {
  final Audit audit;
  final List<Question> questions;
  final Map<String, AuditResponse> responses; // questionId -> response

  const AuditDetailLoaded({
    required this.audit,
    required this.questions,
    required this.responses,
  });

  /// Group questions by category.
  Map<String, List<Question>> get questionsByCategory {
    final map = <String, List<Question>>{};
    for (final q in questions) {
      map.putIfAbsent(q.category, () => []).add(q);
    }
    return map;
  }

  @override
  List<Object?> get props => [audit, questions, responses];
}

class AuditDetailError extends AuditDetailState {
  final String message;

  const AuditDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
