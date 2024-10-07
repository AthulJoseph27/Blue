import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

enum RenderEngine {
  aurora,
  comet,
}

enum RenderQuality {
  high,
  medium,
  low
}

const supportedModelExtension = ['obj', 'usdc'];

class Int2 {
  int  x = 0, y = 0;
  Int2({required this.x, required this.y});

  Map<String, dynamic> toJson() => {
    'x' : x,
    'y' : y,
  };
}

class Double3 {
  final double x, y, z;
  const Double3({required this.x, required this.y, required this.z});

  Double3.fromJson(Map<String, dynamic> json)
      : x = (json['x'] ?? 0).toDouble(),
        y = (json['y'] ?? 0).toDouble(),
        z = (json['z'] ?? 0).toDouble();

  Map<String, dynamic> toJson() => {
    'x' : x,
    'y' : y,
    'z' : z,
  };
}

double toRadians(double value) {
  return value * math.pi / 180.0;
}

double toDegrees(double value) {
  return value * 180.0 / math.pi;
}

final GlobalKey<ScaffoldMessengerState> settingsScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final GlobalKey<ScaffoldMessengerState> renderAnimationScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

SnackBar getSnackBar(String message, {bool error = false}) {
  return SnackBar(
    backgroundColor: error ? CupertinoColors.systemRed : const Color(0xff04cfb5),
    content: Text(
      message,
      style: const TextStyle(
        color: CupertinoColors.white,
        fontSize: 16,
      ),
    ),);
}