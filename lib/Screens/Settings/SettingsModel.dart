import 'package:blue_engine/Screens/Settings/Tabs/Scene/SceneSettingsModel.dart';

import 'Tabs/Viewport/Models/ViewportModel.dart';

class SettingsModel {
  static var viewportSettings = ViewportModel();
  static var sceneSettings = SceneSettingsModel();

  Future<bool> load() async {
    throw UnimplementedError();
  }

  Future<bool> save() async {
    throw UnimplementedError();
  }
}