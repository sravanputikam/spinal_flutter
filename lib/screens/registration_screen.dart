import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spinal_flutter/widgets/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spinal_flutter/screens/login_screen.dart';
import 'package:spinal_flutter/services/auth.dart';
import 'package:spinal_flutter/validators.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  String _errorMessage;
  bool _isLoginForm;
  bool _isLoading;
  final _formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _confirmpwd;
  String _first;
  String _last;

  @override
  void initState() {
    // TODO: implement initState
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;
    super.initState();
  }

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
    Navigator.popAndPushNamed(context, LoginScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Register'),
        centerTitle: true,
      ),
      body: Stack(children: [
        Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'First Name*',
                    hintText: "John",
                  ),
                  validator: (value) =>
                      value.isEmpty ? 'First Name can\'t be empty' : null,
                  onSaved: (value) => _first = value.trim(),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Last Name*',
                    hintText: "Doe",
                  ),
                  validator: (value) =>
                      value.isEmpty ? 'Last Name can\'t be empty' : null,
                  onSaved: (value) => _last = value.trim(),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email*',
                    hintText: "john.doe@gmail.com",
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: emailValidator,
                  onSaved: (value) => _email = value.trim(),
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Password*', hintText: "********"),
                  obscureText: true,
                  validator: pwdValidator,
                  onSaved: (value) => _password = value.trim(),
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Confirm Password*', hintText: "********"),
                  obscureText: true,
                  validator: pwdValidator,
                  onSaved: (value) => _confirmpwd = value.trim(),
                ),
                RoundedButton(
                  title: "Register",
                  colour: Colors.lightBlueAccent,
                  onPressed: () async {
                    setState(() {
                      _errorMessage = "";
                      _isLoading = true;
                    });
                    try {
                      if (validateAndSave(_formKey)) {
                        if (_password == _confirmpwd) {
                          FirebaseUser result = await Provider.of<AuthService>(
                                  context,
                                  listen: false)
                              .createUser(
                                  email: _email,
                                  password: _password,
                                  firstName: _first,
                                  lastName: _last);
                          setState(() {
                            _isLoading = false;
                          });
                          print(result);
                          Navigator.of(context).pop();
//                    Navigator.pushNamed(context, InventoryScreen.id)
                        } else {
                          setState(() {
                            _isLoading = false;
                          });
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Error"),
                                  content: Text("The passwords do not match"),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text("Close"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              });
                        }
                      } else {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    } catch (e) {
                      print('Error: $e');
                      setState(() {
                        _isLoading = false;
                        _errorMessage = e.message;
                        _formKey.currentState.reset();
                      });
                    }
                  },
                ),
                GoogleSignInButton(
                  text: 'Sign up with Google',
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    FirebaseUser result =
                        await Provider.of<AuthService>(context, listen: false)
                            .signInWithGoogle();
                    setState(() {
                      _isLoading = false;
                    });
                    print(result);
                    Navigator.of(context).pop();
                  },
                  borderRadius: 20.0,
                ),
                showErrorMessage(_errorMessage),
                showSecondaryButton(_isLoading, toggleFormMode),
              ],
            ),
          ),
        ),
        showCircularProgress(_isLoading)
      ]),
    );
  }
}
