class PersonalInfo {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String? profilePhotoPath;

  PersonalInfo({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    this.profilePhotoPath,
  });
} 