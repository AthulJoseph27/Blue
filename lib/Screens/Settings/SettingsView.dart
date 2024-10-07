import 'package:blue_engine/Screens/Settings/Tabs/Camera/CameraSettingsView.dart';
import 'package:blue_engine/Screens/Settings/Tabs/Scene/SceneSettingsView.dart';
import 'package:blue_engine/Widgets/MaterialSlidingSegmentedControl.dart';
import 'package:blue_engine/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Tabs/Viewport/Views/ViewportSettingsView.dart';

enum SettingTab { viewPort, scene, camera }

class SettingsPage extends StatefulWidget {
  final SettingTab? tab;
  final void Function(SettingTab)? onTabChanged;
  const SettingsPage({Key? key, this.tab, this.onTabChanged}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingTab _selectedTab;
  var tabs = [
    ViewportSettingsView(key: UniqueKey(),),
    SceneSettingsView(key: UniqueKey(),),
    CameraSettingsView(key: UniqueKey(),),
  ];

  @override
  void initState() {
    _selectedTab = widget.tab ?? SettingTab.viewPort;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) => ScaffoldMessenger(
          key: settingsScaffoldMessengerKey,
          child: Scaffold(
                body: Center(
                  child: Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: SizedBox(
                            height: 60,
                            child: MaterialSlidingSegmentedControl<SettingTab>(
                              backgroundColor: CupertinoColors.lightBackgroundGray,
                              thumbColor: CupertinoColors.white,
                              groupValue: _selectedTab,
                              onValueChanged: (SettingTab? value) {
                                if (value == null || value == _selectedTab) {
                                  return;
                                }

                                widget.onTabChanged?.call(value);

                                setState(() {
                                  _selectedTab = value;
                                });
                              },
                              children: const <SettingTab, Widget>{
                                SettingTab.viewPort: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    'View Port',
                                    style: TextStyle(
                                        color: CupertinoColors.label, fontSize: 16),
                                  ),
                                ),
                                SettingTab.scene: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    'Scene',
                                    style: TextStyle(
                                        color: CupertinoColors.label, fontSize: 16),
                                  ),
                                ),
                                SettingTab.camera: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    'Camera',
                                    style: TextStyle(
                                        color: CupertinoColors.label, fontSize: 16),
                                  ),
                                ),
                              },
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight - 80,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: tabs[_selectedTab.index],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ));
  }
}
