import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:share_the_wealth/constants/api_paths.dart';
import 'package:share_the_wealth/main.dart';
import 'package:share_the_wealth/screens/Prooduct_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageWidget extends StatefulWidget {
  int productId;
  String productName;
  String decription;
  String imgPath;
  String tags;
  double donationRecived;
  int doationCount;

  ImageWidget(this.productId,this.productName,this.decription,this.imgPath,this.tags,this.donationRecived,this.doationCount);

  @override
  _ImageWidgetState createState() => _ImageWidgetState(productId, productName, decription, imgPath, tags, donationRecived, doationCount);
}

class _ImageWidgetState extends State<ImageWidget> {
  int productId;
  String productName;
  String decription;
  String imgPath;
  String tags;
  double donationRecived;
  int doationCount;

  _ImageWidgetState(this.productId,this.productName,this.decription,this.imgPath,this.tags,this.donationRecived,this.doationCount);

  String partyType;

  _getSharedPrefInfo() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String partyType = prefs.getString('partyType');
    if(partyType == 'accepter'){
      setState(() {
        this.partyType = partyType;
        productName = productName.replaceAll("Donate", 'Recive');
      });
    }
  }

  @override
  void initState() {
    super.initState();
      _getSharedPrefInfo();
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return MyApp();
        }));
      },
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white
          ),
          margin: EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              Container(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Image.network("http://"+ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port+imgPath),
                          Positioned(
                              bottom: 20,
                              left: 10,
                              child: Text(productName,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                ),
                              )
                          ),
                          Positioned(
                            child: Icon(Icons.share,color: Colors.white,),
                            right: 20,
                            top: 10,
                          )
                        ],
                      )
                  )
              ),
              Container(
                height: 225,
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Wrap(
                        children: <Widget>[
                          Builder(
                              builder: (context) {
                                final split = tags.split(",");

                                return
                                  Row(
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
                                  );
                              }
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 15),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(donationRecived.toString()+'% Medicines Donated',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                          LinearPercentIndicator(
                            width: MediaQuery.of(context).size.width - 150,
                            animation: true,
                            lineHeight: 7.0,
                            animationDuration: 2000,
                            percent: donationRecived/100,
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            progressColor:Color(0xFFF99300),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Text(doationCount.toString()+' supporters',
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
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return ProductDetail(productId,partyType);
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
                            width: 250,
                            child: TextButton(
                                child: Text(
                                  partyType !=null?'Recive':'Donate',
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                )
                            ),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              )
            ],
          )
      ),
    );
  }

}
