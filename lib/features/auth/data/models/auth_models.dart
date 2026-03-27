class LoginResponse {
  final String accessToken;
  final String message;
  final String status;
  final UserModel user;

  LoginResponse({
    required this.accessToken,
    required this.message,
    required this.status,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}

class UserModel {
  final String? documentNumber;
  final int? entityId;
  final String? firstName;
  final String? msisdn;
  final String? otherNames;
  final int? userId;

  UserModel({
    this.documentNumber,
    this.entityId,
    this.firstName,
    this.msisdn,
    this.otherNames,
    this.userId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      documentNumber: json['document_number']?.toString(),
      entityId: json['entity_id'] as int?,
      firstName: json['first_name']?.toString(),
      msisdn: json['msisdn']?.toString(),
      otherNames: json['other_names']?.toString(),
      userId: json['user_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_number': documentNumber,
      'entity_id': entityId,
      'first_name': firstName,
      'msisdn': msisdn,
      'other_names': otherNames,
      'user_id': userId,
    };
  }
}

class RegisterResponse {
  final String message;
  final String status;

  RegisterResponse({required this.message, required this.status});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
