import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'config.dart';

/// Represents a single debug log entry.
class DebugLog {
  final String id;
  final String method;
  final String path;
  final dynamic requestBody;
  final dynamic queryParams;
  final dynamic responseBody;
  final int? statusCode;
  final DateTime timestamp;
  final String? errorMessage;
  final String? stackTrace;

  DebugLog({
    required this.id,
    required this.method,
    required this.path,
    this.requestBody,
    this.queryParams,
    this.responseBody,
    this.statusCode,
    required this.timestamp,
    this.errorMessage,
    this.stackTrace,
  });

  DebugLog copyWith({
    dynamic responseBody,
    int? statusCode,
    String? errorMessage,
    String? stackTrace,
  }) {
    return DebugLog(
      id: id,
      method: method,
      path: path,
      requestBody: requestBody,
      queryParams: queryParams,
      responseBody: responseBody ?? this.responseBody,
      statusCode: statusCode ?? this.statusCode,
      timestamp: timestamp,
      errorMessage: errorMessage ?? this.errorMessage,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
}

/// Manages the state of the debug console.
class ConsoleController extends ChangeNotifier {
  static final ConsoleController instance = ConsoleController._();
  ConsoleController._();

  DebugTerminalConfig _config = const DebugTerminalConfig();

  final List<DebugLog> _logs = [];
  List<DebugLog> get logs => List.unmodifiable(_logs);

  final ValueNotifier<bool> showConsole = ValueNotifier(false);
  final ValueNotifier<bool> showPinEntry = ValueNotifier(false);
  final ValueNotifier<bool> autoScrollLogs = ValueNotifier(true);
  final ValueNotifier<bool> isRecording = ValueNotifier(false);

  final List<Timer> _timers = [];

  DebugTerminalConfig get config => _config;
  int get pinLength => _config.pin.toString().length;

  int _tapCount = 0;
  Timer? _tapResetTimer;

  void configure(DebugTerminalConfig config) {
    _config = config;
    if (config.startRecordingImmediately) {
      isRecording.value = true;
    }
  }

  void handleTap() {
    if (_config.openOnTapCount <= 0) return;

    _tapCount++;
    _tapResetTimer?.cancel();
    _tapResetTimer = Timer(const Duration(milliseconds: 400), () {
      _tapCount = 0;
    });

    if (_tapCount >= _config.openOnTapCount) {
      _tapCount = 0;
      handleActivation();
    }
  }

  void handleActivation() {
    isRecording.value = true;
    final effectivelyBypass = kDebugMode;

    if (effectivelyBypass) {
      showPinEntry.value = false;
      showConsole.value = true;
    } else {
      if (showConsole.value) {
        toggleConsole();
      } else {
        showPinEntry.value = true;
      }
    }
    notifyListeners();
  }

  void addLog(DebugLog log) {
    if (!isRecording.value) return; // Only log if activated
    _logs.add(log);
    notifyListeners();
  }

  /// General generic log
  void log(String title, {String method = "LOG", dynamic data}) {
    addLog(DebugLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      method: method,
      path: title,
      requestBody: data,
      timestamp: DateTime.now(),
    ));
  }

  /// Specialized API log
  void logApi({
    required String path,
    String method = "GET",
    dynamic body,
    dynamic query,
    dynamic response,
    int? code,
  }) {
    addLog(DebugLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      method: method,
      path: path,
      requestBody: body,
      queryParams: query,
      responseBody: response,
      statusCode: code,
      timestamp: DateTime.now(),
    ));
  }

  /// Specialized Error log
  void logError(String message, {dynamic error, dynamic stack, dynamic data}) {
    addLog(DebugLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      method: "ERROR",
      path: message,
      requestBody: data,
      errorMessage: error?.toString(),
      stackTrace: stack?.toString(),
      statusCode: 500, // Visual hint for errors
      timestamp: DateTime.now(),
    ));
  }

  void updateLog(String id, {dynamic responseBody, int? statusCode}) {
    final index = _logs.indexWhere((l) => l.id == id);
    if (index != -1) {
      _logs[index] = _logs[index].copyWith(
        responseBody: responseBody,
        statusCode: statusCode,
      );
      notifyListeners();
    }
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  void startTimer() {
    _stopAllTimers();

    final duration = _config.holdDuration;

    // Dynamic deterrent sequence
    if (_config.enableVibrations) {
      _timers.add(Timer(duration * 0.5, () => HapticFeedback.heavyImpact()));
      _timers.add(Timer(duration * 0.75, () => HapticFeedback.heavyImpact()));
      _timers.add(Timer(duration * 0.9, () => HapticFeedback.heavyImpact()));
    }

    _timers.add(Timer(duration, () {
      handleActivation();
    }));
  }

  void stopTimer() => _stopAllTimers();

  void _stopAllTimers() {
    for (var t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  void toggleConsole() {
    showConsole.value = !showConsole.value;
  }

  void toggleAutoScroll() {
    autoScrollLogs.value = !autoScrollLogs.value;
  }

  bool verifyPin(String pin) {
    if (pin == _config.pin.toString()) {
      showPinEntry.value = false;
      showConsole.value = true;
      return true;
    }
    showPinEntry.value = false;
    return false;
  }
}
