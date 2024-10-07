import 'dart:async';
import 'dart:math';

import 'package:blue_engine/Screens/Settings/Tabs/Viewport/Controllers/ViewportSettingsController.dart';
import 'package:blue_engine/Screens/Settings/Tabs/Viewport/Models/ViewportModel.dart';
import 'package:blue_engine/SwiftCommunicationBridge.dart';
import 'package:blue_engine/globals.dart';
import 'package:flutter/material.dart';

class AuroraViewPortController {
  final maxBounceController = TextEditingController(text: ViewportModel.auroraViewportModel.maxBounce.toString());
  final tileXController = TextEditingController(text: ViewportModel.auroraViewportModel.tileSize.x.toString());
  final tileYController = TextEditingController(text: ViewportModel.auroraViewportModel.tileSize.y.toString());
  final tileXStreamController = StreamController<int>();
  final tileYStreamController = StreamController<int>();
  final tileXFocusNode = FocusNode();
  final tileYFocusNode = FocusNode();

  final maxBounceStreamController = StreamController<int>();
  final maxBounceFocusNode = FocusNode();

  final alphaTestingStreamController = StreamController<bool>();
  final isDynamicViewportStreamController = StreamController<bool>();

  final keyboardTranslationSensitivityController = StreamController<double>();
  final keyboardRotationSensitivityController = StreamController<double>();
  final trackpadRotationSensitivityController = StreamController<double>();
  final trackpadZoomSensitivityController = StreamController<double>();

  AuroraViewPortController() {
    tileXFocusNode.addListener(() {
      if(!tileXFocusNode.hasFocus) {
        onTileXEdited();
      }
    });

    tileYFocusNode.addListener(() {
      if(!tileYFocusNode.hasFocus) {
        onTileYEdited();
      }
    });

    maxBounceFocusNode.addListener(() {
      if(!maxBounceFocusNode.hasFocus) {
        maxBounceController.text = ViewportModel.auroraViewportModel.maxBounce.toString();
      }
    });
  }

  void onAlphaTestingChanged(bool value) {
    ViewportModel.auroraViewportModel.alphaTesting = value;
    alphaTestingStreamController.sink.add(value);
    ViewportSettingsController.onViewportSettingsUpdated();
  }

  void onViewportTypeChanged(bool value) {
    ViewportModel.auroraViewportModel.isDynamicViewport = value;
    isDynamicViewportStreamController.sink.add(value);
    if(value) {
      invokePlatformMethod(
          SwiftMethods.switchToDynamicRTViewport, {});
    } else {
      invokePlatformMethod(
          SwiftMethods.switchToStaticRTViewport, {});
    }
  }

  void onResolutionChanged(String? value) {
    if(value == null) {
      return;
    }

    switch(value) {
      case 'High':
        ViewportModel.auroraViewportModel.resolution = RenderQuality.high;
        break;
      case 'Medium':
        ViewportModel.auroraViewportModel.resolution = RenderQuality.medium;
        break;
      case 'Low':
        ViewportModel.auroraViewportModel.resolution = RenderQuality.low;
        break;
    }

    ViewportSettingsController.onViewportSettingsUpdated();
  }

  void setMaxBounce(String? value) {
    if(value == null) {
      return;
    }

    int maxBounce = int.tryParse(value) ?? 6;
    maxBounce = max(maxBounce, 1);
    ViewportModel.auroraViewportModel.maxBounce = maxBounce;
    ViewportSettingsController.onViewportSettingsUpdated();
  }

  void onTileXEdited() {
      var value = tileXController.text;
      if(value.isEmpty) {
        return;
      }

      var x = int.tryParse(value) ?? 8;
      var y = int.tryParse(tileYController.text) ?? 8;

      if(x != 0 && ((x * y) % 32) == 0) {
        ViewportModel.auroraViewportModel.tileSize = Int2(x: x, y: y);
        ViewportSettingsController.onViewportSettingsUpdated();
        return;
      }

      x = max(1, x);

      var p = x * 32;

      y = p ~/ (x * gcd(x, 32));
      tileYController.text = y.toString();
      tileYStreamController.sink.add(y);
      ViewportModel.auroraViewportModel.tileSize = Int2(x: x, y: y);
      ViewportSettingsController.onViewportSettingsUpdated();
  }

  void onTileYEdited() {
    var value = tileYController.text;
    if(value.isEmpty) {
      return;
    }

      var x = int.tryParse(tileXController.text) ?? 8;
      var y = int.tryParse(value) ?? 8;

      if(y != 0 && ((x * y) % 32) == 0) {
        ViewportModel.auroraViewportModel.tileSize = Int2(x: x, y: y);
        ViewportSettingsController.onViewportSettingsUpdated();
        return;
      }

      y = max(1, y);
      var p = y * 32;

      x = p ~/ (y * gcd(y, 32));
      tileXController.text = x.toString();
      tileXStreamController.sink.add(x);
      ViewportModel.auroraViewportModel.tileSize = Int2(x: x, y: y);
      ViewportSettingsController.onViewportSettingsUpdated();
  }

  void onKeyboardTranslationSensitivityChanged(double value) {
    ViewportModel.auroraViewportModel.controlSensitivity.keyboardSensitivity.translation = value;
    keyboardTranslationSensitivityController.sink.add(value);
    ViewportSettingsController.onViewportSettingsUpdated();
  }

  void onKeyboardRotationSensitivityChanged(double value) {
    ViewportModel.auroraViewportModel.controlSensitivity.keyboardSensitivity.rotation = value;
    keyboardRotationSensitivityController.sink.add(value);
    ViewportSettingsController.onViewportSettingsUpdated();
  }

  void onTrackpadRotationSensitivityChanged(double value) {
    ViewportModel.auroraViewportModel.controlSensitivity.trackpadSensitivity.rotation = value;
    trackpadRotationSensitivityController.sink.add(value);
    ViewportSettingsController.onViewportSettingsUpdated();
  }

  void onTrackpadZoomSensitivityChanged(double value) {
    ViewportModel.auroraViewportModel.controlSensitivity.trackpadSensitivity.zoom = value;
    trackpadZoomSensitivityController.sink.add(value);
    ViewportSettingsController.onViewportSettingsUpdated();
  }

  int gcd(int a, int b) {
    if(b == 0){
      return a;
    }

    return gcd(b, a % b);
  }
}