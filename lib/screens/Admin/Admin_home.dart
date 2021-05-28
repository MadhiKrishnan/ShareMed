import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_the_wealth/constants/api_paths.dart';
import 'package:share_the_wealth/screens/Admin/Donation_detail.dart';
import 'package:share_the_wealth/widgets/AdminBottomNav.dart';
import 'package:http/http.dart' as http;



Future<List<Donation>> _fetchPendingDonation() async{
  final response = await http.get(Uri.http(ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port, "/getNotRecivedDonation"));
  if(response.statusCode == 200){
    List donationList = json.decode(response.body);
    return donationList.map((e) => new Donation.fromJson(e)).toList();
  }else {
    throw Exception('Unexpected error occure');
  }
}

class Donation {
  final int donationId;
  final String medicationType;
  final String medicationName;
  final int numberOfDoses;
  final String pickUpAddress1;
  final String pickUpAddress2;
  final String state;
  final String city;
  final String donationStatus;
  final int partyId;
  final int productId;

  Donation({this.medicationType,this.medicationName,this.numberOfDoses,this.pickUpAddress1,this.pickUpAddress2,this.state,this.city,this.donationStatus,this.partyId,this.donationId,this.productId});

  factory Donation.fromJson(Map<String,dynamic> json) {
    return Donation(
        medicationType: json['medicationType'],
        medicationName: json['medicationName'],
        numberOfDoses: json['numberOfDoses'],
        pickUpAddress1: json['pickUpAddress1'],
        pickUpAddress2:json['pickUpAddress2'],
        state:json['state'],
        city:json['city'],
        donationStatus:json['donationStatus'],
        partyId:json['partyId'],
        donationId: json['donationId'],
        productId: json['productId']
    );
  }

}

class AdminHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: AdminHomeScreenBody(),
        bottomNavigationBar: BottomNavigation(),
      ),
    );
  }
}

class AdminHomeScreenBody extends StatefulWidget {
  const AdminHomeScreenBody({Key key}) : super(key: key);

  @override
  _AdminHomeScreenBodyState createState() => _AdminHomeScreenBodyState();
}

class _AdminHomeScreenBodyState extends State<AdminHomeScreenBody> {
 Future<List<Donation>> pendingDonation;

  @override
  void initState() {
    super.initState();
    pendingDonation = _fetchPendingDonation();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Today\'s Donation Recived',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1
                      ),
                    )
                  ],
                ),
              ),
              Container(
                child: FutureBuilder<List<Donation>>(
                  future: pendingDonation,
                  builder: (context, AsyncSnapshot snapshot){
                    switch(snapshot.connectionState){
                      case ConnectionState.waiting : return CircularProgressIndicator();
                      default :
                        if(snapshot.hasError){
                          return Text('Error : ${snapshot.error}');
                        }else {
                          return Column(
                            children: [
                              for(var donation in snapshot.data)
                                TextButton(
                                    onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context){
                                    return DonationDetail(donation.donationId);
                                  }));
                                }, child: Container(
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
                                          Text("Donation Id :  #DONID${donation.donationId}"),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text('Medication Name : ${donation.medicationName}',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Icon(Icons.arrow_forward_ios,color: Colors.black,size: 15,),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10),
                                            child: Text('Dose Count ${donation.numberOfDoses}'),
                                          )
                                        ],
                                      )
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  ),
                                )),

                            ],
                          );
                        }
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
