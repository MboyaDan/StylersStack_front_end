import 'package:flutter/material.dart';

enum CategoryType { tshirt, pant, dress, jacket }

extension CategoryTypeExtension on CategoryType {
  String get label {
    switch (this) {
      case CategoryType.tshirt:
        return 'T-Shirt';
      case CategoryType.pant:
        return 'Pant';
      case CategoryType.dress:
        return 'Dress';
      case CategoryType.jacket:
        return 'Jacket';
    }
  }

  String get value {
    // Backend string values (normalized slugs)
    return toString().split('.').last;
  }

  IconData get icon {
    switch (this) {
      case CategoryType.tshirt:
        return Icons.emoji_people;
      case CategoryType.pant:
        return Icons.checkroom;
      case CategoryType.dress:
        return Icons.woman;
      case CategoryType.jacket:
        return Icons.man;
    }
  }

  /// Safely parse a string into a CategoryType enum
  static CategoryType? fromString(String value) {
    try {
      return CategoryType.values.firstWhere(
            (e) => e.value == value.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
