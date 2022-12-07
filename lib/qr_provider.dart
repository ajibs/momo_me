import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final qrProvider = ChangeNotifierProvider(
  (_) => QrCodeProvider(),
);

class QRInfo {
  String? phone;
  String? label;
  String? link;
  QRInfo(this.phone, this.label, this.link);
}

class QrCodeProvider extends ChangeNotifier {
  QrCodeProvider() : super();

  final box = Hive.box('');

  String? qrData;
  String? label;
  String? link;

  List<dynamic> createdQrs = [];

  void getQrs() {
    // box.delete('createdQrList');
    createdQrs = box.get('createdQrList') ?? [];
  }

  getQRInfo(int i) {
    return {
      "phone": createdQrs[i]["phone"],
      "label": createdQrs[i]["label"],
      "link": createdQrs[i]["link"],
    };
  }

  Future<void> saveQRInfo(String phone, label, link) async {
    List tempList = box.get('createdQrList') ?? [];
    Map<String, String> data = {"phone": phone, "label": label, "link": link};
    box.put('createdQrList', [
      ...tempList,
      data,
    ]);
    createdQrs.add(data);
  }
}
