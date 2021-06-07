
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_the_wealth/constants/api_paths.dart';
import 'package:share_the_wealth/main.dart';
import 'package:share_the_wealth/screens/CreateAccount.dart';
import 'package:share_the_wealth/screens/DonationList.dart';
import 'package:share_the_wealth/widgets/AdminBottomNav.dart';
import 'package:share_the_wealth/widgets/Header.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_the_wealth/model/Party.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Party> _fetchParty(int partyId) async{
  final response = await http.get(Uri.http(ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port, "/getParty/"+partyId.toString()));
  if(response.statusCode == 200){
    return Party.fromJson(json.decode(response.body));
  }else {
    throw Exception('Unexpected error occured!');
  }
}

Future<MedDonationModel> _fetchMedDonatinCount(int partyId) async{
  final response = await http.get(Uri.http(ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port, "getMedicationCharedCount/"+partyId.toString()));
  if(response.statusCode == 200){
    return MedDonationModel.fromJson(json.decode(response.body));
  }else {
    throw Exception('Unexpected error occured!');
  }
}

class MedDonationModel{
  final int medDonationCount;
  MedDonationModel({this.medDonationCount});
  factory MedDonationModel.fromJson(Map<String,dynamic> json){
    return MedDonationModel(
        medDonationCount: json['totalMedicationDonated']
    );
  }
}

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
  bool isLoggedInUser = false;
  int partyId;
  Future fetchDontationCount;
  _checkIfUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getBool('isUserLoggedIn')!=null && prefs.getBool('isUserLoggedIn')){
      setState(() {
        this.isLoggedInUser = true;
        this.partyId = prefs.getInt("partyId");
      });
      fetchDontationCount = _fetchMedDonatinCount(this.partyId);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfUserLoggedIn();
  }



  _logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("isUserLoggedIn");
    prefs.remove("partyId");
    prefs.remove("partyType");
  }
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
                      child: Builder(
                        builder: (context){
                          if(this.isLoggedInUser){
                            return
                              FutureBuilder(
                                future: _fetchParty(this.partyId),
                                builder: (context,snapshot){
                                  return Column(
                                    children: [
                                      Text(snapshot.data.firstName.toString().toUpperCase()+" "+snapshot.data.lastName.toString().toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: .5,
                                            wordSpacing: 2
                                        ),
                                      ),
                                      TextButton(onPressed: (){
                                        _logOut();
                                        Navigator.push(context, MaterialPageRoute(builder: (context){
                                          return MyApp();
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
                                              child: Text('LogOut',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    letterSpacing: 1
                                                ),
                                              ),
                                            ),
                                          )
                                      )
                                    ],
                                  );
                                },
                              );
                          }else {
                            return Column(
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
                            );
                          }
                        },
                      )
                  )
                ],
              )
          )
        ],
      ),
    );
  }
}
