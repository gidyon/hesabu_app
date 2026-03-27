class SettingsUserModel {
  final String? documentNumber;
  final int? entityId;
  final String? firstName;
  final String? msisdn;
  final String? otherNames;
  final int? userId;
  final String? avatarUrl;

  SettingsUserModel({
    this.documentNumber,
    this.entityId,
    this.firstName,
    this.msisdn,
    this.otherNames,
    this.userId,
    this.avatarUrl,
  });

  factory SettingsUserModel.fromJson(Map<String, dynamic> json) {
    return SettingsUserModel(
      documentNumber: json['document_number']?.toString(),
      entityId: json['entity_id'] as int?,
      firstName: json['first_name']?.toString(),
      msisdn: json['msisdn']?.toString(),
      otherNames: json['other_names']?.toString(),
      userId: json['user_id'] as int?,
      avatarUrl: json['avatar_url']?.toString(),
    );
  }
}
