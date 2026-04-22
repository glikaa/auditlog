import 'package:equatable/equatable.dart';

class AuditCatalog extends Equatable {
  final String id;
  final String countryCode;
  final String version;
  final int year;
  final int questionCount;

  const AuditCatalog({
    required this.id,
    required this.countryCode,
    required this.version,
    required this.year,
    required this.questionCount,
  });

  String get displayLabel => '$countryCode – $version ($year) [$questionCount Fragen]';

  @override
  List<Object?> get props => [id, countryCode, version, year, questionCount];
}
