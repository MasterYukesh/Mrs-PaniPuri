// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Product {
  final String name;
  final String? id;
  final double price;
  final int? quantity;

  const Product(
      {this.id,
      this.quantity,
      required this.name,
      required this.price,
      Key? key});

  Product copy({String? name, String? id, double? price, int? quantity}) =>
      Product(
          id: this.id,
          name: name ?? this.name,
          price: price ?? this.price,
          quantity: quantity ?? this.quantity);

  static Product  fromJson(Map<String, dynamic> json) {
    return Product(
        id: json['id'],
        name: json['name'],
        price: double.parse(json['price'].toString()),
        quantity:int.parse(json['quantity'].toString()));
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity
      };
}
