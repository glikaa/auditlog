import 'package:equatable/equatable.dart';

class MasterQuestion extends Equatable {
  final String masterQuestionId;
  final String textDe;
  final int countryCount;

  const MasterQuestion({
    required this.masterQuestionId,
    required this.textDe,
    required this.countryCount,
  });

  @override
  List<Object?> get props => [masterQuestionId, textDe, countryCount];
}
