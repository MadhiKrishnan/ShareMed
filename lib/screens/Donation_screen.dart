import 'dart:convert';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:share_the_wealth/constants/api_paths.dart';
import 'package:share_the_wealth/main.dart';
import 'package:share_the_wealth/model/Donation.dart';
import 'package:share_the_wealth/model/MedRequest.dart';
import 'package:share_the_wealth/model/Product.dart';
import 'package:share_the_wealth/widgets/BottomNavigation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';



Future<Product> _fetchProductDetail(int productId) async{
  final response = await http.get(Uri.http(ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port, '/getProduct/'+productId.toString()));
  if(response.statusCode == 200){
    return Product.fromJson(jsonDecode(response.body));
  }else {
    throw Exception('Unexpected error occurred !');
  }
}

Future<List<Medication>> _fetchMedications(String productId) async{
  final response = await http.get(Uri.http(ApiPaths.shareMedBackendEndPoint+":"+ApiPaths.port, '/getMedsByProdId/'+productId.toString()));
  if(response.statusCode == 200){
    List medicationList = json.decode(response.body);
    return medicationList.map((e) => new Medication.fromJson(e)).toList();
  }else {
    throw Exception('Unexpected error occurred!');
  }
}

Future<Donation> _createDonationRequest(String medicationType,String medicationName,int numberOfDoses,String pickUpAddress1,String pickUpAddress2,String state,String city,String donationStatus,int partyId,int productId) async{
  final response =  await http.post(Uri.http(ApiPaths.shareMedBackendEndPoint+':'+ApiPaths.port, '/addDonation'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String ,Object>
    {
      'medicationType': medicationType,
      'medicationName':medicationName,
      'numberOfDoses':numberOfDoses,
      'pickUpAddress1':pickUpAddress1,
      'pickUpAddress2':pickUpAddress2,
      'state':state,
      'city':city,
      'donationStatus':donationStatus,
      'partyId':partyId,
      'productId':productId
    }
    ),
  );

  if(response.statusCode == 200){
    return Donation.fromJson(json.decode(response.body));
  }else {
    throw Exception('Unexpected error occurred!');
  }
  
}

Future<MedRequest> _createMedRequest(String medicationType,String medicationName,int numberOfDoses,String dropAddress1,String dropAddress2,String state,String city,String medReqStatus,int partyId,int productId,File prescription) async{
  final response =  await http.post(Uri.http(ApiPaths.shareMedBackendEndPoint+':'+ApiPaths.port, '/addMedRequest'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String ,Object>
    {
      'medicationType': medicationType,
      'medicationName':medicationName,
      'numberOfDoses':numberOfDoses,
      'dropAddress1':dropAddress1,
      'dropAddress2':dropAddress2,
      'state':state,
      'city':city,
      'requestStatus':medReqStatus,
      'partyId':partyId,
      'productId':productId,
      'prescriptionUrl':' '
    }
    ),
  );

  if(response.statusCode == 200){
    return MedRequest.fromJson(json.decode(response.body));
  }else {
    throw Exception('Unexpected error occurred!');
  }

}

Future<bool> _uploadPrescritpion(String medRequestId,File file) async{
  http.MultipartRequest request = new http.MultipartRequest("POST", Uri.http(ApiPaths.shareMedBackendEndPoint+':'+ApiPaths.port, '/uploadPrescription/'+medRequestId));

  http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
      'file', file.path);

  request.files.add(multipartFile);

  http.StreamedResponse response = await request.send();
  if(response.statusCode == 200){
    return true;
  }else {
    return false;
  }

}

class Medication {
  final int medicationId;
  final String medicationName;
  final String medicationType;
  final String medicationDescription;
  Medication({this.medicationId,this.medicationName,this.medicationType,this.medicationDescription});

  factory Medication.fromJson(Map<String,dynamic> json) {
    return Medication(
        medicationId: json['medicationId'],
        medicationName: json['medicationName'],
        medicationType: json['medicationType'],
        medicationDescription: json['medicationDescription']
    );
  }
}

class DonationScreen extends StatelessWidget {
  int productId;
  String partyType;
  DonationScreen(this.productId,this.partyType);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: DonationScreenBody(productId,this.partyType),
        bottomNavigationBar: BottomNavigation(),
      ),
    );
  }
}

