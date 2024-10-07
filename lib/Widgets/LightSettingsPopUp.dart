import 'package:blue_engine/Screens/Settings/Tabs/Scene/SceneSettingsModel.dart';
import 'package:blue_engine/Widgets/SettingsRow.dart';
import 'package:blue_engine/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'MaterialSegmentedControl.dart';
import 'XYZInputBoxWidget.dart';

Future<dynamic> editLightSettings(BuildContext context, SceneLight light, {String heading = 'Edit Light'}) {
  return showDialog(
    context: context,
    builder: (context) {
      const spacingRatio = 0.56;
      var sceneLight = light;
      final pX = TextEditingController(text: light.position.x.toString());
      final pY = TextEditingController(text: light.position.y.toString());
      final pZ = TextEditingController(text: light.position.z.toString());
      final pXFocus = FocusNode();
      final pYFocus = FocusNode();
      final pZFocus = FocusNode();

      pXFocus.addListener(() {
        if(!pXFocus.hasFocus) {
          pX.text = (double.tryParse(pX.text) ?? 0.0).toString();
        }
      });

      pYFocus.addListener(() {
        if(!pYFocus.hasFocus) {
          pY.text = (double.tryParse(pY.text) ?? 0.0).toString();
        }
      });

      pZFocus.addListener(() {
        if(!pZFocus.hasFocus) {
          pZ.text = (double.tryParse(pZ.text) ?? 0.0).toString();
        }
      });


      final dX = TextEditingController(text: light.direction.x.toString());
      final dY = TextEditingController(text: light.direction.y.toString());
      final dZ = TextEditingController(text: light.direction.z.toString());
      final dXFocus = FocusNode();
      final dYFocus = FocusNode();
      final dZFocus = FocusNode();

      dXFocus.addListener(() {
        if(!dXFocus.hasFocus) {
          dX.text = (double.tryParse(dX.text) ?? 0.0).toString();
        }
      });

      dYFocus.addListener(() {
        if(!dYFocus.hasFocus) {
          dY.text = (double.tryParse(dY.text) ?? 0.0).toString();
        }
      });

      dZFocus.addListener(() {
        if(!dZFocus.hasFocus) {
          dZ.text = (double.tryParse(dZ.text) ?? 0.0).toString();
        }
      });

      final intensityController = TextEditingController(text: light.intensity.toString());

      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          heading,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: SizedBox(
          width: 520,
          height: 520,
          child: Center(
            child: StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 32,
                    ),
                    SettingsRow(
                      spacingRatio: spacingRatio,
                      firstChild: Container(
                        alignment: Alignment.centerRight,
                        width: 100,
                        child: Text(
                          'Light Type : ',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      secondChild: MaterialSegmentedControl<LightType>(
                        selectedColor: CupertinoColors.activeBlue,
                        pressedColor:
                            CupertinoTheme.of(context).scaffoldBackgroundColor,
                        groupValue: sceneLight.lightType,
                        onValueChanged: (value) {
                          setState(() {
                            sceneLight.lightType = value;
                          });
                        },
                        children: const <LightType, Widget>{
                          LightType.sun: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Sun',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          LightType.spot: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Spot',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          LightType.area: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Area',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    SettingsRow(
                      spacingRatio: spacingRatio,
                      firstChild: Text(
                        'Color : ',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      secondChild: GestureDetector(
                        onTap: () async {
                          var selectedColor =
                              (await showColorPicker(context, sceneLight.color))
                                  as Color?;
                          setState(() {
                            sceneLight.color =
                                selectedColor ?? sceneLight.color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(left: 24),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            color: sceneLight.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    SettingsRow(
                      spacingRatio: spacingRatio,
                      firstChild: Text(
                        'Intensity : ',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      secondChild: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: 80,
                          child: CupertinoTextField(
                            controller: intensityController,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                sceneLight.intensity =
                                    double.tryParse(value) ?? 1.0;
                              });
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp("[0-9.]"),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    SettingsRow(
                      spacingRatio: spacingRatio,
                      firstChild: Text(
                        'Position : ',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      secondChild: const SizedBox(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 112),
                      child: getXYZInputBox(context, pX, pY, pZ, pXFocus, pYFocus, pZFocus, (val) {
                        var x = double.tryParse(val) ?? 0.0;
                        setState(() {
                          sceneLight.position = Double3(x: x, y: sceneLight.position.y, z: sceneLight.position.z);
                        });
                      }, (val) {
                        var y = double.tryParse(val) ?? 0.0;
                        setState(() {
                          sceneLight.position = Double3(x: sceneLight.position.x, y: y, z: sceneLight.position.z);
                        });
                      }, (val) {
                        var z = double.tryParse(val) ?? 0.0;
                        setState(() {
                          sceneLight.position = Double3(x: sceneLight.position.x, y: sceneLight.position.y, z: z);
                        });
                      }),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    SettingsRow(
                      spacingRatio: spacingRatio,
                      firstChild: Text(
                        'Direction : ',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      secondChild: const SizedBox(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 112),
                      child: getXYZInputBox(
                          context, dX, dY, dZ, dXFocus, dYFocus, dZFocus, (val) {
                        var x = double.tryParse(val) ?? 0.0;
                        setState(() {
                          sceneLight.direction = Double3(x: x, y: sceneLight.direction.y, z: sceneLight.direction.z);
                        });
                      }, (val) {
                        var y = double.tryParse(val) ?? 0.0;
                        setState(() {
                          sceneLight.direction = Double3(x: sceneLight.direction.x, y: y, z: sceneLight.direction.z);
                        });
                      }, (val) {
                        var z = double.tryParse(val) ?? 0.0;
                        setState(() {
                          sceneLight.direction = Double3(x: sceneLight.direction.x, y: sceneLight.direction.y, z: z);
                        });
                      }),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 32,
                        width: 72,
                        child: CupertinoButton(
                          padding: const EdgeInsets.all(2.0),
                          color: CupertinoColors.activeBlue,
                          child: const Text(
                            'Update',
                            style: TextStyle(color: CupertinoColors.white, fontSize: 16),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(sceneLight);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

Future<dynamic> showColorPicker(BuildContext context, Color color) {
  return showDialog(
    context: context,
    builder: (context) {
      var selectedColor = color;
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            hexInputBar: true,
            pickerColor: color,
            onColorChanged: (color) {
              selectedColor = color;
            },
          ),
        ),
        actions: <Widget>[
          SizedBox(
            height: 32,
            width: 72,
            child: CupertinoButton(
              padding: const EdgeInsets.all(2.0),
              color: CupertinoColors.activeBlue,
              child: const Text(
                'Pick',
                style: TextStyle(color: CupertinoColors.white, fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop(selectedColor);
              },
            ),
          ),
        ],
      );
    },
  );
}
