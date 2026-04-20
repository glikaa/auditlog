import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/audit.dart';
import '../entities/audit_response.dart';
import '../entities/question.dart';

abstract class AuditRepository {
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
}
