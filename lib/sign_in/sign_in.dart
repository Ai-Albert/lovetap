import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lovetap/custom_widgets/show_exception_alert_dialogue.dart';
import 'package:lovetap/services/auth.dart';
import 'package:lovetap/sign_in/validators.dart';
import 'package:provider/provider.dart';
import 'password_recovery.dart';

enum FormType {signIn, register}

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key, required this.isLoading}) : super(key: key);
  final bool isLoading;

  static Widget create(BuildContext context) {
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, isLoading, __) => SignInPage(isLoading: isLoading.value),
      ),
    );
  }
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with
    EmailAndPasswordValidator, SingleTickerProviderStateMixin {

  /********** EMAIL SIGN IN STUFF **********/

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  FormType _formState = FormType.signIn;
  String get _email => _emailController.text;
  String get _password => _passwordController.text;
  bool _submitted = false;
  bool _loading = false;

  void changeFormType() {
    setState(() {
      _submitted = false;
      _formState = _formState == FormType.signIn ? FormType.register : FormType.signIn;
    });
    _emailController.clear();
    _passwordController.clear();
  }

  void submit() async {
    setState(() {
      _submitted = true;
      _loading = true;
    });
    try {
      if (_formState == FormType.signIn) {
        await Provider.of<AuthBase>(context, listen: false).signInEmail(_email, _password);
      } else {
        await Provider.of<AuthBase>(context, listen: false).createUserEmail(_email, _password);
      }
    } on Exception catch (e) {
      _showSignInError(context, e);
    } finally {
      _loading = false;
    }
  }

  void _updateState() {
    setState(() {});
  }

  void _showSignInError(BuildContext context, Exception exception) {
    if (exception is FirebaseException &&
        exception.code == 'ERROR_ABORTED_BY_USER') {
      return;
    }
    showExceptionAlertDialog(
      context,
      title: 'Sign in failed',
      exception: exception,
    );
  }

  /********** UI STUFF **********/

  @override
  Widget build(BuildContext context) {
    String primaryButtonText = _formState == FormType.signIn ?
    'Sign in' : 'Register';
    String secondaryButtonText = _formState == FormType.signIn ?
    'Don\'t have an account? Register' : 'Have an account? Sign in';
    bool emailValid = emailValidator.isValid(_email);
    bool passwordValid = passwordValidator.isValid(_password);
    bool submitValid = !_loading && emailValid && passwordValid;
    bool showEmailError = _submitted && !emailValid;
    bool showPasswordError = _submitted && !passwordValid;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(35.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width),
              Image.asset('assets/love_letter.jpg'),
              TextField(
                style: GoogleFonts.montserrat(textStyle: TextStyle(fontSize: 14)),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: GoogleFonts.montserrat(),
                  errorText: showEmailError ? 'Email can\'t be empty' : null,
                  errorStyle: TextStyle(color: Colors.red),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(15)),
                ),
                cursorColor: Colors.black,
                controller: _emailController,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: (_email) => _updateState(),
              ),
              SizedBox(height: 15.0),
              TextField(
                style: GoogleFonts.montserrat(textStyle: TextStyle(fontSize: 14)),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: GoogleFonts.montserrat(),
                  errorText: showPasswordError ? 'Password can\'t be empty' : null,
                  errorStyle: TextStyle(color: Colors.red),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(15)),
                ),
                cursorColor: Colors.black,
                controller: _passwordController,
                autocorrect: false,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onChanged: (_password) => _updateState(),
              ),
              SizedBox(height: 50.0),
              _signInButton(primaryButtonText, submitValid),
              SizedBox(height: 15),
              _switchButton(secondaryButtonText),
              _forgotPasswordButton(_formState == FormType.signIn ? "Forgot your password?" : " "),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signInButton(String primaryButtonText, bool submitValid) {
    return AnimatedButton(
      height: 50,
      width: 200,
      text: primaryButtonText,
      isReverse: true,
      selectedTextColor: Colors.white,
      transitionType: TransitionType.LEFT_TO_RIGHT,
      selectedBackgroundColor: Colors.red,
      //textStyle: submitTextStyle,
      backgroundColor: Colors.black,
      borderColor: Colors.white,
      borderRadius: 15,
      borderWidth: 2,
      onPress: submitValid ? submit : () {},
    );
  }

  Widget _switchButton(String secondaryButtonText) {
    return TextButton(
      child: Text(
        secondaryButtonText,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      style: ButtonStyle(overlayColor: MaterialStateProperty.all(Colors.transparent)),
      onPressed: !_loading ? changeFormType : () {},
    );
  }

  Widget _forgotPasswordButton(String text) {
    return TextButton(
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      style: ButtonStyle(overlayColor: MaterialStateProperty.all(Colors.transparent)),
      onPressed: text == " " ? () {} : () => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PasswordRecovery(),
      )),
    );
  }
}

