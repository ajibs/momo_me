import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:momo_me/utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'qr_provider.dart';

const minNameLength = 2;
const minPhoneLength = 9;

String? validateName(value) {
  if (value.length < minNameLength) {
    return 'Name must be at least $minNameLength characters';
  } else {
    return null;
  }
}

bool _isNumeric(String str) {
  if (str == null) {
    return false;
  }
  return int.tryParse(str) != null;
}

String? validatePhone(value) {
  if (!_isNumeric(value)) {
    return 'Enter a number e.g. 600978 or 0792153258';
  } else if (value.length < minPhoneLength) {
    return 'Number must be at least $minPhoneLength digits';
  } else {
    return null;
  }
}

// used for listing QRs and creating a new QR
class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = useState(0);
    const tabNumber = 1;
    final tabController = useTabController(initialLength: tabNumber);
    final qrdata = useTextEditingController();
    final qrLabel = useTextEditingController();
    final _formKey = GlobalKey<FormState>();

    tabController.addListener(() => index.value = tabController.index);
    final qrData = ref.watch(qrProvider.notifier);
    useEffect(() {
      qrData.getQrs();
      return () {};
    }, []);

    codeComponent() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: TextFormField(
          // The validator receives the text that the user has entered.
          validator: validatePhone,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(),
            ),
            labelText: 'Merchant Code or Phone Number',
          ),
          controller: qrdata,
          autofocus: true,
        ),
      );
    }

    labelComponent() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: TextFormField(
          // The validator receives the text that the user has entered.
          validator: validateName,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(),
            ),
            labelText: 'Name',
          ),
          controller: qrLabel,
        ),
      );
    }

    saveButton() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: ElevatedButton(
          onPressed: () async {
            // Validate returns true if the form is valid, or false otherwise.

            if (_formKey.currentState!.validate()) {
              qrData.qrData = qrdata.text;
              qrData.label = qrLabel.text;
              qrData.link = composePhoneLink(qrData.qrData!);
              Navigator.pushNamed(context, '/ViewQR');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: const Size(253, 62),
          ),
          child: const Text(
            'Create QR',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      );
    }

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
                    return Form(
                        key: _formKey,
                        child: Dialog(
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Your Qr Data'),
                                const SizedBox(height: 20),
                                codeComponent(),
                                labelComponent(),
                                const SizedBox(height: 20),
                                saveButton(),
                              ],
                            ),
                          ),
                        ));
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
                              Text("${qrData.getQRInfo(i)["label"]}"),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        // setting here makes it available on the view qr page
                        qrData.link = qrData.getQRInfo(i)["link"];
                        qrData.label = qrData.getQRInfo(i)["label"];
                        qrData.qrData = qrData.getQRInfo(i)["code"];
                        Navigator.pushNamed(context, '/ViewQR');
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
