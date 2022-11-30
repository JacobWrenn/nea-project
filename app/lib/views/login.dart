import 'package:app/api.dart';
import 'package:app/components/buttons.dart';
import 'package:app/components/expansion.dart';
import 'package:app/views/customer/customerhome.dart';
import 'package:app/views/staff/staffhome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool checkedRestore = false;

  Future checkRestore() async {
    String accessLevel = await Api().restore();
    if (accessLevel != "") openHome(accessLevel);
    setState(() {
      checkedRestore = true;
    });
  }

  openHome(String accessLevel) {
    // initialises the correct homepage dependent on the user's access level
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return accessLevel == "user" ? CustomerHome() : StaffHome();
    }));
  }

  @override
  Widget build(BuildContext context) {
    // we need to check if an auth token already exists before login buttons are shown
    if (!checkedRestore) checkRestore();

    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: !checkedRestore
          ? SpinKitRing(color: Colors.blue)
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome to the Intelligent Platform.",
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  Text(
                    "Your intelligent delivery service starts here...",
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  expansion(button("Login", () async {
                    String accessLevel = await Api().login();
                    if (accessLevel != "") openHome(accessLevel);
                  })),
                  SizedBox(height: 16),
                  expansion(button("Register", () async {
                    String accessLevel = await Api().register();
                    if (accessLevel != "") openHome(accessLevel);
                  })),
                  SizedBox(height: 64),
                ],
              ),
            ),
    );
  }
}
