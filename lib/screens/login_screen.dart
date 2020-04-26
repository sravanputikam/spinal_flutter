import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spinal_flutter/widgets/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spinal_flutter/services/auth.dart';
import 'package:spinal_flutter/validators.dart';
import 'package:spinal_flutter/screens/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  String _errorMessage;
  bool _isLoginForm;
  bool _isLoading;
  final _formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;
    super.initState();
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
    print("User Sign Out");
  }

  // Check if form is valid before perform login or signup

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
    Navigator.popAndPushNamed(context, RegistrationScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('Login'),
          elevation: 0.0,
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Stack(children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: [
                  Container(
                    height: 150.0,
                    child: FlutterLogo(
                      size: 100.0,
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    child: TextFormField(
                      maxLines: 1,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (term) {
                        _fieldFocusChange(context, _emailFocus, _passwordFocus);
                      },
                      autofocus: false,
                      decoration: InputDecoration(
                          hintText: 'Email',
                          icon: Icon(
                            Icons.mail,
                            color: Colors.grey,
                          )),
                      validator: emailValidator,
                      onSaved: (value) => _email = value.trim(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    child: TextFormField(
                      maxLines: 1,
                      focusNode: _passwordFocus,
                      onFieldSubmitted: (term) {
                        _passwordFocus.unfocus();
                      },
                      obscureText: true,
                      autofocus: false,
                      decoration: InputDecoration(
                          hintText: 'Password',
                          icon: Icon(
                            Icons.lock,
                            color: Colors.grey,
                          )),
                      validator: pwdValidator,
                      onSaved: (value) => _password = value.trim(),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  RoundedButton(
                    title: 'Log In',
                    colour: Colors.lightBlueAccent,
                    onPressed: () async {
                      setState(() {
                        _errorMessage = "";
                        _isLoading = true;
                      });
                      try {
                        if (validateAndSave(_formKey)) {
                          try {
                            FirebaseUser result = await Provider.of<
                                    AuthService>(context, listen: false)
                                .loginUser(email: _email, password: _password);
                            setState(() {
                              _isLoading = false;
                            });
                            print(result);
                            Navigator.of(context).pop();
//                    Navigator.pushNamed(context, InventoryScreen.id)
                          } on AuthException catch (error) {
                            return _buildErrorDialog(context, error.message);
                          } on Exception catch (error) {
                            return _buildErrorDialog(context, error.toString());
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
      ),
    );
  }
}

Future _buildErrorDialog(BuildContext context, _message) {
  return showDialog(
    builder: (context) {
      return AlertDialog(
        title: Text('Error Message'),
        content: Text(_message),
        actions: <Widget>[
          FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              })
        ],
      );
    },
    context: context,
  );
}

_fieldFocusChange(
    BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}
