class Login {
  final bool isValidUser;
  final int partyId;
  final String partyType;
  Login({this.isValidUser,this.partyId,this.partyType});
  factory Login.fromJson(Map<String,dynamic> json){
    return Login(
        isValidUser : json['isValidUser'],
        partyId:json['partyId'],
        partyType: json['partyType']
    );
  }
}