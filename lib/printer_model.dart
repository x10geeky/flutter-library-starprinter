class PrinterModel {
  String modelName;
  String macAddress;
  String portName;

  PrinterModel({this.modelName, this.macAddress, this.portName});

  PrinterModel.fromJson(Map<String, dynamic> json) {
    modelName = json['modelName'];
    macAddress = json['macAddress'];
    portName = json['portName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['modelName'] = this.modelName;
    data['macAddress'] = this.macAddress;
    data['portName'] = this.portName;
    return data;
  }
}