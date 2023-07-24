// 2:19:00

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loginsystem/model/profiles.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loginsystem/screen/home.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  Profile profile = Profile("profile.email", "password");
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebase,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: Center(
                child: Text('${snapshot.error}'),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('สร้างบัญชีผู้ใช้'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Email', style: TextStyle(fontSize: 20)),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (String? email) {
                              profile.email = email!;
                            },
                            validator: MultiValidator([
                              RequiredValidator(errorText: "กรุณาป้อนข้อมูล"),
                              EmailValidator(errorText: 'รูปแบบไม่ถูกต้อง'),
                            ]),
                          ),
                          const SizedBox(height: 15),
                          const Text('Password',
                              style: TextStyle(fontSize: 20)),
                          TextFormField(
                            obscureText: true,
                            onSaved: (String? password) =>
                                profile.password = password!,
                            validator: RequiredValidator(
                                errorText: "กรุณาป้อนรหัสผ่าน"),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 45,
                              width: double.infinity,
                              child: ElevatedButton(
                                child: const Text('Register',
                                    style: TextStyle(fontSize: 20)),
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    formKey.currentState?.save();
                                    try {
                                      await FirebaseAuth.instance
                                          .createUserWithEmailAndPassword(
                                              email: profile.email,
                                              password: profile.password)
                                          .then(
                                        (value) {
                                          Fluttertoast.showToast(
                                            msg: 'Finish',
                                            gravity: ToastGravity.TOP,
                                          );
                                          formKey.currentState?.reset();
                                          // ignore: use_build_context_synchronously
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const HomeScreen(),
                                            ),
                                          );
                                        },
                                      );
                                    } on FirebaseAuthException catch (e) {
                                      //print(e.message);
                                      Fluttertoast.showToast(
                                        msg: e.message ?? "Orther Error",
                                        gravity: ToastGravity.TOP,
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          )
                        ]),
                  ),
                ),
              ),
            );
          }
          // ignore: prefer_const_constructors
          return Scaffold(
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }
}

// @firebase > build Project > select auten service > ON email&pasword
//  - select android application service > GOTO  Flutter project

// @ Flutter project/android/app/build.gradle > defaultConfig {applicationId "com.example.loginsystem"}
//  - to Firebase then Follow step from firebase
