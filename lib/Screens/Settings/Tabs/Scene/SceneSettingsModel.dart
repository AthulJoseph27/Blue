import 'dart:ui';

import 'package:blue_engine/globals.dart';

class SceneSettingsModel {
  static const List<String> _scenes = [
    'Cornell Box',
    'Harmonic Cubes',
    'Enchanting Glow',
    'Ocean',
    'Custom'
  ];
  static const List<String> _skyBoxes = [
    'Sky',
    'Jungle',
    'NightCity',
    'Beach',
    'Custom'
  ];
  static var hasImportedScene = false;
  static var hasImportedSkybox = false;
  static var scene = scenes[0];
  static var skybox = skyBoxes[0];
  static var ambientBrightness = 0.1;
  static List<SceneLight> sceneLights = [];


  static List<String> get scenes {
    List<String> scenes = List.from(_scenes);
    if (!hasImportedScene) {
      scenes.removeLast();
    }
    return scenes;
  }

  static List<String> get skyBoxes {
    List<String> skyBoxes = List.from(_skyBoxes);
    if (!hasImportedSkybox) {
      skyBoxes.removeLast();
    }
    return skyBoxes;
  }

  static Map<String, dynamic> toJson() => {
        'scene': scene,
        'skybox': skybox,
        'ambient': ambientBrightness,
      };
}

enum LightType { area, spot, sun }

class SceneLight {
  LightType lightType;
  Color color;
  double intensity;
  Double3 position;
  Double3 direction;

  SceneLight(
      {this.lightType = LightType.sun,
      this.color = const Color(0xffffffff),
      this.intensity = 1.0,
      this.position = const Double3(x: 0, y: 0, z: 0),
      this.direction = const Double3(x: 0, y: -1, z: 0)});

  Map<String, dynamic> toJson() => {
    'lightType' : lightType.name,
    'color' : {'r': color.red, 'g' : color.green, 'b' : color.blue},
    'intensity' : intensity,
    'position' : position.toJson(),
    'direction' : direction.toJson(),
  };

}
