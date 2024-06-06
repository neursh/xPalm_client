// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'package:flutter/foundation.dart';
import "package:socket_io_client/socket_io_client.dart" as sio;
import 'package:vibration/vibration.dart';

enum KeyAction { press, release }

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

enum JoystickPosition { left_joystick, right_joystick }

enum Trigger { left_trigger, right_trigger }

class ClientProvider extends ChangeNotifier {
  bool authorized = false;
  bool connection = false;
  sio.Socket? socket;

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

    socket!.on("authorized", (data) {
      authorized = true;
      Timer.run(() => notifyListeners());
    });

    socket!.on("disconnect", (data) {
      disconnect();
    });

    if (hasVibrator) {
      socket!.on("vibrate", (vibrate) {
        if (vibrate) {
          Vibration.vibrate(duration: 10000);
        } else {
          Vibration.cancel();
        }
      });
    }

    socket!.connect();
  }

  sendKey(KeyAction action, KeyPad key) {
    socket!.emit("key", {"action": action.name, "key": key.value});
  }

  sendJoystick(JoystickPosition joystick, double x, double y) {
    socket!.emit("joystick", {"action": joystick.name, "x": x, "y": y});
  }

  sendTrigger(Trigger trigger, double value) {
    socket!.emit("trigger", {"action": trigger.name, "value": value});
  }

  sendReset() {
    socket!.emit("reset");
  }

  disconnect() {
    socket?.dispose();
    Vibration.cancel();
    socket = null;
    connection = false;
    authorized = false;
    Timer.run(() => notifyListeners());
  }
}
