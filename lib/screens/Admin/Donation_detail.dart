import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_the_wealth/constants/api_paths.dart';
import 'package:share_the_wealth/model/Party.dart';
import 'package:share_the_wealth/model/Product.dart';
import 'package:share_the_wealth/screens/Admin/Admin_home.dart';
import 'package:share_the_wealth/widgets/AdminBottomNav.dart';
import 'package:http/http.dart' as http;


Future<DonationDetailModel> _fetchDonationDetailInfo(int donationId) async {
  final response = await http.get(Uri.http(ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port, "/getDonationDetailInfo/"+donationId.toString()));
  if(response.statusCode == 200){
    return DonationDetailModel.fromJson(json.decode(response.body));
  }else {
    throw Exception('Unexpected error occured!');
  }
}

Future<void> _updateDonationStatus(int donationId) async{
  debugPrint('futuew Fun Called');
  await http.put(Uri.http(ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port, "/updateDonation"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String,dynamic>{
        "donationId":donationId,
        "donationStatus":'recived'
      })
  );
}


class DonationDetailModel {
  final Donation donation;
  final Product product;
  final Party party;

  DonationDetailModel({this.donation,this.party,this.product});

  factory DonationDetailModel.fromJson(Map<String,dynamic> json){
    return DonationDetailModel(
      donation: Donation.fromJson(json['donation']),
      product: Product.fromJson(json['product']),
      party: Party.fromJson(json['party'])
    );
  }

}

class DonationDetail extends StatelessWidget {
  final int donationId;
  DonationDetail(this.donationId);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: DonationDetailBody(this.donationId),
        bottomNavigationBar: BottomNavigation(),
      ),
    );
  }
}

class DonationDetailBody extends StatefulWidget {
  final int donationId;
  DonationDetailBody(this.donationId);
  @override
  _DonationDetailBodyState createState() => _DonationDetailBodyState(this.donationId);
}

class _DonationDetailBodyState extends State<DonationDetailBody> {
  final int donationId;
  _DonationDetailBodyState(this.donationId);

  Future<DonationDetailModel> futureDonationDetail;
  @override
  void initState() {
    super.initState();
    futureDonationDetail = _fetchDonationDetailInfo(this.donationId);
  }

  String currentStatus = 'Not Picked';
  void changeStatusFun(int donationId){
    _updateDonationStatus(donationId).then((value) {
      setState(() {
        currentStatus = 'Picked/Recived';
      });
    });
}
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            color: Colors.orange,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Donation Detail',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1
                    ),
                  ),
                  TextButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return AdminHomeScreen();
                    }));
                  },
                      style: TextButton.styleFrom(
                        primary: Colors.white,
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
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20,left: 20,right: 20),
            child: FutureBuilder<DonationDetailModel>(
                future: futureDonationDetail,
                builder: (context,AsyncSnapshot snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.waiting : return CircularProgressIndicator();
                    default:
                      if(snapshot.hasError){
                        return Text("Error While Gettingdetails${snapshot.error}");
                      }else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey))
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('#DONID${donationId}',style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15
                                    )
                                    ),
                                    Text(currentStatus ==null?snapshot.data.donation.donationId.toString():currentStatus,style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.orange
                                    )
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey)),
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: Text('Pickup From',style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                        ),),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(snapshot.data.donation.pickUpAddress1,style: TextStyle(fontSize: 15,letterSpacing: 1,fontWeight: FontWeight.bold)),
                                          Text("${snapshot.data.donation.pickUpAddress2} ${snapshot.data.donation.state} ${snapshot.data.donation.city}",style: TextStyle(fontSize: 15,letterSpacing: 1,fontWeight: FontWeight.bold))
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey))
                              ),
                              child:  Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Text('Medication Info',style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                        )
                                        ),
                                      ),
                                      RichText(text: TextSpan(
                                          style: TextStyle(fontSize: 15,letterSpacing: 1,fontWeight: FontWeight.bold,color: Colors.black),
                                          text: "${snapshot.data.donation.medicationName}",
                                          children: [
                                            TextSpan(text: " x ${snapshot.data.donation.numberOfDoses} Doses",style: TextStyle(color: Colors.orange)),
                                          ]
                                      )),
                                      Padding(
                                        padding: EdgeInsets.only(top: 5),
                                        child: Text('Note : This medication is used for ${snapshot.data.donation.medicationType} patients,',style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        )
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey))
                              ),
                              child:  Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Text('Product Info',style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                        )
                                        ),
                                      ),
                                      RichText(text: TextSpan(
                                          style: TextStyle(fontSize: 15,letterSpacing: 1,fontWeight: FontWeight.bold,color: Colors.black),
                                          text: "Product Id : ",
                                          children: [
                                            TextSpan(text: " #PROID${snapshot.data.product.productId.toString()}",style: TextStyle(color: Colors.orange)),
                                          ]
                                      )),
                                      Padding(
                                        padding: EdgeInsets.only(top: 5),
                                        child: Text('Product Name : ${snapshot.data.product.productName}',style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        )
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey))
                              ),
                              child:  Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Text('Doner Info',style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                        )
                                        ),
                                      ),
                                      RichText(text: TextSpan(
                                          style: TextStyle(fontSize: 15,letterSpacing: 1,fontWeight: FontWeight.bold,color: Colors.black),
                                          text: "Party Id : ",
                                          children: [
                                            TextSpan(text: " #PARTYID${snapshot.data.party.id.toString()}",style: TextStyle(color: Colors.orange)),
                                          ]
                                      )),
                                      Padding(
                                        padding: EdgeInsets.only(top: 5),
                                        child: Text('Party Name : ${snapshot.data.party.firstName} ${snapshot.data.party.lastName}',style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        )
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 5),
                                        child: Text('Party Email : ${snapshot.data.party.email}',style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        )
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: TextButton(onPressed: (){
                                changeStatusFun(snapshot.data.donation.donationId);
                              },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width-80,
                                    decoration: BoxDecoration(
                                        color: Color(0xFFF99300),
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                                    child: Center(
                                      child: Text('Change Status To Recived'.toUpperCase(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            letterSpacing: 1
                                        ),
                                      ),
                                    ),
                                  )
                              ),
                            )
                          ],
                        );
                      }
                  }
                }
            ),
          )
        ],
      )
    );
  }
}


