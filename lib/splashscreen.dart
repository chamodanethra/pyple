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
    return SplashScreen(
      seconds: 2,
      navigateAfterSeconds: Home(),
      title: Text(
        'pyPle',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: Color(
            0xFFE99600,
          ),
        ),
      ),
      loadingText: Text(
        'Convolutional Neural Network by Chamoda Nethra Nanayakkara',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
          color: Color(
            0xFFE99600,
          ),
        ),
      ),
      image: Image.asset('assets/gender.jpeg'),
      backgroundColor: Colors.black,
      photoSize: 75,
      loaderColor: Color(0xFFEEDA28),
    );
  }
}
