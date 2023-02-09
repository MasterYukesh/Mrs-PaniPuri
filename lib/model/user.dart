import 'package:flutter/material.dart';

class User {
  final bool isAdmin;
  final String username;
  final String password;
  const User(
      {Key? key,
      required this.isAdmin,
      required this.username,
      required this.password});

  static User fromJson(Map<String, dynamic> json) => User(
      username: json['username'],
      password: json['password'],
      isAdmin: json['isadmin']);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'username': username,
        'password': password,
        'isadmin': isAdmin
      };
}
