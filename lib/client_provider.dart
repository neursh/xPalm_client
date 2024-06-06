// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'package:flutter/foundation.dart';
import "package:socket_io_client/socket_io_client.dart" as sio;
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
  final num value;
}

enum JoystickPosition {
  left_joystick(0),
  right_joystick(1);

  const JoystickPosition(this.value);
  final num value;
}

enum Trigger {
  left_trigger(0),
  right_trigger(1);

  const Trigger(this.value);
  final num value;
}

class ClientProvider extends ChangeNotifier {
  bool authorized = false;
  bool connection = false;
  late sio.Socket socket;
  int ping = 0;
  int start = DateTime.now().millisecondsSinceEpoch;

  connect(String ip, int port, String pin) async {
    connection = true;
    bool hasVibrator = (await Vibration.hasVibrator()) ?? false;

    socket = sio.io(
      "http://$ip:$port",
      sio.OptionBuilder()
          .enableForceNew()
          .setTransports(["websocket"])
          .setExtraHeaders({"PIN": pin})
          .disableAutoConnect()
          .disableReconnection()
          .build(),
    );

    socket.on("authorized", (data) {
      authorized = true;
      Timer.run(() => notifyListeners());
    });

    socket.on("disconnect", (data) {
      disconnect();
    });

    if (hasVibrator) {
      socket.on("v", (vibrate) {
        if (vibrate) {
          Vibration.vibrate(duration: 10000);
        } else {
          Vibration.cancel();
        }
      });
    }

    socket.on("PO", (_) {
      ping = DateTime.now().millisecondsSinceEpoch - start;
      Timer.run(() => notifyListeners());
    });

    socket.connect();

    Timer.periodic(const Duration(seconds: 5), (_) {
      start = DateTime.now().millisecondsSinceEpoch;
      socket.emit("PI", "");
    });
  }

  sendKey(KeyAction action, KeyPad key) {
    socket.emit("K", [action.value, key.value]);
  }

  sendJoystick(JoystickPosition joystick, double x, double y) {
    socket.emit("J", [joystick.value, x, y]);
  }

  sendTrigger(Trigger trigger, double value) {
    socket.emit("T", [trigger.value, value]);
  }

  sendReset() {
    socket.emit("reset");
  }

  disconnect() {
    socket.dispose();
    Vibration.cancel();
    connection = false;
    authorized = false;
    Timer.run(() => notifyListeners());
  }
}
