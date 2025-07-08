import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final String street;
  final String city;
  final String province;
  final String postalCode;
  final String country;

  const Address({
    required this.street,
    required this.city,
    required this.province,
    required this.postalCode,
    this.country = 'Canada',
  });

  const Address.empty()
      : street = '',
        city = '',
        province = '',
        postalCode = '',
        country = 'Canada';

  String get fullAddress => '$street, $city, $province $postalCode, $country';

  Address copyWith({
    String? street,
    String? city,
    String? province,
    String? postalCode,
    String? country,
  }) {
    return Address(
      street: street ?? this.street,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
      'province': province,
      'postalCode': postalCode,
      'country': country,
    };
  }

  static Address fromMap(Map<String, dynamic> map) {
    return Address(
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      province: map['province'] ?? '',
      postalCode: map['postalCode'] ?? '',
      country: map['country'] ?? 'Canada',
    );
  }

  @override
  List<Object?> get props => [street, city, province, postalCode, country];
} 