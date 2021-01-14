import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'home.dart';

class MySplash extends StatefulWidget {
  @override
  _MySplashState createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return SplashScreen(
      seconds: 2,
      navigateAfterSeconds: Home(),
      title: Text(
        'Pyple',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 60,
          color: Color(
            0xFFA81C1C,
          ),
        ),
      ),
      loadingText: Text(
        'CNN by CNN',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Color(
            0xFFA81C1C,
          ),
        ),
      ),
      backgroundColor: Color(0xFFFDD624),
      photoSize: 75,
      loaderColor: Color(0xFFA81C1C),
    );
  }
}
