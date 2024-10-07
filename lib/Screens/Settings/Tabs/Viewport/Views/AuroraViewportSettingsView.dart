import 'package:blue_engine/Screens/Settings/Tabs/Viewport/Controllers/AuroraViewportSettingsController.dart';
import 'package:blue_engine/Screens/Settings/Tabs/Viewport/Models/ViewportModel.dart';
import 'package:blue_engine/Widgets/CustomDropDownMenu.dart';
import 'package:blue_engine/Widgets/SettingsRow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuroraViewportSettingsView extends StatefulWidget {
  const AuroraViewportSettingsView({Key? key}) : super(key: key);

  @override
  State<AuroraViewportSettingsView> createState() =>
      _AuroraViewportSettingsViewState();
}

class _AuroraViewportSettingsViewState
    extends State<AuroraViewportSettingsView> {
  final spacingRatio = 0.7;
  final controller = AuroraViewPortController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SettingsRow(
            spacingRatio: spacingRatio,
            firstChild: Text(
              'Resolution :',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: CustomDropDownMenu(
                list: const ['High', 'Medium', 'Low'],
                onChanged: controller.onResolutionChanged,
              ),
            ),
          ),
          SettingsRow(
            firstChild: Text(
              'Max Bounce :',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: SizedBox(
                width: 80,
                child: StreamBuilder<int>(
                  stream: controller.maxBounceStreamController.stream,
                  builder: (context, snapshot) {
                    return CupertinoTextField(
                      controller: controller.maxBounceController,
                      focusNode: controller.maxBounceFocusNode,
                      onChanged: controller.setMaxBounce,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    );
                  }
                ),
              ),
            ),
            spacingRatio: spacingRatio,
          ),
          SettingsRow(
            firstChild: Text(
              'Dynamic Viewport :',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            secondChild: SizedBox(
              width: 80,
              child: StreamBuilder<bool>(
                  stream: controller.isDynamicViewportStreamController.stream,
                  builder: (context, snapshot) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: SizedBox(
                        height: 32,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: CupertinoSwitch(
                            activeColor: Theme.of(context).primaryColor,
                            value: ViewportModel.auroraViewportModel.isDynamicViewport,
                            onChanged: controller.onViewportTypeChanged,
                          ),
                        ),
                      ),);
                  }
              ),
            ),
            spacingRatio: spacingRatio,
          ),
          SettingsRow(
            firstChild: Text(
              'Alpha Testing :',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            secondChild: SizedBox(
              width: 80,
              child: StreamBuilder<bool>(
                  stream: controller.alphaTestingStreamController.stream,
                  builder: (context, snapshot) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: SizedBox(
                        height: 32,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: CupertinoSwitch(
                              activeColor: Theme.of(context).primaryColor,
                              value: ViewportModel.auroraViewportModel.alphaTesting,
                              onChanged: controller.onAlphaTestingChanged,
                          ),
                        ),
                      ),);
                  }
              ),
            ),
            spacingRatio: spacingRatio,
          ),
          SettingsRow(
            firstChild: Text(
              'Tile Size :',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            secondChild: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<int>(
                    stream: controller.tileXStreamController.stream,
                    builder: (context, snapshot) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: SizedBox(
                          width: 80,
                          child: CupertinoTextField(
                            controller: controller.tileXController,
                            focusNode: controller.tileXFocusNode,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                      );
                    }),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('x'),
                ),
                StreamBuilder<int>(
                    stream: controller.tileYStreamController.stream,
                    builder: (context, snapshot) {
                      return SizedBox(
                        width: 80,
                        child: CupertinoTextField(
                          controller: controller.tileYController,
                          focusNode: controller.tileYFocusNode,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      );
                    }),
              ],
            ),
            spacingRatio: spacingRatio,
          ),
          const SizedBox(
            height: 24,
          ),
          Center(
            child: Text(
              'Keyboard Sensitivity',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          SettingsRow(
            firstChild: Text(
              'Translation :',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: SizedBox(
                  width: 300,
                  child: StreamBuilder<double>(
                    stream: controller.keyboardTranslationSensitivityController.stream,
                    initialData: ViewportModel.auroraViewportModel.controlSensitivity.keyboardSensitivity.translation,
                    builder: (context, snapshot) {
                      var value = snapshot.data ?? 1.0;
                      return CupertinoSlider(
                        value: value,
                        onChanged: controller.onKeyboardTranslationSensitivityChanged,
                        min: 0.001,
                        max: 1000,
                      );
                    }
                  )),
            ),
            spacingRatio: spacingRatio,
          ),
          SettingsRow(
            firstChild: Text(
              'Rotation :',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: SizedBox(
                  width: 300,
                  child: StreamBuilder<double>(
                    stream: controller.keyboardRotationSensitivityController.stream,
                    initialData: ViewportModel.auroraViewportModel.controlSensitivity.keyboardSensitivity.rotation,
                    builder: (context, snapshot) {
                      var value = snapshot.data ?? 1.0;
                      return CupertinoSlider(
                        value: value,
                        onChanged: controller.onKeyboardRotationSensitivityChanged,
                        min: 1,
                        max: 100,
                      );
                    }
                  )),
            ),
            spacingRatio: spacingRatio,
          ),
          const SizedBox(
            height: 24,
          ),
          Center(
            child: Text(
              'Trackpad Sensitivity',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          SettingsRow(
            firstChild: Text(
              'Rotation :',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: SizedBox(
                  width: 300,
                  child: StreamBuilder<double>(
                    stream: controller.trackpadRotationSensitivityController.stream,
                    initialData: ViewportModel.auroraViewportModel.controlSensitivity.trackpadSensitivity.rotation,
                    builder: (context, snapshot) {
                      var value = snapshot.data ?? 1.0;
                      return CupertinoSlider(
                        value: value,
                        onChanged: controller.onTrackpadRotationSensitivityChanged,
                        min: 0.01,
                        max: 10,
                      );
                    }
                  )),
            ),
            spacingRatio: spacingRatio,
          ),
          SettingsRow(
            firstChild: Text(
              'Zoom :',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: SizedBox(
                  width: 300,
                  child: StreamBuilder<double>(
                    stream: controller.trackpadZoomSensitivityController.stream,
                    initialData: ViewportModel.auroraViewportModel.controlSensitivity.trackpadSensitivity.zoom,
                    builder: (context, snapshot) {
                      var value = snapshot.data ?? 1.0;
                      return CupertinoSlider(
                        value: value,
                        onChanged: controller.onTrackpadZoomSensitivityChanged,
                        min: 1,
                        max: 100,
                      );
                    }
                  )),
            ),
            spacingRatio: spacingRatio,
          ),
        ],
      ),
    );
  }
}
