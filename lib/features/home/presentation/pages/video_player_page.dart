import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Reproduce un video de una propiedad a pantalla completa.
/// Inicializa [VideoPlayerController] y lo envuelve en [Chewie] para los
/// controles (play/pausa, scrubbing, fullscreen).
class VideoPlayerPage extends StatefulWidget {
  final String url;
  final String? title;

  const VideoPlayerPage({super.key, required this.url, this.title});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
      );
      _videoController = controller;
      await controller.initialize();

      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        aspectRatio: controller.value.aspectRatio,
      );
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.title ?? 'Video'),
      ),
      body: Center(child: _buildContent()),
    );
  }

  Widget _buildContent() {
    if (_hasError) {
      return const _VideoMessage(
        icon: Icons.error_outline_rounded,
        message: 'No se pudo reproducir el video',
      );
    }

    final chewie = _chewieController;
    final video = _videoController;
    if (chewie == null || video == null || !video.value.isInitialized) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    return AspectRatio(
      aspectRatio: video.value.aspectRatio,
      child: Chewie(controller: chewie),
    );
  }
}

class _VideoMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _VideoMessage({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 48, color: Colors.white54),
        const SizedBox(height: 12),
        Text(message, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
