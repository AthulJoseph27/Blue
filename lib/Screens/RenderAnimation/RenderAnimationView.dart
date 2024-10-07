import 'package:blue_engine/Widgets/SettingsRow.dart';
import 'package:blue_engine/Widgets/MaterialSegmentedControl.dart';
import 'package:blue_engine/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'RenderAnimationController.dart';
import 'RenderAnimationModel.dart';


class RenderAnimationPage extends StatefulWidget {
  const RenderAnimationPage({Key? key}) : super(key: key);

  @override
  State<RenderAnimationPage> createState() => _RenderAnimationPageState();
}

class _RenderAnimationPageState extends State<RenderAnimationPage> {
  final spacingRatio = 0.8;
  final controller = RenderAnimationController();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: renderAnimationScaffoldMessengerKey,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SettingsRow(
                firstChild: Text(
                  'Record Mode:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                secondChild: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SizedBox(
                    height: 32,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: StreamBuilder<bool>(
                        stream: controller.recordModeStreamController.stream,
                        builder: (context, snapshot) {
                          return CupertinoSwitch(
                              activeColor: Theme.of(context).primaryColor,
                              value: RenderAnimationModel.record,
                              onChanged: controller.switchCamera,);
                        }
                      ),
                    ),
                  ),),
                spacingRatio: spacingRatio,
              ),
              SettingsRow(
                firstChild: Text(
                  'Render Engine :',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                secondChild: MaterialSegmentedControl<RenderEngine>(
                  selectedColor: CupertinoColors.activeBlue,
                  groupValue: RenderAnimationModel.renderEngine,
                  onValueChanged: (RenderEngine value) {
                    setState(() {
                      RenderAnimationModel.renderEngine = value;
                    });
                  },
                  children: const <RenderEngine, Widget>{
                    RenderEngine.aurora: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Aurora',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    RenderEngine.comet: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Comet',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  },
                ),
                spacingRatio: spacingRatio,
              ),
              SettingsRow(
                firstChild: Text(
                  'Resolution :',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                secondChild: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: SizedBox(
                        width: 80,
                        child: CupertinoTextField(
                          controller: controller.resolutionXController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('x'),
                    ),
                    SizedBox(
                      width: 80,
                      child: CupertinoTextField(
                        controller: controller.resolutionYController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                  ],
                ),
                spacingRatio: spacingRatio,
              ),
              SettingsRow(
                firstChild: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    'FPS :',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                secondChild: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: SizedBox(
                    width: 80,
                    child: StreamBuilder<int>(
                        stream: controller.fpsStreamController.stream,
                        builder: (context, snapshot) {
                          return CupertinoTextField(
                            controller: controller.fpsController,
                            focusNode: controller.fpsFocusNode,
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
                firstChild: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    'Samples :',
                    style: (RenderAnimationModel.renderEngine == RenderEngine.aurora) ? Theme.of(context).textTheme.titleMedium
                        :
                    const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.systemGrey3,
                    ) ,
                  ),
                ),
                secondChild: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: SizedBox(
                    width: 80,
                    child: StreamBuilder<int>(
                        stream: controller.samplesStreamController.stream,
                        builder: (context, snapshot) {
                          return CupertinoTextField(
                            enabled: RenderAnimationModel.renderEngine == RenderEngine.aurora,
                            controller: controller.samplesController,
                            focusNode: controller.samplesFocusNode,
                            onChanged: controller.setSamples,
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
                firstChild: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    'Max Bounce :',
                    style: (RenderAnimationModel.renderEngine == RenderEngine.aurora) ? Theme.of(context).textTheme.titleMedium
                        :
                    const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.systemGrey3,
                    ) ,
                  ),
                ),
                secondChild: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: SizedBox(
                    width: 80,
                    child: StreamBuilder<int>(
                        stream: controller.maxBounceStreamController.stream,
                        builder: (context, snapshot) {
                          return CupertinoTextField(
                            enabled: RenderAnimationModel.renderEngine == RenderEngine.aurora,
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
                  'Alpha Testing :',
                  style: (RenderAnimationModel.renderEngine == RenderEngine.aurora) ? Theme.of(context).textTheme.titleMedium
                      :
                  const TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemGrey3,
                  ) ,
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
                                value: RenderAnimationModel.alphaTesting,
                                onChanged: (RenderAnimationModel.renderEngine == RenderEngine.aurora) ? controller.onAlphaTestingChanged : null,
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
                  'Save Location :',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                secondChild: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SizedBox(
                    width: 400,
                    child: CupertinoTextField(
                      controller: controller.saveLocationController,
                    ),
                  ),
                ),
                spacingRatio: spacingRatio,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: StreamBuilder<bool>(
                    stream: controller.recordModeStreamController.stream,
                    builder: (context, snapshot) {
                      return SizedBox(
                        height: 32,
                        width: 100,
                        child: CupertinoButton(
                          color: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          onPressed: RenderAnimationModel.record ? controller.renderAnimation : null,
                          child: const Center(child: Text('Render', style: TextStyle(fontSize: 16),),),),
                      );
                    }
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
