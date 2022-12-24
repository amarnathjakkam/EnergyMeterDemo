import 'package:energymeter/meter_live_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:energymeter/login_page.dart';
import 'state/application_state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        url += "/demo/info/meter.json";
        // print("url $url");
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
          if (!mounted) return;
          context.read<ApplicationState>().resetMeterList();
          parameters.forEach((key, value) {
            // print("Key $key value $value");
            context
                .read<ApplicationState>()
                .addMeterToMeterList(value["id"], value["description"]);
          });
          if (kDebugMode) {
            print("Meter List ${context.read<ApplicationState>().meterList}");
          }
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
                meterImei: context.read<ApplicationState>().meterList[index].id,
                meterLocation: context
                    .read<ApplicationState>()
                    .meterList[index]
                    .description)));
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
                padding: const EdgeInsets.all(5),
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
            padding: const EdgeInsets.all(5.0),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.gas_meter,
                    color: Colors.blue.shade600, size: 45),
                title: Text(
                  context
                      .read<ApplicationState>()
                      .meterList
                      .elementAt(index)
                      .description,
                  style: const TextStyle(fontSize: 20),
                ),
                subtitle: Text(context
                    .read<ApplicationState>()
                    .meterList
                    .elementAt(index)
                    .id),
              ),
            )));
  }
}
