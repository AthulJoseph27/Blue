import 'package:blue_engine/Screens/Settings/Tabs/Scene/SceneSettingsModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LightTile extends StatelessWidget {
  final SceneLight light;
  final void Function()? onTap;
  const LightTile({Key? key, required this.light, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(getIcon()),
      title: Text(getLightType()),
      trailing: CupertinoButton(
        onPressed: onTap,
        child: const Icon(CupertinoIcons.option, size: 18,),
      ),
    );
  }

  IconData getIcon() {
    switch(light.lightType) {
      case LightType.sun:
        return CupertinoIcons.sun_dust;
      case LightType.spot:
        return CupertinoIcons.lightbulb;
      case LightType.area:
        return CupertinoIcons.light_max;
        break;
    }
  }

  String getLightType() {
    var lightType = light.lightType.name;
    return '${lightType[0].toUpperCase()}${lightType.substring(1)}';
  }
}
