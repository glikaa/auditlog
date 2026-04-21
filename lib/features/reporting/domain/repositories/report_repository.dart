import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/branch_report.dart';
import '../entities/country_comparison.dart';
import '../entities/question_stat.dart';

abstract class ReportRepository {
  /// Audit results per branch over time, optionally filtered by [country].
  Future<Either<Failure, List<BranchReport>>> getBranchResults({
    String? country,
  });

  /// Top-5 questions with most yes/no answers.
  Future<Either<Failure, Top5Report>> getTop5Questions({
    String? country,
    int? year,
  });

  /// Cross-country comparison for a single master question.
  Future<Either<Failure, CountryComparison>> getCountryComparison({
    required String masterQuestionId,
  });
}
