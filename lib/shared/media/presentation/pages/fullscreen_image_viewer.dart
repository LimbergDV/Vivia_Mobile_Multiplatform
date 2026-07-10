import 'package:flutter/material.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_media.dart';

class FullscreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  /// Medios paralelos a [imageUrls]. Junto con los callbacks habilita las
  /// acciones de lessor (eliminar / hacer principal) sobre la imagen actual.
  final List<PropertyMedia>? media;
  final Future<bool> Function(PropertyMedia media)? onDelete;
  final Future<void> Function(PropertyMedia media)? onSetMain;

  const FullscreenImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.media,
    this.onDelete,
    this.onSetMain,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  late final PageController _controller;
  late int _currentIndex;
  late List<String> _imageUrls;
  late List<PropertyMedia>? _media;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: _currentIndex);
    _imageUrls = List.of(widget.imageUrls);
    _media = widget.media != null ? List.of(widget.media!) : null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  PropertyMedia? get _currentMedia {
    final media = _media;
    if (media == null || _currentIndex >= media.length) return null;
    return media[_currentIndex];
  }

  bool get _canDelete => widget.onDelete != null && _currentMedia != null;

  bool get _canSetMain =>
      widget.onSetMain != null &&
      _currentMedia != null &&
      _currentMedia!.classification.trim() != 'MAIN';

  Future<void> _confirmDelete() async {
    final media = _currentMedia;
    final onDelete = widget.onDelete;
    if (media == null || onDelete == null || _busy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar imagen'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta imagen? '
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

    setState(() => _busy = true);
    final deleted = await onDelete(media);
    if (!mounted) return;

    if (!deleted) {
      setState(() => _busy = false);
      return;
    }

    setState(() {
      _imageUrls.removeAt(_currentIndex);
      _media?.removeAt(_currentIndex);
      if (_currentIndex >= _imageUrls.length) {
        _currentIndex = _imageUrls.length - 1;
      }
      _busy = false;
    });
    if (_imageUrls.isEmpty) Navigator.of(context).pop();
  }

  Future<void> _confirmSetMain() async {
    final media = _currentMedia;
    final onSetMain = widget.onSetMain;
    if (media == null || onSetMain == null || _busy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hacer imagen principal'),
        content: const Text(
          'Esta imagen se convertirá en la portada de tu propiedad y será '
          'la que se muestre en los listados. La portada actual pasará a la '
          'categoría OTHER.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    await onSetMain(media);
    // La galería recarga las clasificaciones: el estado local del visor
    // queda obsoleto, así que se cierra.
    if (mounted) Navigator.of(context).pop();
  }

  Widget _actionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: _busy ? null : onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _imageUrls.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, index) {
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    _imageUrls[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.image_outlined,
                      size: 64,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _actionButton(
                      Icons.close,
                      () => Navigator.of(context).pop(),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${_imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (_canSetMain) ...[
                          _actionButton(Icons.star_outline, _confirmSetMain),
                          const SizedBox(width: 8),
                        ],
                        if (_canDelete)
                          _actionButton(
                            Icons.delete_outline,
                            _confirmDelete,
                          )
                        else
                          const SizedBox(width: 40),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_busy)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black38,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
