import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';

class Address {
  final String id;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String addressType;
  final bool isDefault;

  const Address({
    this.id = '',
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = 'India',
    this.addressType = 'home',
    this.isDefault = false,
  });

  String get displayShort => '$street, $city, $state - $zipCode';

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      street: (json['street'] ?? json['addressLine1'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      zipCode: (json['zipCode'] ?? json['postalCode'] ?? '').toString(),
      country: (json['country'] ?? 'India').toString(),
      addressType: (json['addressType'] ?? 'home').toString(),
      isDefault: json['isDefault'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phone': phone,
        'street': street,
        'city': city,
        'state': state,
        'zipCode': zipCode,
        'country': country,
        'addressType': addressType,
        'isDefault': isDefault,
      };

  /// Returns shipping address format needed by order API
  Map<String, dynamic> toShippingJson() => {
        'fullName': fullName,
        'phone': phone,
        'addressLine1': street,
        'city': city,
        'state': state,
        'postalCode': zipCode,
        'country': 'IN',
        'addressType': addressType,
      };

  Address copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? addressType,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      addressType: addressType ?? this.addressType,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class AddressProvider extends ChangeNotifier {
  final ApiService _api = ApiService.instance;

  List<Address> _addresses = [];
  bool _loading = false;
  String? _error;

  List<Address> get addresses => List.unmodifiable(_addresses);
  bool get loading => _loading;
  String? get error => _error;
  Address? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  void reset() {
    _addresses = [];
    _loading = false;
    _error = null;
    notifyListeners();
  }

  /// Load all addresses from the backend.
  Future<void> loadAddresses() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/address', auth: true);

      print(res);
      final list = res['addresses'] as List? ??
          res['data'] as List? ??
          (res['address'] is List ? res['address'] as List : <dynamic>[]);

      _addresses =
          list.whereType<Map<String, dynamic>>().map(Address.fromJson).toList();
    } catch (e) {
      _error = 'Failed to load addresses';
    }

    _loading = false;
    notifyListeners();
  }

  /// Create a new address.
  Future<bool> addAddress(Address address) async {
    _error = null;
    try {
      await _api.post('/address', body: address.toJson(), auth: true);
      await loadAddresses();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to save address';
      notifyListeners();
      return false;
    }
  }

  /// Update an existing address.
  Future<bool> updateAddress(String id, Address address) async {
    _error = null;
    try {
      await _api.put('/address/$id', body: address.toJson(), auth: true);
      await loadAddresses();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update address';
      notifyListeners();
      return false;
    }
  }

  /// Delete an address.
  Future<bool> deleteAddress(String id) async {
    _error = null;
    try {
      await _api.delete('/address/$id', auth: true);
      await loadAddresses();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to delete address';
      notifyListeners();
      return false;
    }
  }

  /// Set address as default.
  Future<bool> setDefault(String id) async {
    _error = null;
    try {
      await _api.put('/address/$id/default', auth: true);
      await loadAddresses();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to set default address';
      notifyListeners();
      return false;
    }
  }
}
