import 'package:flutter/material.dart';

class Animal {
  String? imagePath;
  String? animalName;
  String? kind;
  bool? flyExist = false;

  Animal({
    required this.animalName,
    this.flyExist,
    required this.imagePath,
    required this.kind
});
}