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

class CreateQrPage extends HookConsumerWidget {
  final qrKey = GlobalKey();

  CreateQrPage({Key? key}) : super(key: key);

  takeScreenShot(ref) async {
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
            await ref.saveQRInfo(ref.qrData!, ref.label!, ref.link);
          });
        }
      }
    } catch (err) {
      print("error here $err");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrData = ref.watch(qrProvider.notifier);

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
                  data: qrData.link ?? '',
                  size: 250,
                  backgroundColor: Colors.white,
                  version: QrVersions.auto,
                ),
                // tel:*182*1*1*#
                // 0780577048
              ),
            ),
            const SizedBox(height: 25),
            Text(qrData.label ?? ""),
            const SizedBox(height: 25),
            CupertinoButton(
              child: const Text("Save"),
              onPressed: () => takeScreenShot(qrData),
            ),
            const SizedBox(height: 25)
          ],
        ),
      ),
    );
  }
}
