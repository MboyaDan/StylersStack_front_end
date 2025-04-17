class UserModel{
  final String uid;
  final String email;

  UserModel({required this.email, required this.uid});

  factory UserModel.fromFirebase(Map<String, dynamic> data) {
    return UserModel(uid: data['uid'], email: data['email']);
  }
}