import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ViviaLogo extends StatelessWidget {
  final double size;

  const ViviaLogo({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.18),
        child: SvgPicture.asset(
          'assets/images/logo.svg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}