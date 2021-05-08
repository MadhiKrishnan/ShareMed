import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:share_the_wealth/constants/api_paths.dart';
import 'package:share_the_wealth/main.dart';
import 'package:share_the_wealth/model/Login.dart';
import 'package:share_the_wealth/screens/CreateAccount.dart';
import 'package:share_the_wealth/screens/Profile.dart';
import 'package:share_the_wealth/widgets/BottomNavigation.dart';
import 'package:http/http.dart' as http;


Future<Login> _checkLogin(String email,String password) async {
  final response =  await http.post(Uri.http(ApiPaths.shareMedBackendEndPoint+':'+ApiPaths.port, '/checkLogin'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String,dynamic>{
      "email":email,
      "password":password
    })
  );
  debugPrint('Status COde '+response.statusCode.toString());

  if (response.statusCode == 200) {
    debugPrint('inside 200 if');
    return Login.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create album.');
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: LoginScreenBody(),
        bottomNavigationBar: BottomNavigation(),
      ),
    );
  }
}

class LoginScreenBody extends StatefulWidget {
  @override
  _LoginScreenBodyState createState() => _LoginScreenBodyState();
}

class _LoginScreenBodyState extends State<LoginScreenBody> {
  final _formKey = GlobalKey<FormState>();
  // Initially password is obscure
  bool _obscureText = true;
  bool isLoggedInSuccessfully = true;
  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Container(
          child: Column(
            children: [
              Row(
                children: [
                  TextButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return ProfileScreen();
                    }));
                  },
                      style: TextButton.styleFrom(
                        primary: Colors.black,
                      ),
                      child: Text.rich(
                          TextSpan(
                            children: <InlineSpan>[
                              WidgetSpan(
                                  child: Container(
                                      width: 40,
                                      child: Icon(Icons.arrow_back,size: 20,))
                              ),
                              TextSpan(text: 'Back',style: TextStyle(
                                  fontSize: 17
                              )),
                            ],
                          )
                      )
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20,top: 20,right: 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: 200
                      ),
                      child: Text('Hello Again! Welcome Back',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF99300),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 30,vertical: 50),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Theme(
                          data: new ThemeData(
                            primaryColor: Color(0xFFF99300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: new BorderSide(color: Colors.teal)),
                                  hintText: 'Enter Your Email Address',
                                  labelText: 'Email Address',
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Color(0xFFF99300),
                                  )
                              ),
                            ),
                          ),
                        ),
                        Theme(
                          data: new ThemeData(
                            primaryColor: Color(0xFFF99300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TextField(
                              controller: passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: new BorderSide(color: Colors.teal)),
                                  hintText: 'Enter Your Password',
                                  labelText: 'Password',
                                  prefixIcon: IconButton(
                                    onPressed: _toggle,
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      color: Color(0xFFF99300),
                                    ),
                                  )
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(onPressed: (){
                            showDialog(context: context, builder: (context){
                              return AlertDialog(
                                content: FutureBuilder<Login> (
                                  future:  _checkLogin(emailController.text,passwordController.text),
                                  builder: (context,AsyncSnapshot snapshot){
                                    if(snapshot.hasData && snapshot.data.isValidUser){
                                      return Text("Logged In successfully");
                                    }else {
                                       return Text('Failed to Login');
                                    }
                                  },
                                ),
                                actions: [TextButton(onPressed: (){
                                  if(isLoggedInSuccessfully){
                                    Navigator.push(context, MaterialPageRoute(builder: (context){
                                      return MyApp();
                                    }));
                                  }else {
                                    Navigator.push(context, MaterialPageRoute(builder: (context){
                                      return LoginScreen();
                                    }));
                                  }

                                }, child: Text('Ok'))],
                              );
                            });
                          },
                              style: ElevatedButton.styleFrom(
                                primary:  Color(0xFFF99300),
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text('Sign In',
                                style: TextStyle(
                                    fontSize: 16
                                ),
                              )
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10,left: 10),
                              child: Text.rich(
                                  TextSpan(
                                    children: <InlineSpan>[
                                      TextSpan(text: 'Don\'t have an account ?',style: TextStyle(
                                          fontSize: 17
                                      )),
                                      TextSpan(text: ' Sign Up',
                                          recognizer: new TapGestureRecognizer()..onTap = () =>
                                          {
                                            Navigator.push(context, MaterialPageRoute(builder: (context){
                                              return createAccount();
                                            }))
                                          },
                                          style: TextStyle(
                                            fontSize: 17,
                                            decoration: TextDecoration.underline, color:  Color(0xFFF99300),
                                          )),
                                    ],
                                  )
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}

