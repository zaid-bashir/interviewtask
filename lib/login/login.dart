// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:interviewtask/users/userlist.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _validateAndSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
        });
        if (kDebugMode) {
          print("Successfully signed in: ${userCredential.user!.uid}");
        }
        showSnackBar(
          context,
          content: "User Logged In",
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const UserListScreen(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (kDebugMode) {
          print("Error: $e");
        }
        showSnackBar(
          context,
          content: "$e",
        );
      }
    }
  }

  void _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'email': userCredential.user!.email,
      });
      if (kDebugMode) {
        print(
            "Successfully signed in with Google: ${userCredential.user!.displayName}");
      }
      showSnackBar(
        context,
        content: "User Logged In",
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const UserListScreen(),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error signing in with Google: $e");
      }
      log("Error signing in with Google: $e");
      showSnackBar(
        context,
        content: "$e",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Interview Task"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Interview Task",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter your email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter your password";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _validateAndSubmit,
                child: const Text("Login"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _signInWithGoogle,
                child: const Text("Login with Google"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showSnackBar(BuildContext context, {required String content}) {
  final snackBar = SnackBar(
    content: Text(content),
    duration: const Duration(seconds: 3),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
