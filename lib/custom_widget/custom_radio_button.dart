import 'package:flutter/material.dart';

class CustomRadioButtonWidget extends StatelessWidget {
  final dynamic liveStatus;
  final Map<dynamic, String> optionsMap;
  final Function updateStatus;
  const CustomRadioButtonWidget(
      {Key? key,
      required this.liveStatus,
      required this.optionsMap,
      required this.updateStatus})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        children: optionsMap.entries.map((option) {
      return Expanded(
        child: ListTile(
          onTap: () => updateStatus(option.key),
          leading: Radio(
            groupValue: liveStatus,
            value: option.key,
            onChanged: (ind) => {},
          ),
          title: Text(option.value),
        ),
      );
    }).toList());
  }
}
