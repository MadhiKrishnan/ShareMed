class Login {
  final bool isValidUser;
  Login({this.isValidUser});
  factory Login.fromJson(Map<String,dynamic> json){
    return Login(
        isValidUser : json['isValidUser']
    );
  }
}