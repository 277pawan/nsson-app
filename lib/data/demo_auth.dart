import 'models.dart';

class DemoCredentialInfo {
  final String label;
  final String description;
  final String identifier;
  final String password;
  final bool isApproved;

  const DemoCredentialInfo({
    required this.label,
    required this.description,
    required this.identifier,
    required this.password,
    required this.isApproved,
  });
}

class _DemoAccountRecord {
  final DemoCredentialInfo credential;
  final List<String> identifiers;
  final UserInfo user;

  const _DemoAccountRecord({
    required this.credential,
    required this.identifiers,
    required this.user,
  });
}

class DemoAuth {
  DemoAuth._();

  static const String defaultPassword = 'Moto@123';

  static const List<_DemoAccountRecord> _accounts = [
    _DemoAccountRecord(
      credential: DemoCredentialInfo(
        label: 'Approved Retailer',
        description:
            'Use this account to enter the app and review the dashboard.',
        identifier: 'approved@motocrafter.demo',
        password: defaultPassword,
        isApproved: true,
      ),
      identifiers: ['approved@motocrafter.demo', '+919876500001'],
      user: UserInfo(
        id: 'demo-approved',
        name: 'Amit Sharma',
        firstName: 'Amit',
        lastName: 'Sharma',
        shopName: 'Sharma Auto Spares',
        email: 'approved@motocrafter.demo',
        phone: '+919876500001',
        address: '14 Auto Market, Karol Bagh, New Delhi - 110005',
        role: 'retailer',
        status: 'Approved',
      ),
    ),
    _DemoAccountRecord(
      credential: DemoCredentialInfo(
        label: 'Pending Retailer',
        description: 'Use this account to open the approval pending page.',
        identifier: 'pending@motocrafter.demo',
        password: defaultPassword,
        isApproved: false,
      ),
      identifiers: ['pending@motocrafter.demo', '+919876500002'],
      user: UserInfo(
        id: 'demo-pending',
        name: 'Rahul Verma',
        firstName: 'Rahul',
        lastName: 'Verma',
        shopName: 'Verma Bike Parts',
        email: 'pending@motocrafter.demo',
        phone: '+919876500002',
        address: '22 Spare Parts Lane, Lajpat Nagar, New Delhi - 110024',
        role: 'retailer',
        status: 'Pending',
      ),
    ),
  ];

  static List<DemoCredentialInfo> get credentials =>
      _accounts.map((account) => account.credential).toList(growable: false);

  static UserInfo? authenticate(String identifier, String password) {
    final normalizedIdentifier = identifier.trim().toLowerCase();
    final trimmedPassword = password.trim();

    for (final account in _accounts) {
      final matchesIdentifier = account.identifiers
          .map((value) => value.trim().toLowerCase())
          .contains(normalizedIdentifier);
      if (matchesIdentifier && trimmedPassword == account.credential.password) {
        return account.user;
      }
    }

    return null;
  }

  static UserInfo createPendingRetailer({
    required String fullName,
    required String shopName,
    required String email,
    required String phone,
    required String address,
  }) {
    final cleanName =
        fullName.trim().isEmpty ? 'New Retailer' : fullName.trim();
    final parts = cleanName.split(RegExp(r'\s+'));
    final cleanShop =
        shopName.trim().isEmpty ? '$cleanName Auto Spares' : shopName.trim();

    return UserInfo(
      id: 'retailer-${DateTime.now().millisecondsSinceEpoch}',
      name: cleanName,
      firstName: parts.first,
      lastName: parts.length > 1 ? parts.sublist(1).join(' ') : 'Retailer',
      shopName: cleanShop,
      email: email.trim().isEmpty
          ? 'pending@motocrafter.demo'
          : email.trim().toLowerCase(),
      phone: phone.trim().isEmpty ? '+919000000000' : phone.trim(),
      address:
          address.trim().isEmpty ? 'Retail Auto Market, India' : address.trim(),
      role: 'retailer',
      status: 'Pending',
    );
  }
}
