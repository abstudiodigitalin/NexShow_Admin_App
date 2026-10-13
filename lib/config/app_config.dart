/// Central app configuration for NexShow Admin.
class AppConfig {
  AppConfig._();

  /// The admin PHP page loaded in-app after the splash screen.
  static const String phpPageUrl = 'https://abstudiodigital.in/admin.php';

  static const String appName = 'NexShow Admin';

  /// How long the splash screen is shown before revealing the WebView.
  static const Duration splashDuration = Duration(milliseconds: 2600);
}
