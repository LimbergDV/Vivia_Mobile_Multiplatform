import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vivia_mobile/features/lessor/publishing/presentation/viewmodels/property_draft_viewmodel.dart';

const _kTo = Color(0xFF16A34A);
const _kReassurances = [
  'Ten calma, estamos analizando tu propiedad para evitar inconvenientes.',
  'Revisando las fotos y la información. Esto puede tardar un momento.',
  'Verificamos que todo cumpla para publicarse sin problemas.',
  'Casi listo, afinando los últimos detalles de tu publicación.',
];

class PublishProgressCard extends StatefulWidget {
  const PublishProgressCard({super.key});

  @override
  State<PublishProgressCard> createState() => _PublishProgressCardState();
}

class _PublishProgressCardState extends State<PublishProgressCard> {
  double _progress = 0.04;
  int _messageIndex = 0;
  Timer? _creepTimer;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _creepTimer = Timer.periodic(const Duration(milliseconds: 350), _creep);
    _messageTimer = Timer.periodic(const Duration(seconds: 4), _rotate);
  }

  void _creep(Timer _) {
    if (!mounted) return;
    setState(() => _progress += (0.9 - _progress) * 0.06);
  }

  void _rotate(Timer _) {
    if (!mounted) return;
    setState(() => _messageIndex = (_messageIndex + 1) % _kReassurances.length);
  }

  @override
  void dispose() {
    _creepTimer?.cancel();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stage = context.select<PropertyDraftViewModel, String>(
      (vm) => vm.streamStatusMessage,
    );
    return _Card(
      progress: _progress,
      stage: stage,
      reassurance: _kReassurances[_messageIndex],
    );
  }
}

class _Card extends StatelessWidget {
  final double progress;
  final String stage;
  final String reassurance;

  const _Card({
    required this.progress,
    required this.stage,
    required this.reassurance,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF04364A),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(stage: stage, progress: progress, textTheme: textTheme),
            const SizedBox(height: 12),
            _Bar(progress: progress),
            const SizedBox(height: 10),
            Text(
              reassurance,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.82),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String stage;
  final double progress;
  final TextTheme textTheme;

  const _Header({
    required this.stage,
    required this.progress,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            stage,
            style: textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          '${(progress * 100).round()}%',
          style: textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double progress;

  const _Bar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 350),
        builder: (_, value, __) => LinearProgressIndicator(
          value: value,
          minHeight: 8,
          backgroundColor: Colors.white.withValues(alpha: 0.18),
          valueColor: const AlwaysStoppedAnimation(_kTo),
        ),
      ),
    );
  }
}
