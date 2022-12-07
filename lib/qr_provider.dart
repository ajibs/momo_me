import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final qrProvider = ChangeNotifierProvider(
  (_) => QrCodeProvider(),
);

class QrCodeProvider extends ChangeNotifier {
  QrCodeProvider() : super();

  final box = Hive.box('');

  String? qrData;
  String? label;
  String? link;
  String? codeType;

  List<dynamic> createdQrs = [];

  void getQrs() {
    // box.delete('createdQrList');
    createdQrs = box.get('createdQrList') ?? [];
  }

  getQRInfo(int i) {
    return {
      "code": createdQrs[i]["code"],
      "label": createdQrs[i]["label"],
      "link": createdQrs[i]["link"],
      "codeType": createdQrs[i]["codeType"]
    };
  }

  Future<void> saveQRInfo(String code, label, link, codeType) async {
    List tempList = box.get('createdQrList') ?? [];
    Map<String, String> data = {
      "code": code,
      "label": label,
      "link": link,
      "codeType": codeType
    };
    box.put('createdQrList', [
      ...tempList,
      data,
    ]);
    createdQrs.add(data);
  }
}
