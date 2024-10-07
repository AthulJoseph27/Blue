import 'dart:async';

import 'package:blue_engine/Screens/Settings/Tabs/Viewport/Models/ViewportModel.dart';
import 'package:blue_engine/SwiftCommunicationBridge.dart';
import 'package:blue_engine/globals.dart';


class ViewportSettingsController {
  var streamController = StreamController<RenderEngine>();

  void toggleRenderEngine(RenderEngine engine) {
      ViewportModel.renderEngine = engine;
      streamController.sink.add(engine);
  }

  static onViewportSettingsUpdated() {
    invokePlatformMethod(SwiftMethods.updateViewportSettings, ViewportModel.toJson());
  }
}