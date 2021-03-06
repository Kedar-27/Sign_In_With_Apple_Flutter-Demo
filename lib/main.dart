import 'dart:io';

import 'package:flutter/material.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:provider/provider.dart';

import './Firebase/apple_signIn_with_firebase.dart';
import 'Firebase/apple_sign_in_available.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign In With Apple Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isIOS) {
      //check for ios if developing for both android & ios
      AppleSignIn.onCredentialRevoked.listen((_) {
        print("Credentials revoked");
      });
    }
  }

  //region Methods
  void appleLogIn() async {
    if (await AppleSignIn.isAvailable()) {
      final AuthorizationResult result = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);
      switch (result.status) {
        case AuthorizationStatus.authorized:
          print(result.credential);
          break; //All the required credentials
        case AuthorizationStatus.error:
          print("Sign in failed: ${result.error.localizedDescription}");
          break;
        case AuthorizationStatus.cancelled:
          print('User cancelled');
          break;
      }
    }
  }

  Future<void> showAppleSignWithFirebasePage() async {
    WidgetsFlutterBinding.ensureInitialized();
    final appleSignInAvailable = await AppleSignInAvailable.check();

//    Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => AppleSignWithFirebaseDemo()),
//    );
//
    
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Provider<AppleSignInAvailable>.value(
        value: appleSignInAvailable,
        child: AppleSignWithFirebaseDemo(),
      ),
    ));
  }

  //endregion

  @override
  Widget build(BuildContext context) {
    final safeAreaHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sign In With Apple Demo'),
        ),
        body: Container(
          color: Colors.amberAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                color: Colors.transparent,
                height: safeAreaHeight * 0.9,
                padding: EdgeInsets.all(9),
                child: AppleSignInButton(
                  style: ButtonStyle.black,
                  type: ButtonType.continueButton,
                  onPressed: appleLogIn,
                ),
              ),
              Container(
                  color: Colors.transparent,
                  height: safeAreaHeight * 0.1,
                  child: FlatButton(
                      onPressed: showAppleSignWithFirebasePage,
                      child: Text(
                        'With Firebase',
                        style: TextStyle(color: Colors.black),
                      )))
            ],
          ),
        ),
      ),
    );
  }
}
