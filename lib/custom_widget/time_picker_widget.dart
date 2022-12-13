import 'package:flutter/material.dart';

extension TimeOfDayConverter on TimeOfDay {
  String to24hours() {
    // print("$hour:$minute");
    // if (this.hour == 0 && this.minute == 0) {
    //   return "24:00";
    // } else {
    final hour = this.hour.toString().padLeft(2, "0");
    final minute = this.minute.toString().padLeft(2, "0");
    return "$hour:$minute";
    // }
  }
}

class TimePickerlWidget extends StatefulWidget {
  final TextEditingController inputController;
  final String? labelText;
  const TimePickerlWidget(
      {Key? key, required this.inputController, required this.labelText})
      : super(key: key);

  @override
  State<TimePickerlWidget> createState() => _TimePickerlWidgetState();
}

class _TimePickerlWidgetState extends State<TimePickerlWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: TextField(
      controller: widget.inputController,
      decoration: InputDecoration(
          icon: const Icon(Icons.timer), //icon of text field
          labelText: widget.labelText //label text of field
          ),
      readOnly: true,
      onTap: () async {
        TimeOfDay currentTime = TimeOfDay.now();
        TimeOfDay? pickedTime = await showTimePicker(
          initialTime: currentTime,
          context: context,
          builder: (context, child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child ?? Container(),
            );
          },
        );

        if (pickedTime != null) {
          // ignore: avoid_print
          // print("formattedTime ${pickedTime.toString()}");
          // DateTime parsedTime =
          //     DateFormat.jm().format(DateFormat("HH:mm").parse("10:30"));
          // ignore: use_build_context_synchronously
          // .parse(pickedTime.format(context).toString());

          // //converting to DateTime so that we can further format on different pattern.
          // String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
          // print("formattedTime  $formattedTime");
          setState(() {
            widget.inputController.text = pickedTime.to24hours();
          });
          // ignore: use_build_context_synchronously
          // context.read<LoraState>().syncInterval.text =
          //     formattedTime; //set the value of text field.
        } else {}
      },
    ));
  }
}
