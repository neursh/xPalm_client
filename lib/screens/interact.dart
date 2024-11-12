import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:vibration/vibration.dart';
import '../client_provider.dart';
import 'package:provider/provider.dart';

class Interact extends StatefulWidget {
  final String name;
  const Interact({
    super.key,
    required this.name,
  });

  @override
  State<StatefulWidget> createState() => _InteractState();
}

class _InteractState extends State<Interact> {
  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Stack(children: [
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 80),
                child: Image(
                  image: AssetImage("assets/logo.png"),
                  width: 60,
                  height: 60,
                ),
              ),
            ),
            const Align(
              alignment: Alignment.topLeft,
              child: Column(children: [
                KeyPadButton(
                  height: 80,
                  width: 70,
                  input: Trigger.left_trigger,
                  text: "LT",
                ),
                SizedBox(height: 16),
                KeyPadButton(
                  height: 80,
                  width: 70,
                  input: KeyPad.XUSB_GAMEPAD_LEFT_SHOULDER,
                  text: "LB",
                ),
              ]),
            ),
            const Align(
              alignment: Alignment.topRight,
              child: Column(children: [
                KeyPadButton(
                  height: 80,
                  width: 70,
                  input: Trigger.right_trigger,
                  text: "RT",
                ),
                SizedBox(height: 16),
                KeyPadButton(
                  height: 80,
                  width: 70,
                  input: KeyPad.XUSB_GAMEPAD_RIGHT_SHOULDER,
                  text: "RB",
                )
              ]),
            ),
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 32),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      KeyPadButton(
                        height: 32,
                        width: 32,
                        input: KeyPad.XUSB_GAMEPAD_BACK,
                        icon: Icon(
                          Icons.chevron_left,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 48),
                      KeyPadButton(
                        height: 32,
                        width: 32,
                        input: KeyPad.XUSB_GAMEPAD_START,
                        icon: Icon(
                          Icons.chevron_right,
                          color: Colors.black,
                        ),
                      ),
                    ]),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(
                    left: 70 + screen.width / 20, top: screen.height / 5),
                child: const JoystickAttach(
                  position: JoystickPosition.left_joystick,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(
                    right: 70 + screen.width / 6, bottom: screen.height / 8),
                child: const JoystickAttach(
                  position: JoystickPosition.right_joystick,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.only(
                    left: 70 + screen.width / 6, bottom: screen.height / 15),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KeyPadButton(
                      height: 60,
                      width: 60,
                      input: KeyPad.XUSB_GAMEPAD_DPAD_UP,
                    ),
                    SizedBox(height: 7),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          KeyPadButton(
                            height: 60,
                            width: 60,
                            input: KeyPad.XUSB_GAMEPAD_DPAD_LEFT,
                          ),
                          SizedBox(width: 74),
                          KeyPadButton(
                            height: 60,
                            width: 60,
                            input: KeyPad.XUSB_GAMEPAD_DPAD_RIGHT,
                          ),
                        ]),
                    SizedBox(height: 7),
                    KeyPadButton(
                      height: 60,
                      width: 60,
                      input: KeyPad.XUSB_GAMEPAD_DPAD_DOWN,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(
                    right: 70 + screen.width / 20, top: screen.height / 15),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KeyPadButton(
                      height: 60,
                      width: 60,
                      input: KeyPad.XUSB_GAMEPAD_Y,
                      color: Colors.yellow,
                      text: "Y",
                    ),
                    SizedBox(height: 7),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          KeyPadButton(
                            height: 60,
                            width: 60,
                            input: KeyPad.XUSB_GAMEPAD_X,
                            color: Colors.blue,
                            text: "X",
                          ),
                          SizedBox(width: 74),
                          KeyPadButton(
                            height: 60,
                            width: 60,
                            input: KeyPad.XUSB_GAMEPAD_B,
                            color: Colors.red,
                            text: "B",
                          ),
                        ]),
                    SizedBox(height: 7),
                    KeyPadButton(
                      height: 60,
                      width: 60,
                      input: KeyPad.XUSB_GAMEPAD_A,
                      color: Colors.green,
                      text: "A",
                    ),
                  ],
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: PingDisplay(),
            ),
          ]),
        ),
      ),
    );
  }
}

class JoystickAttach extends StatelessWidget {
  final JoystickPosition position;
  const JoystickAttach({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    Timer? sendClick;

    return Consumer<ClientProvider>(
      builder: (context, clientProvider, _) => GestureDetector(
        onPanEnd: (_) {
          sendClick?.cancel();
          clientProvider.sendKey(
              KeyAction.release,
              position == JoystickPosition.left_joystick
                  ? KeyPad.XUSB_GAMEPAD_LEFT_THUMB
                  : KeyPad.XUSB_GAMEPAD_RIGHT_THUMB);
        },
        onPanCancel: () {
          sendClick?.cancel();
          clientProvider.sendKey(
              KeyAction.release,
              position == JoystickPosition.left_joystick
                  ? KeyPad.XUSB_GAMEPAD_LEFT_THUMB
                  : KeyPad.XUSB_GAMEPAD_RIGHT_THUMB);
        },
        onPanDown: (_) => {
          sendClick = Timer(const Duration(seconds: 2), () {
            clientProvider.sendKey(
                KeyAction.press,
                position == JoystickPosition.left_joystick
                    ? KeyPad.XUSB_GAMEPAD_LEFT_THUMB
                    : KeyPad.XUSB_GAMEPAD_RIGHT_THUMB);
            Vibration.vibrate(duration: 5);
          })
        },
        child: Joystick(
          stick: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(90)),
          ),
          base: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(500),
            ),
          ),
          period: const Duration(milliseconds: 10),
          listener: (details) => clientProvider.sendJoystick(position,
              (details.x * 32767).floor(), (-details.y * 32767).floor()),
        ),
      ),
    );
  }
}

class KeyPadButton extends StatelessWidget {
  final Icon? icon;
  final String? text;
  final dynamic input;
  final double height;
  final double width;
  final Color? color;
  const KeyPadButton({
    super.key,
    required this.input,
    required this.height,
    required this.width,
    this.icon,
    this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme scheme = Theme.of(context).colorScheme;

    return Consumer<ClientProvider>(
      builder: (context, clientProvider, _) => Listener(
        onPointerDown: (_) {
          input.runtimeType == KeyPad
              ? clientProvider.sendKey(KeyAction.press, input)
              : clientProvider.sendTrigger(input, 1);
          Vibration.vibrate(duration: 5);
        },
        onPointerUp: (_) => input.runtimeType == KeyPad
            ? clientProvider.sendKey(KeyAction.release, input)
            : clientProvider.sendTrigger(input, 0),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: color ?? scheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                text ?? "",
                style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: icon ?? Container(),
            ),
          ]),
        ),
      ),
    );
  }
}

class PingDisplay extends StatelessWidget {
  const PingDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientProvider>(
        builder: (context, clientProvider, _) =>
            Text("${clientProvider.ping}ms"));
  }
}
