import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/audit.dart';
import '../../domain/entities/audit_response.dart';
import '../../domain/repositories/audit_repository.dart';
import 'audit_detail_state.dart';

class AuditDetailCubit extends Cubit<AuditDetailState> {
  final AuditRepository repository;

  AuditDetailCubit({required this.repository})
      : super(const AuditDetailInitial());

  // Incremented on every loadAudit call so stale responses from a previous
  // navigation can be discarded before they overwrite the current audit.
  int _loadGeneration = 0;

  Future<void> loadAudit(String auditId) async {
    final generation = ++_loadGeneration;
    emit(const AuditDetailLoading());

    final auditResult = await repository.getAudit(auditId);
    if (generation != _loadGeneration) return;

    await auditResult.fold(
      (failure) async => emit(AuditDetailError(failure.message)),
      (audit) async {
        final questionsResult = await repository.getQuestions(audit.catalogId);
        final responsesResult = await repository.getResponses(auditId);
        if (generation != _loadGeneration) return;

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

  /// Auto-save audit-level fields such as the closing summary.
  Future<void> saveAudit(Audit audit) async {
    final currentState = state;
    if (currentState is! AuditDetailLoaded) return;

    emit(AuditDetailLoaded(
      audit: audit,
      questions: currentState.questions,
      responses: currentState.responses,
    ));

    await repository.updateAudit(audit);
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

  /// Branch acknowledges a released audit.
  Future<void> acknowledgeAudit(String auditId) async {
    final result = await repository.acknowledgeAudit(auditId);
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

  Future<bool> updateAttachmentReportRelevance({
    required String auditId,
    required String questionId,
    required String attachmentId,
    required bool isReportRelevant,
  }) async {
    final currentState = state;
    if (currentState is! AuditDetailLoaded) return false;

    final updatedResponses =
        Map<String, AuditResponse>.from(currentState.responses);
    final existing = updatedResponses[questionId];
    if (existing == null) return false;

    final originalAttachments = existing.attachments;
    final optimisticAttachments = originalAttachments
        .map(
          (attachment) => attachment.id == attachmentId
              ? Attachment(
                  id: attachment.id,
                  url: attachment.url,
                  type: attachment.type,
                  isReportRelevant: isReportRelevant,
                  filename: attachment.filename,
                  storedName: attachment.storedName,
                )
              : attachment,
        )
        .toList();

    updatedResponses[questionId] = existing.copyWith(
      attachments: optimisticAttachments,
    );
    emit(AuditDetailLoaded(
      audit: currentState.audit,
      questions: currentState.questions,
      responses: updatedResponses,
    ));

    final result = await repository.updateAttachmentReportRelevance(
      auditId: auditId,
      questionId: questionId,
      attachmentId: attachmentId,
      isReportRelevant: isReportRelevant,
    );

    return result.fold(
      (_) {
        updatedResponses[questionId] = existing.copyWith(
          attachments: originalAttachments,
        );
        emit(AuditDetailLoaded(
          audit: currentState.audit,
          questions: currentState.questions,
          responses: updatedResponses,
        ));
        return false;
      },
      (attachment) {
        updatedResponses[questionId] = existing.copyWith(
          attachments: originalAttachments
              .map((item) => item.id == attachmentId ? attachment : item)
              .toList(),
        );
        emit(AuditDetailLoaded(
          audit: currentState.audit,
          questions: currentState.questions,
          responses: updatedResponses,
        ));
        return true;
      },
    );
  }
}
