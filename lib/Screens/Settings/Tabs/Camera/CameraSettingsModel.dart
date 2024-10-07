import 'package:blue_engine/globals.dart';

class CameraSettingsModel {
  static var position = const Double3(x: 0, y: 1, z: 3.38);
  static var rotation = const Double3(x: 0, y: 0, z: 0);
  static var focalLength = 1.0;
  static var dofBlurStrength = 0.0;

  static void fromJson(Map<String, dynamic> json) {
      position = Double3.fromJson(json['position']);
      rotation = Double3.fromJson(json['rotation']);
      rotation = Double3(x: toDegrees(rotation.x), y: toDegrees(rotation.y), z: toDegrees(rotation.z));
      focalLength = (json['focalLength'] ?? 1).toDouble();
      dofBlurStrength = (json['dofBlurStrength'] ?? 1).toDouble();
  }

  static Map<String, dynamic> toJson() => {
    'dofBlurStrength': dofBlurStrength,
    'focalLength': focalLength,
    'position': position,
    'rotation': Double3(x: toRadians(rotation.x), y: toRadians(rotation.y), z: toRadians(rotation.z)),
  };
}