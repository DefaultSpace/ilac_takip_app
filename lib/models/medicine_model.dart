import 'package:flutter/material.dart';

class Medicine {
  final String id;
  final String name;
  int quantity;
  final DateTime addedDate;
  final String? photoPath;

  Medicine({
    required this.id,
    required this.name,
    required this.quantity,
    required this.addedDate,
    this.photoPath,
  });

  Medicine copyWith({
    String? id,
    String? name,
    int? quantity,
    DateTime? addedDate,
    String? photoPath,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      addedDate: addedDate ?? this.addedDate,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  void decreaseQuantity() {
    if (quantity > 0) {
      quantity--;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'addedDate': addedDate.toIso8601String(),
      'photoPath': photoPath,
    };
  }

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      addedDate: DateTime.parse(json['addedDate']),
      photoPath: json['photoPath'],
    );
  }
}
