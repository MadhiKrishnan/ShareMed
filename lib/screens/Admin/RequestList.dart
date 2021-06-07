import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_the_wealth/constants/api_paths.dart';
import 'package:share_the_wealth/screens/Admin/RequestDetail.dart';
import 'package:share_the_wealth/widgets/AdminBottomNav.dart';
import 'package:http/http.dart' as http;



Future<List<MedRequest>> _fetchPendingRequest() async{
  final response = await http.get(Uri.http(ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port, "/getPendingRequest"));
  if(response.statusCode == 200){
    List requestList = json.decode(response.body);
    return requestList.map((e) => new MedRequest.fromJson(e)).toList();
  }else {
    throw Exception('Unexpected error occure');
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

class RequestList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: RequestListBody(),
        bottomNavigationBar: BottomNavigation(),
      ),
    );
  }
}

class RequestListBody extends StatefulWidget {
  const RequestListBody({Key key}) : super(key: key);
  @override
  _RequestListBodyState createState() => _RequestListBodyState();
}

class _RequestListBodyState extends State<RequestListBody> {

  Future<List<MedRequest>> pendingDonation;
  @override
  void initState() {
    super.initState();
    pendingDonation = _fetchPendingRequest();
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
                    Text('Today\'s Request Recived',
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
                child: FutureBuilder<List<MedRequest>>(
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
                                        return RequestDetail(donation.medRequestId);
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
                                          Text("Request Id :  #REQID${donation.medRequestId}"),
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

