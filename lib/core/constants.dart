/// App-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'Audit App';

  /// Supported countries.
  static const List<String> countries = [
    'DE', 'AT', 'CH', 'HR', 'SI', 'HU', 'ES', 'SK',
  ];

  /// Supported app languages.
  static const List<String> supportedLanguages = ['de', 'hr'];

  /// Audit categories (German names, used as keys).
  static const List<String> auditCategories = [
    'Inventursicherheit',
    'Bestandsführung',
    'Geldsicherheit',
    'Haussicherheit',
    'Lagerorganisation',
    'Filialorganisation und Verkaufsbereitschaft',
  ];
}
