class Address {
  final String address1;
  final String address2;
  final String city;
  final String postcode;
  final String state;

  Address({
    required this.address1,
    required this.address2,
    required this.city,
    required this.postcode,
    required this.state,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      address1: map['address1'] ?? '',
      address2: map['address2'] ?? '',
      city: map['city'] ?? '',
      postcode: map['postcode'] ?? '',
      state: map['state'] ?? '',
    );
  }

  String get fullAddress => '$address1, $address2, $city, $postcode $state';

  @override
  String toString() {
    return 'Address('
        'address1: $address1, '
        'address2: $address2, '
        'city: $city, '
        'postcode: $postcode, '
        'state: $state'
        ')';
  }
}
