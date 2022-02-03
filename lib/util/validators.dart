String? validateEmail(String? value) {
  String? _msg;
  RegExp regex = new RegExp(
      r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  if (value!.isEmpty) {
    _msg = "Your email is required";
  } else if (!regex.hasMatch(value)) {
    _msg = "Please provide a valid email address";
  } else if (value.contains(" ")) {
    _msg = "Email cannot have spaces"; // different prompt for space
  }

  return _msg;
}

String? validatePassword(String? value) {
  String? _msg;
  var maxLength = 37;
  var minLength = 8;
  if (value == null) {
    _msg = "Password can't be empty";
  } else if (value.length < minLength) {
    _msg = 'Password must be at least $minLength characters';
  } else if (value.length > maxLength) {
    _msg = "Password can't be longer than $maxLength characters";
  }
  return _msg;
}

String? validateUsername(String? value) {
  var notValid = [":", ",", " "];
  String? _msg;
  var maxLength = 31;
  var minLength = 6;
  if (value == null) {
    _msg = "Username can't be empty";
  }
  else if (value.length < minLength) {
    _msg = 'Username must be at least $minLength characters';
  }
  else if (value.length > maxLength) {
    _msg = "Username can't be longer than $maxLength characters";
  }

  for (String char in notValid) {
    if (value != null && value.contains(char)) {
      _msg = "Can not use '$char' in username";
      break;
    }
  }

  return _msg;
}

String? validateNotEmpty(String? value) {
  String? _msg;
  if (value == null || value == "") {
    _msg = "Please fill the form";
  }
  return _msg;
}
