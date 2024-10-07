import 'dart:async';
import 'dart:convert';

import 'package:blue_engine/Screens/Settings/Tabs/Scene/SceneSettingsModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const String methodChannelName = "flutter_method_channel";
const String eventChannelName = "flutter_event_channel";

enum SwiftMethods {
  renderImage,
  renderAnimation,
  switchCamera,
  queryKeyframeCount,
  getCameraSettings,
  updateViewportSettings,
  updateSceneSettings,
  updateCameraSettings,
  importScene,
  importSkybox,
  updateSceneLighting,
  switchToStaticRTViewport,
  switchToDynamicRTViewport,
}

enum SwiftEvents {
  setPage,
  updateCurrentScene,
}


const methodChannel = MethodChannel(methodChannelName);
const eventChannel = EventChannel(eventChannelName);
final pageController = StreamController<dynamic>();

Future<dynamic> invokePlatformMethod(SwiftMethods function, Map<String, dynamic> arguments) async {
  try {
    var result = await methodChannel.invokeMethod(function.name, jsonEncode(arguments));
    return result ?? false;
  } on PlatformException catch (e) {
    if (kDebugMode) {
      print("Failed to send message: '${e.message}'.");
    }

    return false;
  }
}

void initializeEventChannel() {
  eventChannel.receiveBroadcastStream().listen(handleEvent);
}

void handleEvent(event) {
  var json = jsonDecode(event);
  final function = json['function'];

  if(function == SwiftEvents.setPage.name) {
    pageController.add(json);
  } else if(function == SwiftEvents.updateCurrentScene) {
    SceneSettingsModel.hasImportedScene = true;
    SceneSettingsModel.scene = json['scene'] ?? SceneSettingsModel.scene;
  }

}