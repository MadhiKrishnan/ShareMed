import 'package:share_the_wealth/model/Product.dart';

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
  final Product productInfo;

  Donation({this.medicationType,this.medicationName,this.numberOfDoses,this.pickUpAddress1,this.pickUpAddress2,this.state,this.city,this.donationStatus,this.partyId,this.donationId,this.productId,this.productInfo});

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
        productId: json['productId'],
        productInfo: Product.fromJson(json['productInfo'])
    );
  }

}