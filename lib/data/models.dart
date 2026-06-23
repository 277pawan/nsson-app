import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/utils/image_url_helper.dart';
String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  if (value is String) return value;
  return value.toString();
}
int _asInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}
double _asDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}
List<String> _stringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .where((item) => item != null)
      .map((item) => ApiService.resolveImageUrl(item.toString()))
      .toList();
}
IconData _categoryIconForName(String name) {
  switch (name.trim().toLowerCase()) {
    case 'fiber parts':
      return Icons.layers_rounded;
    case 'body parts':
      return Icons.shield_outlined;
    case 'engine parts':
      return Icons.settings_rounded;
    case 'braking system':
      return Icons.stop_circle_outlined;
    case 'electricals':
      return Icons.electric_bolt_rounded;
    case 'lubricants':
      return Icons.water_drop_outlined;
    case 'tyres & tubes':
      return Icons.trip_origin_rounded;
    default:
      return Icons.category_outlined;
  }
}
class Brand {
  final String id;
  final String name;
  final String logo;
  const Brand({required this.id, required this.name, required this.logo});
  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: _asString(json['_id'] ?? json['id']),
      name: _asString(json['name']),
      logo: ImageUrlHelper.fromDynamic(
        json['logo'] ?? json['logoUrl'] ?? json['image'] ?? json['secure_url'],
      ),
    );
  }
}
class Category {
  final String id;
  final String name;
  final IconData icon;
  const Category({required this.id, required this.name, required this.icon});
  factory Category.fromJson(Map<String, dynamic> json) {
    final name = _asString(json['name']);
    return Category(
      id: _asString(json['_id'] ?? json['id']),
      name: name,
      icon: _categoryIconForName(name),
    );
  }
}
class Product {
  final String id;
  final String name;
  final String partNumber;
  final String brand;
  final String category;
  final int price;
  final int discount;
  final int stock;
  final String image;
  final List<String> images;
  final String description;
  final int warrantyMonths;
  final double finalPrice;
  const Product({
    required this.id,
    required this.name,
    required this.partNumber,
    required this.brand,
    required this.category,
    required this.price,
    this.discount = 0,
    required this.stock,
    required this.image,
    this.images = const [],
    required this.description,
    this.warrantyMonths = 0,
    this.finalPrice = 0,
  });
  factory Product.fromJson(Map<String, dynamic> json) {
    final imagesList = ImageUrlHelper.listFromDynamic(json['images']);
    final primaryImage = ImageUrlHelper.fromDynamic(
      json['image'] ??
          json['imageUrl'] ??
          json['thumbnail'] ??
          json['media'] ??
          (imagesList.isNotEmpty ? imagesList.first : null),
    );
    final price = _asInt(json['price']);
    final discount = _asInt(json['discount']);
    final computedFinalPrice = price - ((price * discount) / 100);
    return Product(
      id: _asString(json['_id'] ?? json['id']),
      name: _asString(json['name']),
      partNumber: _asString(json['partNumber']),
      brand: _asString(json['brand']),
      category: _asString(json['category']),
      price: price,
      discount: discount,
      stock: _asInt(json['stock']),
      image: primaryImage.isNotEmpty
          ? primaryImage
          : (imagesList.isNotEmpty ? imagesList.first : ''),
      images: imagesList,
      description: _asString(json['description']),
      warrantyMonths: _asInt(json['warrantyMonths']),
      finalPrice: _asDouble(
        json['finalPrice'],
        fallback: computedFinalPrice.toDouble(),
      ),
    );
  }
  /// Returns all images (primary + additional)
  List<String> get allImages =>
      image.isNotEmpty ? [image, ...images.where((i) => i != image)] : images;
}
class CartItem {
  final String productId;
  final String name;
  final int price;
  int quantity;
  final String image;
  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
  });
  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? json['productId'];
    // product can be a populated object or just a string ID
    final String prodId;
    final String prodName;
    final String prodImage;
    final int prodPrice;
    if (product is Map<String, dynamic>) {
      prodId = _asString(product['_id'] ?? product['id']);
      prodName = _asString(product['name'] ?? json['name']);
      prodImage = ImageUrlHelper.fromDynamic(
        product['image'] ??
            product['imageUrl'] ??
            product['thumbnail'] ??
            product['images'] ??
            json['image'],
      );
      prodPrice =
          _asInt(product['price'] ?? product['finalPrice'] ?? json['price']);
    } else {
      prodId = _asString(product ?? json['productId']);
      prodName = _asString(json['name']);
      prodImage = ImageUrlHelper.fromDynamic(json['image']);
      prodPrice = _asInt(json['price'] ?? json['finalPrice']);
    }
    return CartItem(
      productId: prodId,
      name: prodName,
      price: prodPrice,
      quantity: _asInt(json['quantity'], fallback: 1),
      image: prodImage,
    );
  }
}
class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final int price;
  final String image;
  const OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.image = '',
  });
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? json['productId'];
    final String prodId;
    final String prodName;
    final String prodImage;
    if (product is Map<String, dynamic>) {
      prodId = _asString(product['_id'] ?? product['id']);
      prodName = _asString(json['name'] ?? product['name']);
      prodImage = ImageUrlHelper.fromDynamic(
        json['image'] ??
            product['image'] ??
            product['imageUrl'] ??
            product['thumbnail'] ??
            product['images'],
      );
    } else {
      prodId = _asString(product ?? json['productId']);
      prodName = _asString(json['name']);
      prodImage = ImageUrlHelper.fromDynamic(json['image']);
    }
    return OrderItem(
      productId: prodId,
      name: prodName,
      quantity: _asInt(json['quantity']),
      price: _asInt(json['price'] ?? json['finalPrice']),
      image: prodImage,
    );
  }
}
class AppOrder {
  final String id;
  final String date;
  final String status;
  final int total;
  final String paymentStatus;
  final String paymentMethod;
  final String shippingAddress;
  final String phone;
  final List<OrderItem> items;
  const AppOrder({
    required this.id,
    required this.date,
    required this.status,
    required this.total,
    this.paymentStatus = 'UNPAID',
    this.paymentMethod = '',
    this.shippingAddress = '',
    this.phone = '',
    required this.items,
  });
  factory AppOrder.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final rawStatus = _asString(json['status'], fallback: 'pending');
    // Build a human-readable address string from the shippingAddress map
    String addrStr = '';
    final addrMap = json['shippingAddress'];
    if (addrMap is Map<String, dynamic>) {
      final parts = [
        addrMap['phone'],
        addrMap['fullName'],
        addrMap['addressLine1'],
        addrMap['addressLine2'],
        addrMap['city'],
        addrMap['state'],
        addrMap['postalCode'],
        addrMap['country'],
      ].whereType<String>().where((s) => s.isNotEmpty).toList();
      addrStr = parts.join(', ');
    } else if (addrMap is String) {
      addrStr = addrMap;
    }
    return AppOrder(
      id: _asString(json['_id'] ?? json['id']),
      date: _asString(json['createdAt'] ?? json['orderDate'] ?? json['date']),
      status: _capitalize(rawStatus),
      total: _asInt(json['totalAmount'] ?? json['total']),
      paymentStatus:
          _asString(json['paymentStatus'], fallback: 'unpaid').toUpperCase(),
      paymentMethod: _asString(json['paymentMethod']),
      shippingAddress: addrStr,
      items: itemsList,
    );
  }
  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
