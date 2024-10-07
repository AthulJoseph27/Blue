import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget getXYZInputBox(BuildContext context, TextEditingController x, TextEditingController y, TextEditingController z, FocusNode fx, FocusNode fy, FocusNode fz, Function(String) onXChanged,
    Function(String) onYChanged, Function(String) onZChanged) {
  return Padding(
    padding: const EdgeInsets.only(left: 16),
    child: Row(
      children: [
        Text(
          'x :',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: 80,
            child: CupertinoTextField(
              focusNode: fx,
              controller: x,
              keyboardType: TextInputType.number,
              onChanged: onXChanged,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r"^-?(?:\d+\.?\d*|\.\d+)?$|^-$"),
                )
              ],
            ),
          ),
        ),
        Text(
          'y :',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: 80,
            child: CupertinoTextField(
              focusNode: fy,
              controller: y,
              onChanged: onYChanged,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r"^-?(?:\d+\.?\d*|\.\d+)?$|^-$"),
                )
              ],
            ),
          ),
        ),
        Text(
          'z :',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: 80,
            child: CupertinoTextField(
              focusNode: fz,
              controller: z,
              onChanged: onZChanged,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r"^-?(?:\d+\.?\d*|\.\d+)?$|^-$"),
                )
              ],
            ),
          ),
        ),
      ],
    ),
  );
}