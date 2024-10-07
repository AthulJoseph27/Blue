import 'package:blue_engine/globals.dart';

class RenderImageModel {
  static var renderEngine = RenderEngine.aurora;
  static var samples = 400;
  static var resolution = Int2(x: 1080, y: 720);
  static var maxBounce = 6;
  static var saveLocation = '/Users/Personal/Downloads/';
  static var alphaTesting = false;

  static Future<bool> load() async {
    throw UnimplementedError();
  }

  static Future<bool> save() async {
    throw UnimplementedError();
  }

  static Map<String, dynamic> toJson()=> {
    'renderEngine' : renderEngine.name,
    'resolution' : resolution.toJson(),
    'alphaTesting' : alphaTesting,
    'samples': samples,
    'maxBounce' : maxBounce,
    'saveLocation' : saveLocation,
  };

}