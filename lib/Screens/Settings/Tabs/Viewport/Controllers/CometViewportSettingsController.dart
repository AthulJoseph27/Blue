import 'dart:async';

import 'package:blue_engine/Screens/Settings/Tabs/Viewport/Models/ViewportModel.dart';

import 'ViewportSettingsController.dart';

class CometViewportSettingsController {
  final keyboardTranslationSensitivityController = StreamController<double>();
  final keyboardRotationSensitivityController = StreamController<double>();
  final trackpadRotationSensitivityController = StreamController<double>();
  final trackpadZoomSensitivityController = StreamController<double>();

  void onKeyboardTranslationSensitivityChanged(double value) {
    ViewportModel.cometViewportModel.controlSensitivity.keyboardSensitivity.translation = value;
    keyboardTranslationSensitivityController.sink.add(value);
    ViewportSettingsController.onViewportSettingsUpdated();
  }

  void onKeyboardRotationSensitivityChanged(double value) {
    ViewportModel.cometViewportModel.controlSensitivity.keyboardSensitivity.rotation = value;
    keyboardRotationSensitivityController.sink.add(value);
    ViewportSettingsController.onViewportSettingsUpdated();
  }

  void onTrackpadRotationSensitivityChanged(double value) {
    ViewportModel.cometViewportModel.controlSensitivity.trackpadSensitivity.rotation = value;
    trackpadRotationSensitivityController.sink.add(value);
    ViewportSettingsController.onViewportSettingsUpdated();
  }

  void onTrackpadZoomSensitivityChanged(double value) {
    ViewportModel.cometViewportModel.controlSensitivity.trackpadSensitivity.zoom = value;
    trackpadZoomSensitivityController.sink.add(value);
    ViewportSettingsController.onViewportSettingsUpdated();
  }
}