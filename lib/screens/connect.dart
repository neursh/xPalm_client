import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import '../client_provider.dart';
import 'manual_connect.dart';
import 'enter_pin.dart';

class Connect extends StatefulWidget {
  const Connect({super.key});

  @override
  State<StatefulWidget> createState() => _ConnectState();
}

class _ConnectState extends State<Connect> {
  late ClientProvider clientProvider;
  ServersMulticast serverSearch = ServersMulticast();

  @override
  void initState() {
    try {
      clientProvider.disconnect();
    } catch (_) {}
    serverSearch.bind();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    clientProvider = Provider.of<ClientProvider>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    serverSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("xPalm Client"),
        actions: [
          IconButton(
              onPressed: () => showModalBottomSheet(
                    isScrollControlled: true,
                    showDragHandle: true,
                    isDismissible: false,
                    enableDrag: false,
                    context: context,
                    builder: (context) => const PopScope(
                      canPop: false,
                      child: ManualConnect(),
                    ),
                  ),
              icon: const Icon(Icons.sync_alt))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          serverSearch.dispose();
          serverSearch.bind();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ValueListenableBuilder(
          builder: (context, sv, __) => ListView.builder(
            itemBuilder: (context, index) => InkWell(
              onTap: () => showModalBottomSheet(
                showDragHandle: true,
                isDismissible: false,
                enableDrag: false,
                context: context,
                builder: (context) => PopScope(
                  canPop: false,
                  child: EnterPin(
                    ip: sv[index].ip.address,
                    port: 45784,
                    name: sv[index].name,
                  ),
                ),
              ),
              child: ListTile(
                leading: const Icon(Icons.laptop_windows),
                title: Text(sv[index].name),
                subtitle: Text(sv[index].ip.address),
                trailing: const Icon(Icons.link),
              ),
            ),
            itemCount: sv.length,
          ),
          valueListenable: serverSearch.serversList,
        ),
      ),
    );
  }
}

class ServersMulticast {
  late RawDatagramSocket socket;
  InternetAddress multicastGroup = InternetAddress("224.3.29.115");
  int port = 45783;

  ListNotifier serversList = ListNotifier();
  late Timer sendTask;

  MethodChannel mutlcastLock =
      const MethodChannel("udp.neurs.click/multicast_lock");

  bind() async {
    if (Platform.isAndroid) {
      await mutlcastLock.invokeMethod<bool>("acquire");
    }

    socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    socket.joinMulticast(multicastGroup);
    socket.readEventsEnabled = true;

    const utf8 = Utf8Codec();
    socket.listen(
      (RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket.receive();
          if (datagram != null && socket.address != datagram.address) {
            final message = String.fromCharCodes(datagram.data);
            if (message.startsWith("xpalm::server::")) {
              final serverInfo = ServerInfo(
                  name: message.split("::")[2], ip: datagram.address);
              if (serversList.value.firstWhereOrNull((element) =>
                      element.ip.address == serverInfo.ip.address) ==
                  null) {
                serversList.add(ServerInfo(
                    name: message.split("::")[2], ip: datagram.address));
              }
            }
          }
        }
      },
    );

    socket.send(utf8.encode("xpalm::client"), multicastGroup, port);
    sendTask = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        socket.send(utf8.encode("xpalm::client"), multicastGroup, port);
      },
    );
  }

  dispose() async {
    sendTask.cancel();
    serversList.clear();

    if (Platform.isAndroid) {
      await mutlcastLock.invokeMethod<bool>("release");
    }
    socket.close();
  }
}

class ServerInfo {
  final String name;
  final InternetAddress ip;

  ServerInfo({required this.name, required this.ip});
}

class ListNotifier extends ValueNotifier<List<ServerInfo>> {
  ListNotifier() : super([]);

  void add(ServerInfo listItem) {
    value.add(listItem);
    notifyListeners();
  }

  void clear() {
    value.clear();
    notifyListeners();
  }
}
