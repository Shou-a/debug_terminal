import 'package:flutter/material.dart';
import 'package:debug_terminal/debug_terminal.dart';

void main() {
  // No separate init() call needed!
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debug Terminal Example',
      theme: ThemeData.dark(),
      // 1. One-Line Setup: Wrap and configure simultaneously
      builder: (context, child) => DebugTerminal.wrap(
        child!,
        config: const DebugTerminalConfig(
          pin: 2486,
          holdDuration: Duration(seconds: 3),
          openOnTapCount: 4,
          showFloatingButton: true,
          floatingButtonAlignment: Alignment.bottomRight,
          primaryColor: Colors.cyanAccent,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _triggerLogs() {
    DebugTerminal.log("Button Pressed", data: {"id": "main_action"});
    DebugTerminal.logApi(
      path: "/api/v1/user/profile",
      method: "GET",
      query: {"userId": "99"},
      response: {
        "status": "success",
        "data": {"name": "John Doe", "role": "Developer"}
      },
      code: 200,
    );
  }

  void _triggerError() {
    try {
      throw Exception("Simulated connection timeout");
    } catch (e, stack) {
      DebugTerminal.logError("Network Failure", error: e, stack: stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Debug Terminal Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bug_report, size: 80, color: Colors.cyanAccent),
            const SizedBox(height: 24),
            const Text(
              "Access Methods:\n1. Hold (3s)\n2. Quad-Tap Anywhere\n3. Floating Button",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _triggerLogs,
              child: const Text("Generate API Logs"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _triggerError,
              child: const Text("Simulated Error"),
            ),
          ],
        ),
      ),
    );
  }
}
