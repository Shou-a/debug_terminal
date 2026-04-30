import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'logic.dart';

/// Wraps your application to enable the hidden trigger and debug console.
class DebugTerminalWrapper extends StatelessWidget {
  final Widget child;
  const DebugTerminalWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = ConsoleController.instance;

    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: (details) {
              c.startTimer();
              // Collapse the terminal when the user taps outside its bounds
              if (c.showConsole.value && !c.collapseConsole.value) {
                final rb = c.terminalKey.currentContext?.findRenderObject()
                    as RenderBox?;
                if (rb != null) {
                  final local = rb.globalToLocal(details.globalPosition);
                  if (!rb.paintBounds.contains(local)) {
                    c.collapseTerminal();
                  }
                }
              }
            },
            onTapUp: (_) => c.stopTimer(),
            onTapCancel: () => c.stopTimer(),
            onTap: () => c.handleTap(),
            child: Stack(
              children: [
                child,
                // Floating Action Button (Debug Mode Only)
                if (kDebugMode && c.config.showFloatingButton)
                  Align(
                    alignment: c.config.floatingButtonAlignment,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: c.config.primaryColor,
                        onPressed: () => c.handleActivation(),
                        child:
                            const Icon(Icons.bug_report, color: Colors.black),
                      ),
                    ),
                  ),
                ValueListenableBuilder<bool>(
                  valueListenable: c.showPinEntry,
                  builder: (context, show, _) {
                    if (show) return const PinEntryOverlay();
                    return const SizedBox.shrink();
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: c.showConsole,
                  builder: (context, show, _) {
                    if (show) {
                      return const DraggableConsole(
                        child: TerminalView(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DraggableConsole extends StatefulWidget {
  final Widget child;
  const DraggableConsole({super.key, required this.child});

  @override
  State<DraggableConsole> createState() => _DraggableConsoleState();
}

class _DraggableConsoleState extends State<DraggableConsole> {
  double top = 100;
  double left = 16;
  double width = 340;
  double height = 300;
  bool collapsed = false;
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    ConsoleController.instance.collapseConsole.addListener(_onCollapseChanged);
  }

  @override
  void dispose() {
    ConsoleController.instance.collapseConsole
        .removeListener(_onCollapseChanged);
    super.dispose();
  }

  void _onCollapseChanged() {
    final shouldCollapse = ConsoleController.instance.collapseConsole.value;
    if (shouldCollapse && !collapsed) {
      setState(() => collapsed = true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      final sw = MediaQuery.of(context).size.width;
      width = sw * 0.95;
      left = (sw - width) / 2; // center horizontally
      initialized = true;
    }
  }

  void _clamp() {
    final size = MediaQuery.of(context).size;
    left = left.clamp(0, size.width - width);
    top = top.clamp(0, size.height - (collapsed ? 48 : height));
  }

  @override
  Widget build(BuildContext context) {
    _clamp();
    final border = BorderRadius.circular(12);

    return Positioned(
      top: top,
      left: left,
      width: width,
      child: Material(
        key: ConsoleController.instance.terminalKey,
        elevation: 8,
        borderRadius: border,
        color: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: collapsed ? 48 : height,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withAlpha(240),
            borderRadius: border,
            border: Border.all(color: Colors.white10),
            boxShadow: const [BoxShadow(blurRadius: 15, color: Colors.black54)],
          ),
          child: Stack(
            children: [
              GestureDetector(
                onPanUpdate: (d) => setState(() {
                  left += d.delta.dx;
                  top += d.delta.dy;
                }),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(12),
                    borderRadius: BorderRadius.vertical(top: border.topLeft),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.drag_indicator,
                          size: 18,
                          color:
                              ConsoleController.instance.config.primaryColor),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Debug Console",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                            collapsed ? Icons.unfold_more : Icons.unfold_less,
                            size: 18,
                            color:
                                ConsoleController.instance.config.primaryColor),
                        onPressed: () => setState(() {
                          collapsed = !collapsed;
                          // sync notifier so barrier re-collapse works next time
                          ConsoleController.instance.collapseConsole.value =
                              collapsed;
                        }),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.red[300],
                        ),
                        onPressed: () =>
                            ConsoleController.instance.toggleConsole(),
                      ),
                    ],
                  ),
                ),
              ),
              if (!collapsed)
                Positioned.fill(
                  top: 44,
                  bottom:
                      28, // clears the resize handle (4px offset + 8px padding + 16px icon)
                  child: widget.child,
                ),
              if (!collapsed)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onPanUpdate: (d) => setState(() {
                        width = (width + d.delta.dx)
                            .clamp(200.0, MediaQuery.of(context).size.width);
                        height = (height + d.delta.dy).clamp(
                            120.0, MediaQuery.of(context).size.height * 0.9);
                      }),
                      child: Transform.scale(
                        scaleX: -1,
                        child: Icon(Icons.open_in_full,
                            size: 16,
                            color:
                                ConsoleController.instance.config.primaryColor),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TerminalView extends StatefulWidget {
  const TerminalView({super.key});

  @override
  State<TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends State<TerminalView> {
  final _scroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    final c = ConsoleController.instance;

    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (c.autoScrollLogs.value && _scroll.hasClients) {
            _scroll.jumpTo(_scroll.position.maxScrollExtent);
          }
        });

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text("System Logs",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: c.autoScrollLogs,
                      builder: (context, auto, _) => IconButton(
                        icon: Icon(auto ? Icons.swap_vert : Icons.swipe_down,
                            size: 16,
                            color:
                                auto ? c.config.primaryColor : Colors.white38),
                        onPressed: c.toggleAutoScroll,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.delete_outline,
                          size: 16, color: Colors.red[300]),
                      onPressed: c.clearLogs,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white10),
              Expanded(
                child: ListView.separated(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: c.logs.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Colors.white10),
                  itemBuilder: (_, i) => LogEntryWidget(log: c.logs[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LogEntryWidget extends StatefulWidget {
  final DebugLog log;
  const LogEntryWidget({super.key, required this.log});

  @override
  State<LogEntryWidget> createState() => _LogEntryWidgetState();
}

class _LogEntryWidgetState extends State<LogEntryWidget> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final status = widget.log.statusCode;
    final primaryColor = ConsoleController.instance.config.primaryColor;

    final color = status == null
        ? Colors.grey
        : (status < 300
            ? Colors.greenAccent
            : (status >= 400 ? Colors.red[300] : Colors.amberAccent));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => expanded = !expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Text(
                    "${widget.log.timestamp.hour}:${widget.log.timestamp.minute}",
                    style: const TextStyle(color: Colors.white38, fontSize: 9)),
                const SizedBox(width: 8),
                Text(widget.log.method,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(widget.log.path,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12))),
                if (status != null) ...[
                  const SizedBox(width: 4),
                  Text(status.toString(),
                      style: TextStyle(color: color, fontSize: 12)),
                ],
                Icon(expanded ? Icons.expand_less : Icons.expand_more,
                    size: 14, color: Colors.white30),
              ],
            ),
          ),
        ),
        if (expanded) _buildExpandedBody(context, primaryColor),
      ],
    );
  }

