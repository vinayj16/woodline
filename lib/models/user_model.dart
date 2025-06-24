class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String role; // 'woodworker' or 'customer'
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      role: data['role'] ?? 'customer',
      createdAt: (data['createdAt'] != null) 
          ? (data['createdAt'] as dynamic).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': createdAt,
    };
  }
}
