import 'package:flutter/material.dart';

class CategoryModel {
  final int id;
  final String nama;
  final String? icon; // Icon name from API, might need mapping
  final String? color; // Hex color string

  CategoryModel({
    required this.id,
    required this.nama,
    this.icon,
    this.color,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id_kategori'] is int ? json['id_kategori'] : int.tryParse(json['id_kategori'].toString()) ?? 0,
      nama: json['nama_kategori'] ?? 'Unknown',
      icon: json['icon'], 
      color: json['color'],
    );
  }
}
