library debug_terminal;

import 'package:flutter/material.dart';
import 'src/logic.dart';
import 'src/widgets.dart';
import 'src/config.dart';

export 'src/logic.dart' show DebugLog, ConsoleController;
export 'src/config.dart' show DebugTerminalConfig;
/// Main entry point for the Secure Debug Terminal.
class DebugTerminal {
  static bool _isWrapped = false;

  /// Initializes the terminal with a custom configuration.
  /// 
  /// [Deprecated] Use [DebugTerminal.wrap] instead to configure at the app root.
  @Deprecated("Use DebugTerminal.wrap instead to simplify initialization.")
  static void init({DebugTerminalConfig config = const DebugTerminalConfig()}) {
    ConsoleController.instance.configure(config);
  }

  /// Wraps your application and configures the terminal in one step.
  ///
  /// Place this in your [MaterialApp.builder] at the very root of your app:
  /// ```dart
  /// builder: (context, child) => DebugTerminal.wrap(child!, config: DebugTerminalConfig(pin: 1234))
  /// ```
  static Widget wrap(Widget child, {DebugTerminalConfig? config}) {
    if (!_isWrapped) {
      final _config = config ?? const DebugTerminalConfig();
      ConsoleController.instance.configure(_config);

      if (_config.logUnhandledExceptions) {
        // Catch Flutter Framework errors (build, layout, etc.)
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          logError(
            "Flutter Framework Error",
            error: details.exception,
            stack: details.stack,
            data: details.context?.toString(),
          );
          originalOnError?.call(details);
        };

        // Catch Unhandled Asynchronous errors
        WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
          logError(
            "Unhandled App Error",
            error: error,
            stack: stack,
          );
          return false; // Let the system handle it normally too
        };
      }

      _isWrapped = true;
    }

    return DebugTerminalWrapper(child: child);
  }

  /// Logs a custom message to the console.
  ///
  /// [title] is the name of the log entry.
  /// [group] is an optional category (defaults to "LOG").
  /// [data] is any serializable data to display when expanded.
  static void log(String title, {String group = "LOG", dynamic data}) {
    ConsoleController.instance.log(title, method: group, data: data);
  }

  /// Specialized API log for network traffic.
  ///
  /// [path] The URL path.
  /// [method] The HTTP method (GET, POST, etc).
  /// [body] The request payload.
  /// [query] URL query parameters.
  /// [response] The server response payload.
  /// [code] The HTTP status code.
  static void logApi({
    required String path,
    String method = "GET",
    dynamic body,
    dynamic query,
    dynamic response,
    int? code,
  }) {
    ConsoleController.instance.logApi(
      path: path,
      method: method,
      body: body,
      query: query,
      response: response,
      code: code,
    );
  }

  /// Specialized Error log for capturing exceptions.
  /// 
  /// [message] A brief description of the error.
  /// [error] The actual error object or message.
  /// [stack] The stack trace associated with the error.
  /// [data] Any additional context or metadata.
  static void logError(String message,
      {dynamic error, dynamic stack, dynamic data}) {
    ConsoleController.instance
        .logError(message, error: error, stack: stack, data: data);
  }
}
