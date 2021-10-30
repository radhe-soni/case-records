
import 'package:case_records/home.dart';
import 'package:case_records/view/sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';

final Color PRIMARY_COLOR = Colors.lightGreen[900]!;
final String SHEET_ID = "1hIou3IG2sD4xvtfHaHceZfLmtvLjHRN2xi3ZqL4m2AQ";

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
    if(record.error != null) {
      print('Error: ${record.error}');
      print(record.stackTrace);
    }
  });
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Google Sign In',
      home: LoginRouter(),
    );
  }
}

class LoginRouter extends StatefulWidget {
  const LoginRouter({Key? key}) : super(key: key);

  @override
  _LoginRouterState createState() => _LoginRouterState();
}

class _LoginRouterState extends State<LoginRouter> {
  GoogleSignInAccount? _currentUser;

  void setLoginStatus(GoogleSignInAccount? _currentUser){
    setState((){
      this._currentUser = _currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Sign In',
      home: _currentUser != null ? Home(googleSignInAccount: _currentUser!) : SignInDemo(signInCallBack: setLoginStatus),
    );
  }
}



