import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff1b6585),
      surfaceTint: Color(0xff1b6585),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffc3e8ff),
      onPrimaryContainer: Color(0xff004c68),
      secondary: Color(0xff206487),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffc6e7ff),
      onSecondaryContainer: Color(0xff004c6b),
      tertiary: Color(0xff006a60),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff9ef2e4),
      onTertiaryContainer: Color(0xff005048),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff5fafb),
      onSurface: Color(0xff171d1e),
      onSurfaceVariant: Color(0xff3f484a),
      outline: Color(0xff6f797a),
      outlineVariant: Color(0xffbfc8ca),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3133),
      inversePrimary: Color(0xff8fcff3),
      primaryFixed: Color(0xffc3e8ff),
      onPrimaryFixed: Color(0xff001e2c),
      primaryFixedDim: Color(0xff8fcff3),
      onPrimaryFixedVariant: Color(0xff004c68),
      secondaryFixed: Color(0xffc6e7ff),
      onSecondaryFixed: Color(0xff001e2d),
      secondaryFixedDim: Color(0xff92cef5),
      onSecondaryFixedVariant: Color(0xff004c6b),
      tertiaryFixed: Color(0xff9ef2e4),
      onTertiaryFixed: Color(0xff00201c),
      tertiaryFixedDim: Color(0xff82d5c8),
      onTertiaryFixedVariant: Color(0xff005048),
      surfaceDim: Color(0xffd5dbdc),
      surfaceBright: Color(0xfff5fafb),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5f6),
      surfaceContainer: Color(0xffe9eff0),
      surfaceContainerHigh: Color(0xffe3e9ea),
      surfaceContainerHighest: Color(0xffdee3e5),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003b51),
      surfaceTint: Color(0xff1b6585),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff2f7495),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff003a53),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff337397),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003e37),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff1d7a6f),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fafb),
      onSurface: Color(0xff0c1213),
      onSurfaceVariant: Color(0xff2f3839),
      outline: Color(0xff4b5456),
      outlineVariant: Color(0xff656f70),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3133),
      inversePrimary: Color(0xff8fcff3),
      primaryFixed: Color(0xff2f7495),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff065b7b),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff337397),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff105b7d),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff1d7a6f),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff006056),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc2c7c9),
      surfaceBright: Color(0xfff5fafb),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5f6),
      surfaceContainer: Color(0xffe3e9ea),
      surfaceContainerHigh: Color(0xffd8dedf),
      surfaceContainerHighest: Color(0xffcdd3d4),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003043),
      surfaceTint: Color(0xff1b6585),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff004f6b),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff003045),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff004f6f),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff00332d),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff00534b),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fafb),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff252e2f),
      outlineVariant: Color(0xff414b4c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3133),
      inversePrimary: Color(0xff8fcff3),
      primaryFixed: Color(0xff004f6b),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff00374c),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff004f6f),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff00374e),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff00534b),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff003a34),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb4babb),
      surfaceBright: Color(0xfff5fafb),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffecf2f3),
      surfaceContainer: Color(0xffdee3e5),
      surfaceContainerHigh: Color(0xffcfd5d6),
      surfaceContainerHighest: Color(0xffc2c7c9),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff8fcff3),
      surfaceTint: Color(0xff8fcff3),
      onPrimary: Color(0xff003549),
      primaryContainer: Color(0xff004c68),
      onPrimaryContainer: Color(0xffc3e8ff),
      secondary: Color(0xff92cef5),
      onSecondary: Color(0xff00344b),
      secondaryContainer: Color(0xff004c6b),
      onSecondaryContainer: Color(0xffc6e7ff),
      tertiary: Color(0xff82d5c8),
      onTertiary: Color(0xff003731),
      tertiaryContainer: Color(0xff005048),
      onTertiaryContainer: Color(0xff9ef2e4),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff0e1415),
      onSurface: Color(0xffdee3e5),
      onSurfaceVariant: Color(0xffbfc8ca),
      outline: Color(0xff899294),
      outlineVariant: Color(0xff3f484a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee3e5),
      inversePrimary: Color(0xff1b6585),
      primaryFixed: Color(0xffc3e8ff),
      onPrimaryFixed: Color(0xff001e2c),
      primaryFixedDim: Color(0xff8fcff3),
      onPrimaryFixedVariant: Color(0xff004c68),
      secondaryFixed: Color(0xffc6e7ff),
      onSecondaryFixed: Color(0xff001e2d),
      secondaryFixedDim: Color(0xff92cef5),
      onSecondaryFixedVariant: Color(0xff004c6b),
      tertiaryFixed: Color(0xff9ef2e4),
      onTertiaryFixed: Color(0xff00201c),
      tertiaryFixedDim: Color(0xff82d5c8),
      onTertiaryFixedVariant: Color(0xff005048),
      surfaceDim: Color(0xff0e1415),
      surfaceBright: Color(0xff343a3b),
      surfaceContainerLowest: Color(0xff090f10),
      surfaceContainerLow: Color(0xff171d1e),
      surfaceContainer: Color(0xff1b2122),
      surfaceContainerHigh: Color(0xff252b2c),
      surfaceContainerHighest: Color(0xff303637),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb4e3ff),
      surfaceTint: Color(0xff8fcff3),
      onPrimary: Color(0xff00293a),
      primaryContainer: Color(0xff5898ba),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffb8e2ff),
      onSecondary: Color(0xff00293c),
      secondaryContainer: Color(0xff5b97bc),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xff98ecde),
      onTertiary: Color(0xff002b26),
      tertiaryContainer: Color(0xff4a9e92),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0e1415),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd4dee0),
      outline: Color(0xffaab4b5),
      outlineVariant: Color(0xff889294),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee3e5),
      inversePrimary: Color(0xff004e6a),
      primaryFixed: Color(0xffc3e8ff),
      onPrimaryFixed: Color(0xff00131d),
      primaryFixedDim: Color(0xff8fcff3),
      onPrimaryFixedVariant: Color(0xff003b51),
      secondaryFixed: Color(0xffc6e7ff),
      onSecondaryFixed: Color(0xff00131e),
      secondaryFixedDim: Color(0xff92cef5),
      onSecondaryFixedVariant: Color(0xff003a53),
      tertiaryFixed: Color(0xff9ef2e4),
      onTertiaryFixed: Color(0xff001512),
      tertiaryFixedDim: Color(0xff82d5c8),
      onTertiaryFixedVariant: Color(0xff003e37),
      surfaceDim: Color(0xff0e1415),
      surfaceBright: Color(0xff3f4647),
      surfaceContainerLowest: Color(0xff040809),
      surfaceContainerLow: Color(0xff191f20),
      surfaceContainer: Color(0xff23292a),
      surfaceContainerHigh: Color(0xff2d3435),
      surfaceContainerHighest: Color(0xff393f40),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffe1f2ff),
      surfaceTint: Color(0xff8fcff3),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff8bcbef),
      onPrimaryContainer: Color(0xff000d15),
      secondary: Color(0xffe3f2ff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xff8ecaf1),
      onSecondaryContainer: Color(0xff000d16),
      tertiary: Color(0xffaffff1),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff7ed1c4),
      onTertiaryContainer: Color(0xff000e0c),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff0e1415),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffe8f2f3),
      outlineVariant: Color(0xffbbc4c6),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee3e5),
      inversePrimary: Color(0xff004e6a),
      primaryFixed: Color(0xffc3e8ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff8fcff3),
      onPrimaryFixedVariant: Color(0xff00131d),
      secondaryFixed: Color(0xffc6e7ff),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xff92cef5),
      onSecondaryFixedVariant: Color(0xff00131e),
      tertiaryFixed: Color(0xff9ef2e4),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xff82d5c8),
      onTertiaryFixedVariant: Color(0xff001512),
      surfaceDim: Color(0xff0e1415),
      surfaceBright: Color(0xff4b5152),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1b2122),
      surfaceContainer: Color(0xff2b3133),
      surfaceContainerHigh: Color(0xff363c3e),
      surfaceContainerHighest: Color(0xff424849),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
