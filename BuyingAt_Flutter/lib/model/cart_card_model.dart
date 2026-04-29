import 'dart:convert';

class CartCardItem {
  final int? id;
  final int? customerId;
  final int? cardId;
  final CardCartDetails? card;
  final String? itemType;
  final int? quantity;

  CartCardItem({
    this.id,
    this.customerId,
    this.cardId,
    this.card,
    this.itemType,
    this.quantity,
  });

  factory CartCardItem.fromJson(Map<String, dynamic> json) {
    return CartCardItem(
      id: json['id'],
      customerId: json['customer_id'],
      cardId: json['card_id'],
      card: json['card'] is Map<String, dynamic>
          ? CardCartDetails.fromJson(json['card'])
          : null,
      itemType: json['itemType']?.toString(),
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? ''),
    );
  }
}

class CardCartDetails {
  final int? id;
  final String? title;
  final String? price;
  final dynamic images;
  final String? grade;
  final String? condition;
  final String? sportType;

  CardCartDetails({
    this.id,
    this.title,
    this.price,
    this.images,
    this.grade,
    this.condition,
    this.sportType,
  });

  factory CardCartDetails.fromJson(Map<String, dynamic> json) {
    return CardCartDetails(
      id: json['id'],
      title: json['card_title']?.toString(),
      price: json['price']?.toString(),
      images: json['images'],
      grade: json['grade']?.toString(),
      condition: json['condition']?.toString(),
      sportType: json['sport_type']?.toString(),
    );
  }

  String? resolveImageUrl(String baseUrl) {
    final raw = _extractRawImage(images);
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    return '$baseUrl$raw';
  }

  static String? _extractRawImage(dynamic images) {
    if (images == null) return null;
    if (images is String) {
      final trimmed = images.trim();
      if (trimmed.isEmpty) return null;
      if (trimmed.startsWith('[')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is List && decoded.isNotEmpty) {
            return decoded.first.toString();
          }
        } catch (_) {
          // ignore parse error, fall back to original string
        }
      }
      return trimmed;
    }
    if (images is List && images.isNotEmpty) {
      return images.first.toString();
    }
    if (images is Map && images.isNotEmpty) {
      final firstValue = images.values.first;
      if (firstValue != null) {
        return firstValue.toString();
      }
    }
    return images.toString();
  }
}
