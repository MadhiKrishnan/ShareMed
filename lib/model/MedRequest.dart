import 'package:share_the_wealth/model/Product.dart';

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

  MedRequest({this.medicationType,this.medicationName,this.numberOfDoses,this.dropAddress1,this.dropAddress2,this.state,this.city,this.medRequestStatus,this.partyId,this.medRequestId,this.productId});

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
    );
  }

}