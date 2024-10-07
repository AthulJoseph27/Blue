import 'package:blue_engine/Screens/Settings/Tabs/Viewport/Models/ViewportModel.dart';
import 'package:blue_engine/Screens/Settings/Tabs/Viewport/Controllers/ViewportSettingsController.dart';
import 'package:blue_engine/Widgets/MaterialSegmentedControl.dart';
import 'package:blue_engine/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AuroraViewportSettingsView.dart';
import 'CometViewportSettingsView.dart';


class ViewportSettingsView extends StatefulWidget {
  const ViewportSettingsView({Key? key}) : super(key: key);

  @override
  State<ViewportSettingsView> createState() => _ViewportSettingsViewState();
}

class _ViewportSettingsViewState extends State<ViewportSettingsView> {
  final controller = ViewportSettingsController();
  final auroraViewPort = const AuroraViewportSettingsView();
  final cometViewPort = const CometViewportSettingsView();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return StreamBuilder(
      stream: controller.streamController.stream,
      builder: (context, snapshot) {
        final engine = snapshot.data ?? RenderEngine.aurora;
        final crossFadeState = engine == RenderEngine.aurora ? CrossFadeState.showFirst : CrossFadeState.showSecond;
        return Stack(
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: CupertinoColors.systemGrey5)
                ),
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                padding: const EdgeInsets.only(top: 30),
                height: size.height - 120,
                width: 800,
                child: AnimatedCrossFade(
                  firstChild: auroraViewPort,
                  secondChild: cometViewPort,
                  firstCurve: Curves.easeInOut,
                  secondCurve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 500),
                  crossFadeState: crossFadeState,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              height: size.height - 120,
              child: Align(
                alignment: Alignment.topCenter,
                child: MaterialSegmentedControl<RenderEngine>(
                  selectedColor: CupertinoColors.activeBlue,
                  pressedColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
                  groupValue: ViewportModel.renderEngine,
                  onValueChanged: controller.toggleRenderEngine,
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
              ),
            ),
          ],
        );
      },
    );
  }
}
