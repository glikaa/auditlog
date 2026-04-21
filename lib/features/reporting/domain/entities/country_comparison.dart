import 'package:equatable/equatable.dart';

/// The rating breakdown for one country for a master question.
class CountryResult extends Equatable {
  final String countryCode;
  final String localQuestionId;
  final int localQuestionOrder;
  final int yesCount;
  final int noCount;
  final int naCount;

  const CountryResult({
    required this.countryCode,
    required this.localQuestionId,
    required this.localQuestionOrder,
    required this.yesCount,
    required this.noCount,
    required this.naCount,
  });

  int get total => yesCount + noCount + naCount;
  double get yesPercent => total == 0 ? 0 : (yesCount / total) * 100;

  @override
  List<Object?> get props =>
      [countryCode, localQuestionId, localQuestionOrder, yesCount, noCount, naCount];
}

/// Cross-country comparison for a master question.
class CountryComparison extends Equatable {
  final String masterQuestionId;
  final String masterQuestionText;
  final List<CountryResult> results;

  const CountryComparison({
    required this.masterQuestionId,
    required this.masterQuestionText,
    required this.results,
  });

  @override
  List<Object?> get props => [masterQuestionId, masterQuestionText, results];
}
