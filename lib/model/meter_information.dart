class MeterRecord {
  double? current;
  double? voltage;
  double? frequecny;
  double? kwh;
}

class MeterInformation {
  final String id;
  final String description;
  MeterInformation({required this.id, required this.description}) {}
}
