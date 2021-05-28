import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:share_the_wealth/constants/api_paths.dart';
import 'package:share_the_wealth/model/Product.dart';
import 'package:share_the_wealth/widgets/BottomNavigation.dart';
import 'package:share_the_wealth/widgets/Header.dart';
import 'package:share_the_wealth/widgets/ImageWidget.dart';
import 'package:http/http.dart' as http;


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
                    }else {
                      return Text('No Data Found');
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



