class Hospital {
  final int hospitalID;
  final String hospitalName;
  final double hospitalLang;
  final double hospitalLong;
  final String hospitalAddress;
  final int totalAppointments;
  final int totalReviews;
  final double ratings;
  final dynamic assign;  // Replace with proper type if known
  final dynamic doctor;  // Replace with proper type if known

  Hospital({
    required this.hospitalID,
    required this.hospitalName,
    required this.hospitalLang,
    required this.hospitalLong,
    required this.hospitalAddress,
    required this.totalAppointments,
    required this.totalReviews,
    required this.ratings,
    required this.assign,
    required this.doctor,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      hospitalID: json['HospitalID'] as int,
      hospitalName: json['HospitalName'] as String,
      hospitalLang: json['HospitalLang'] as double,
      hospitalLong: json['HospitalLong'] as double,
      hospitalAddress: json['HospitalAddress'] as String,
      totalAppointments: json['Total_Appointments'] as int,
      totalReviews: json['Total_Reviews'] as int,
      ratings: json['Ratings'] as double,
      assign: json['assign'],
      doctor: json['doctor'],
    );
  }
}