import 'package:flutter/material.dart';
import 'package:share_the_wealth/main.dart';
import 'package:share_the_wealth/screens/Admin/Admin_home.dart';
import 'package:share_the_wealth/screens/Admin/RequestList.dart';
import 'package:share_the_wealth/screens/Profile.dart';

class BottomNavigation extends StatefulWidget {
  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int currentIndex = 0;
  String contents = 'home';
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: (index){
        setState(() {
          currentIndex = index;
          switch(currentIndex){
            case 0:
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return AdminHomeScreen();
              }));
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return RequestList();
              }));
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return ProfileScreen();
              }));
              break;
          }
        });
      },
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Donations',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.request_page),
          label: 'Requests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pending_actions),
          label: 'More Actions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_outlined),
          label: 'Profile',
        ),
      ],
      selectedItemColor: Colors.orange,
    );
  }
}
