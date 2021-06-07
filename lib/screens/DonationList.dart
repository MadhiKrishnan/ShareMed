import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_the_wealth/constants/api_paths.dart';
import 'package:share_the_wealth/model/Donation.dart';
import 'package:share_the_wealth/model/MedRequest.dart';
import 'package:share_the_wealth/model/Product.dart';
import 'package:share_the_wealth/screens/Admin/RequestList.dart';
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

Future<List<RequestAndProductInfo>> _fetchPartyRequest(int partyId) async{
  final response = await http.get(Uri.http(ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port, "/getPartyRequest/"+partyId.toString()));
  if(response.statusCode == 200){
    List requestList = json.decode(response.body);
    return requestList.map((e) => new RequestAndProductInfo.fromJson(e)).toList();
  }else {
    throw Exception('Unexpected error occured!');
  }
}

class RequestAndProductInfo {
  final MedRequest medRequest;
  final Product product;

  RequestAndProductInfo({this.medRequest,this.product});
  factory RequestAndProductInfo.fromJson(Map<String,dynamic> json){
    return RequestAndProductInfo(
      medRequest: MedRequest.fromJson(json['medRequest']),
      product: Product.fromJson(json['productInfo'])
    );
  }
}

class MedRequest {
  final int medRequestId;
  final String medicationType;
  final String medicationName;
  final int numberOfDoses;
  final String dropAddress1;
  final String dropAddress2;
  final String state;
  final String city;
  final String medRequestStatus;
  final int partyId;
  final int productId;
  final String presUrl;

  MedRequest({this.medicationType,this.medicationName,this.numberOfDoses,this.dropAddress1,this.dropAddress2,this.state,this.city,this.medRequestStatus,this.partyId,this.medRequestId,this.productId,this.presUrl});

  factory MedRequest.fromJson(Map<String,dynamic> json) {
    return MedRequest(
        medicationType: json['medicationType'],
        medicationName: json['medicationName'],
        numberOfDoses: json['numberOfDoses'],
        dropAddress1: json['dropAddress1'],
        dropAddress2:json['dropAddress2'],
        state:json['state'],
        city:json['city'],
        medRequestStatus:json['requestStatus'],
        partyId:json['partyId'],
        medRequestId: json['medRequestId'],
        productId: json['productId'],
        presUrl: json['prescriptionUrl']
    );
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
  Future<List<Donation>> fetucUserDonation;
  Future<List<RequestAndProductInfo>> fetchUserRequest;
  bool isLoggedInUser = false;
  int partyId;
  String partyType;
  _checkIfUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getBool('isUserLoggedIn')!=null && prefs.getBool('isUserLoggedIn')){
      setState(() {
        this.isLoggedInUser = true;
        this.partyId = prefs.getInt("partyId");
        this.partyType = prefs.getString("partyType");
      });

      if(partyType != null && partyType == 'accepter'){
        fetchUserRequest = _fetchPartyRequest(this.partyId);
      }else {
        fetucUserDonation = _fetchPartyDonations(this.partyId);
      }

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
                  Builder(
                      builder: (context){
                        if(partyType != null && partyType == 'accepter'){
                         return  Text('Total Medication Request',
                           style: TextStyle(
                               fontSize: 16,
                               color: Colors.black,
                               fontWeight: FontWeight.w600,
                               letterSpacing: 1
                           ),
                         );
                        }else {
                          return Text('Total Donations',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1
                            ),
                          );
                        }
                      }
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
              child: Builder(
                builder: (context){
                  if(partyType == null){
                    return FutureBuilder<List<Donation>>(
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
                                                        Flexible(child: Builder(
                                                          builder: (context){
                                                            if(donation.donationStatus == 'not_recived'){
                                                              return Text('Not Recived',style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold,fontSize: 16));
                                                            }else if(donation.donationStatus == 'recived'){
                                                              return Text('Recived',style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold,fontSize: 16));
                                                            }else if(donation.donationStatus == 'Yet_To_Deliver'){
                                                              return Text('Requested',style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold,fontSize: 16));
                                                            }
                                                          },
                                                        )),
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
                        });
                  }else {
                    return FutureBuilder<List<RequestAndProductInfo>>(
                        future: fetchUserRequest,
                        builder: (context,AsyncSnapshot<List<RequestAndProductInfo>> snapshot){
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
                                                  child: Image.network("http://"+ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port+donation.product.imageUrl,width: 75,)
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
                                                    child: Text("${donation.product.productName}".toUpperCase(),style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w700
                                                    ),),
                                                  ),
                                                  Container(
                                                    width: 135,
                                                    child: Row(
                                                      children: [
                                                        Text('Status : ',style: TextStyle(fontSize: 15),),
                                                        Flexible(child: Builder(
                                                          builder: (context){
                                                            if(donation.medRequest.medRequestStatus == 'Yet_To_Deliver'){
                                                              return Text('Yet To Deliver',style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold,fontSize: 16));
                                                            }else if(donation.medRequest.medRequestStatus == 'delivered'){
                                                              return Text('Delivered',style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold,fontSize: 16));
                                                            }else{
                                                              return Text('Unavilable',style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold,fontSize: 16));
                                                            }
                                                          },
                                                        )),
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
                                                    Text('${donation.medRequest.numberOfDoses}  Doses',style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold,fontSize: 16),),
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
                        });
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}


