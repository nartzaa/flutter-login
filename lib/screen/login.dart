import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../model/profiles.dart';
import 'welcome.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                title: const Text('เข้าสู่ระบบ'),
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
                                child: const Text('Login',
                                    style: TextStyle(fontSize: 20)),
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    formKey.currentState?.save();
                                    try {
                                      await FirebaseAuth.instance
                                          .signInWithEmailAndPassword(
                                              email: profile.email,
                                              password: profile.password)
                                          .then((value) {
                                        Fluttertoast.showToast(
                                          msg: 'Finish',
                                          gravity: ToastGravity.TOP,
                                        );
                                        formKey.currentState?.reset();
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const WelcomeScreen(),
                                          ),
                                        );
                                      });
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
