import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:blue_engine/Screens/Settings/Tabs/Scene/SceneSettingsModel.dart';
import 'package:blue_engine/SwiftCommunicationBridge.dart';
import 'package:blue_engine/globals.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';

class SceneSettingsController {
  final sceneController = StreamController<String>();
  final skyboxController = StreamController<String>();
  final ambientLightController = StreamController<double>();
  final sceneLightingController = StreamController<int>();
  final ambientLightTextController = TextEditingController(text: SceneSettingsModel.ambientBrightness.toString());
  final ambientLightFocusNode = FocusNode();

  SceneSettingsController() {
    ambientLightFocusNode.addListener(() {
      if(!ambientLightFocusNode.hasFocus) {
        String value = ambientLightTextController.text;
        if(value.isEmpty) {
          value = SceneSettingsModel.ambientBrightness.toString();
        }
        onAmbientLightTextEdited(value);
      }
    });
  }

  void onSceneChanged(String scene) {
    if(scene == SceneSettingsModel.scene) {
      return;
    }
    SceneSettingsModel.scene = scene;
    invokePlatformMethod(SwiftMethods.updateSceneSettings, SceneSettingsModel.toJson());
  }

  void onSkyboxChanged(String skybox) {
    if(skybox == SceneSettingsModel.skybox) {
      return;
    }
    SceneSettingsModel.skybox = skybox;
    invokePlatformMethod(SwiftMethods.updateSceneSettings, SceneSettingsModel.toJson());
  }

  void onAmbientLightChanged(double value) {
    SceneSettingsModel.ambientBrightness = value;
    ambientLightTextController.text = value.toString();
    ambientLightController.sink.add(value);
    invokePlatformMethod(SwiftMethods.updateSceneSettings, SceneSettingsModel.toJson());
  }

  void onAmbientLightTextChanged(String? value) {
    if(value == null || value.isEmpty) {
      return;
    }

    double ambient = min(max(double.tryParse(value) ?? 0.0, 0.0), 1.0);

    SceneSettingsModel.ambientBrightness = ambient;
    ambientLightController.sink.add(ambient);
    invokePlatformMethod(SwiftMethods.updateSceneSettings, SceneSettingsModel.toJson());
  }

  void onAmbientLightTextEdited(String? value) {
    if(value == null || value.isEmpty) {
      return;
    }

    double ambient = min(max(double.tryParse(value) ?? 0.0, 0.0), 1.0);

    SceneSettingsModel.ambientBrightness = ambient;
    ambientLightTextController.text = ambient.toString();
    ambientLightController.sink.add(ambient);
    invokePlatformMethod(SwiftMethods.updateSceneSettings, SceneSettingsModel.toJson());
  }

  void import3DModel() async {
    var result = await FilePicker.platform.pickFiles(allowedExtensions: supportedModelExtension);
    if (result != null) {
      File file = File(result.files.single.path ?? "");
      var loaded = await invokePlatformMethod(SwiftMethods.importScene, {'filePath' : file.path});
      if(loaded) {
        addSceneLight(SceneLight());
        SceneSettingsModel.hasImportedScene = true;
        SceneSettingsModel.scene = SceneSettingsModel.scenes.last;
        sceneController.sink.add(SceneSettingsModel.scene);
        settingsScaffoldMessengerKey.currentState?.showSnackBar(getSnackBar('Model imported successfully.'));
      } else {
        settingsScaffoldMessengerKey.currentState?.showSnackBar(getSnackBar('Failed to import model.'));
      }
    }
  }

  void importSkyBox() async {
    var result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path ?? "");
      var loaded = await invokePlatformMethod(SwiftMethods.importSkybox, {'filePath' : file.path});
      if(loaded) {
        SceneSettingsModel.hasImportedSkybox = true;
        SceneSettingsModel.skybox = SceneSettingsModel.skyBoxes.last;
        skyboxController.sink.add(SceneSettingsModel.skybox);
        settingsScaffoldMessengerKey.currentState?.showSnackBar(getSnackBar('Skybox imported successfully.'));
      } else {
        settingsScaffoldMessengerKey.currentState?.showSnackBar(getSnackBar('Failed to import skybox.'));
      }
    }
  }

  void addSceneLight(SceneLight light) {
    SceneSettingsModel.sceneLights.add(light);
    sceneLightingController.sink.add(SceneSettingsModel.sceneLights.length);
    invokePlatformMethod(SwiftMethods.updateSceneSettings, {'sceneLights': SceneSettingsModel.sceneLights.map((e) => e.toJson()).toList()});
  }

  void updateSceneLight(int index, SceneLight light) async {
      SceneSettingsModel.sceneLights[index] = light;
      invokePlatformMethod(SwiftMethods.updateSceneSettings, {'sceneLights': SceneSettingsModel.sceneLights.map((e) => e.toJson()).toList()});
  }
}