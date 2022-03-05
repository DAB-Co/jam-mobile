Duration durationUntilNextMatch() {
  var now = DateTime.now();
  var nextMatch =
      DateTime.utc(now.year, now.month, now.day + 1); // midnight at Greenwich
  return nextMatch.difference(now);
}

double getTimerPercentage() {
  Duration timeUntilNextMatch = durationUntilNextMatch();
  int inSeconds = timeUntilNextMatch.inSeconds;
  return 1 - inSeconds / Duration(days: 1).inSeconds;
}

String getTimerText() {
  Duration timeUntilNextMatch = durationUntilNextMatch();
  if (timeUntilNextMatch.inHours > 0) {
    return "${timeUntilNextMatch.inHours} hours";
  } else if (timeUntilNextMatch.inMinutes > 0) {
    return "${timeUntilNextMatch.inMinutes} minutes";
  } else {
    return "${timeUntilNextMatch.inSeconds} seconds";
  }
}
