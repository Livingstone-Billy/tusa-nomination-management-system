import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mailto/mailto.dart';
import 'package:private_domain/home.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminSide extends StatelessWidget {
  const AdminSide({super.key});

  Route<dynamic> route(Widget widget) {
    return CupertinoPageRoute(builder: ((context) {
      return widget;
    }));
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Admin Login",
      debugShowCheckedModeBanner: false,
      home: AdminLogin(),
    );
  }
}

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isUser = false;
  int? code;

  @override
  void initState() {
    super.initState();

    setState(() {
      code = codeGenerator();
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  int codeGenerator() {
    var random = Random();
    int code = random.nextInt(900000) + 100000;
    return code;
  }

  Future mailCode(int code) async {
    final mailToLink = Mailto(
        to: [emailController.text],
        subject: 'Verification Code',
        body: 'Verification Code: $code');

    debugPrint("success");

    await launchUrl(Uri.parse('$mailToLink'));
  }

  ///
  ///@login - handles admin login into the application
  ///

  Future<void> login() async {
    //no persistence for the application
    await FirebaseAuth.instance.setPersistence(Persistence.NONE);
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
      if (userCredential.user != null) {
        setState(() {
          isUser = true;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        showDialog(
            context: context,
            builder: ((context) {
              return const AlertDialog(
                content: SizedBox(
                  height: 100,
                  child: Center(
                    child: Text(
                      "Incorrect Login Credentials!",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                          fontSize: 17),
                    ),
                  ),
                ),
              );
            }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Login"),
      ),
      body: Center(
        child: SizedBox(
          height: 300,
          width: 300,
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            child: Form(
              key: _formKey,
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Login Details",
                    style: TextStyle(
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                        fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "email cannot be null";
                      } else {
                        return null;
                      }
                    },
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "password cannot be null";
                      } else {
                        return null;
                      }
                    },
                    obscureText: true,
                    controller: passwordController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: (() {
                      if (_formKey.currentState!.validate()) {
                        login().then((value) {
                          if (isUser) {
                            mailCode(code!).then((value) =>
                                Navigator.of(context).pushAndRemoveUntil(
                                    const AdminSide().route(UserVerification(
                                        email: emailController.text,
                                        code: code!)),
                                    (route) => false));
                          }
                        });
                      }
                    }),
                    child: const Text("Login"),
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class UserVerification extends StatefulWidget {
  const UserVerification({super.key, required this.email, required this.code});

  final String email;
  final int code;

  @override
  State<UserVerification> createState() => _UserVerificationState();
}

class _UserVerificationState extends State<UserVerification> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  TextEditingController codeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "User verification",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("User Veification"),
        ),
        body: Center(
          child: SizedBox(
            width: 250,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    validator: ((value) {
                      if (value == null || value.isEmpty) {
                        return "This field cannot be empty";
                      } else {
                        return null;
                      }
                    }),
                    controller: codeController,
                    decoration: InputDecoration(
                        labelText: 'Verification Code',
                        prefixIcon: const Icon(Icons.code),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0))),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton(
                        onPressed: (() {
                          if (_formKey.currentState!.validate()) {
                            if (int.tryParse(codeController.text) ==
                                widget.code) {
                              Navigator.of(context).pushAndRemoveUntil(
                                  const AdminSide().route(const AdminHome()),
                                  (route) => false);
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                        "Invalid Code!",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      content: SizedBox(
                                          height: 100,
                                          child: Center(
                                            child: TextButton(
                                                onPressed: (() => Navigator.of(
                                                        context)
                                                    .pushAndRemoveUntil(
                                                        const AdminSide().route(
                                                            const AdminLogin()),
                                                        (route) => false)),
                                                child: const Text("Back")),
                                          )),
                                    );
                                  },
                                  barrierDismissible: false);
                            }
                          }
                        }),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            minimumSize: const Size(150, 45)),
                        child: const Text("Verify")),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
