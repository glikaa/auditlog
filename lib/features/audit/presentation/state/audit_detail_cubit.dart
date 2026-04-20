import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/audit_response.dart';
import '../../domain/repositories/audit_repository.dart';
import 'audit_detail_state.dart';

class AuditDetailCubit extends Cubit<AuditDetailState> {
  final AuditRepository repository;

  AuditDetailCubit({required this.repository})
      : super(const AuditDetailInitial());

  Future<void> loadAudit(String auditId) async {
    emit(const AuditDetailLoading());

    final auditResult = await repository.getAudit(auditId);

    await auditResult.fold(
      (failure) async => emit(AuditDetailError(failure.message)),
      (audit) async {
        // Load questions and responses in parallel
        final questionsResult = await repository.getQuestions(audit.catalogId);
        final responsesResult = await repository.getResponses(auditId);

        questionsResult.fold(
          (failure) => emit(AuditDetailError(failure.message)),
          (questions) {
            final responses = <String, AuditResponse>{};
            responsesResult.fold(
              (_) {}, // Ignore response errors, start with empty
              (responseList) {
                for (final r in responseList) {
                  responses[r.questionId] = r;
                }
              },
            );

            emit(AuditDetailLoaded(
              audit: audit,
              questions: questions,
              responses: responses,
            ));
          },
        );
      },
    );
  }

  /// Auto-save a single response.
  Future<void> saveResponse(String auditId, AuditResponse response) async {
    final currentState = state;
    if (currentState is! AuditDetailLoaded) return;

    // Optimistic update
    final updatedResponses = Map<String, AuditResponse>.from(currentState.responses);
    updatedResponses[response.questionId] = response;
    emit(AuditDetailLoaded(
      audit: currentState.audit,
      questions: currentState.questions,
      responses: updatedResponses,
    ));

    // Persist to backend
    await repository.saveResponse(auditId, response);
  }

  /// Complete the audit.
  Future<void> completeAudit(String auditId) async {
    final result = await repository.completeAudit(auditId);
    result.fold(
      (failure) => emit(AuditDetailError(failure.message)),
      (audit) {
        final currentState = state;
        if (currentState is AuditDetailLoaded) {
          emit(AuditDetailLoaded(
            audit: audit,
            questions: currentState.questions,
            responses: currentState.responses,
          ));
        }
      },
    );
  }

  /// Release the audit to the branch.
  Future<void> releaseAudit(String auditId) async {
    final result = await repository.releaseAudit(auditId);
    result.fold(
      (failure) => emit(AuditDetailError(failure.message)),
      (audit) {
        final currentState = state;
        if (currentState is AuditDetailLoaded) {
          emit(AuditDetailLoaded(
            audit: audit,
            questions: currentState.questions,
            responses: currentState.responses,
          ));
        }
      },
    );
  }
}
