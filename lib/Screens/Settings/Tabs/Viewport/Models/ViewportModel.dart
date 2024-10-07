import 'package:blue_engine/globals.dart';

class ViewportModel {
  static var renderEngine = RenderEngine.aurora;
  static var auroraViewportModel = AuroraViewportModel();
  static var cometViewportModel = CometViewportModel();

  static Map<String, dynamic> toJson() => {
    'aurora' : auroraViewportModel.toJson(),
    'comet' : cometViewportModel.toJson(),
  };
}

class AuroraViewportModel {
  var maxBounce = 6;
  var alphaTesting = false;
  var isDynamicViewport = false;
  var resolution = RenderQuality.high;
  var tileSize = Int2(x: 8, y: 8);
  var controlSensitivity = ControlSensitivity();

  Map<String, dynamic> toJson() => {
    'maxBounce' : maxBounce,
    'alphaTesting' : alphaTesting,
    'resolution' : resolution.name,
    'tileSize' : tileSize.toJson(),
    'controlSensitivity' : controlSensitivity.toJson()
  };
}

class CometViewportModel {
  var controlSensitivity = ControlSensitivity();
  Map<String, dynamic> toJson() => {
    'controlSensitivity' : controlSensitivity.toJson()
  };
}

class ControlSensitivity {
  var keyboardSensitivity = KeyboardSensitivity();
  var trackpadSensitivity = TrackpadSensitivity();
  Map<String, dynamic> toJson() => {
    'keyboardSensitivity' : keyboardSensitivity.toJson(),
    'trackpadSensitivity' : trackpadSensitivity.toJson(),
  };
}

class KeyboardSensitivity {
  var translation = 1.0;
  var rotation = 1.0;
  Map<String, dynamic> toJson() => {
    'translation' : translation,
    'rotation' : rotation,
  };
}

class TrackpadSensitivity {
  var zoom = 1.0;
  var rotation = 1.0;
  Map<String, dynamic> toJson() => {
    'zoom' : zoom,
    'rotation' : rotation,
  };
}