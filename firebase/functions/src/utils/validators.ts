// pulled from dart codebase

const usernameRegExp = /^(?!_)(?!.*\.$)(?!.*\.\.)[a-z0-9._]{3,28}(?<!\.)$/;
const emailRegExp = /^[a-zA-Z0-9]+(?:\.[a-zA-Z0-9]+)*@[a-zA-Z0-9]+(?:\.[a-zA-Z0-9]+)*$/;
const passwordRegExp = /^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$/;

type StrOrNull = string | null | undefined;


export function validateEmail(value: StrOrNull ): StrOrNull {
  if (value == null || value == undefined || value.length == 0) {
    return "Email cannot be empty";
  } else if (!emailRegExp.test(value)) {
    return "Invalid email format";
  }
  return null;
}

export function validatePassword(value: StrOrNull): StrOrNull {
  if (value == null || value == undefined || value.length == 0) {
    return "Password is too short password";
  } else if (value.length < 8) {
    return "Password must be at least 8 characters";
  } else if (!passwordRegExp.test(value)) {
    return "Password must contain upper and lowercase letters and numbers";
  }
  return null;
}

export function validateUsername(value: StrOrNull): StrOrNull {
  if (value == null || value == undefined || value.length == 0) {
    return "Please enter your username";
  } else if (value.length < 3) {
    return "Your username needs to be at least 3 characters";
  } else if (value.length > 20) {
    return "Your username needs to be shorter than 20 characters";
  } else if (!usernameRegExp.test(value)) {
    return `${value} is not a valid username`;
  }
  return null;
}

export function validateName(value: StrOrNull): StrOrNull {
  if (value == null || value == undefined || value.length == 0) {
    return null;
  } else if (value.length > 50) {
    return "Name should be under 50 characters";
  }
  return null;
}



export function validateGroupName(value: StrOrNull): StrOrNull {
  if (value == null || value == undefined || value.length == 0) {
    return "Please enter a group name";
  } else if (value.length < 3) {
    return "Group name needs to be at least 3 characters";
  } else if (value.length > 20) {
    return "Group name needs to be shorter than 20 characters";
  } else if (!usernameRegExp.test(value)) {
    return `${value} is not a valid group name`;
  }
  return null;
}

export function validateGroupDescription(value: StrOrNull): StrOrNull {
  if (value != null && value != undefined && value.length > 500) {
    return "Group description needs to be under 500 characters";
  }
  return null;
}

