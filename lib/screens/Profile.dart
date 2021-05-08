
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_the_wealth/screens/CreateAccount.dart';
import 'package:share_the_wealth/widgets/BottomNavigation.dart';
import 'package:share_the_wealth/widgets/Header.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_the_wealth/model/Party.dart';


class ProfileScreen extends StatelessWidget {
  ProfileScreen();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: HeaderBar(),
        body: ProfileScreenBody(),
        bottomNavigationBar: BottomNavigation(),
      ),
    );
  }
}
 
class ProfileScreenBody extends StatefulWidget {
  @override
  _ProfileScreenBodyState createState() => _ProfileScreenBodyState();
}

class _ProfileScreenBodyState extends State<ProfileScreenBody> {

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Profile',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1
                    ),
                  ),
                  IconButton(icon: Icon(Icons.settings), onPressed: (){})
                ],
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset('assets/images/profile.png',
                    width: 130,
                  ),
                  ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 200
                      ),
                    child: Column(
                      children: [
                        Text('Together we can cure the needy.',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: .5,
                              wordSpacing: 2
                          ),
                        ),
                        TextButton(onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return createAccount();
                          }));
                        },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Color(0xFFF99300),
                                borderRadius: BorderRadius.circular(5)
                              ),
                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                              child: Center(
                                child: Text('Create account or login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 1
                                  ),
                                ),
                              ),
                            )
                        )
                      ],
                    )
                  )
                ],
              )
            ),
            Container(
              height: 20,
            ),
            TextButton(onPressed: null, child: Container(
              decoration: BoxDecoration(
                  color: Color(0x66FFA500),
                  borderRadius: BorderRadius.circular(10)
              ),
              padding: EdgeInsets.symmetric(vertical: 15,horizontal: 15),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('0',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text('Medication Shared',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15
                          ),
                        ),
                      )
                    ],
                  ),
                  Icon(Icons.volunteer_activism,color: Colors.black,size: 30,)
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
            )
            ),
            TextButton(onPressed: null, child: Container(
              decoration: BoxDecoration(
                  color: Color(0x66FFA500),
                  borderRadius: BorderRadius.circular(10)
              ),
              padding: EdgeInsets.symmetric(vertical: 15,horizontal: 15),
              child: Row(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Icon(FontAwesomeIcons.trophy),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('See All achievements',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios,color: Colors.black,size: 15,)
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
            )
            )
          ],
        ),
    );
  }
}
