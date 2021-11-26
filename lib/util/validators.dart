String? validateEmail(String? value) {
  String? _msg;
  var notValid = [":", ",", " "];
  RegExp regex = new RegExp(
      r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  if (value!.isEmpty) {
    _msg = "Your email is required";
  } else if (!regex.hasMatch(value)) {
    _msg = "Please provide a valid email address";
  } else if (value.contains(" ")) {
    _msg = "Username cannot have spaces"; // different prompt for space
  }

  for (String char in notValid) {
    if (value.contains(char)) {
      _msg = "Can not use '$char' in username";
      break;
    }
  }

  return _msg;
}

String? validatePassword(String? value) {
  String? _msg;
  var maxLength = 37;
  var minLength = 8;
  if (value == null) {
    _msg = "Your password is required";
  } else if (value.length < minLength) {
    _msg = 'Password must be at least $minLength characters';
  } else if (value.length > maxLength) {
    _msg = "Password can't be longer than $maxLength characters";
  }
  return _msg;
}
