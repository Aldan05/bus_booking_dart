class UserModel {
  final String uid;
  final String phone;
  final String? fullName;

  UserModel({
    required this.uid,
    required this.phone,
    this.fullName,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phone': phone,
      'fullName': fullName,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phone: map['phone'] ?? '',
      fullName: map['fullName'],
    );
  }
}
