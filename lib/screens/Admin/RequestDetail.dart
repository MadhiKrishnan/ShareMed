import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_the_wealth/constants/api_paths.dart';
import 'package:share_the_wealth/model/Party.dart';
import 'package:share_the_wealth/model/Product.dart';
import 'package:share_the_wealth/screens/Admin/RequestList.dart';
import 'package:share_the_wealth/widgets/AdminBottomNav.dart';
import 'package:http/http.dart' as http;



Future<RequestDetailModel> _fetchReqDetailInfo(int reqId) async {
  final response = await http.get(Uri.http(ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port, "/getMedReqInfo/"+reqId.toString()));
  if(response.statusCode == 200){
    return RequestDetailModel.fromJson(json.decode(response.body));
  }else {
    throw Exception('Unexpected error occured!');
  }
}

Future<void> _updateRequestStatus(int medRequestId) async{
  await http.post(Uri.http(ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port, "/updateMedRequet/${medRequestId}"));
}


class RequestDetailModel {
  final MedRequest medRequest;
  final Product product;
  final Party party;

  RequestDetailModel({this.medRequest,this.party,this.product});

  factory RequestDetailModel.fromJson(Map<String,dynamic> json){
    return RequestDetailModel(
        medRequest: MedRequest.fromJson(json['medRequest']),
        product: Product.fromJson(json['product']),
        party: Party.fromJson(json['party'])
    );
  }

}


class RequestDetail extends StatelessWidget {
  final int requestId;
  RequestDetail(this.requestId);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: RequestDetailBody(this.requestId),
        bottomNavigationBar: BottomNavigation(),
      ),
    );
  }
}

class RequestDetailBody extends StatefulWidget {
  final int requestId;
  RequestDetailBody(this.requestId);

  @override
  _RequestDetailBodyState createState() => _RequestDetailBodyState(requestId);
}

class _RequestDetailBodyState extends State<RequestDetailBody> {

  final int requestId;
  _RequestDetailBodyState(this.requestId);

  Future<RequestDetailModel> futureReqDetail;
  @override
  void initState() {
    super.initState();
    futureReqDetail = _fetchReqDetailInfo(this.requestId);
  }

  String currentStatus = 'Yet To Deliver';
  void changeStatusFun(int donationId){
    _updateRequestStatus(this.requestId).then((value) {
      setState(() {
        currentStatus = 'delivered';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            Container(
              color: Colors.orange,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Request Detail',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1
                      ),
                    ),
                    TextButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return RequestList();
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
              child: FutureBuilder<RequestDetailModel>(
                future: futureReqDetail,
                builder: (context,AsyncSnapshot snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.waiting : return CircularProgressIndicator();
                    default:
                      if(snapshot.hasError){
                        return Text("Error While Gettingdetails${snapshot.error}");
                      }else {
                        return Column(
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
                                    Text('#REQID${snapshot.data.medRequest.medRequestId}',style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15
                                    )
                                    ),
                                    Text(currentStatus,style: TextStyle(
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
                                          Text('${snapshot.data.medRequest.dropAddress1}',style: TextStyle(fontSize: 15,letterSpacing: 1,fontWeight: FontWeight.bold)),
                                          Text("${snapshot.data.medRequest.dropAddress2}",style: TextStyle(fontSize: 15,letterSpacing: 1,fontWeight: FontWeight.bold))
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
                                          text: "${snapshot.data.medRequest.medicationName}",
                                          children: [
                                            TextSpan(text: " x ${snapshot.data.medRequest.numberOfDoses} Doses",style: TextStyle(color: Colors.orange)),
                                          ]
                                      )),
                                      Padding(
                                        padding: EdgeInsets.only(top: 5),
                                        child: Text('Note : This medication is used for ${snapshot.data.medRequest.medicationType} patients,',style: TextStyle(
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
                                            TextSpan(text: " #PROID${snapshot.data.product.productId}",style: TextStyle(color: Colors.orange)),
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
                                            TextSpan(text: " #PARTYID${snapshot.data.party.id}",style: TextStyle(color: Colors.orange)),
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
                                        child: Text('Requester Prescription',style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                        )
                                        ),
                                      ),
                                      Container(
                                          width: MediaQuery.of(context).size.width-50,
                                          child: Image.network('http://${ApiPaths.shareMedBackendEndPoint}:${ApiPaths.port}/${snapshot.data.medRequest.presUrl}')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: TextButton(onPressed: (){
                               changeStatusFun(this.requestId);
                              },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width-80,
                                    decoration: BoxDecoration(
                                        color: Color(0xFFF99300),
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                                    child: Center(
                                      child: Text('Change Status To Delivered'.toUpperCase(),
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
                },
              ),
            )



          ],
        ),
      ),
    );
  }
}
