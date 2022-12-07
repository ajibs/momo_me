import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:momo_me/qr_provider.dart';

class ViewQR extends HookConsumerWidget {
  final qrKey = GlobalKey();

  ViewQR({Key? key}) : super(key: key);

  takeScreenShot(ref, BuildContext context) async {
    try {
      PermissionStatus res;
      res = await Permission.storage.request();
      if (res.isGranted) {
        final boundary =
            qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 5.0);
        final byteData =
            await (image.toByteData(format: ui.ImageByteFormat.png));
        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();
          final directory = (await getApplicationDocumentsDirectory()).path;
          final imgFile = File(
            '$directory/${DateTime.now()}${ref.label!}.png',
          );
          imgFile.writeAsBytes(pngBytes);
          GallerySaver.saveImage(imgFile.path).then((success) async {
            // store in hive for later retrieval
            await ref.saveQRInfo(ref.qrData, ref.label, ref.link);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data Saved')),
            );
          });
        }
      }
    } catch (err) {
      showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text('Error saving qr code'),
                content: const Text(
                    "Please ensure to you've granted the app gallery permissions and try again"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ],
              ));
    }
  }

  saveQRButtonComponent(qrData, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: ElevatedButton(
        onPressed: () => takeScreenShot(qrData, context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          minimumSize: const Size(253, 62),
        ),
        child: const Text(
          'Save QR',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrData = ref.watch(qrProvider.notifier);
    print("qr data here");
    print(qrData.link);
    print(qrData.label);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 25),
            Center(
              child: RepaintBoundary(
                key: qrKey,
                child: QrImage(
                  data: qrData.link ?? 'no link present',
                  size: 250,
                  backgroundColor: Colors.white,
                  version: QrVersions.auto,
                ),
                // tel:*182*1*1*#
                // 0780577048
              ),
            ),
            const SizedBox(height: 25),
            Text(
              "Label: ${qrData.label}",
              style: const TextStyle(fontSize: 15),
            ),
            Text(
              "Code: ${qrData.qrData}",
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 25),
            saveQRButtonComponent(qrData, context),
            const SizedBox(height: 25)
          ],
        ),
      ),
    );
  }
}
