import 'dart:ui';
import 'package:chat_app/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../components/rounded_button.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  static const String id =
      'welcomeScreen'; //static -  const - value cant be changed accidentatlly

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  //Concept - MIXINS
  //with SingleTickerProviderStateMixin - can act as SingleTickerProvider.
  // new ability to act as ticker for single animation and for multiple we can use TickerProviderStateMixin.

  late AnimationController controller; //for the animation control

  late Animation animation; // to use curved animation
  late Animation screenAnimation;

  @override
  void initState() {
    //this method gets called when the welcome screen gets created.
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
      //upperBound: 1, //when using curves upperbound should not be greater than 1
    );
    animation = CurvedAnimation(parent: controller, curve: Curves.decelerate);
    //parent - for what we are going to apply the animation
    //curve : what kind of curve
    controller.forward(); //small to large
    //controller.reverse(from: 1.0); //go from large to small
    //animate from 0-1 in 60 steps
    screenAnimation =
        ColorTween(begin: Colors.grey, end: Colors.white).animate(controller);

    //to check animation completed or not. This is the loop for animation to go from small-large and vice versa.
    // animation.addStatusListener((status) {
    //   if(status==AnimationStatus.completed) {
    //     controller.reverse(from: 1);
    //   }
    //   else if(status == AnimationStatus.dismissed){
    //     controller.forward();
    //   }
    // });

    //what controller is doing we need to add a listener
    controller.addListener(() {
      setState(() {});
    });
  }

  //to stop the animation when we go to other screen.
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenAnimation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset(
                      'images/logo.jpeg',
                    ),
                    height: animation.value * 100,
                  ),
                ),
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Flash Chat',
                      textStyle: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ],
                  pause: Duration(microseconds: 100),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              title: 'Log In',
              colour: Colors.lightBlueAccent,
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.logID);
              },
            ),
            RoundedButton(
                title: 'Register',
                onPressed: () {
                  Navigator.pushNamed(context, RegistrationScreen.regID);
                },
                colour: Colors.blue),
          ],
        ),
      ),
    );
  }
}


//import 'package:firebase_core/firebase_core.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

//pod setup