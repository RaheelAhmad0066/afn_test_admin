import 'package:flutter/material.dart';

class AnalyticInfo {
  final String? svgSrc, title;
  final int? count;
  final Color? color;

  AnalyticInfo({
    this.svgSrc,
    this.title,
    this.count,
    this.color,
  });

  AnalyticInfo copyWith({
    String? svgSrc,
    String? title,
    int? count,
    Color? color,
  }) {
    return AnalyticInfo(
      svgSrc: svgSrc ?? this.svgSrc,
      title: title ?? this.title,
      count: count ?? this.count,
      color: color ?? this.color,
    );
  }
}

