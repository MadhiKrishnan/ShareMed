import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:share_the_wealth/constants/api_paths.dart';
import 'package:share_the_wealth/widgets/BottomNavigation.dart';
import 'package:share_the_wealth/widgets/Header.dart';
import 'package:share_the_wealth/widgets/ImageWidget.dart';
import 'package:http/http.dart' as http;

/*Future<List<Product>> _getProductList() async{
  final response =  await http.get(Uri.http(ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port, '/getProductList'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  if(response.statusCode == 200){
    debugPrint('inside 200 if');
    List jsonResponse = jsonDecode(response.body);
    return jsonResponse.map((e) => Product.fromJson(e));
  }else {
    throw Exception('Failed to get products.');
  }
}*/

Future <List<Product>> _getProductList() async {
  final response =
  await http.get(Uri.http(ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port, '/getProductList'));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => new Product.fromJson(data)).toList();
  } else {
    throw Exception('Unexpected error occured!');
  }
}

class Product {
  final int productId;
  final String productName;
  final String imageUrl;
  final String tags;
  final double donationRecived;
  final int  doationCount;
  final String prodDesc;

  Product({this.productId,this.productName,this.imageUrl,this.tags,this.donationRecived,this.doationCount,this.prodDesc});

  factory Product.fromJson(Map<String,dynamic> json) {
   return Product(
     productId: json['productId'],
     productName: json['productName'],
     imageUrl: json['productImageUrl'],
     tags: json['tags'],
     donationRecived: json['donationRecived'],
     doationCount:json['doationCount'],
     prodDesc: json['productDesc']
   );
  }
}


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Future<List<Product>> futureProducts;
  @override
  void initState() {
    super.initState();
    futureProducts = _getProductList();
  }

  List<String> listPaths = [
    "assets/images/Carousel1.jpg",
  ];

  int currentPos = 0;


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: HeaderBar(),
        body: Container(
          color: Color(0x66FFA500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder<List<Product>>(
                  future: futureProducts,
                  builder: (context,snapshot){
                    if(snapshot.hasData){
                      List<Product> products = snapshot.data;
                      return CarouselSlider.builder(itemCount: products.length, options: CarouselOptions(
                          initialPage: 0,
                          autoPlay: false,
                          pauseAutoPlayOnTouch: true,
                          height: 500
                      ),
                        itemBuilder: (context, index, realIndex){
                          return ImageWidget(products[index].productId,products[index].productName,products[index].prodDesc,products[index].imageUrl,products[index].tags,products[index].donationRecived,products[index].doationCount);
                        },
                      );
                    }
                  }
              )
            ],
          ),
        ),

        bottomNavigationBar: BottomNavigation()
    );
  }
}



