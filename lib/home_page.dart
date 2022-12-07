import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:momo_me/utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'qr_provider.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = useState(0);
    const tabNumber = 1;
    final tabController = useTabController(initialLength: tabNumber);
    final qrdata = useTextEditingController();
    final qrLabel = useTextEditingController();
    tabController.addListener(() => index.value = tabController.index);
    final qrData = ref.watch(qrProvider.notifier);
    useEffect(() {
      qrData.getQrs();
      return () {};
    }, []);

    return DefaultTabController(
      length: tabNumber,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              CupertinoButton(
                child: const Text('Create Qr'),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Your Qr Data'),
                            const SizedBox(height: 20),
                            TextField(controller: qrdata, autofocus: true),
                            TextField(controller: qrLabel),
                            const SizedBox(height: 20),
                            CupertinoButton(
                              child: const Text('Create Qr'),
                              onPressed: () {
                                qrData.qrData = qrdata.text;
                                qrData.label = qrLabel.text;
                                qrData.link = composePhoneLink(qrData.qrData!);
                                Navigator.pushNamed(context, '/CreateQr');
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
          bottom: TabBar(
            controller: tabController,
            isScrollable: true,
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.black87,
            tabs: const [
              Tab(text: 'Created'),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            qrData.createdQrs.isEmpty
                ? const Center(
                    child: Text("There isn't any created Qr's yet."),
                  )
                : ListView.builder(
                    itemCount: qrData.createdQrs.length,
                    itemBuilder: (_, i) => GestureDetector(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              QrImage(
                                data: qrData.getQRInfo(i)["link"],
                                size: 75,
                                backgroundColor: Colors.white,
                                version: QrVersions.auto,
                              ),
                              Text(qrData.getQRInfo(i)["label"]),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        qrData.link = qrData.getQRInfo(i)["link"];
                        Navigator.pushNamed(context, '/CreateQr');
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
