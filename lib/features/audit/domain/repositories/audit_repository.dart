import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../features/auth/domain/entities/app_user.dart';
import '../entities/audit.dart';
import '../entities/audit_catalog.dart';
import '../entities/audit_response.dart';
import '../entities/branch.dart';
import '../entities/question.dart';

abstract class AuditRepository {
  /// Get all available audit catalogs, optionally filtered by country code.
  Future<Either<Failure, List<AuditCatalog>>> getCatalogs({String? country});

  /// Get all branches.
  Future<Either<Failure, List<Branch>>> getBranches();

  /// Get all audits (filtered by backend based on user role).
  Future<Either<Failure, List<Audit>>> getAudits();

  /// Get a single audit by ID.
  Future<Either<Failure, Audit>> getAudit(String auditId);

  /// Create a new audit.
  Future<Either<Failure, Audit>> createAudit(Audit audit);

  /// Update an existing audit.
  Future<Either<Failure, Audit>> updateAudit(Audit audit);

  /// Complete an audit (calculate results).
  Future<Either<Failure, Audit>> completeAudit(String auditId);

  /// Release an audit (make visible to branch).
  Future<Either<Failure, Audit>> releaseAudit(String auditId);

  /// Get questions for a catalog.
  Future<Either<Failure, List<Question>>> getQuestions(String catalogId);

  /// Get all responses for an audit.
  Future<Either<Failure, List<AuditResponse>>> getResponses(String auditId);

  /// Save a single response (auto-save).
  Future<Either<Failure, AuditResponse>> saveResponse(
    String auditId,
    AuditResponse response,
  );

  /// Upload an attachment for a question.
  Future<Either<Failure, Attachment>> uploadAttachment({
    required String auditId,
    required String questionId,
    required List<int> fileBytes,
    required String fileName,
    bool isReportRelevant,
  });

  /// Delete an attachment.
  Future<Either<Failure, void>> deleteAttachment({
    required String auditId,
    required String questionId,
    required String attachmentId,
  });

  /// Delete an audit (admin only).
  Future<Either<Failure, void>> deleteAudit(String auditId);

  /// Create a Nachrevision (follow-up audit) for a completed audit.
  Future<Either<Failure, Audit>> createNachrevision(String auditId);

  /// Get users with role auditor or preparer.
  Future<Either<Failure, List<AppUser>>> getAuditors();
}
