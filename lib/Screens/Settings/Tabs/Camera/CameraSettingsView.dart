import 'package:blue_engine/Screens/Settings/Tabs/Camera/CameraSettingsController.dart';
import 'package:blue_engine/Screens/Settings/Tabs/Camera/CameraSettingsModel.dart';
import 'package:blue_engine/Widgets/SettingsRow.dart';
import 'package:blue_engine/Widgets/XYZInputBoxWidget.dart';
import 'package:blue_engine/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraSettingsView extends StatefulWidget {
  const CameraSettingsView({Key? key}) : super(key: key);

  @override
  State<CameraSettingsView> createState() => _CameraSettingsViewState();
}

class _CameraSettingsViewState extends State<CameraSettingsView> {
  final controller = CameraSettingsController();
  final spacingRatio = 0.57;

  @override
  void initState() {
    controller.updateCameraSettings();
    super.initState();
  }

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
          children: [
            const SizedBox(
              height: 24,
            ),
            SettingsRow(
              spacingRatio: spacingRatio,
              firstChild: Text(
                'Position : ',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              secondChild: StreamBuilder<Double3>(
                  stream: controller.positionController.stream,
                  builder: (context, snapshot) {
                    return getXYZInputBox(
                        context,
                        controller.pX,
                        controller.pY,
                        controller.pZ,
                        controller.pXFocus,
                        controller.pYFocus,
                        controller.pZFocus,
                        controller.onPositionXChanged,
                        controller.onPositionYChanged,
                        controller.onPositionZChanged);
                  }),
            ),

            const SizedBox(
              height: 24,
            ),
            SettingsRow(
              spacingRatio: spacingRatio,
              firstChild: Text(
                'Rotation : ',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              secondChild: StreamBuilder<Double3>(
                  stream: controller.rotationController.stream,
                  builder: (context, snapshot) {
                    return getXYZInputBox(
                        context,
                        controller.rX,
                        controller.rY,
                        controller.rZ,
                        controller.rXFocus,
                        controller.rYFocus,
                        controller.rZFocus,
                        controller.onRotationXChanged,
                        controller.onRotationYChanged,
                        controller.onRotationZChanged);
                  }),
            ),
            const SizedBox(
              height: 24,
            ),
            Center(
              child: Text(
                'Depth of Field',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            SettingsRow(
              firstChild: Text(
                'Focal Length :',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              secondChild: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: SizedBox(
                  width: 80,
                  child: StreamBuilder<double>(
                      stream: controller.focalLengthController.stream,
                      builder: (context, snapshot) {
                        return CupertinoTextField(
                          controller: controller.focalLengthTextController,
                          focusNode: controller.focalLengthFocusNode,
                          onChanged: controller.setFocalLength,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.allow(
                            RegExp(r"^-?(?:\d+\.?\d*|\.\d+)?$|^-$"),
                          )],
                        );
                      }
                  ),
                ),
              ),
              spacingRatio: spacingRatio,
            ),
            const SizedBox(
              height: 24,
            ),
            SettingsRow(
              firstChild: Text(
                'Blur Strength :',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              secondChild: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: StreamBuilder<double>(
                    stream: controller.dofBlurStrengthController.stream,
                    initialData: CameraSettingsModel.dofBlurStrength,
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
                                      controller.onDoFBlurStrengthChanged,
                                      min: 0.0,
                                      max: 10.0,
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
                                        '10.0',
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
                              controller: controller.dofBlurStrengthTextController,
                              focusNode: controller.dofBlurStrengthFocusNode,
                              onChanged: controller.onDoFBlurStrengthTextChanged,
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
          ],
        ),
      ),
    );
  }
}
