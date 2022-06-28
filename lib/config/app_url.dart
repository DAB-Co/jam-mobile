class AppUrl {
  static const int serverPort = 41370;
  static const String baseURL = "https://rocketdodgegame.com:$serverPort"; // localhost: http://10.0.2.2
  static const String apiUrl = baseURL + "/api";

  static const String login = apiUrl + "/auth";
  static const String register = apiUrl + "/signup";
  static const String forgotPassword = apiUrl + "/forgot_password";
  static const String wake = apiUrl + "/wake";
  static const String logout = apiUrl + "/logout";
  static const String block = apiUrl + "/block";
  static const String unBlock = apiUrl + "/unblock";
  static const String setLanguages = apiUrl + "/update_languages";
  static const String topPreferences = apiUrl + "/top_preferences";
  static const String updateProfilePic = apiUrl + "/update_profile_picture";
  static const String getLanguages = apiUrl + "/get_languages";
  static const String deleteAccount = apiUrl + "/delete_account";
  static const String changePassword = apiUrl + "/change_password";

  static const String suggestion = baseURL + "/suggestion";

  static const String spotifyUrlStart = baseURL + "/spotify/login";
  static const String spotifyUrlEnd = baseURL + "/spotify/callback";

  static const String mqttURL = "rocketdodgegame.com";
  static const int mqttPort = 41371;
}
