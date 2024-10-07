import 'package:blue_engine/Screens/Settings/Tabs/Viewport/Controllers/CometViewportSettingsController.dart';
import 'package:blue_engine/Screens/Settings/Tabs/Viewport/Models/ViewportModel.dart';
import 'package:blue_engine/Widgets/SettingsRow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CometViewportSettingsView extends StatefulWidget {
  const CometViewportSettingsView({Key? key}) : super(key: key);

  @override
  State<CometViewportSettingsView> createState() => _CometViewportSettingsViewState();
}

class _CometViewportSettingsViewState extends State<CometViewportSettingsView> {
  final spacingRatio = 0.7;
  final controller = CometViewportSettingsController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                    initialData: ViewportModel.cometViewportModel.controlSensitivity.keyboardSensitivity.translation,
                    builder: (context, snapshot) {
                      var value = snapshot.data ?? 0.0;
                      return CupertinoSlider(
                        value: value,
                        onChanged: controller.onKeyboardTranslationSensitivityChanged,
                        min: 1,
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
                    initialData: ViewportModel.cometViewportModel.controlSensitivity.keyboardSensitivity.rotation,
                    builder: (context, snapshot) {
                      var value = snapshot.data ?? 0.0;
                      return CupertinoSlider(
                        value: value,
                        onChanged: controller.onKeyboardRotationSensitivityChanged,
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
                    initialData: ViewportModel.cometViewportModel.controlSensitivity.trackpadSensitivity.rotation,
                    builder: (context, snapshot) {
                      var value = snapshot.data ?? 0.0;
                      return CupertinoSlider(
                        value: value,
                        onChanged: controller.onTrackpadRotationSensitivityChanged,
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
                    initialData: ViewportModel.cometViewportModel.controlSensitivity.trackpadSensitivity.zoom,
                    builder: (context, snapshot) {
                      var value = snapshot.data ?? 0.0;
                      return CupertinoSlider(
                        value: value,
                        onChanged: controller.onTrackpadZoomSensitivityChanged,
                      );
                    }
                )),
          ),
          spacingRatio: spacingRatio,
        ),
      ],
    );
  }
}
