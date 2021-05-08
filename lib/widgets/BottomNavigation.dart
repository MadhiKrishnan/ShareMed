import 'package:flutter/material.dart';
import 'package:share_the_wealth/main.dart';
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
              contents = "Home";
              break;
            case 1:
              contents = "Subscription";
              break;
            case 2:
              contents = "Community";
              break;
            case 3:
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
          icon: Icon(Icons.volunteer_activism),
          label: 'Give',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.subscriptions_outlined),
          label: 'Subscription',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_work),
          label: 'Community',
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
