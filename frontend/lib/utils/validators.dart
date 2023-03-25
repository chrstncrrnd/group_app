String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter your email";
  } else if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
    return "Please enter a valid email address";
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter your password";
  } else if (value.length < 8) {
    return "Password must be at least 8 characters";
  } else if (!RegExp(r"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$")
      .hasMatch(value)) {
    return "Password must contain at least one uppercase letter, one lowercase letter, and one number";
  }
  return null;
}
