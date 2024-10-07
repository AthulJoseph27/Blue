import 'dart:async';
import 'dart:math';

import 'package:blue_engine/Screens/Settings/Tabs/Viewport/Models/ViewportModel.dart';
import 'package:blue_engine/SwiftCommunicationBridge.dart';
import 'package:blue_engine/globals.dart';
import 'package:flutter/cupertino.dart';

import 'RenderAnimationModel.dart';

class RenderAnimationController {
  final maxBounceController = TextEditingController(text: RenderAnimationModel.maxBounce.toString());
  final fpsController = TextEditingController(text: RenderAnimationModel.fps.toString());
  final samplesController = TextEditingController(text: RenderAnimationModel.samples.toString());
  final resolutionXController = TextEditingController(text: RenderAnimationModel.resolution.x.toString());
  final resolutionYController = TextEditingController(text: RenderAnimationModel.resolution.y.toString());
  final saveLocationController = TextEditingController(text: RenderAnimationModel.saveLocation);

  final maxBounceStreamController = StreamController<int>();
  final maxBounceFocusNode = FocusNode();

  final fpsStreamController = StreamController<int>();
  final fpsFocusNode = FocusNode();

  final samplesStreamController = StreamController<int>();
  final samplesFocusNode = FocusNode();

  final alphaTestingStreamController = StreamController<bool>();

  final recordModeStreamController = StreamController<bool>.broadcast();

  RenderAnimationController() {
    resolutionXController.addListener(() {
      RenderAnimationModel.resolution.x = int.tryParse(resolutionXController.text) ?? RenderAnimationModel.resolution.x;
    });

    resolutionYController.addListener(() {
      RenderAnimationModel.resolution.y = int.tryParse(resolutionYController.text) ?? RenderAnimationModel.resolution.y;
    });

    saveLocationController.addListener(() {
      RenderAnimationModel.saveLocation = saveLocationController.text;
    });

    maxBounceFocusNode.addListener(() {
      if(!maxBounceFocusNode.hasFocus) {
        setMaxBounce(maxBounceController.text);
        maxBounceController.text = RenderAnimationModel.maxBounce.toString();
        maxBounceStreamController.sink.add(int.parse(maxBounceController.text));
      }
    });

    fpsFocusNode.addListener(() {
      if(!fpsFocusNode.hasFocus) {
        setFPS(fpsController.text);
        fpsController.text = RenderAnimationModel.fps.toString();
        fpsStreamController.sink.add(int.parse(fpsController.text));
      }
    });

    samplesFocusNode.addListener(() {
      if(!samplesFocusNode.hasFocus) {
        setSamples(samplesController.text);
        samplesController.text = RenderAnimationModel.samples.toString();
        samplesStreamController.sink.add(int.parse(samplesController.text));
      }
    });

  }

  void setSamples(String value) {
    int samples = int.tryParse(value) ?? 400;
    samples = max(samples, 1);
    RenderAnimationModel.samples = samples;
  }

  void setMaxBounce(String value) {
    int maxBounce = int.tryParse(value) ?? 6;
    maxBounce = max(maxBounce, 1);
    RenderAnimationModel.maxBounce = maxBounce;
  }

  void onAlphaTestingChanged(bool value) {
    RenderAnimationModel.alphaTesting = value;
    alphaTestingStreamController.sink.add(value);
  }

  void setFPS(String value) {
    int fps = int.tryParse(value) ?? 24;
    fps = max(1, fps);
    RenderAnimationModel.fps = fps;
  }
  
  void switchCamera(bool value) {
    RenderAnimationModel.record = value;
    recordModeStreamController.sink.add(value);
    invokePlatformMethod(SwiftMethods.switchCamera, {'recordMode' : RenderAnimationModel.record});
  }

  void renderAnimation() async {
    int result = (await invokePlatformMethod(SwiftMethods.queryKeyframeCount, {})) as int;
    if(result <= 0) {
      renderAnimationScaffoldMessengerKey.currentState?.showSnackBar(getSnackBar('0 keyframes record. Try again after recording keyframes.', error: true));
      return;
    }
    RenderAnimationModel.dynamicScene = ViewportModel.auroraViewportModel.isDynamicViewport;
    invokePlatformMethod(SwiftMethods.renderAnimation, RenderAnimationModel.toJson());
  }
}