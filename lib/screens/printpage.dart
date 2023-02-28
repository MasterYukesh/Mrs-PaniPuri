import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';

class PrintPage extends StatefulWidget {
  final List<Map<String, dynamic>> billdata;
  final String date;
  final String totalcost;
  final String mop;
  final String title;
  const PrintPage(
      {super.key,
      required this.billdata,
      required this.totalcost,
      required this.mop,
      required this.date,
      required this.title});

  @override
  State<StatefulWidget> createState() {
    return _PrintPage();
  }
}

class _PrintPage extends State<PrintPage> {
  BluetoothPrint bp = BluetoothPrint.instance;
  List<BluetoothDevice> devices = [];
  String deviceMsg = "";
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initprint();
    });
  }

  Future<void> initprint() async {
    // scan for bluetooth devices for 2 seconds
    bp.startScan(timeout: const Duration(seconds: 2));
    // the mounted property will check if the current widget is present in the widget tree or not.
    if (!mounted) return;
    // listen all the bluetooth devices found after scanning
    bp.scanResults.listen((event) {
      if (!mounted) return;
      setState(() {
        devices = event;
      });
      // if no devices are found
      if (devices.isEmpty) {
        setState(() {
          deviceMsg = "No devices Found!";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available BlueTooth Devices'),
      ),
      body: devices.isEmpty
          ? const Center(
              child: Text(
                'No devices found!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
            )
          : ListView.builder(
              itemBuilder: ((context, index) => ListTile(
                    leading: const Icon(Icons.print_sharp),
                    title: Text(devices[index].name.toString()),
                    subtitle: Text(devices[index].address.toString()),
                    onTap: () {},
                  )),
              itemCount: devices.length),
    );
  }

  Future printreceipt() async {
    Map<String, dynamic> config = {};
    List<LineText> list = [];
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        align: LineText.ALIGN_CENTER,
        content: 'Mrs PaniPuri',
        weight: 2,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        align: LineText.ALIGN_CENTER,
        content: widget.title,
        weight: 1,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        align: LineText.ALIGN_RIGHT,
        content: widget.date,
        linefeed: 1));
    for (int i = 0; i < widget.billdata.length; i++) {
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          align: LineText.ALIGN_CENTER,
          content:
              '${widget.billdata[i]['product']} \t\t ${widget.billdata[i]['price']} ${widget.billdata[i]['quantity']}',
          weight: 1,
          linefeed: 1));
    }
    list.add(LineText(linefeed: 2));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        align: LineText.ALIGN_CENTER,
        height: 5,
        content: 'Total  : ${widget.totalcost}',
        linefeed: 1));
    list.add(LineText(linefeed: 2));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        align: LineText.ALIGN_LEFT,
        content: 'Method Of Payment : ${widget.mop}',
        linefeed: 1));

    bp.printReceipt(config, list);
  }
}
