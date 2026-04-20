# debug_terminal 🛡️

[![pub package](https://img.shields.io/pub/v/debug_terminal.svg)](https://pub.dev/packages/debug_terminal)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**`debug_terminal`** is a high-performance, stealthy, and secure debugging toolkit for Flutter applications. 

Designed for teams that need to inspect API traffic and system logs in production-like environments, it provides a "hidden door" into your app's internals without compromising the user experience or security for regular users.

---

## ✨ The USP: Why debug_terminal?

Most logging tools are either stripped out for production or left dangerously exposed. `debug_terminal` is built differently:

- **🔓 Zero-Friction Development**: By setting `requirePinForShortcut: false`, you get **instant access** via the floating button or quad-tap during development. No PIN entry required when you just want to see your logs!
- **🛡️ Secure Production Inspection**: Unlike other tools, you don't have to remove this from your `release` builds. It remains **stealthily active**, protected by a hidden "Hold" gesture, tactile deterrents, and a secure PIN gate.
- **📡 Specialized Intelligence**: Not just a text dump—specialized views for JSON payloads, API headers, and stack traces.
- **🛠️ One-Line Integration**: Works with any app architecture (GetX, Bloc, Provider, etc.) with zero setup overhead.

---

## 🚀 Activation Strategies

Choose the method that best fits your workflow:

| Method | Description | Security |
| :--- | :--- | :--- |
| **Long Press** | Hold anywhere for 5s (configurable). | ✅ PIN Required |
| **Combo Taps** | Tap quickly N times (e.g., Quad-tap). | ✅ Configurable |
| **Debug Button** | A visible FAB (Debug mode ONLY). | 🔓 Instant Access |

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  debug_terminal: ^1.0.0
```

## 🛠️ Quick Start (One-Step Setup)

You can install and configure the terminal in exactly one step by wrapping your application root (usually in `MaterialApp.builder`):

```dart
import 'package:debug_terminal/debug_terminal.dart';

MaterialApp(
  // ...
  builder: (context, child) => DebugTerminal.wrap(
    child!,
    config: DebugTerminalConfig(
      pin: 1234,                        // Access code
      holdDuration: Duration(seconds: 3), // Secret hold time
      openOnTapCount: 4,                // Open on Quad-tap
      showFloatingButton: true,         // FAB (Debug only)
    ),
  ),
)
```

> [!TIP]
> **Best Practice**: `DebugTerminal.wrap()` should ideally be called **once** at the very root of your application. This ensures consistent logging and a single unified debug overlay.

---

## 📝 Advanced Logging

### Inspecting API Traffic
Perfect for Dio or Http interceptors:

```dart
DebugTerminal.logApi(
  path: "/v1/orders",
  method: "POST",
  body: {"id": 101},
  response: {"status": "shipped"},
  code: 200,
);
```

### Catching Exceptions
Keep track of production crashes:

```dart
try {
  throw "Payment Failed";
} catch (e, stack) {
  DebugTerminal.logError("Checkout Error", error: e, stack: stack);
}
```

---

## 🛡️ Security Model

- **Release Safety**: The floating button and detailed console are automatically gated (hidden) in release mode. Only discrete gestures remain active.
- **Tactile Deterrents**: During the "Hold" activation, the device vibrates with increasing intensity to discourage non-developers from continuing the hold.

---

## ☕ Support the Project

If you find `debug_terminal` helpful and want to support its continued development, you can buy me a coffee!

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/shoua)

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
