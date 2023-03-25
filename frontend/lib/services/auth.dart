// Services to use for auth such as logging the user in and out,
// creating a new account and stuff like that

// Returns null if successful, otherwise string with what went wrong
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_app/utils/validators.dart';

Future<String?> logUserIn(String email, String password) async {
  var emailValid = validateEmail(email);
  if (emailValid != null) {
    return emailValid;
  }

  var passwordValid = validatePassword(email);
  if (passwordValid != null) {
    return passwordValid;
  }

  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return null;
  } catch (error) {
    return error.toString();
  }
}

Future<String?> createUser(
    String email, String password, String username, String? name) async {
  var emailValid = validateEmail(email);
  if (emailValid != null) {
    return emailValid;
  }

  var passwordValid = validatePassword(email);
  if (passwordValid != null) {
    return passwordValid;
  }

  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return null;
  } catch (error) {
    return error.toString();
  }
}
