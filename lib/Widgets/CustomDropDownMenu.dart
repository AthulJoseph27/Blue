import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDropDownMenu extends StatefulWidget {
  final double width;
  final List<String> list;
  final String? initialValue;
  final void Function(String)? onChanged;
  const CustomDropDownMenu({Key? key, required this.list, this.width = 300, this.onChanged, this.initialValue}) : super(key: key);

  @override
  State<CustomDropDownMenu> createState() => _CustomDropDownMenuState();
}

class _CustomDropDownMenuState extends State<CustomDropDownMenu> {
  late String dropdownValue;

  @override
  void initState() {
    dropdownValue = widget.initialValue ?? widget.list[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey3),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButton<String>(
        borderRadius: BorderRadius.circular(8.0),
        value: dropdownValue,
        icon: Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Icon(CupertinoIcons.chevron_down, color: Theme.of(context).primaryColor,),
        ),
        elevation: 16,
        style: TextStyle(color: Theme.of(context).primaryColor),
        underline: const SizedBox(),
        isExpanded: true,
        focusColor: Theme.of(context).primaryColor.withOpacity(0.2),
        onChanged: (String? value) {
          value = value ?? dropdownValue;
          setState(() {
            dropdownValue = value!;
          });
          if(widget.onChanged != null) {
            widget.onChanged!(value);
          }
        },
        items: widget.list.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(value, style: Theme.of(context).textTheme.labelLarge,),
            ),
          );
        }).toList(),
      ),
    );
  }
}
