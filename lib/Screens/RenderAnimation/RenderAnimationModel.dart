import 'package:blue_engine/globals.dart';

class RenderAnimationModel {
  static var renderEngine = RenderEngine.aurora;
  static var samples = 400;
  static var resolution = Int2(x: 1080, y: 720);
  static var maxBounce = 6;
  static var fps = 24;
  static var alphaTesting = false;
  static var dynamicScene = false;
  static var record = false;
  static var saveLocation = '/Users/Personal/Downloads/Animation/';

  static Future<bool> load() async {
    throw UnimplementedError();
  }

  static Future<bool> save() async {
    throw UnimplementedError();
  }

  static Map<String, dynamic> toJson()=> {
    'renderEngine' : renderEngine.name,
    'alphaTesting' : alphaTesting,
    'dynamicScene' : dynamicScene,
    'samples': samples,
    'resolution' : resolution.toJson(),
    'maxBounce' : maxBounce,
    'fps' : fps,
    'saveLocation' : saveLocation,
  };

}