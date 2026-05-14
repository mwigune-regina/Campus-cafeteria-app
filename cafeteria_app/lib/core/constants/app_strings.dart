class AppStrings {
  static const String appName = "Campus Cafeteria";

  /// Backend host. Overridable at build time:
  ///   flutter run --dart-define=API_HOST=192.168.1.42
  ///
  /// Default is `localhost`, which works for:
  ///   - iOS simulator (always)
  ///   - Android emulator OR real Android device, when `adb reverse
  ///     tcp:3000 tcp:3000` is set up (run once per USB connection)
  ///
  /// Override with `--dart-define=API_HOST=YOUR_LAN_IP` when running
  /// over Wi-Fi without adb reverse.
  static const String _hostOverride =
      String.fromEnvironment('API_HOST', defaultValue: 'localhost');

  static const String _portOverride =
      String.fromEnvironment('API_PORT', defaultValue: '3000');

  static String get baseUrl => 'http://$_hostOverride:$_portOverride/api';

  // Auth
  static const String loginTitle = "Welcome Back";
  static const String registerTitle = "Create Account";

  // Storage keys
  static const String tokenKey = "jwt_token";
  static const String userDataKey = "user_data";
}
