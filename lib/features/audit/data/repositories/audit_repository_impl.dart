import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/audit.dart';
import '../../domain/entities/audit_response.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/audit_repository.dart';
import '../datasources/audit_remote_data_source.dart';
import '../models/audit_model.dart';
import '../models/audit_response_model.dart';

class AuditRepositoryImpl implements AuditRepository {
  final AuditRemoteDataSource remote;

  AuditRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<Audit>>> getAudits() async {
    try {
      final audits = await remote.getAudits();
      return Right(audits);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, Audit>> getAudit(String auditId) async {
    try {
      final audit = await remote.getAudit(auditId);
      return Right(audit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Audit>> createAudit(Audit audit) async {
    try {
      final model = AuditModel(
        id: audit.id,
        type: audit.type,
        catalogId: audit.catalogId,
        branchId: audit.branchId,
        branchName: audit.branchName,
        auditorId: audit.auditorId,
        auditorName: audit.auditorName,
        preparerId: audit.preparerId,
        status: audit.status,
        createdAt: audit.createdAt,
        isNachrevision: audit.isNachrevision,
        linkedAuditId: audit.linkedAuditId,
      );
      final result = await remote.createAudit(model.toJson());
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Audit>> updateAudit(Audit audit) async {
    try {
      final model = AuditModel(
        id: audit.id,
        type: audit.type,
        catalogId: audit.catalogId,
        branchId: audit.branchId,
        branchName: audit.branchName,
        auditorId: audit.auditorId,
        auditorName: audit.auditorName,
        preparerId: audit.preparerId,
        status: audit.status,
        resultPercent: audit.resultPercent,
        countYes: audit.countYes,
        countNo: audit.countNo,
        countNA: audit.countNA,
        managementSummary: audit.managementSummary,
        createdAt: audit.createdAt,
        completedAt: audit.completedAt,
        isNachrevision: audit.isNachrevision,
        linkedAuditId: audit.linkedAuditId,
      );
      final result = await remote.updateAudit(audit.id, model.toJson());
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Audit>> completeAudit(String auditId) async {
    try {
      final result = await remote.completeAudit(auditId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Audit>> releaseAudit(String auditId) async {
    try {
      final result = await remote.releaseAudit(auditId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Question>>> getQuestions(String catalogId) async {
    try {
      final questions = await remote.getQuestions(catalogId);
      return Right(questions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<AuditResponse>>> getResponses(String auditId) async {
    try {
      final responses = await remote.getResponses(auditId);
      return Right(responses);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AuditResponse>> saveResponse(
    String auditId,
    AuditResponse response,
  ) async {
    try {
      final model = AuditResponseModel(
        questionId: response.questionId,
        rating: response.rating,
        finding: response.finding,
        measure: response.measure,
        attachments: response.attachments,
        updatedAt: DateTime.now(),
        comparisonResult: response.comparisonResult,
        previousRating: response.previousRating,
        previousFinding: response.previousFinding,
      );
      final result = await remote.saveResponse(auditId, model.toJson());
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Attachment>> uploadAttachment({
    required String auditId,
    required String questionId,
    required List<int> fileBytes,
    required String fileName,
    bool isReportRelevant = true,
  }) async {
    try {
      final attachment = await remote.uploadAttachment(
        auditId: auditId,
        questionId: questionId,
        fileBytes: fileBytes,
        fileName: fileName,
        isReportRelevant: isReportRelevant,
      );
      return Right(attachment);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAttachment({
    required String auditId,
    required String questionId,
    required String attachmentId,
  }) async {
    try {
      await remote.deleteAttachment(
        auditId: auditId,
        questionId: questionId,
        attachmentId: attachmentId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
