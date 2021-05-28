import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_the_wealth/constants/api_paths.dart';
import 'package:share_the_wealth/model/Donation.dart';
import 'package:share_the_wealth/model/Product.dart';
import 'package:share_the_wealth/screens/Profile.dart';
import 'package:share_the_wealth/widgets/BottomNavigation.dart';
import 'package:share_the_wealth/widgets/Header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


Future<List<Donation>> _fetchPartyDonations(int partyId) async{
  final response = await http.get(Uri.http(ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port, "/getPartyDonationList/"+partyId.toString()));
  if(response.statusCode == 200){
    List donationList = json.decode(response.body);
    return donationList.map((e) => new Donation.fromJson(e)).toList();
  }else {
    throw Exception('Unexpected error occured!');
  }
}

Future<Product> _fetchProductDetail(int productId) async{
  final response = await http.get(Uri.http(ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port, '/getProduct/'+productId.toString()));
  if(response.statusCode == 200){
    return Product.fromJson(jsonDecode(response.body));
  }else {
    throw Exception('Unexpected error occured!');
  }
}

class DonationListScreen extends StatelessWidget {
  int productId;
  DonationListScreen();
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
        body: DonationListScreenBody(),
        bottomNavigationBar: BottomNavigation(),
      ),
    );
  }
}
class DonationListScreenBody extends StatefulWidget {
  const DonationListScreenBody({Key key}) : super(key: key);

  @override
  _DonationListScreenBodyState createState() => _DonationListScreenBodyState();
}

class _DonationListScreenBodyState extends State<DonationListScreenBody> {

  bool isLoggedInUser = false;
  int partyId;
  Future<List<Donation>> fetucUserDonation;

  _checkIfUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getBool('isUserLoggedIn')!=null && prefs.getBool('isUserLoggedIn')){
      setState(() {
        this.isLoggedInUser = true;
        this.partyId = prefs.getInt("partyId");
      });
      fetucUserDonation = _fetchPartyDonations(this.partyId);
    }
  }
  

  @override
  void initState() {
    super.initState();
    _checkIfUserLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child:  Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40,horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Donations',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return ProfileScreen();
                      }));
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 15),
                      child: Text("Back",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            letterSpacing: 1,
                        ),),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: FutureBuilder<List<Donation>>(
                  future: fetucUserDonation,
                  builder: (context,AsyncSnapshot<List<Donation>> snapshot){
                    switch(snapshot.connectionState){
                      case ConnectionState.waiting : return CircularProgressIndicator();
                      default :
                        if(snapshot.hasError){
                          return Text('Error : ${snapshot.error}');
                        }else {
                          return Column(
                            children: [
                              for(var donation in snapshot.data)
                              Container(
                            padding: EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network("http://"+ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port+donation.productInfo.imageUrl,width: 75,)
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  height: 70,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 5),
                                        child: Text("${donation.productInfo.productName}".toUpperCase(),style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700
                                        ),),
                                      ),
                                      Container(
                                        width: 135,
                                        child: Row(
                                          children: [
                                            Text('Status : ',style: TextStyle(fontSize: 15),),
                                            Flexible(child: Text(donation.donationStatus == 'not_recived'?'NOT RECIVED':'Recived',style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold,fontSize: 16),)),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                    margin: EdgeInsets.only(left: 10,top: 12),
                                    height: 100,
                                    child: Row(
                                      children: [
                                        Text('${donation.numberOfDoses}  Doses',style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold,fontSize: 16),),
                                        Icon(Icons.arrow_forward,size: 17,)
                                      ],
                                    )
                                )
                              ],
                            ),
                          )
                            ],
                          );
                        }
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}


