import 'package:blue_engine/Screens/Settings/Tabs/Scene/SceneSettingsController.dart';
import 'package:blue_engine/Widgets/CustomDropDownMenu.dart';
import 'package:blue_engine/Widgets/LightSettingsPopUp.dart';
import 'package:blue_engine/Widgets/LightTile.dart';
import 'package:blue_engine/Widgets/SettingsRow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'SceneSettingsModel.dart';

class SceneSettingsView extends StatefulWidget {
  const SceneSettingsView({Key? key}) : super(key: key);

  @override
  State<SceneSettingsView> createState() => _SceneSettingsViewState();
}

class _SceneSettingsViewState extends State<SceneSettingsView> {
  final spacingRatio = 0.7;
  final controller = SceneSettingsController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CupertinoColors.systemGrey5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        padding: const EdgeInsets.only(top: 30),
        height: size.height - 180,
        width: 800,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SettingsRow(
                spacingRatio: spacingRatio,
                firstChild: Text(
                  'Scene :',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                secondChild: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: StreamBuilder<String>(
                          stream: controller.sceneController.stream,
                          builder: (context, snapshot) {
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: CustomDropDownMenu(
                                key: UniqueKey(),
                                list: SceneSettingsModel.scenes,
                                onChanged: controller.onSceneChanged,
                                initialValue: SceneSettingsModel.scene,
                              ),
                            );
                          }),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    IconButton(
                      onPressed: controller.import3DModel,
                      icon: Icon(CupertinoIcons.upload_circle,
                          color: Theme.of(context).primaryColor),
                      tooltip: "Import new scene",
                    ),
                  ],
                )),
            SettingsRow(
              spacingRatio: spacingRatio,
              firstChild: Text(
                'Skybox :',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              secondChild: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: StreamBuilder<String>(
                        stream: controller.skyboxController.stream,
                        builder: (context, snapshot) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: CustomDropDownMenu(
                              key: UniqueKey(),
                              list: SceneSettingsModel.skyBoxes,
                              onChanged: controller.onSkyboxChanged,
                              initialValue: SceneSettingsModel.skybox,
                            ),
                          );
                        }),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  IconButton(
                    onPressed: controller.importSkyBox,
                    icon: Icon(CupertinoIcons.upload_circle,
                        color: Theme.of(context).primaryColor),
                    tooltip: "Import new skybox",
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Center(
              child: Text(
                'Scene Lighting',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            SettingsRow(
              firstChild: Text(
                'Ambient Lighting :',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              secondChild: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: StreamBuilder<double>(
                    stream: controller.ambientLightController.stream,
                    initialData: SceneSettingsModel.ambientBrightness,
                    builder: (context, snapshot) {
                      var value = snapshot.data ?? 0.0;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16, right: 12),
                            child: SizedBox(
                              width: 240,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 240,
                                    child: CupertinoSlider(
                                      value: value,
                                      onChanged:
                                          controller.onAmbientLightChanged,
                                      min: 0.0,
                                      max: 1.0,
                                      divisions: 20,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '0.0',
                                        style:
                                            Theme.of(context).textTheme.bodySmall,
                                      ),
                                      const Spacer(),
                                      Text(
                                        '1.0',
                                        style:
                                            Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 48,
                            height: 32,
                            child: CupertinoTextField(
                              controller: controller.ambientLightTextController,
                              focusNode: controller.ambientLightFocusNode,
                              onChanged: controller.onAmbientLightTextChanged,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp("[0-9.]"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
              ),
              spacingRatio: spacingRatio,
            ),
            const SizedBox(
              height: 24,
            ),
            StreamBuilder<int>(
              stream: controller.sceneLightingController.stream,
              builder: (context, snapshot) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: SceneSettingsModel.hasImportedScene
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SettingsRow(
                              firstChild: Text(
                                'Scene Lights :',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              secondChild: Padding(
                                padding: const EdgeInsets.only(left: 24),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CupertinoButton(
                                    color: CupertinoColors.activeBlue,
                                    padding: const EdgeInsets.all(2.0),
                                    onPressed: () async {
                                      var sceneLight = SceneLight();
                                      var light = await editLightSettings(
                                          context, sceneLight,
                                          heading: 'Add Light');
                                      if (light != null) {
                                        controller.addSceneLight(light);
                                      }
                                    },
                                    child: const Icon(
                                      CupertinoIcons.add,
                                      color: CupertinoColors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                              spacingRatio: spacingRatio,
                            ),
                            SettingsRow(
                              firstChild: const SizedBox(),
                              secondChild: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: CupertinoColors.systemGrey5)),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 0),
                                padding:
                                    const EdgeInsets.only(top: 12, bottom: 12),
                                constraints: BoxConstraints(
                                  maxWidth: 300,
                                  maxHeight: size.height - 572,
                                  minWidth: 300,
                                  minHeight: 60,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    SceneSettingsModel.sceneLights.length,
                                    (index) => LightTile(
                                      light:
                                          SceneSettingsModel.sceneLights[index],
                                      onTap: () async {
                                        var light = await editLightSettings(
                                            context,
                                            SceneSettingsModel
                                                .sceneLights[index]);
                                        if (light != null) {
                                          controller.updateSceneLight(
                                              index, light);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              spacingRatio: spacingRatio,
                            ),
                          ],
                        )
                      : const SizedBox(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
