import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:tagaddod_ports/utils/extensions.dart';

class PortPage extends StatefulWidget {
  const PortPage({super.key, required this.portName});
  final String portName;

  @override
  State<PortPage> createState() => _PortPageState();
}

class _PortPageState extends State<PortPage> {
  late SerialPort myPort;
  late SerialPortReader portReader;
  StreamSubscription<Uint8List>? subStream;
  String result = "";

  @override
  void initState() {
    try {
      myPort = SerialPort(widget.portName);
      myPort.openReadWrite();
      myPort.config = SerialPortConfig()
        ..baudRate = 9600
        ..bits = 8
        ..stopBits = 1
        ..parity = 0
        ..setFlowControl(SerialPortFlowControl.none);

      portReader = SerialPortReader(myPort, timeout: 2000);
      _listenToPort();
      super.initState();
    } catch (e) {
      print("Error: $e");
      context.pop();
    }
  }

  void _listenToPort() {
    try {
      subStream = portReader.stream.listen((data) {
        setState(() {
          if (String.fromCharCodes(data).contains('\r\n') ||
              String.fromCharCodes(data).contains('\n') ||
              String.fromCharCodes(data).contains('\r')) {
            result += "\n";
          } else {
            result += String.fromCharCodes(data);
          }
        });
      }, onError: (e) {
        myPort.close();
        subStream?.cancel();
      }, onDone: () {
        myPort.close();
        subStream?.cancel();
        if (mounted) {
          context.pop();
        }
      });
    } catch (e) {
      context.pop();
    }
  }

  @override
  void dispose() {
    myPort.close();
    subStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Port ${widget.portName} '),
      ),
      body: SafeArea(
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Result Of reading is :",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                ),
                const Divider(),
                Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                    ),
                    child: Text(result)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
