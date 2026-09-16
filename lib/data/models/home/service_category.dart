import 'package:flutter/material.dart';

class ServiceCategory {
  final int id;
  final String title;
  final String iconPath;
  final Color mainColor;
  final Color secondaryColor;

  const ServiceCategory({
    required this.id,
    required this.title,
    required this.iconPath,
    required this.mainColor,
    required this.secondaryColor,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      iconPath: (json['icon_path'] ?? json['iconPath']) as String? ?? '',
      mainColor: _hexToColor(json['mainColor'] ?? json['main_color']),
      secondaryColor: _hexToColor(json['secondaryColor'] ?? json['secondary_color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon_path': iconPath,
      'main_color': _colorToHex(mainColor),
      'secondary_color': _colorToHex(secondaryColor),
    };
  }


  static Color _hexToColor(dynamic hexInput) {
    if (hexInput is! String || hexInput.isEmpty) {
      return Colors.transparent;
    }

    String hex = hexInput.replaceAll('#', '').trim();
    if (hex.startsWith('0x') || hex.startsWith('0X')) {
      hex = hex.substring(2);
    }


    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    final intColor = int.tryParse(hex, radix: 16);
    return intColor != null ? Color(intColor) : Colors.transparent;
  }


  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}