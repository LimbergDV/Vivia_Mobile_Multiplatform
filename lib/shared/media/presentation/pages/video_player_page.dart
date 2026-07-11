import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Reproduce un video de una propiedad a pantalla completa.
/// Inicializa [VideoPlayerController] y lo envuelve en [Chewie] para los
/// controles (play/pausa, scrubbing, fullscreen).
class VideoPlayerPage extends StatefulWidget {
  final String url;
  final String? title;

  /// Acción de lessor: eliminar este video. Si devuelve true, la página
  /// se cierra.
  final Future<bool> Function()? onDelete;

  const VideoPlayerPage({
    super.key,
    required this.url,
    this.title,
    this.onDelete,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _hasError = false;
  bool _deleting = false;

  Future<void> _confirmDelete() async {
    final onDelete = widget.onDelete;
    if (onDelete == null || _deleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar video'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este video? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    _videoController?.pause();
    final deleted = await onDelete();
    if (!mounted) return;
    if (deleted) {
      Navigator.of(context).pop();
    } else {
      setState(() => _deleting = false);
    }
  }

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
        actions: [
          if (widget.onDelete != null)
            IconButton(
              icon: _deleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
        ],
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