enum NoticeType { approved, info, discount }
class AppNotification {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool read;
  final NoticeType type;
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.read,
    required this.type,
  });
  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      time: time,
      read: read ?? this.read,
      type: type,
    );
  }
  static NoticeType _typeFromCategory(String? category) {
    switch ((category ?? '').toLowerCase()) {
      case 'approved':
        return NoticeType.approved;
      case 'discount':
        return NoticeType.discount;
      default:
        return NoticeType.info;
    }
  }
  static String _relativeTime(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final created = _asString(json['sentAt'] ?? json['createdAt']);
    return AppNotification(
      id: _asString(json['_id'] ?? json['id']),
      title: _asString(json['title']),
      message: _asString(json['body'] ?? json['message']),
      time: _relativeTime(created),
      read: json['isRead'] == true || json['read'] == true,
      type: _typeFromCategory(_asString(json['category'])),
    );
  }
}
class UserInfo {
  final String id;
  final String name;
  final String firstName;
  final String lastName;
  final String shopName;
  final String email;
  final String phone;
  final String address;
  final String role;
  final String status; // 'Approved' or 'Pending'
  const UserInfo({
    this.id = '',
    required this.name,
    this.firstName = '',
    this.lastName = '',
    this.shopName = '',
    required this.email,
    required this.phone,
    required this.address,
    this.role = 'customer',
    required this.status,
  });
  bool get isApproved => status.toLowerCase() == 'approved';
  String get approvalStatus => status.toLowerCase();
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    final first = _asString(json['firstName']);
    final last = _asString(json['lastName']);
    final shopDetails = json['shopDetails'] is Map
        ? json['shopDetails'] as Map
        : <String, dynamic>{};
    final addr = json['address'] ?? shopDetails['businessAddress'];
    String addressStr = '';
    if (addr is Map) {
      final parts = [
        addr['street'],
        addr['city'],
        addr['state'],
        addr['zipCode'],
        addr['country'],
      ].where((e) => e != null && e.toString().isNotEmpty);
      addressStr = parts.join(', ');
    } else if (addr != null) {
      addressStr = addr.toString();
    }
    final rawStatus = _asString(
      json['status'] ?? json['approvalStatus'] ?? json['accountStatus'],
      fallback: 'pending',
    ).toLowerCase();
    final normalizedStatus = rawStatus == 'approved'
        ? 'Approved'
        : rawStatus == 'rejected'
            ? 'Rejected'
            : 'Pending';
    return UserInfo(
      id: _asString(json['_id'] ?? json['id']),
      name: _asString(json['fullName'], fallback: '$first $last'.trim()),
      firstName: first,
      lastName: last,
      shopName: _asString(
        json['shopName'] ?? json['businessName'] ?? shopDetails['shopName'],
      ),
      email: _asString(json['email']),
      phone: _asString(json['phone']),
      address: addressStr,
      role: _asString(json['role'], fallback: 'customer'),
      status: normalizedStatus,
    );
  }
  UserInfo copyWith({
    String? name,
    String? firstName,
    String? lastName,
    String? shopName,
    String? email,
    String? phone,
    String? address,
    String? role,
    String? status,
  }) {
    return UserInfo(
      id: id,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      shopName: shopName ?? this.shopName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': name,
      'firstName': firstName,
      'lastName': lastName,
      'shopName': shopName,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'approvalStatus': approvalStatus,
    };
  }
}
class PromoBanner {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final List<Color> gradient;
  final String? productId;
  const PromoBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.gradient,
    this.productId,
  });
  /// Parse a banner from the Garage backend response.
  factory PromoBanner.fromJson(Map<String, dynamic> json) {
    final String imageUrl = ImageUrlHelper.fromDynamic(
      json['image'] ??
          json['imageUrl'] ??
          json['bannerImage'] ??
          json['secure_url'],
    );
    // Map position to a gradient colour pair
    final position = json['position'] ?? '';
    List<Color> grad;
    switch (position) {
      case 'home_top':
        grad = const [Color(0xFF2563EB), Color(0xFF1D4ED8)];
        break;
      case 'home_mid':
        grad = const [Color(0xFF059669), Color(0xFF047857)];
        break;
      default:
        grad = const [Color(0xFF0F172A), Color(0xFF1E293B)];
    }
    return PromoBanner(
      id: _asString(json['_id'] ?? json['id']),
      title: _asString(json['heading'] ?? json['title']),
      subtitle: _asString(json['subheading'] ?? json['subtitle']),
      image: imageUrl,
      gradient: grad,
      productId: _asString(json['product_id'] ?? json['productId'] ?? json['product']),
    );
  }
}
class AppCoupon {
  final String id;
  final String code;
  final String title;
  final String description;
  final String discountType;
  final double discountValue;
  final double minOrderAmount;
  final double? maxDiscountAmount;
  final String? startDate;
  final String? endDate;
  final int? usageLimit;
  final int usedCount;
  final String couponType;
  final bool isActive;
  // Assigned/Private fields
  final String? assignedAt;
  final bool isUsed;
  final String status; // active | used | expired | upcoming | exhausted | inactive
  final bool usable;
  const AppCoupon({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    this.maxDiscountAmount,
    this.startDate,
    this.endDate,
    this.usageLimit,
    this.usedCount = 0,
    required this.couponType,
    required this.isActive,
    this.assignedAt,
    this.isUsed = false,
    this.status = 'active',
    this.usable = true,
  });
  factory AppCoupon.fromJson(Map<String, dynamic> json) {
    return AppCoupon(
      id: _asString(json['_id'] ?? json['id']),
      code: _asString(json['code']),
      title: _asString(json['title']),
      description: _asString(json['description']),
      discountType: _asString(json['discountType']),
      discountValue: _asDouble(json['discountValue']),
      minOrderAmount: _asDouble(json['minOrderAmount']),
      maxDiscountAmount: json['maxDiscountAmount'] != null ? _asDouble(json['maxDiscountAmount']) : null,
      startDate: json['startDate'] != null ? _asString(json['startDate']) : null,
      endDate: json['endDate'] != null ? _asString(json['endDate']) : null,
      usageLimit: json['usageLimit'] != null ? _asInt(json['usageLimit']) : null,
      usedCount: _asInt(json['usedCount']),
      couponType: _asString(json['couponType'], fallback: 'public'),
      isActive: json['isActive'] ?? true,
      assignedAt: json['assignedAt'] != null ? _asString(json['assignedAt']) : null,
      isUsed: json['isUsed'] ?? false,
      status: _asString(json['status'], fallback: (json['isActive'] ?? true) ? 'active' : 'inactive'),
      usable: json['usable'] ?? (json['isActive'] ?? true),
    );
  }
}
