import 'dart:convert';
import 'dart:ffi';

import 'package:energymeter/state/application_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import 'HomePage.dart';
// import 'Home_Page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameIP = TextEditingController();
  TextEditingController passwordIP = TextEditingController();
  bool isServerResponseGoingOn = false, _passwordVisible = true;

  @override
  void initState() {
    super.initState();
    passwordIP.text = "";
  }

  Future<void> handleLogin(String username, String password) async {
    if (kDebugMode) {
      print("handleLogin $username:$password");
    }
    setState(() {
      isServerResponseGoingOn = true;
    });
    Response? response;
    try {
      String url = context.read<ApplicationState>().getUrl();
      url +=
          "/user.json?orderBy=\"username\"&&startAt=\"$username\"&endAt=\"$username\"";

      response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      setState(() {
        isServerResponseGoingOn = false;
      });

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('response $url ${response.statusCode} ${response.body} ');
        }
      }
      bool? result = false;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        Map<String, dynamic> parameters = jsonDecode(response.body);
        var cd = parameters.forEach((key, value) {
          // list.add(value);
          // print("value $value");
          if (value["password"] == password) {
            result = true;
          }
        });
        // print("parameters1 ${list[0]["password"]}");
        if (result == true) {
          // EasyLoading.showToast("Successfull", dismissOnTap: true);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomePage()));
        }
        // if (kDebugMode) {
        //   print("parameters $parameters");
        // }
        // ignore: use_build_context_synchronously
        // EasyLoading.showToast("Successfull", dismissOnTap: true);
      }
      if (result == false) {
        EasyLoading.showToast("Invalid Username or Password",
            dismissOnTap: true);
        // setState(() {
        //   passwordIP.text = "";
        // });
      }
      // } else {
      //   EasyLoading.showToast("Unable to Communicate server",
      //       dismissOnTap: true);
      // }
    } catch (e) {
      response = null;
      String message = e.toString();
      EasyLoading.showToast(message, dismissOnTap: true);
    }

    setState(() {
      isServerResponseGoingOn = false;
    });
    // print("response ${response.statusCode}");
    // return null; //response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("EnergyMeter Tracking"),
        ),
        body: (isServerResponseGoingOn == true)
            ? Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: const CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                verticalDirection: VerticalDirection.down,
                children: <Widget>[
                  Padding(
                      //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        controller: usernameIP,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Username',
                          hintText: 'Enter username',
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.verified_user,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            onPressed: () {
                              // Update the state i.e. toogle the state of passwordVisible variable
                              setState(() {});
                            },
                          ),
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 15, bottom: 10),
                    //padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextField(
                      controller: passwordIP,
                      obscureText: _passwordVisible,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Password',
                        hintText: 'Enter secure password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 250,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20)),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          handleLogin(usernameIP.text, passwordIP.text);
                        });
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 130,
                  ),
                  // Text('New User? Create Account')
                ],
              ));
  }
}

// http://103.146.217.82:4302/api/login
// {
//   "username": "operator",
//   "password": "password"
// }
//{"user":{"username":"operator","token":"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9
