import 'package:flutter/material.dart';

class MessageModel {
  Image? image;
  String? text;
  bool fromUser;
  List<String>? options;

  MessageModel({this.image, this.text, this.fromUser = false, this.options});
}
