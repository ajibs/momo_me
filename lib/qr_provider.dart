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

  List<dynamic> createdQrs = [];

  void getQrs() {
    // box.delete('createdQrList');
    createdQrs = box.get('createdQrList') ?? [];
    print("getting qrs");
    print(createdQrs);
  }

  getQRInfo(int i) {
    return {
      "code": createdQrs[i]["code"],
      "label": createdQrs[i]["label"],
      "link": createdQrs[i]["link"],
    };
  }

  Future<void> saveQRInfo(String code, label, link) async {
    List tempList = box.get('createdQrList') ?? [];
    Map<String, String> data = {"code": code, "label": label, "link": link};
    box.put('createdQrList', [
      ...tempList,
      data,
    ]);
    print("saving qrs");
    print(data);
    createdQrs.add(data);
  }
}
