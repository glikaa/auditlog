import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/audit_response.dart';
import '../../domain/repositories/audit_repository.dart';
import 'audit_detail_state.dart';

class AuditDetailCubit extends Cubit<AuditDetailState> {
  final AuditRepository repository;

  AuditDetailCubit({required this.repository})
      : super(const AuditDetailInitial());

  Future<void> loadAudit(String auditId, {bool canViewInternalHints = false}) async {
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
            // Strip internal notes from memory for users without permission
            final processedQuestions = canViewInternalHints
                ? questions
                : questions
                    .map((q) => q.copyWithoutInternalNotes())
                    .toList();

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
              questions: processedQuestions,
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

  /// Upload an attachment for a question. Returns true on success.
  Future<bool> uploadAttachment({
    required String auditId,
    required String questionId,
    required List<int> fileBytes,
    required String fileName,
    bool isReportRelevant = true,
  }) async {
    final result = await repository.uploadAttachment(
      auditId: auditId,
      questionId: questionId,
      fileBytes: fileBytes,
      fileName: fileName,
      isReportRelevant: isReportRelevant,
    );

    return result.fold(
      (_) => false,
      (attachment) {
        final currentState = state;
        if (currentState is AuditDetailLoaded) {
          final updatedResponses =
              Map<String, AuditResponse>.from(currentState.responses);
          final existing = updatedResponses[questionId] ??
              AuditResponse(questionId: questionId);
          updatedResponses[questionId] = existing.copyWith(
            attachments: [...existing.attachments, attachment],
          );
          emit(AuditDetailLoaded(
            audit: currentState.audit,
            questions: currentState.questions,
            responses: updatedResponses,
          ));
        }
        return true;
      },
    );
  }

  /// Delete an attachment.
  Future<void> deleteAttachment({
    required String auditId,
    required String questionId,
    required String attachmentId,
  }) async {
    final currentState = state;
    if (currentState is! AuditDetailLoaded) return;

    // Optimistic removal
    final updatedResponses =
        Map<String, AuditResponse>.from(currentState.responses);
    final existing = updatedResponses[questionId];
    if (existing != null) {
      updatedResponses[questionId] = existing.copyWith(
        attachments: existing.attachments
            .where((a) => a.id != attachmentId)
            .toList(),
      );
      emit(AuditDetailLoaded(
        audit: currentState.audit,
        questions: currentState.questions,
        responses: updatedResponses,
      ));
    }

    await repository.deleteAttachment(
      auditId: auditId,
      questionId: questionId,
      attachmentId: attachmentId,
    );
  }
}
