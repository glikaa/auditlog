import 'package:equatable/equatable.dart';

import '../../domain/entities/branch_report.dart';
import '../../domain/entities/country_comparison.dart';
import '../../domain/entities/master_question.dart';
import '../../domain/entities/question_stat.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportLoading extends ReportState {
  const ReportLoading();
}

class BranchResultsLoaded extends ReportState {
  final List<BranchReport> reports;
  final String? activeCountry;

  const BranchResultsLoaded(this.reports, {this.activeCountry});

  @override
  List<Object?> get props => [reports, activeCountry];
}

class Top5Loaded extends ReportState {
  final Top5Report report;
  final String? activeCountry;
  final int? activeYear;

  const Top5Loaded(this.report, {this.activeCountry, this.activeYear});

  @override
  List<Object?> get props => [report, activeCountry, activeYear];
}

class CountryComparisonLoaded extends ReportState {
  final CountryComparison comparison;

  const CountryComparisonLoaded(this.comparison);

  @override
  List<Object?> get props => [comparison];
}

class MasterQuestionsLoaded extends ReportState {
  final List<MasterQuestion> questions;

  const MasterQuestionsLoaded(this.questions);

  @override
  List<Object?> get props => [questions];
}

class ReportError extends ReportState {
  final String message;

  const ReportError(this.message);

  @override
  List<Object?> get props => [message];
}
