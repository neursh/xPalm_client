- No connection:
    - 0 / Client announcement.
    - 1 / Server announcement.

- First byte (Sent by client):
    - 0 / Request connect.
    - 1 / Disconnect.
    - 2 / Action key input, the rest in the data is the button addess.
    - 3 / Joystick key input, the rest in the data is the button addess.
    - 4 / Trigger key input, the rest in the data is the button addess.
    - 5 / Reset controller.
    - 6 / Pong.

- First byte (Sent by server):
    - 0 / Connection rejected, unauthorized.
    - 1 / Authorized.
    - 6 / Ping.
