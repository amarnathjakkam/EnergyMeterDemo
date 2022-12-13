import 'dart:convert';

import 'package:energymeter/MeterLive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:energymeter/login_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'state/application_state.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoadinGoinOn = false;
  bool isFirstTimeDone = false;
  bool isMeterLoaded = false;
  @override
  void initState() {
    super.initState();

    EasyLoading.addStatusCallback((status) {
      if (kDebugMode) {
        print('addStatusCallback $status');
      }
      if (status == EasyLoadingStatus.dismiss) {}
    });
  }

  Future<void> loadMeterList() async {
    if (isLoadinGoinOn == false) {
      isLoadinGoinOn = true;

      setState(() {
        isMeterLoaded = false;
      });
      try {
        String url = context.read<ApplicationState>().getUrl();
        url += "/meters.json?shallow=true";
        // print("url $url");
        Response response = await http.get(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          Map<String, dynamic> parameters = jsonDecode(response.body);
          // print('parameters $parameters');
          context.read<ApplicationState>().resetMeterList();
          var cd = parameters.forEach((key, value) {
            // print("Key $key value $value");
            context.read<ApplicationState>().addMeterToMeterList(key);
          });
          print("Meter List ${context.read<ApplicationState>().meterList}");
        }
      } catch (e) {
        String message = e.toString();
        EasyLoading.showToast(message, dismissOnTap: true);
      }
      setState(() {
        isMeterLoaded = true;
      });
      isLoadinGoinOn = false;
    }
  }

  void loadMeterLive(int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => MeterLiveWidget(
                meter_imei:
                    context.read<ApplicationState>().meterList[index])));
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    if (isFirstTimeDone == false) {
      isFirstTimeDone = true;
      loadMeterList();
    }
    // EasyLoading.show(status: "fg");
    return Scaffold(
        appBar: AppBar(title: const Text('Meter List'), actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                loadMeterList();
              },
              child: const Icon(Icons.refresh),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginPage()));
              },
              child: const Icon(Icons.logout),
            ),
          ),
        ]),
        body: (isMeterLoaded == false)
            ? Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: const CircularProgressIndicator())
            : Container(
                padding: EdgeInsets.all(5),
                child: ListView.builder(
                  itemBuilder: _buildMeterItem,
                  itemCount: context.read<ApplicationState>().meterList.length,
                )));
  }

  Widget _buildMeterItem(BuildContext context, int index) {
    return GestureDetector(
        onTap: () => {
              // print(
              //     "Meter List ${context.read<ApplicationState>().meterList.elementAt(index)}")
              loadMeterLive(index)
            },
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              child: Text(
                  context.read<ApplicationState>().meterList.elementAt(index)),
            )));
  }
}
