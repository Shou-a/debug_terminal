import 'package:flutter/material.dart';

/// Configuration for the Debug Terminal.
class DebugTerminalConfig {
  /// The security PIN required to access the console.
  final int pin;

  /// How long the user must hold the screen before the PIN entry appears.
  /// Default is 5 seconds.
  final Duration holdDuration;

  /// Whether to enable haptic feedback deterrents during the hold period.
  final bool enableVibrations;

  /// The primary color used for icons and highlights in the console.
  final Color primaryColor;

  /// Whether to automatically start recording logs upon initialization.
  /// If false, logs will only be recorded after the first successful activation.
  final bool startRecordingImmediately;

  /// The number of quick taps required to open the console (e.g. 3 for triple-tap).
  /// Set to 0 to disable tap-based activation.
  final int openOnTapCount;

  /// Whether to show a visible floating button to open the console.
  /// This button is ONLY visible in debug mode.
  final bool showFloatingButton;

  /// Where to place the floating button on the screen.
  final Alignment floatingButtonAlignment;

  const DebugTerminalConfig(
      {this.pin = 1111,
      this.holdDuration = const Duration(seconds: 5),
      this.enableVibrations = true,
      this.primaryColor = Colors.amberAccent,
      this.startRecordingImmediately = false,
      this.openOnTapCount = 0,
      this.showFloatingButton = true,
      this.floatingButtonAlignment = Alignment.topRight});
}
