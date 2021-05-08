class Party {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  Party({this.firstName, this.lastName,this.email,this.password,this.id});

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      id: json['id']
    );
  }
}