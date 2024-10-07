import 'dart:async';
import 'dart:math';

import 'package:blue_engine/Screens/RenderImage/RenderImageModel.dart';
import 'package:blue_engine/SwiftCommunicationBridge.dart';
import 'package:flutter/cupertino.dart';

class RenderImageController {
  final samplesController = TextEditingController(text: RenderImageModel.samples.toString());
  final maxBounceController = TextEditingController(text: RenderImageModel.maxBounce.toString());
  final resolutionXController = TextEditingController(text: RenderImageModel.resolution.x.toString());
  final resolutionYController = TextEditingController(text: RenderImageModel.resolution.y.toString());
  final saveLocationController = TextEditingController(text: RenderImageModel.saveLocation);

  final maxBounceStreamController = StreamController<int>();
  final maxBounceFocusNode = FocusNode();

  final samplesStreamController = StreamController<int>();
  final samplesFocusNode = FocusNode();

  final alphaTestingStreamController = StreamController<bool>();

  RenderImageController() {
    resolutionXController.addListener(() {
      RenderImageModel.resolution.x = int.tryParse(resolutionXController.text) ?? RenderImageModel.resolution.x;
    });

    resolutionYController.addListener(() {
      RenderImageModel.resolution.y = int.tryParse(resolutionYController.text) ?? RenderImageModel.resolution.y;
    });

    saveLocationController.addListener(() {
      RenderImageModel.saveLocation = saveLocationController.text;
    });

    maxBounceFocusNode.addListener(() {
      if(!maxBounceFocusNode.hasFocus) {
        setMaxBounce(maxBounceController.text);
        maxBounceController.text = RenderImageModel.maxBounce.toString();
        maxBounceStreamController.sink.add(int.parse(maxBounceController.text));
      }
    });

    samplesFocusNode.addListener(() {
      if(!samplesFocusNode.hasFocus) {
        setSamples(samplesController.text);
        samplesController.text = RenderImageModel.samples.toString();
        samplesStreamController.sink.add(int.parse(samplesController.text));
      }
    });

  }

  void setSamples(String value) {
    int samples = int.tryParse(value) ?? 400;
    samples = max(samples, 1);
    RenderImageModel.samples = samples;
  }

  void setMaxBounce(String value) {
    int maxBounce = int.tryParse(value) ?? 6;
    maxBounce = max(maxBounce, 1);
    RenderImageModel.maxBounce = maxBounce;
  }

  void onAlphaTestingChanged(bool value) {
    RenderImageModel.alphaTesting = value;
    alphaTestingStreamController.sink.add(value);
  }

  void renderImage() {
    invokePlatformMethod(SwiftMethods.renderImage, RenderImageModel.toJson());
  }
}