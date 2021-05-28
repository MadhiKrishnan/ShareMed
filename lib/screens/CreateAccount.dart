import 'dart:convert';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:share_the_wealth/constants/api_paths.dart';
import 'package:share_the_wealth/main.dart';
import 'package:share_the_wealth/model/Party.dart';
import 'package:share_the_wealth/screens/Login.dart';
import 'package:share_the_wealth/screens/Profile.dart';
import 'package:share_the_wealth/widgets/BottomNavigation.dart';
import 'package:http/http.dart' as http;

Future<Party> _createParty(String firstName,String lastName,String email,String password,String partyType) async {

  if(partyType == 'Medication Doner'){
    partyType='doner';
  }else if(partyType == 'Medication Accepter'){
    partyType='accepter';
  }

  final response =  await http.post(Uri.http(ApiPaths.shareMedBackendEndPoint+':'+ApiPaths.port, '/addUser'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String ,String>
        {
        'firstName': firstName,
        'lastName':lastName,
        'email':email,
        'password':password,
        'partyType':partyType
      }
    ),
  );
  debugPrint('Status COde '+response.statusCode.toString());

  if (response.statusCode == 200) {
      debugPrint('inside 200 if');
      return Party.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create album.');
  }
}


class createAccount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: createAccountScreenBody(),
        bottomNavigationBar: BottomNavigation(),
      ),
    );
  }
}

class createAccountScreenBody extends StatefulWidget {
  @override
  _createAccountScreenBodyState createState() => _createAccountScreenBodyState();
}

class _createAccountScreenBodyState extends State<createAccountScreenBody> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final emailController = TextEditingController();
  final lastNameController = TextEditingController();
  final passwordController = TextEditingController();
  String _dropDownValue;
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
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
                          maxWidth: 100
                      ),
                      child: Text('Hello ! SignUp to start helping',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF99300),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Color(0xFFF99300),
                    ),
                    width: 50,
                    height: 50,

                    child: Image.asset('assets/images/profile.png',
                      width: 130,
                      color: Colors.white,
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
                            data: ThemeData(
                              primaryColor: Color(0xFFF99300),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              padding: EdgeInsets.only(left: 10),
                              child: DropdownButton(
                                hint: _dropDownValue == null?Center(child: Text('Who Are You?')):Center(child: Text(_dropDownValue)),
                                isExpanded: true,
                                iconEnabledColor: Color(0xFFF99300),
                                items: ['Medication Doner', 'Medication Accepter'].map(
                                      (val) {
                                    return DropdownMenuItem<String>(
                                      value: val,
                                      child: Text(val),
                                    );
                                  },
                                ).toList(),
                                onChanged: (val) {
                                  setState(
                                        () {
                                      _dropDownValue = val;
                                    },
                                  );
                                },
                              ),
                            )
                        ),
                        Theme(
                          data: new ThemeData(
                            primaryColor: Color(0xFFF99300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TextField(
                              controller: firstNameController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: new BorderSide(color: Colors.teal)),
                                  hintText: 'Enter Your First Name',
                                  labelText: 'First Name',
                                  prefixIcon: const Icon(
                                    Icons.person,
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
                              controller: lastNameController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: new BorderSide(color: Colors.teal)),
                                  hintText: 'Enter Your Last Name',
                                  labelText: 'Last Name',
                                  prefixIcon: const Icon(
                                    Icons.person,
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
                              obscureText: true,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: new BorderSide(color: Colors.teal)),
                                  hintText: 'Enter Your Password',
                                  labelText: 'Password',
                                  prefixIcon: const Icon(
                                    Icons.remove_red_eye,
                                    color: Color(0xFFF99300),
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
                                  content: FutureBuilder<Party> (
                                    future:  _createParty(firstNameController.text, lastNameController.text, emailController.text, passwordController.text,_dropDownValue),
                                    builder: (context,AsyncSnapshot<Party> snapshot){
                                      switch(snapshot.connectionState){
                                        case ConnectionState.waiting : return CircularProgressIndicator();
                                        default :
                                          if(snapshot.hasError){
                                            return Text("Error While Registering");
                                          }else {
                                            return Text('Registered Successfully');
                                          }
                                      }
                                    },
                                  ),
                                  actions: [TextButton(onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context){
                                    return LoginScreen();
                                  }));
                                }, child: Text('Ok'))],
                              );
                            });
                          },
                              style: ElevatedButton.styleFrom(
                                primary:  Color(0xFFF99300),
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text('SignUp',
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
                                      TextSpan(text: 'Already Have An Account ',style: TextStyle(
                                          fontSize: 17
                                      )),
                                      TextSpan(text: ' Sign in',
                                          recognizer: new TapGestureRecognizer()..onTap = () =>
                                          {
                                            Navigator.push(context, MaterialPageRoute(builder: (context){
                                              return LoginScreen();
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



