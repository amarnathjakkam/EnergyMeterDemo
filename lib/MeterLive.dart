import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:energymeter/login_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'state/application_state.dart';
import 'package:http/http.dart' as http;

class MeterLiveWidget extends StatefulWidget {
  String? meter_imei;

  MeterLiveWidget({Key? key, required this.meter_imei}) : super(key: key);

  @override
  State<MeterLiveWidget> createState() => _MeterLiveState();
}

class _MeterLiveState extends State<MeterLiveWidget> {
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

  Future<void> loadMeterList() async {
    if (isLoadinGoinOn == false) {
      setState(() {
        isLoadinGoinOn = true;
        isMeterLoaded = false;
      });
      try {
        String url = context.read<ApplicationState>().getUrl();
        url +=
            "/meters/${widget.meter_imei}.json?orderBy=\"timestamp\"&limitToLast=1";
        print("url $url");
        Response response = await http.get(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          Map<String, dynamic> parameters = jsonDecode(response.body);
          print('parameters $parameters');
          var cd = parameters.forEach((key, value) {
            // list.add(value);
            print("value $value");
            message = "KWH:       ${value['kwh'].toStringAsFixed(3)} Watt\n";
            message += "Current:   ${value['current'].toStringAsFixed(3)} A\n";
            message += "Voltage:   ${value['voltage'].toStringAsFixed(3)} V\n";
            message +=
                "Frequency: ${value['frequency'].toStringAsFixed(3)} Hz\n";
            var date =
                DateTime.fromMillisecondsSinceEpoch(value['timestamp'] * 1000);

            message +=
                "\nAt ${DateFormat('dd/MM/yyyy, hh:mm:ss a').format(date)}";
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
        appBar: AppBar(title: Text('${widget.meter_imei}'), actions: <Widget>[
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
            : Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.topCenter,
                child: Text(message,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ));
  }
}
