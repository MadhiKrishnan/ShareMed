import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:share_the_wealth/constants/api_paths.dart';
import 'package:share_the_wealth/main.dart';
import 'package:share_the_wealth/model/Product.dart';
import 'package:http/http.dart' as http;
import 'package:share_the_wealth/screens/Donation_screen.dart';
import 'package:share_the_wealth/screens/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Product> _fetchProductDetail(int productId) async{
  final response = await http.get(Uri.http(ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port, '/getProduct/'+productId.toString()));
  if(response.statusCode == 200){
    return Product.fromJson(jsonDecode(response.body));
  }else {
    throw Exception('Unexpected error occured!');
  }
}

class ProductDetail extends StatelessWidget {
  int productId;
  String partyType;

  ProductDetail(this.productId,this.partyType);

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: ProductDetailBody(productId),
        bottomNavigationBar: Container(
          height: 80,
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey))
          ),
          child: SafeArea(
            child: InkWell(
              onTap: () => print('tap on close'),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return MyApp();
                  }));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xFFF99300),
                      ),
                      width: MediaQuery.of(context).size.width-50,
                      child: TextButton(
                        onPressed: () async{
                          final pref = await SharedPreferences.getInstance();
                          if(pref.getBool("isUserLoggedIn") != null && pref.getBool("isUserLoggedIn")){
                            debugPrint(pref.getInt("partyId").toString());
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return DonationScreen(this.productId,this.partyType);
                            }));
                          }else {
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return LoginScreen();
                            }));
                          }
                        },
                          child: Text(
                            partyType!=null?'Accept Medication':'Donate Now',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          )
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductDetailBody extends StatefulWidget {
  int productId;
  ProductDetailBody(this.productId);
  @override
  _ProductDetailBodyState createState() => _ProductDetailBodyState(productId);
}

class _ProductDetailBodyState extends State<ProductDetailBody> {
  int productId;
  _ProductDetailBodyState(this.productId);
  Future<Product> futureProduct;

  String partyType;

  _getSharedPrefInfo() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String partyType = prefs.getString('partyType');
    if(partyType == 'accepter'){
      setState(() {
        this.partyType = partyType;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    futureProduct = _fetchProductDetail(productId);
    _getSharedPrefInfo();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Container(
          child: FutureBuilder<Product>(
            future: futureProduct,
            builder: (context,snapshot){
              // ignore: missing_return
              final split = snapshot.data.tags.split(",");
              if(snapshot.hasData){
                return Column(
                  children: [
                    Stack(
                      children: [
                        Image.network("http://"+ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port+snapshot.data.imageUrl),
                        Positioned(
                            bottom: 20,
                            left: 10,
                            child: Text(partyType != null?snapshot.data.productName.replaceAll('Donate', 'Recive'):snapshot.data.productName,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.bold
                              ),
                            )
                        ),
                        Positioned(
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context){
                                return MyApp();
                              }));
                            },
                            child: Row(
                              children: [
                                Icon(Icons.arrow_back,color: Colors.white,),
                                Container(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Text("Back",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.bold
                                    ),),
                                )
                              ],
                            ),
                          ),
                          left: 20,
                          top: 10,
                        )
                      ],
                    ),
                    Container(
                      height: 50.0,
                      padding: EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for(var i in split)
                            Container(
                              decoration: BoxDecoration(
                                  color: Color(0x66FFA500),
                                  borderRadius: BorderRadius.circular(50)
                              ),
                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 12),
                              margin: EdgeInsets.only(right: 10),
                              child: Text(i.toString(),
                                  style: TextStyle(
                                    color: Color(0xFFF99300),
                                  )
                              ),
                            )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 15,top: 20),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                               padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                              child: Text(snapshot.data.donationRecived.toString()+'% Medicines Donated',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                          LinearPercentIndicator(
                            width: MediaQuery.of(context).size.width - 50,
                            animation: true,
                            lineHeight: 7.0,
                            animationDuration: 2000,
                            percent: snapshot.data.donationRecived/100,
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            progressColor:Color(0xFFF99300),

                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                              child: Text(snapshot.data.doationCount.toString()+' supporters',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 30,horizontal: 25),
                      child: Column(
                        children: [
                          Container(
                              child: Row(
                                children: [
                                  Text('Overview',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700
                                    ),
                                  ),
                                ],
                              )
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Text(snapshot.data.prodDesc,
                                    style: TextStyle(
                                        fontSize: 16
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Text(snapshot.data.prodDesc2,
                                    style: TextStyle(
                                        fontSize: 16
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Text(snapshot.data.prodDesc3,
                                    style: TextStyle(
                                        fontSize: 16
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                );
              }else {
                return Text('No Data Found');
              }

            },
          ),
        ),
      ),
    );
  }
}

