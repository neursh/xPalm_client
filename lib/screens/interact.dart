import 'dart:async';
import 'package:flutter/material.dart';
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
        body: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: JoyStickCustom(
                  position: JoystickPosition.left_joystick,
                ),
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: JoyStickCustom(
                  position: JoystickPosition.right_joystick,
                  showArea: false,
                  divisionFactor: 5,
                ),
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: KeyPadButton(
                    input: KeyPad.XUSB_GAMEPAD_LEFT_THUMB,
                    height: 30,
                    width: 30,
                    borderRadius: 15,
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: KeyPadButton(
                    input: KeyPad.XUSB_GAMEPAD_RIGHT_THUMB,
                    height: 30,
                    width: 30,
                    borderRadius: 15,
                  ),
                ),
              ),
              Positioned(
                bottom: screen.height / 2.5 + screen.height / 15 + 10,
                left: screen.height / 15 + 5,
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  KeyPadButton(
                    height: 70,
                    width: 70,
                    input: Trigger.left_trigger,
                    text: "LT",
                  ),
                  SizedBox(width: 16),
                  KeyPadButton(
                    height: 70,
                    width: 70,
                    input: KeyPad.XUSB_GAMEPAD_LEFT_SHOULDER,
                    text: "LB",
                  ),
                ]),
              ),
              Positioned(
                bottom: screen.height / 2.5 + screen.height / 15 + 70,
                right: screen.height / 15 + 10,
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  KeyPadButton(
                    height: 70,
                    width: 70,
                    input: Trigger.right_trigger,
                    text: "RT",
                  ),
                  SizedBox(width: 16),
                  KeyPadButton(
                    height: 70,
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
                            Icons.web_asset,
                          ),
                        ),
                        SizedBox(width: 32),
                        Image(
                          image: AssetImage("assets/logo.png"),
                          width: 60,
                          height: 60,
                        ),
                        SizedBox(width: 32),
                        KeyPadButton(
                          height: 32,
                          width: 32,
                          input: KeyPad.XUSB_GAMEPAD_START,
                          icon: Icon(
                            Icons.menu,
                          ),
                        ),
                      ]),
                ),
              ),
              Positioned(
                left: screen.height / 2.5 + screen.height / 15 + 10,
                bottom: screen.height / 15,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KeyPadButton(
                      height: 60,
                      width: 60,
                      input: KeyPad.XUSB_GAMEPAD_DPAD_UP,
                      text: "↑",
                    ),
                    SizedBox(width: 12),
                    KeyPadButton(
                      height: 60,
                      width: 60,
                      input: KeyPad.XUSB_GAMEPAD_DPAD_LEFT,
                      text: "←",
                    ),
                    SizedBox(width: 12),
                    KeyPadButton(
                      height: 60,
                      width: 60,
                      input: KeyPad.XUSB_GAMEPAD_DPAD_RIGHT,
                      text: "→",
                    ),
                    SizedBox(width: 12),
                    KeyPadButton(
                      height: 60,
                      width: 60,
                      input: KeyPad.XUSB_GAMEPAD_DPAD_DOWN,
                      text: "↓",
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(screen.height / 15),
                  child: KeyPadButton(
                    height: screen.height / 3,
                    width: screen.height / 3,
                    borderRadius: screen.height / 3,
                    input: KeyPad.XUSB_GAMEPAD_A,
                    color: Colors.green,
                    strength: 15,
                    text: "A",
                  ),
                ),
              ),
              Positioned(
                right: screen.height / 3 - screen.height / 15 - 60,
                bottom: screen.height / 3 + screen.height / 15 + 10,
                child: const KeyPadButton(
                  height: 70,
                  width: 70,
                  borderRadius: 35,
                  input: KeyPad.XUSB_GAMEPAD_B,
                  color: Colors.red,
                  text: "B",
                ),
              ),
              Positioned(
                right: screen.height / 3 - screen.height / 15 + 45,
                bottom: screen.height / 3 + screen.height / 15 - 35,
                child: const KeyPadButton(
                  height: 70,
                  width: 70,
                  borderRadius: 35,
                  input: KeyPad.XUSB_GAMEPAD_Y,
                  color: Colors.yellow,
                  text: "Y",
                ),
              ),
              Positioned(
                right: screen.height / 3 - screen.height / 15 + 60,
                bottom: screen.height / 15,
                child: const KeyPadButton(
                  height: 70,
                  width: 70,
                  borderRadius: 35,
                  input: KeyPad.XUSB_GAMEPAD_X,
                  color: Colors.blue,
                  text: "X",
                ),
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: PingDisplay(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JoyStickCustom extends StatefulWidget {
  final JoystickPosition position;
  final bool showArea;
  final double divisionFactor;

  const JoyStickCustom(
      {super.key,
      required this.position,
      this.showArea = true,
      this.divisionFactor = 2.5});

  @override
  State<StatefulWidget> createState() => _JoyStickCustomState();
}

class _JoyStickCustomState extends State<JoyStickCustom> {
  Offset? beginPan;
  bool _isOnCooldown = false;

  double clamp(double value, double clampMin, double clampMax) {
    if (value <= clampMin) {
      return clampMin;
    }
    if (value >= clampMax) {
      return clampMax;
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;

    return Consumer<ClientProvider>(
        builder: (context, clientProvider, _) => GestureDetector(
              onPanDown: (details) => setState(() {
                beginPan = details.localPosition;
              }),
              onPanUpdate: (details) {
                if (!_isOnCooldown) {
                  double currentX = (details.localPosition.dx - beginPan!.dx) /
                      (screen.height / (widget.divisionFactor * 2));
                  double currentY = (details.localPosition.dy - beginPan!.dy) /
                      (screen.height / (widget.divisionFactor * 2));

                  currentX = clamp(currentX, -1, 1);
                  currentY = clamp(currentY, -1, 1);

                  clientProvider.sendJoystick(widget.position,
                      (currentX * 32767).floor(), (-currentY * 32767).floor());

                  _isOnCooldown = true;
                  Future.delayed(const Duration(milliseconds: 15),
                      () => _isOnCooldown = false);
                }
              },
              onPanEnd: (_) => setState(() {
                beginPan = null;

                clientProvider.sendJoystick(widget.position, 0, 0);
              }),
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                height: screen.height,
                width: screen.width / 2,
                child: Stack(
                  children: [
                    Positioned(
                      bottom: beginPan != null
                          ? screen.height -
                              beginPan!.dy -
                              screen.height / (widget.divisionFactor * 2)
                          : screen.height / 15,
                      left: widget.position == JoystickPosition.left_joystick
                          ? beginPan != null
                              ? beginPan!.dx -
                                  screen.height / (widget.divisionFactor * 2)
                              : screen.height / 15
                          : null,
                      right: widget.position == JoystickPosition.right_joystick
                          ? beginPan != null
                              ? -beginPan!.dx +
                                  screen.height / widget.divisionFactor * 2
                              : screen.height / 15
                          : null,
                      child: Container(
                        width: screen.height / widget.divisionFactor,
                        height: screen.height / widget.divisionFactor,
                        decoration: BoxDecoration(
                            border: widget.showArea
                                ? Border.all(color: Colors.white)
                                : null,
                            borderRadius: BorderRadius.circular(
                                screen.height / widget.divisionFactor)),
                      ),
                    )
                  ],
                ),
              ),
            ));
  }
}

class KeyPadButton extends StatelessWidget {
  final Icon? icon;
  final String? text;
  final dynamic input;
  final double height;
  final double width;
  final Color? color;
  final double? borderRadius;
  final int strength;
  const KeyPadButton({
    super.key,
    required this.input,
    required this.height,
    required this.width,
    this.icon,
    this.text,
    this.color,
    this.borderRadius,
    this.strength = 5,
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
          Vibration.vibrate(duration: strength);
        },
        onPointerUp: (_) => input.runtimeType == KeyPad
            ? clientProvider.sendKey(KeyAction.release, input)
            : clientProvider.sendTrigger(input, 0),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            border: Border.all(color: color ?? scheme.primary),
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
          child: Stack(children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                text ?? "",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
