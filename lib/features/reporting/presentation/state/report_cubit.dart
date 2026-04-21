import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/report_repository.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportRepository repository;

  ReportCubit({required this.repository}) : super(const ReportInitial());

  Future<void> loadBranchResults({String? country}) async {
    emit(const ReportLoading());
    final result = await repository.getBranchResults(country: country);
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (reports) => emit(BranchResultsLoaded(reports, activeCountry: country)),
    );
  }

  Future<void> loadTop5({String? country, int? year}) async {
    emit(const ReportLoading());
    final result =
        await repository.getTop5Questions(country: country, year: year);
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (report) =>
          emit(Top5Loaded(report, activeCountry: country, activeYear: year)),
    );
  }

  Future<void> loadCountryComparison(String masterQuestionId) async {
    emit(const ReportLoading());
    final result = await repository.getCountryComparison(
      masterQuestionId: masterQuestionId,
    );
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (comparison) => emit(CountryComparisonLoaded(comparison)),
    );
  }
}
