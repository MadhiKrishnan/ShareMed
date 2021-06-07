import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_the_wealth/constants/api_paths.dart';
import 'package:share_the_wealth/widgets/AdminBottomNav.dart';
import 'package:http/http.dart' as http;

Future<List<Inventory>> _fetchInventoryInfo() async {
  final response = await http.get(Uri.http(ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port, "/getInventoryInfo"));
  if(response.statusCode == 200){
    List inventoryList = json.decode(response.body);
    return inventoryList.map((e) => Inventory.fromJson(e)).toList();
  }else {
    throw Exception('Unexpected error occure');
  }
}

class Inventory {
  final int id;
  final int readyToPromise;
  final String medicationName;

  Inventory({this.id,this.medicationName,this.readyToPromise});

  factory Inventory.fromJson(Map<String,dynamic> json){
    return Inventory(
      id: json['id'],
      medicationName: json['medicationName'],
      readyToPromise: json['readyToPromise']
    );
  }
}

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: InventoryScreenBody(),
        bottomNavigationBar: BottomNavigation(),
      ),
    );
  }
}

class InventoryScreenBody extends StatefulWidget {
  const InventoryScreenBody({Key key}) : super(key: key);

  @override
  _InventoryScreenBodyState createState() => _InventoryScreenBodyState();
}

class _InventoryScreenBodyState extends State<InventoryScreenBody> {
  Future<List<Inventory>> futureInventoryList;

  @override
  void initState() {
    super.initState();
    setState(() {
      futureInventoryList = _fetchInventoryInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20,horizontal: 5),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Inventory Details',
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
                  decoration: BoxDecoration(
                      border: Border.all()
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Inventory Id",style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.orange
                      )),
                      Text("Ready To Promise",style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.orange
                      )),
                      Text("Medication Name",style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.orange
                      )),

                    ],
                  ),
                ),
                FutureBuilder(
                  future: futureInventoryList,
                  builder: (context, AsyncSnapshot snapshot){
                    switch(snapshot.connectionState){
                      case ConnectionState.waiting : return CircularProgressIndicator();
                      default :
                        if(snapshot.hasError){
                          return Text('Error : ${snapshot.error}');
                        }else {
                          return Column(
                            children: [
                              for(Inventory inventory in snapshot.data)
                                    Container(
                              decoration: BoxDecoration(
                                  border: Border.all()
                              ),
                              margin: EdgeInsets.symmetric(vertical: 10),
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Center(
                                    child: Text("${inventory.id}",style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,

                                    )),
                                  ),
                                  Center(
                                    child: Text("${inventory.readyToPromise}",style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,

                                    )),
                                  ),
                                  Center(
                                    child: Text("${inventory.medicationName}",style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,

                                    )),
                                  ),

                                ],
                              ),
                            ),
                            ],
                          );
                        }
                        break;
                    }
                  },
                )
              ],
            ),
          ),
        )
    );
  }
}


