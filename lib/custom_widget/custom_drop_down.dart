import 'package:flutter/material.dart';

class CustomDropDownWidget extends StatefulWidget {
  final String? liveStatus;
  final List<String> optionsList;
  final Function updateStatus;
  const CustomDropDownWidget(
      {Key? key,
      required this.liveStatus,
      required this.optionsList,
      required this.updateStatus})
      : super(key: key);

  @override
  State<CustomDropDownWidget> createState() => _CustomDropDownWidgetState();
}

class _CustomDropDownWidgetState extends State<CustomDropDownWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DropdownButtonFormField(
        alignment: AlignmentDirectional.topEnd,
        elevation: 10,
        value: widget.liveStatus,
        onChanged: (String? value) {
          widget.updateStatus(value);
          // context.read<LoraState>().updateValveStatus(value);
        },
        items: widget.optionsList
            .map((cityTitle) =>
                DropdownMenuItem(value: cityTitle, child: Text(cityTitle)))
            .toList(),
      ),
    );
  }
}
