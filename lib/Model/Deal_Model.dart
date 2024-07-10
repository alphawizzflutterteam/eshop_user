import 'dart:convert';

import 'package:tlkmartuser/Model/Section_Model.dart';

class DealModel {
  String? id;
  String? title;
  String? image;

  String? masterCategory;

  DealModel({
    this.id,
    this.title,
    this.image,
    this.masterCategory,
  });

  factory DealModel.fromRawJson(String str) =>
      DealModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DealModel.fromJson(Map<String, dynamic> json) => DealModel(
        id: json["id"],
        title: json["title"],
        image: json["image"],
        masterCategory: json["master_category"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "image": image,
        "master_category": masterCategory,
      };
}
