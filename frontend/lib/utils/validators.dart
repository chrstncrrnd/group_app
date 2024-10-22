RegExp usernameRegExp =
    RegExp(r"^(?!_)(?!.*\.$)(?!.*\.\.)[a-z0-9._]{3,28}(?<!\.)$");
RegExp emailRegExp = RegExp(
    r"^[a-zA-Z0-9]+(?:\.[a-zA-Z0-9]+)*@[a-zA-Z0-9]+(?:\.[a-zA-Z0-9]+)*$");
RegExp passwordRegExp = RegExp(r"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$");

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter your email";
  } else if (value.length > 255) {
    return "Email cannot exceed 255 characters";
  } else if (!emailRegExp.hasMatch(value)) {
    return "Please enter a valid email address";
  }
  return null;
}

String? validatePostCaption(String value) {
  if (value.length > 500) {
    return "Caption is too long";
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter your password";
  } else if (value.length < 8) {
    return "Password must be at least 8 characters";
  } else if (value.length > 255) {
    return "Password cannot exceed 255 characters";
  } else if (!passwordRegExp.hasMatch(value)) {
    return "Password must contain upper and lowercase letters and numbers";
  }
  return null;
}

String? validateUsername(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter your username";
  } else if (value.length < 3) {
    return "Your username needs to be at least 3 characters";
  } else if (value.length > 20) {
    return "Your username needs to be shorter than 20 characters";
  } else if (!usernameRegExp.hasMatch(value)) {
    return "$value is not a valid username";
  }
  return null;
}

String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  } else if (value.length > 50) {
    return "Name should be under 50 characters";
  }

  return null;
}

String? validateGroupName(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter a group name";
  } else if (value.length < 3) {
    return "Group name needs to be at least 3 characters";
  } else if (value.length > 20) {
    return "Group name needs to be shorter than 20 characters";
  } else if (!usernameRegExp.hasMatch(value)) {
    return "$value is not a valid group name";
  }
  return null;
}

String? validateGroupDescription(String? value) {
  if (value != null && value.length > 500) {
    return "Group description needs to be under 500 characters";
  }
  return null;
}

String? validatePageName(String? value) {
  if (value == null || value.isEmpty) {
    return "Page name cannot be empty";
  }

  if (value.length > 50) {
    return "Page name cannot be over 50 characters";
  }
  return null;
}
