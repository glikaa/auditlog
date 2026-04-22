import 'package:equatable/equatable.dart';

/// Aggregated rating counts for one question.
class QuestionStat extends Equatable {
  final String questionId;
  final String questionText;
  final int yesCount;
  final int noCount;
  final int naCount;

  const QuestionStat({
    required this.questionId,
    required this.questionText,
    required this.yesCount,
    required this.noCount,
    required this.naCount,
  });

  int get total => yesCount + noCount + naCount;

  @override
  List<Object?> get props =>
      [questionId, questionText, yesCount, noCount, naCount];
}

/// Top-5 result from the backend.
class Top5Report extends Equatable {
  final List<QuestionStat> topYes;
  final List<QuestionStat> topNo;

  const Top5Report({required this.topYes, required this.topNo});

  @override
  List<Object?> get props => [topYes, topNo];
}
