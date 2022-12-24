import 'package:flutter/foundation.dart';
import "../model/meter_information.dart";

/// Mix-in [DiagnosticableTreeMixin] to have access to [debugFillProperties] for the devtool
// ignore: prefer_mixin
class ApplicationState with ChangeNotifier, DiagnosticableTreeMixin {
  final List<MeterInformation> _meterList = [];
  final List<MeterRecord> _meterRecords = [];
  final String _serverUrl =
      'https://fir-4a8bf-default-rtdb.firebaseio.com/energymeter';

  int _count = 0;
  String _backgroundMessage = 'Unknown battery level.';

  int get count => _count;
  String get backgroundMessage => _backgroundMessage;
  List<MeterInformation> get meterList => _meterList;

  void resetMeterList() {
    _meterList.clear();
    notifyListeners();
  }

  void addMeterToMeterList(String meter, String description) {
    _meterList.add(MeterInformation(id: meter, description: description));
    notifyListeners();
  }

  void setBackgroundMessage(String message) {
    _backgroundMessage = message;
    notifyListeners();
  }

  ApplicationState() {
    // _meterRecords = [];
    _backgroundMessage = "";
  }

  void increment() {
    _count++;
    notifyListeners();
  }

  String getUrl() {
    return _serverUrl;
  }

  void records() {
    _meterRecords.add(MeterRecord());
    notifyListeners();
  }
}
