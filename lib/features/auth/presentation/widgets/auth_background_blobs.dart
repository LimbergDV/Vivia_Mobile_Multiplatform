import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthBackgroundBlobs extends StatelessWidget {
  const AuthBackgroundBlobs({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 100,
            left: -30,
            child: SvgPicture.asset(
              'assets/icons/blob_teal.svg',
              width: 115,
              height: 135,
            ),
          ),
          Positioned(
            bottom: -30,
            left: -35,
            child: SvgPicture.asset(
              'assets/icons/blob_blue_large.svg',
              width: 140,
              height: 140,
            ),
          ),
          Positioned(
            bottom: 85,
            left: 0,
            right: 0,
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/blob_blue_small.svg',
                width: 78,
                height: 80,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: -30,
            child: SvgPicture.asset(
              'assets/icons/blob_dark.svg',
              width: 130,
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
}