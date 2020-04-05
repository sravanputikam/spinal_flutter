import 'package:flutter/material.dart';

bool validateAndSave(formKey) {
  final form = formKey.currentState;
  if (form.validate()) {
    form.save();
    return true;
  }
  return false;
}

Widget showCircularProgress(isLoading) {
  if (isLoading) {
    return Center(child: CircularProgressIndicator());
  }
  return Container(
    height: 0.0,
    width: 0.0,
  );
}

showErrorMessage(errorMessage) {
  if (errorMessage.length > 0 && errorMessage != null) {
    return new Text(
      errorMessage,
      style: TextStyle(
          fontSize: 13.0,
          color: Colors.red,
          height: 1.0,
          fontWeight: FontWeight.w300),
    );
  } else {
    return new Container(
      height: 0.0,
    );
  }
}

String emailValidator(String value) {
  if (value.isEmpty) {
    return 'Email can\'t be empty';
  }
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value)) {
    return 'Email format is invalid';
  } else {
    return null;
  }
}

String pwdValidator(String value) {
  if (value.isEmpty) {
    return 'Password can\'t be empty';
  }
  if (value.length < 8) {
    return 'Password must be longer than 8 characters';
  } else {
    return null;
  }
}

Widget showSecondaryButton(isLoginForm, toggleFormMode) {
  String create = 'Don\'t have an account yet ? \n Regsiter here';
  return new FlatButton(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          isLoginForm ? create : 'Have an account? Sign in',
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      onPressed: toggleFormMode);
}