class DonationScreenBody extends StatefulWidget {
  int productId;
  String partyType;
  DonationScreenBody(this.productId,this.partyType);
  @override
  _DonationScreenBodyState createState() => _DonationScreenBodyState(productId,partyType);
}

class _DonationScreenBodyState extends State<DonationScreenBody> {
  int productId;
  String partyType;
  _DonationScreenBodyState(this.productId,this.partyType);

  Future<Product> futureProduct;
  List<String> medList=['oxicodon'];
  String productType;

  bool isLoggedInUser = false;
  int partyId;

  _checkIfUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getBool('isUserLoggedIn')!=null && prefs.getBool('isUserLoggedIn')){
      setState(() {
        this.isLoggedInUser = true;
        this.partyId = prefs.getInt("partyId");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    futureProduct = _fetchProductDetail(productId);
    _checkIfUserLoggedIn();
     _fetchMedications(this.productId.toString()).then((value){
        for(int i =0;i<=value.length;i++){
          medList.add(value[i].medicationName);
        }
    });
  }


  final medicationNameController = TextEditingController();
  final numberOfDosesController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();

  File _image;
  final picker = ImagePicker();

  Future getImageFromGallary() async {
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if(pickedImage != null){
        setState(() {
          _image = File(pickedImage.path);
        });
      }else {
        _image = null;
      }
    });

  }

  String _dropDownValue;
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    medicationNameController.dispose();
    numberOfDosesController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    stateController.dispose();
    cityController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Container(
          child: Column(
            children: [
              Row(
                children: [
                  TextButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return MyApp();
                    }));
                  },
                      style: TextButton.styleFrom(
                        primary: Colors.black,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20,top: 20,right: 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: 150
                      ),
                      child: Text(partyType!=null?'Submit Request':'Hello!Thank you For Helping',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF99300),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 30,vertical: 50),
                  child: Form(
                    child: Column(
                      children: <Widget>[
                        Theme(
                          data: new ThemeData(
                            primaryColor: Color(0xFFF99300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text("Medication Type : ",style: TextStyle(fontSize: 15,color: Colors.grey,fontWeight: FontWeight.bold,letterSpacing: 1))
                                ),
                                FutureBuilder(
                                    future: _fetchProductDetail(productId),
                                    builder: (context,snapshot){
                                      if(snapshot.hasData){

                                          productType = snapshot.data.medicationType.toString();

                                        return
                                          Text(productType,style: TextStyle(fontSize: 15,color: Color(0xFFF99300),fontWeight: FontWeight.bold,letterSpacing: 1)
                                          );
                                      }
                                    })
                              ],
                            ),
                          ),
                        ),
                        Theme(
                            data: ThemeData(
                              primaryColor: Color(0xFFF99300),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              padding: EdgeInsets.only(left: 10),
                              child: DropdownButton(
                                hint:  _dropDownValue == null?Center(child: Text('Select Medication!')):Center(child: Text(_dropDownValue)),
                                isExpanded: true,
                                iconEnabledColor: Color(0xFFF99300),
                                items: medList.map(
                                      (val) {
                                    return DropdownMenuItem<String>(
                                      value: val,
                                      child: Text(val),
                                    );
                                  },
                                ).toList(),
                                onChanged: (val) {
                                  setState(
                                        () {
                                      _dropDownValue = val;
                                    },
                                  );
                                },
                              ),
                            )
                        ),
                        Theme(
                          data: new ThemeData(
                            primaryColor: Color(0xFFF99300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TextField(
                              controller: numberOfDosesController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: new BorderSide(color: Colors.teal)),
                                  hintText: 'Enter Number Of Doses',
                                  labelText: 'Number Of Doses',
                                  prefixIcon: const Icon(
                                    Icons.person,
                                    color: Color(0xFFF99300),
                                  )
                              ),
                            ),
                          ),
                        ),
                        Theme(
                          data: new ThemeData(
                            primaryColor: Color(0xFFF99300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TextField(
                              controller: addressLine1Controller,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: new BorderSide(color: Colors.teal)),
                                  hintText: 'Enter Pickup Address Line1',
                                  labelText: partyType !=null?'Enter Drop Address1':"Pickup Address Line1",
                                  prefixIcon: const Icon(
                                    Icons.person,
                                    color: Color(0xFFF99300),
                                  )
                              ),
                            ),
                          ),
                        ),
                        Theme(
                          data: new ThemeData(
                            primaryColor: Color(0xFFF99300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TextField(
                              controller: addressLine2Controller,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: new BorderSide(color: Colors.teal)),
                                  hintText: 'Enter Pickup Address Line2',
                                  labelText: partyType !=null?'Enter Drop Address2':"Pickup Address Line2",
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Color(0xFFF99300),
                                  )
                              ),
                            ),
                          ),
                        ),
                        Theme(
                          data: new ThemeData(
                            primaryColor: Color(0xFFF99300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TextField(
                              controller: stateController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: new BorderSide(color: Colors.teal)),
                                  hintText: 'Enter State',
                                  labelText: 'State',
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Color(0xFFF99300),
                                  )
                              ),
                            ),
                          ),
                        ),
                        Theme(
                          data: new ThemeData(
                            primaryColor: Color(0xFFF99300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TextField(
                              controller: cityController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: new BorderSide(color: Colors.teal)),
                                  hintText: 'Enter City',
                                  labelText: 'City',
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Color(0xFFF99300),
                                  )
                              ),
                            ),
                          ),
                        ),
                        Builder(builder: (context){
                          if(partyType != null){
                            return
                              Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    width: MediaQuery.of(context).size.width,
                                    child: _image == null ? Center(child: Text('No Prescription Selected')):Image.file(_image),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: DottedBorder(
                                      strokeWidth: .5,
                                      child: TextButton(
                                          onPressed: getImageFromGallary,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Icon(Icons.file_copy_outlined),
                                              Text('Select Prescription from Gallery')
                                            ],
                                          )
                                      ),
                                    ),
                                  ),
                                ],
                              );
                          }else {
                            return Container();
                          }
                        }),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(onPressed: (){
                            showDialog(context: context, builder: (context){
                               if(partyType != null){
                                return  AlertDialog(
                                  content: FutureBuilder<MedRequest> (
                                    future:  _createMedRequest(productType, _dropDownValue, int.parse(numberOfDosesController.text), addressLine1Controller.text, addressLine2Controller.text, stateController.text, cityController.text, 'Yet_To_Deliver', this.partyId,this.productId,_image),
                                    builder: (context,AsyncSnapshot<MedRequest> snapshot){
                                      switch(snapshot.connectionState){
                                        case ConnectionState.waiting: return CircularProgressIndicator();
                                        default :
                                          if(snapshot.hasError){
                                            return Text(snapshot.error);
                                          }else {
                                            String medRequestId = snapshot.data.medRequestId.toString();
                                            var uploaded = false;
                                            _uploadPrescritpion(medRequestId, _image).then((response) {
                                              if(response){
                                                uploaded = true;
                                              }
                                            });

                                            return  Text("Request Has Been Submited Wiht Request id : ${snapshot.data.medRequestId.toString()}");

                                          }
                                      }
                                    },
                                  ),
                                  actions: [TextButton(onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context){
                                      return MyApp();
                                    }));
                                  }, child: Text('Ok'))],
                                );
                              }else {
                                 return  AlertDialog(
                                   content: FutureBuilder<Donation> (
                                     future:  _createDonationRequest(productType, _dropDownValue, int.parse(numberOfDosesController.text), addressLine1Controller.text, addressLine2Controller.text, stateController.text, cityController.text, 'not_recived', this.partyId,this.productId),
                                     builder: (context,AsyncSnapshot<Donation> snapshot){
                                       switch(snapshot.connectionState){
                                         case ConnectionState.waiting: return CircularProgressIndicator();
                                         default :
                                           if(snapshot.hasError){
                                             return Text("Request Submitted Successfully");
                                           }else {
                                             var requestId = snapshot.data.donationId;
                                             return Text("Request Submitted Successfully with request Id ${requestId}");
                                           }
                                       }
                                     },
                                   ),
                                   actions: [TextButton(onPressed: (){
                                     Navigator.push(context, MaterialPageRoute(builder: (context){
                                       return MyApp();
                                     }));
                                   }, child: Text('Ok'))],
                                 );
                               }
                            });
                          },
                              style: ElevatedButton.styleFrom(
                                primary:  Color(0xFFF99300),
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(partyType !=null?'Submit Request'.toUpperCase():"Submit Donation".toUpperCase(),
                                style: TextStyle(
                                    fontSize: 16
                                ),
                              )
                          ),
                        ),

                      ],
                    ),
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}
