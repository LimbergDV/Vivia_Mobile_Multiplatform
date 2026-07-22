import 'dart:async';

import 'package:flutter/material.dart';

enum AppAlertType { success, error, info, warning }

class AppAlert {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    AppAlertType type = AppAlertType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _AppAlertView(
        message: message,
        title: title,
        type: type,
        duration: duration,
        onDismiss: entry.remove,
      ),
    );
    overlay.insert(entry);
  }

  static void success(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) =>
      show(
        context,
        message: message,
        title: title,
        type: AppAlertType.success,
        duration: duration,
      );

  static void error(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) =>
      show(
        context,
        message: message,
        title: title,
        type: AppAlertType.error,
        duration: duration,
      );
}

class _AppAlertView extends StatefulWidget {
  final String message;
  final String? title;
  final AppAlertType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _AppAlertView({
    required this.message,
    required this.title,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_AppAlertView> createState() => _AppAlertViewState();
}

class _AppAlertViewState extends State<_AppAlertView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _timer?.cancel();
    _controller.reverse().then((_) => widget.onDismiss());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: slide,
        child: FadeTransition(
          opacity: _controller,
          child: _Card(data: widget, onTap: _dismiss),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final _AppAlertView data;
  final VoidCallback onTap;
  const _Card({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final background = _background(scheme);
    final foreground = _foreground(scheme);

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icon, color: foreground, size: 24),
              const SizedBox(width: 12),
              Expanded(child: _Texts(data, foreground, textTheme)),
            ],
          ),
        ),
      ),
    );
  }

  Color _background(ColorScheme scheme) => switch (data.type) {
        AppAlertType.success => const Color(0xFF16A34A),
        AppAlertType.error => scheme.error,
        AppAlertType.info => const Color(0xFF0095FF),
        AppAlertType.warning => const Color(0xFFF59E0B),
      };

  Color _foreground(ColorScheme scheme) =>
      data.type == AppAlertType.error ? scheme.onError : Colors.white;

  IconData get _icon => switch (data.type) {
        AppAlertType.success => Icons.check_circle_rounded,
        AppAlertType.error => Icons.error_rounded,
        AppAlertType.info => Icons.info_rounded,
        AppAlertType.warning => Icons.warning_rounded,
      };
}

class _Texts extends StatelessWidget {
  final _AppAlertView data;
  final Color foreground;
  final TextTheme textTheme;

  const _Texts(this.data, this.foreground, this.textTheme);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (data.title != null) ...[
          Text(
            data.title!,
            style: textTheme.titleSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Text(
          data.message,
          style: textTheme.bodyMedium?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
