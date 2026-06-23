import '../services/api_service.dart';

class ImageUrlHelper {
  ImageUrlHelper._();

  static String fromDynamic(dynamic value) {
    if (value == null) return '';

    if (value is String) {
      return ApiService.resolveImageUrl(value);
    }

    if (value is Map) {
      final possible = value['secure_url'] ??
          value['secureUrl'] ??
          value['imageUrl'] ??
          value['url'] ??
          value['path'] ??
          value['image'] ??
          value['logo'] ??
          value['thumbnail'];

      return fromDynamic(possible);
    }

    if (value is List && value.isNotEmpty) {
      return fromDynamic(value.first);
    }

    return ApiService.resolveImageUrl(value.toString());
  }

  static List<String> listFromDynamic(dynamic value) {
    if (value is! List) return const [];

    return value
        .map(fromDynamic)
        .where((url) => url.trim().isNotEmpty)
        .toList();
  }
}
