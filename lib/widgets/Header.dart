import 'package:flutter/material.dart';
import 'package:share_the_wealth/main.dart';

class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(60);
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
        child: AppBar(
          backgroundColor: Colors.white,
          actions: [
            Container(
                padding: EdgeInsets.only(right: 15),
                child: Icon(Icons.notifications_active,size: 25,color: Colors.grey,
                )
            ),

          ],
          title: GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return MyApp();
              }));
            },
            child: Container(
              child: Row(
                children: [
                  Image.asset("assets/images/logo.png",
                    width: 50,
                  ),
                  Text.rich(TextSpan(
                      style: TextStyle(
                          color: Color(0xFFF99300),
                          letterSpacing: 1
                      ),
                      text: 'Share',
                      children: <InlineSpan>[
                        WidgetSpan(
                          child: Container(
                            padding: EdgeInsets.only(left: 5,right: 5),
                            color: Colors.green,
                            child: Text('Med',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ]
                  ))
                ],
              ),
            ),
          ),
        ),
    );
  }
}
