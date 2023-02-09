//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrs_panipuri/model/product.dart';

class Bill {
  final String? id;
  final List<Product> products;
  final String dateTime;
  final double cost;
  final String paymentMode;
  const Bill(
      {this.id,
      required this.products,
      required this.dateTime,
      required this.cost,
      required this.paymentMode});

  Bill copy(
          {String? id,
          List<Product>? products,
          String? dateTime,
          double? cost,
          String? paymentMode}) =>
      Bill(
          id: id ?? this.id,
          products: products ?? this.products,
          dateTime: dateTime ?? this.dateTime,
          cost: cost ?? this.cost,
          paymentMode: paymentMode ?? this.paymentMode);

  static Bill fromJson(Map<String, dynamic> json) => Bill(
      id: json['id'],
      cost: double.parse(json['cost'].toString()),
      dateTime: json['Date'].toString(),
      products:
          (json['products'] as List).map((e) => Product.fromJson(e)).toList(),
      paymentMode: json['paymentMode'].toString());
}
