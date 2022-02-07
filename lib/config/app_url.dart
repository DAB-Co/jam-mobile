class AppUrl {
  static const int serverPort = 41370;
  static const String baseURL = "https://rocketdodgegame.com:$serverPort";
  static const String apiUrl = baseURL + "/api";

  static const String login = apiUrl + "/auth";
  static const String register = apiUrl + "/signup";
  static const String forgotPassword = apiUrl + "/forgot-password";
  static const String friends = apiUrl + "/friends";
  static const String logout = apiUrl + "/logout";

  static const String suggestion = baseURL + "/suggestion";

  static const String mqttURL = "rocketdodgegame.com";
  static const int mqttPort = 8080;
}
