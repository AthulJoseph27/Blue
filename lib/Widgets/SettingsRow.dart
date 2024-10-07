import 'package:flutter/cupertino.dart';

class SettingsRow extends StatelessWidget {
  final Widget firstChild, secondChild;
  final double spacingRatio;
  const SettingsRow(
      {Key? key, required this.firstChild, required this.secondChild, this.spacingRatio = 1.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth / 2.0 * spacingRatio - 8;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: width,
                child: Row(
                  children: [
                    const Spacer(),
                    firstChild,
                  ],
                ),
              ),
              secondChild,
            ],
          ),
        );
      }
    );
  }
}
