import 'package:flutter/material.dart';

class AuthBackgroundBlobs extends StatelessWidget {
  const AuthBackgroundBlobs({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 200,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Blob teal (izquierda)
            Positioned(
              bottom: -20,
              left: -30,
              child: _Blob(
                color: const Color(0xFF4DD9C0),
                width: 120,
                height: 110,
              ),
            ),
            // Blob azul oscuro (centro-derecha)
            Positioned(
              bottom: 20,
              right: 60,
              child: _Blob(
                color: const Color(0xFF1A3A5C),
                width: 100,
                height: 95,
              ),
            ),
            // Blob azul medio (derecha)
            Positioned(
              bottom: -10,
              right: -10,
              child: _Blob(
                color: const Color(0xFF3B82F6),
                width: 90,
                height: 85,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double width;
  final double height;

  const _Blob({
    required this.color,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(width * 0.7),
          topRight: Radius.circular(width * 0.4),
          bottomLeft: Radius.circular(width * 0.5),
          bottomRight: Radius.circular(width * 0.6),
        ),
      ),
    );
  }
}