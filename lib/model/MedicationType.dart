class MedicationType {
  final int medicationTypeId;
  final String medicationDesc;
  final String medicationType;

  MedicationType({this.medicationTypeId,this.medicationDesc,this.medicationType});

  factory MedicationType.fromJson(Map<String,dynamic> json) {
    return MedicationType(
        medicationTypeId: json['medicationId'],
        medicationDesc: json['medicationDesc'],
        medicationType: json['medicationType']
    );
  }
}