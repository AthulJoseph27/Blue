import 'package:blue_engine/Screens/SplashScreen.dart';
import 'package:blue_engine/screens/RenderImage/RenderImageView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Screens/Loading.dart';
import 'Screens/RenderAnimation/RenderAnimationView.dart';
import 'Screens/Settings/SettingsView.dart';
import 'SwiftCommunicationBridge.dart';
import 'globals.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeEventChannel();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: CupertinoColors.activeBlue),
      home: const FlutterUI(),
    );
  }
}

class FlutterUI extends StatefulWidget {
  const FlutterUI({Key? key}) : super(key: key);

  @override
  State<FlutterUI> createState() => _FlutterUIState();
}

class _FlutterUIState extends State<FlutterUI> {
  var page = '';
  var settingsSelectedTab = SettingTab.viewPort;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: pageController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          page = snapshot.data['page'];
        }
        return SafeArea(child: getPage(page));
      },
    );
  }

  Widget getPage(String page) {
    switch (page) {
      case 'Settings':
        return SettingsPage(
          key: UniqueKey(),
          tab: settingsSelectedTab,
          onTabChanged: (tab) {
            settingsSelectedTab = tab;
          },
        );
      case 'RenderImage':
        return const RenderImagePage();
      case 'RenderAnimation':
        return const RenderAnimationPage();
      case 'Loading':
        return const Loading();
      default:
        return const SplashScreen();
    }
  }
}
