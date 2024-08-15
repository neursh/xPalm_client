// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

enum KeyAction {
  press(1),
  release(0);

  const KeyAction(this.value);
  final num value;
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
  late RawDatagramSocket socket;
  int ping = 0;
  int start = DateTime.now().millisecondsSinceEpoch;
  late InternetAddress destinationIp;
  late int destinationPort;

  connect(String ip, int port, int pin) async {
    destinationIp = InternetAddress(ip);
    destinationPort = port;

    connection = true;
    bool hasVibrator = (await Vibration.hasVibrator()) ?? false;

    socket =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, destinationPort);
    socket.readEventsEnabled = true;

    processAuthorizeEvents(int key) {
      if (key > 1) return;
      if (key == 1) {
        authorized = true;
        Timer.run(() => notifyListeners());
        return;
      }
      if (key == 0) {
        disconnect();
      }
    }

    processVibratorEvents(int key) {
      if (key > 3 && !hasVibrator) return;
      if (key == 2) {
        Vibration.vibrate(duration: 10000);
      }
      if (key == 3) {
        Vibration.cancel();
      }
    }

    processPingPongEvent(int key) {
      if (key == 4) {
        ping = DateTime.now().millisecondsSinceEpoch - start;
        Timer.run(() => notifyListeners());
      }
    }

    socket.listen(
      (RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket.receive();
          if (datagram != null && datagram.address.address == ip) {
            final eventKey = datagram.data[0];
            processAuthorizeEvents(eventKey);
            processVibratorEvents(eventKey);
            processPingPongEvent(eventKey);
          }
        }
      },
    );

    // Send PIN to server.
    ByteData pinByteSend = ByteData(5);
    pinByteSend.setInt8(0, 5);
    pinByteSend.setInt32(1, pin);
    socket.send(
        pinByteSend.buffer.asUint8List(0, 5), destinationIp, destinationPort);

    // Timer.periodic(const Duration(seconds: 5), (_) {
    //   start = DateTime.now().millisecondsSinceEpoch;
    //   socket.send([4], destinationIp, port);
    // });
  }

  sendKey(KeyAction action, KeyPad key) {
    socket.send([0, key.value], destinationIp, destinationPort);
  }

  sendJoystick(JoystickPosition joystick, double x, double y) {
    socket.send([1, joystick.value], destinationIp, destinationPort);
  }

  sendTrigger(Trigger trigger, double value) {
    socket.send([2, trigger.value], destinationIp, destinationPort);
  }

  sendReset() {
    socket.send([3], destinationIp, destinationPort);
  }

  disconnect() {
    socket.close();
    Vibration.cancel();
    connection = false;
    authorized = false;
    Timer.run(() => notifyListeners());
  }
}
