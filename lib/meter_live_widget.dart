import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'state/application_state.dart';
import 'package:http/http.dart' as http;

//ignore: must_be_immutable
class MeterLiveWidget extends StatefulWidget {
  String? meterLocation;
  String? meterImei;

  MeterLiveWidget(
      {Key? key, required this.meterImei, required this.meterLocation})
      : super(key: key);

  @override
  State<MeterLiveWidget> createState() => _MeterLiveState();
}

class _MeterLiveState extends State<MeterLiveWidget> {
  List<String> valueTypes = ["Total", "R", "Y", "B"];
  List<String> lineToLineTypes = ["LL Avg", "ry", "yb", "br"];
  List<String> lineTypes = ["LN Avg", "R", "Y", "B"];
  bool isMeterLoaded = false;
  bool isLoadinGoinOn = false;
  String message = "";
  bool isFirstTimeDone = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MeterLiveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getParameterValueInRedable(String descrption, String units, String key,
      dynamic object, List<String>? types,
      {int numberOfDecimals = 1}) {
    String message = "";
    if (object[key] != null) {
      var values = object[key];
      if (kDebugMode) {
        print('object  type ${values.runtimeType} $descrption $types');
      }
      if (values.runtimeType == List<dynamic>) {
        List<dynamic> list = values;
        if (types != null && types.length == list.length) {
          int ix = 0;
          for (var value in list) {
            message +=
                "$descrption ${types[ix++]} : ${value.toStringAsFixed(numberOfDecimals)} $units \n";
          }
        } else {
          message +=
              "$descrption : ${object[key].toStringAsFixed(numberOfDecimals)} $units \n";
        }
      } else {
        message +=
            "$descrption : ${object[key].toStringAsFixed(numberOfDecimals)} $units \n";
      }
    }
    return message;
  }

  Future<void> loadMeterList() async {
    if (isLoadinGoinOn == false) {
      setState(() {
        isLoadinGoinOn = true;
        isMeterLoaded = false;
      });
      try {
        String url = context.read<ApplicationState>().getUrl();
        url +=
            "/meters/${widget.meterImei}.json?orderBy=\"timestamp\"&limitToLast=1";
        if (kDebugMode) {
          print("url $url");
        }
        Response response = await http.get(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          Map<String, dynamic> parameters = jsonDecode(response.body);
          if (kDebugMode) {
            print('parameters $parameters');
          }
          parameters.forEach((key, value) {
            message = "Location: ${widget.meterLocation}\n";
            var timestamp = value['timestamp'];
            if (timestamp > 19800) {
              timestamp -= 19800;
            }
            var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

            message +=
                "At ${DateFormat('dd/MM/yyyy, hh:mm:ss a').format(date)}\n\n";
            message +=
                getParameterValueInRedable("Wh", 'Wh', "wh", value, null);
            message +=
                getParameterValueInRedable("VAh", 'VAh', "vah", value, null);
            message += getParameterValueInRedable(
                "frequency", 'Hz', "frequency", value, null);
            message += "\n";
            message += getParameterValueInRedable(
                "Current", 'A', "line_current", value, valueTypes);
            message += "\n";
            message += getParameterValueInRedable(
                "Voltage", 'V', "line_to_line_voltage", value, lineToLineTypes);
            message += "\n";
            message += getParameterValueInRedable(
                "Voltage", 'V', "line_voltage", value, lineTypes);
            message += "\n";
            message += getParameterValueInRedable(
                "Power Factor", '', "power_factor", value, valueTypes);
            message += "\n";
            message += getParameterValueInRedable(
                "Apparant Power", 'VA', "va", value, valueTypes);
            message += "\n";
            message += getParameterValueInRedable(
                "Active Power", 'Watt', "watts", value, valueTypes);
            // message += "\n";
            // message += getParameterValueInRedable(
            //     "Reactive Power", 'VAR', "vars", value, valueTypes);

            // message = "Cumlative WH:  ${value['kwh'].toStringAsFixed(3)} WH\n";
            // message +=
            //     "Current    :  ${value['current'].toStringAsFixed(3)} A\n";
            // message +=
            //     "Voltage    :  ${value['voltage'].toStringAsFixed(3)} V\n";
            // message +=
            //     "Frequency: ${value['frequency'].toStringAsFixed(3)} Hz\n";
          });
        }
      } catch (e) {
        String message = e.toString();
        EasyLoading.showToast(message, dismissOnTap: true);
      }
      setState(() {
        isMeterLoaded = true;
        isLoadinGoinOn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstTimeDone == false) {
      isFirstTimeDone = true;
      loadMeterList();
    }

    return Scaffold(
        appBar: AppBar(title: Text('${widget.meterImei}'), actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                loadMeterList();
              },
              child: const Icon(Icons.refresh),
            ),
          )
        ]),
        body: (isMeterLoaded == false)
            ? Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: const CircularProgressIndicator())
            : SingleChildScrollView(
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.topCenter,
                    child: Text(message,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold))) // your root container
                )

        // Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        //     Expanded(
        //         child: Container(
        //       padding: const EdgeInsets.all(8.0),
        //       alignment: Alignment.topCenter,
        //       child: Text(message,
        //               style: const TextStyle(
        //                   fontSize: 18, fontWeight: FontWeight.bold))),
        //     )
        //   ])
        );
  }
}
