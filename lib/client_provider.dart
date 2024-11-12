// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

enum KeyAction {
  press(1),
  release(0);

  const KeyAction(this.value);
  final int value;
}

enum KeyPad {
  XUSB_GAMEPAD_DPAD_UP(0x0001),
  XUSB_GAMEPAD_DPAD_DOWN(0x0002),
  XUSB_GAMEPAD_DPAD_LEFT(0x0004),
  XUSB_GAMEPAD_DPAD_RIGHT(0x0008),
  XUSB_GAMEPAD_START(0x0010),
  XUSB_GAMEPAD_BACK(0x0020),
  XUSB_GAMEPAD_LEFT_THUMB(0x0040),
  XUSB_GAMEPAD_RIGHT_THUMB(0x0080),
  XUSB_GAMEPAD_LEFT_SHOULDER(0x0100),
  XUSB_GAMEPAD_RIGHT_SHOULDER(0x0200),
  XUSB_GAMEPAD_GUIDE(0x0400),
  XUSB_GAMEPAD_A(0x1000),
  XUSB_GAMEPAD_B(0x2000),
  XUSB_GAMEPAD_X(0x4000),
  XUSB_GAMEPAD_Y(0x8000);

  const KeyPad(this.value);
  final int value;
}

enum JoystickPosition {
  left_joystick(0),
  right_joystick(1);

  const JoystickPosition(this.value);
  final int value;
}

enum Trigger {
  left_trigger(0),
  right_trigger(1);

  const Trigger(this.value);
  final int value;
}

class ClientProvider extends ChangeNotifier {
  bool authorized = false;
  bool connection = false;
  late RawDatagramSocket udpJoystick;
  late RawSocket tcpButtons;
  int ping = 0;
  int start = DateTime.now().millisecondsSinceEpoch;
  late InternetAddress destinationIp;
  late int destinationPort;

  connect(String ip, int port) async {
    destinationIp = InternetAddress(ip);
    destinationPort = port;

    connection = true;

    tcpButtons = await RawSocket.connect(destinationIp, port);

    udpJoystick =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, destinationPort);
    udpJoystick.readEventsEnabled = true;

    processAuthorizeEvents(int key) {
      if (key > 1) return;
      if (key == 1) {
        authorized = true;
        Timer.run(() => notifyListeners());

        Timer.periodic(const Duration(seconds: 2), (_) {
          start = DateTime.now().millisecondsSinceEpoch;
          tcpButtons.write([6, 0, 0, 0]);
        });
        return;
      }
      if (key == 0) {
        disconnect();
      }
    }

    processPingPongEvent(int key) {
      if (key == 6) {
        ping = DateTime.now().millisecondsSinceEpoch - start;
        Timer.run(() => notifyListeners());
      }
    }

    tcpButtons.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final datagram = tcpButtons.read();

        if (datagram != null) {
          final eventKey = datagram[0];
          processAuthorizeEvents(eventKey);
          processPingPongEvent(eventKey);
        }
      }
    });

    // Request to server.
    tcpButtons.write([0, 0, 0, 0]);
  }

  sendKey(KeyAction action, KeyPad key) {
    tcpButtons.write([2, action.value] + _intToUint8List(key.value));
  }

  sendJoystick(JoystickPosition joystick, int x, int y) {
    udpJoystick.send(
        [3, joystick.value] + _intToUint8List(x) + _intToUint8List(y),
        destinationIp,
        destinationPort);
  }

  sendTrigger(Trigger trigger, int value) {
    tcpButtons.write([4, trigger.value, 0, value]);
  }

  sendReset() {
    tcpButtons.write([5]);
  }

  disconnect() {
    tcpButtons.write([1]);
    tcpButtons.close();
    udpJoystick.close();
    connection = false;
    authorized = false;
    Timer.run(() => notifyListeners());
  }

  Uint8List _intToUint8List(int value) {
    ByteData byteData = ByteData(2);
    byteData.setInt16(0, value, Endian.little);

    return byteData.buffer.asUint8List();
  }
}
