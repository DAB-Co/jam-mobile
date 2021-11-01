var greetingsText = () {
  DateTime now = new DateTime.now();
  var hour = now.hour;
  if (hour > 5 && hour < 12) {
    return "Good Morning";
  } else if (hour > 12 && hour < 18) {
    return "Good Afternoon";
  } else if (hour > 18 && hour < 23) {
    return "Good Evening";
  } else {
    return "Greetings night owl";
  }
};