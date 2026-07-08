import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FormSectionHeader extends StatelessWidget {
  final String label;
  final String? svgIconPath;
  final IconData? iconData;

  const FormSectionHeader({
    super.key,
    required this.label,
    this.svgIconPath,
    this.iconData,
  }) : assert(
         svgIconPath != null || iconData != null,
         'Debes proveer svgIconPath o iconData',
       );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (svgIconPath != null)
          SvgPicture.asset(svgIconPath!, width: 20, height: 20)
        else
          Icon(iconData, size: 20, color: colorScheme.onSurface),
        const SizedBox(width: 8),
        Text(
          label,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
