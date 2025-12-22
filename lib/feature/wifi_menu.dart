import 'package:flutter/material.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/feature/tcp_client_manager.dart';

import '../utils.dart';

final TextEditingController ipController = TextEditingController(
  text: '127.0.0.1',
);
final TextEditingController portController = TextEditingController(
  text: '5000',
);

class WiFiMenu extends StatefulWidget {
  const WiFiMenu({super.key});

  @override
  State<WiFiMenu> createState() => _WiFiMenuState();
}

class _WiFiMenuState extends State<WiFiMenu> {
  final TCPClientManager _tcpClient = TCPClientManager();

  bool _isConnected = false;

  @override
  Widget build(BuildContext context) {
    return Column(children: [_wifiConnectionPanel()]);
  }

  Widget _wifiConnectionPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: ipController,
              decoration: const InputDecoration(
                labelText: 'Host/IP',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              enabled: !_isConnected,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              enabled: !_isConnected,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _isConnected ? _disconnect : _connect,
            icon: Icon(_isConnected ? Icons.stop : Icons.play_arrow),
            label: Text(_isConnected ? 'Disconnect' : 'Connect'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isConnected ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _connect() async {
    final host = ipController.text.trim();
    final port = int.tryParse(portController.text.trim());

    if (host.isEmpty || port == null) {
      myUtils.e('Invalid host or port');
      return;
    }

    final success = await _tcpClient.connect(host, port);

    if (success) {
      myUtils.e('Connected to $host:$port');
      setState(() {
        // _messages.clear();
      });
    } else {
      myUtils.e('Connection failed');
    }
  }

  void _disconnect() {
    _tcpClient.disconnect();
    myUtils.log('Disconnected');
  }
}
