import 'dart:io' show Platform;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:vivia_mobile/features/maps/data/map_style_loader.dart';
import 'package:vivia_mobile/features/maps/domain/models/geocode_result.dart';

/// Mapa vectorial de ViVia Maps centrado en [point] con un pin.
/// En plataformas sin soporte de maplibre_gl (escritorio, tests) renderiza
/// un fallback estático para no romper el árbol de widgets.
class PropertyLocationMap extends StatefulWidget {
  final GeocodeResult point;
  final bool interactive;
  final VoidCallback? onExpand;

  /// false: solo centra el mapa, sin marcador (para colocar pin manual).
  final bool showPin;

  /// Tap del usuario sobre el mapa (colocación/ajuste del pin).
  final void Function(double lat, double lon)? onTap;

  const PropertyLocationMap({
    super.key,
    required this.point,
    this.interactive = true,
    this.onExpand,
    this.showPin = true,
    this.onTap,
  });

  static bool get isPlatformSupported =>
      kIsWeb || Platform.isAndroid || Platform.isIOS;

  // Bounding box de Chiapas: fuera de él no hay tiles (integration.md §4.1).
  static final chiapasBounds = LatLngBounds(
    southwest: const LatLng(14.53, -94.15),
    northeast: const LatLng(18.00, -90.35),
  );

  @override
  State<PropertyLocationMap> createState() => _PropertyLocationMapState();
}

class _PropertyLocationMapState extends State<PropertyLocationMap> {
  static const _pinImageId = 'property-pin';

  @override
  void initState() {
    super.initState();
    if (PropertyLocationMap.isPlatformSupported) {
      MapStyleLoader.resolve().then((style) {
        if (mounted) setState(() => _styleString = style);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!PropertyLocationMap.isPlatformSupported) {
      return _UnsupportedFallback(displayName: widget.point.displayName);
    }

    final style = _styleString;
    if (style == null) return const _MapLoading();

    final map = MapLibreMap(
      styleString: style,
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.point.lat, widget.point.lon),
        zoom: widget.point.isApproximate ? 15 : 16,
      ),
      cameraTargetBounds:
          CameraTargetBounds(PropertyLocationMap.chiapasBounds),
      minMaxZoomPreference: const MinMaxZoomPreference(0, 18),
      rotateGesturesEnabled: widget.interactive,
      scrollGesturesEnabled: widget.interactive,
      zoomGesturesEnabled: widget.interactive,
      tiltGesturesEnabled: false,
      myLocationEnabled: false,
      onMapCreated: (controller) => _controller = controller,
      onStyleLoadedCallback: () => _onStyleLoaded(context),
      onMapClick: widget.onTap == null
          ? null
          : (_, latLng) => widget.onTap!(latLng.latitude, latLng.longitude),
      // Dentro de scrolls, el mapa reclama los gestos antes que la lista.
      gestureRecognizers: widget.interactive
          ? {Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new)}
          : null,
    );

    if (widget.onExpand == null) return map;

    return Stack(
      children: [
        Positioned.fill(child: map),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: widget.onExpand,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.fullscreen, size: 22),
              ),
            ),
          ),
        ),
      ],
    );
  }

  MapLibreMapController? _controller;
  Symbol? _symbol;
  bool _styleLoaded = false;
  String? _styleString;

  @override
  void didUpdateWidget(covariant PropertyLocationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final moved = oldWidget.point.lat != widget.point.lat ||
        oldWidget.point.lon != widget.point.lon;
    if (_styleLoaded && (moved || oldWidget.showPin != widget.showPin)) {
      _syncPin();
    }
  }

  Future<void> _onStyleLoaded(BuildContext context) async {
    // El controller lo entrega onMapCreated antes de cargar el estilo,
    // pero los símbolos solo pueden agregarse con el estilo listo.
    final controller = _controller;
    if (controller == null || !mounted) return;
    try {
      final pin = await _pinBytes(Theme.of(context).colorScheme.primary);
      await controller.addImage(_pinImageId, pin);
      _styleLoaded = true;
      await _syncPin();
    } catch (_) {
      // Sin pin el mapa sigue siendo útil; no interrumpir la vista.
    }
  }

  /// Agrega, mueve o quita el marcador según [widget.point] y [widget.showPin].
  Future<void> _syncPin() async {
    final controller = _controller;
    if (controller == null || !mounted) return;
    try {
      if (!widget.showPin) {
        if (_symbol != null) {
          await controller.removeSymbol(_symbol!);
          _symbol = null;
        }
        return;
      }
      final geometry = LatLng(widget.point.lat, widget.point.lon);
      if (_symbol != null) {
        await controller.updateSymbol(
          _symbol!,
          SymbolOptions(geometry: geometry),
        );
      } else {
        _symbol = await controller.addSymbol(SymbolOptions(
          geometry: geometry,
          iconImage: _pinImageId,
          iconSize: kIsWeb ? 0.5 : 1.0,
          iconAnchor: 'bottom',
        ));
      }
      // Mantener el pin a la vista cuando lo mueve el geocoding o el usuario.
      await controller.animateCamera(CameraUpdate.newLatLng(geometry));
    } catch (_) {
      // Sin pin el mapa sigue siendo útil; no interrumpir la vista.
    }
  }

  /// Rasteriza Icons.location_on como PNG para usarlo de marcador,
  /// evitando depender de sprites del estilo o de assets nuevos.
  Future<Uint8List> _pinBytes(Color color) async {
    const size = 96.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(Icons.location_on.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: Icons.location_on.fontFamily,
          color: color,
        ),
      )
      ..layout();
    painter.paint(canvas, Offset.zero);
    final image = await recorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }
}

class _MapLoading extends StatelessWidget {
  const _MapLoading();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
      ),
    );
  }
}

class _UnsupportedFallback extends StatelessWidget {
  final String displayName;

  const _UnsupportedFallback({required this.displayName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, color: colorScheme.primary, size: 32),
          const SizedBox(height: 8),
          Text(
            displayName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
