class AppUrl {
  static const String baseURL = "http://rocketdodgegame.com";
  static const String apiUrl = baseURL + ":41370/api";

  static const String login = apiUrl + "/auth";
  static const String register = apiUrl + "/signup";
  static const String forgotPassword = apiUrl + "/forgot-password";

  static const String mqttURL = "rocketdodgegame.com";
  static const int mqttPort = 41371;
}
