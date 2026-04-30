import 'package:flutter/material.dart';
import 'package:debug_terminal/debug_terminal.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'debug_terminal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      builder: (context, child) => DebugTerminal.wrap(
        child!,
        config: const DebugTerminalConfig(
          pin: 2486,
          holdDuration: Duration(seconds: 3),
          openOnTapCount: 4,
          showFloatingButton: true,
          floatingButtonAlignment: Alignment.bottomRight,
          primaryColor: Colors.blue,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logApi() {
    DebugTerminal.logApi(
      path: '/api/v1/user/profile',
      method: 'GET',
      query: {'userId': '99'},
      response: {'name': 'John Doe', 'role': 'Developer'},
      code: 200,
    );
  }

  void _logError() {
    try {
      throw Exception('Simulated connection timeout');
    } catch (e, stack) {
      DebugTerminal.logError('Network failure', error: e, stack: stack);
    }
  }

  void _logMessage() {
    DebugTerminal.log('Button tapped', data: {'screen': 'home'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('debug_terminal'),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Open the console',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Hold anywhere for 3s (duration configurable),\ntap 4 times quickly (tap count configurable),\nor use the button (configurable).',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),
              Text(
                'Generate logs',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _ActionTile(
                label: 'Log a message',
                subtitle: 'DebugTerminal.log()',
                onTap: _logMessage,
              ),
              const SizedBox(height: 10),
              _ActionTile(
                label: 'Simulate API call',
                subtitle: 'GET /api/v1/user/profile → 200',
                onTap: _logApi,
              ),
              const SizedBox(height: 10),
              _ActionTile(
                label: 'Simulate error',
                subtitle: 'Exception: connection timeout',
                onTap: _logError,
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionTile({
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red.shade600 : Colors.blue.shade700;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontFamily: 'monospace')),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
