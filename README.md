# debug_terminal

[![pub package](https://img.shields.io/pub/v/debug_terminal.svg)](https://pub.dev/packages/debug_terminal)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A floating debug console for Flutter apps. Inspect API traffic and logs at runtime — in debug or release builds — without modifying your UI or hardwiring log calls to a visible widget.

<table>
  <tr>
    <td align="center"><b>Debug mode</b></td>
    <td align="center"><b>Release mode</b></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/shou-a/debug_terminal/master/screenshots/debug_demo.gif" width="280"/></td>
    <td><img src="https://raw.githubusercontent.com/shou-a/debug_terminal/master/screenshots/release_demo.gif" width="280"/></td>
  </tr>
</table>

---

## What it does

- Shows a draggable, resizable overlay panel with your log entries
- Supports three ways to open it: long press, tap combo, or a floating button (debug only)
- PIN-gates the console so it's safe to leave in release builds
- In debug builds the PIN is bypassed automatically — no config needed

---

## Installation

```yaml
dependencies:
  debug_terminal: ^1.1.0
```

---

## Setup

Wrap your app (typically in `MaterialApp.builder`) once:

```dart
import 'package:debug_terminal/debug_terminal.dart';

MaterialApp(
  builder: (context, child) => DebugTerminal.wrap(
    child!,
    config: DebugTerminalConfig(
      pin: 1234,
      holdDuration: Duration(seconds: 3),
      openOnTapCount: 4,
      showFloatingButton: true,
    ),
  ),
)
```

That's all the setup required. Wrap it once at the root and you can log from anywhere in the app.

> **Note:** By default, `logUnhandledExceptions: true` — the package hooks into `FlutterError.onError` and `platformDispatcher.onError` to automatically capture crashes. Set it to `false` if you handle those yourself.

---

## How to open the console

| Method | Behavior |
| :--- | :--- |
| Long press | Hold anywhere on screen for the configured duration |
| Tap combo | Tap quickly N times in a row (e.g. 4 taps) |
| Floating button | Visible FAB — debug builds only, PIN-free |

---

## Logging

**General logs**

```dart
DebugTerminal.log("User tapped checkout", data: {"itemId": 42});
```

**API requests** — good to use inside Dio/Http interceptors:

```dart
DebugTerminal.logApi(
  path: "/v1/orders",
  method: "POST",
  body: {"id": 101},
  response: {"status": "shipped"},
  code: 200,
);
```

**Errors and exceptions:**

```dart
try {
  throw "Payment Failed";
} catch (e, stack) {
  DebugTerminal.logError("Checkout error", error: e, stack: stack);
}
```

Each log entry is expandable and shows request body, response, query params, and stack trace where applicable. Individual sections have a copy button.

---

## Security

The floating button only renders in `kDebugMode`. In release builds only the gesture triggers work, and they require the PIN. The hold gesture also fires haptic pulses as a deterrent for accidental activation.

---

## License

MIT — see [LICENSE](LICENSE).