  Widget _buildExpandedBody(BuildContext context, Color primaryColor) {
    final log = widget.log;
    // A plain log is any entry created via log() — it has no statusCode.
    // API logs (logApi/logError) always have a statusCode set.
    final isPlainLog = log.statusCode == null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      color: Colors.white.withAlpha(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPlainLog && log.requestBody != null)
            _buildSection(context,
                label: 'DATA',
                labelColor: primaryColor,
                content: _prettyJson(log.requestBody),
                contentColor: Colors.white70),
          if (!isPlainLog) ...[
            if (log.queryParams != null)
              _buildSection(context,
                  label: 'QUERY PARAMS',
                  labelColor: primaryColor,
                  content: _prettyJson(log.queryParams),
                  contentColor: Colors.white70),
            if (log.requestBody != null)
              _buildSection(context,
                  label: 'REQUEST BODY',
                  labelColor: primaryColor,
                  content: _prettyJson(log.requestBody),
                  contentColor: Colors.white70),
            if (log.responseBody != null)
              _buildSection(context,
                  label: 'RESPONSE BODY',
                  labelColor: Colors.greenAccent,
                  content: _prettyJson(log.responseBody),
                  contentColor: Colors.white70),
            if (log.errorMessage != null)
              _buildSection(context,
                  label: 'ERROR',
                  labelColor: Colors.redAccent,
                  content: log.errorMessage!,
                  contentColor: Colors.redAccent),
            if (log.stackTrace != null)
              _buildSection(context,
                  label: 'STACK TRACE',
                  labelColor: Colors.grey,
                  content: log.stackTrace!,
                  contentColor: Colors.white38),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String label,
    required Color labelColor,
    required String content,
    required Color contentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$label:',
                style: TextStyle(
                    color: labelColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _copyToClipboard(context, label, content),
                child: Tooltip(
                  message: 'Copy $label',
                  child: Icon(Icons.copy_outlined,
                      size: 15, color: labelColor.withAlpha(180)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(content,
              style: TextStyle(
                  color: contentColor, fontSize: 11, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String label, String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF2A2A2A),
      ),
    );
  }

  String _prettyJson(dynamic data) {
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}

class PinEntryOverlay extends StatefulWidget {
  const PinEntryOverlay({super.key});

  @override
  State<PinEntryOverlay> createState() => _PinEntryOverlayState();
}

class _PinEntryOverlayState extends State<PinEntryOverlay> {
  String pin = "";

  void _add(String d) {
    final len = ConsoleController.instance.pinLength;
    if (pin.length < len) {
      if (ConsoleController.instance.config.enableVibrations) {
        HapticFeedback.lightImpact();
      }
      setState(() => pin += d);
      if (pin.length == len) {
        Future.delayed(const Duration(milliseconds: 200),
            () => ConsoleController.instance.verifyPin(pin));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = ConsoleController.instance.config.primaryColor;

    return Material(
      color: Colors.black87,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_person_outlined, color: primaryColor, size: 40),
                const SizedBox(height: 12),
                const Text("Protected Access",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                const SizedBox(height: 4),
                const Text("Enter Security PIN",
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      ConsoleController.instance.pinLength,
                      (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i < pin.length
                                  ? primaryColor
                                  : Colors.white10,
                            ),
                          )),
                ),
                const SizedBox(height: 32),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12),
                  itemCount: 12,
                  itemBuilder: (context, i) {
                    if (i == 9) return const SizedBox.shrink();
                    if (i == 10) return _key("0");
                    if (i == 11) {
                      return IconButton(
                          icon: const Icon(Icons.backspace,
                              color: Colors.white54),
                          onPressed: () => setState(() => pin = pin.isNotEmpty
                              ? pin.substring(0, pin.length - 1)
                              : ""));
                    }
                    return _key((i + 1).toString());
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                    onPressed: () =>
                        ConsoleController.instance.showPinEntry.value = false,
                    child: const Text("Cancel",
                        style: TextStyle(color: Colors.white38))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _key(String d) => InkWell(
        onTap: () => _add(d),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(12)),
          child: Text(d,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
      );
}
