class Hospital {
  final int? hospitalID;
  final String? hospitalName;
  final double? hospitalLang;
  final double? hospitalLong;
  final dynamic hospitalPict;
  final String? hospitalAddress;
  final int? totalAppointments;
  final int? totalReviews;
  final double? ratings;
  final int? assign;
  final int? doctorID;
  final dynamic doctorPict;
  final String? doctorName;

  Hospital({
    this.hospitalID,
    this.hospitalName,
    this.hospitalLang,
    this.hospitalLong,
    this.hospitalPict,
    this.hospitalAddress,
    this.totalAppointments,
    this.totalReviews,
    this.ratings,
    this.assign,
    this.doctorID,
    this.doctorPict,
    this.doctorName,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      hospitalID: tryParseInt(json['HospitalID']),
      hospitalName: json['HospitalName']?.toString(),
      hospitalLang: tryParseDouble(json['HospitalLang']),
      hospitalLong: tryParseDouble(json['HospitalLong']),
      hospitalPict: json['HospitalPicture'],
      hospitalAddress: json['HospitalAddress']?.toString(),
      totalAppointments: tryParseInt(json['Total_Appointments']),
      totalReviews: tryParseInt(json['Total_Reviews']),
      ratings: tryParseDouble(json['Ratings']),
      assign: tryParseInt(json['AssignID']),
      doctorID: tryParseInt(json['DoctorID']),
      doctorPict: json['DoctorPict'],
      doctorName: json['DoctorName']?.toString(),
    );
  }

  static int? tryParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  static double? tryParseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is num) return value.toDouble();
    return null;
  }
}
