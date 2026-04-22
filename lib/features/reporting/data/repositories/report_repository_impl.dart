import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/branch_report.dart';
import '../../domain/entities/country_comparison.dart';
import '../../domain/entities/master_question.dart';
import '../../domain/entities/question_stat.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remote;

  ReportRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<BranchReport>>> getBranchResults({
    String? country,
  }) async {
    try {
      final models = await remote.getBranchResults(country: country);
      return Right(models);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, Top5Report>> getTop5Questions({
    String? country,
    int? year,
  }) async {
    try {
      final model = await remote.getTop5Questions(country: country, year: year);
      return Right(model);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, CountryComparison>> getCountryComparison({
    required String masterQuestionId,
  }) async {
    try {
      final model = await remote.getCountryComparison(
        masterQuestionId: masterQuestionId,
      );
      return Right(model);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, List<MasterQuestion>>> getMasterQuestions() async {
    try {
      final models = await remote.getMasterQuestions();
      return Right(models);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
