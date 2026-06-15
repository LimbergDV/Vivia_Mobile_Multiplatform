import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'app.dart';

void main() {
  //runApp(const MyApp());

  runApp(
      DevicePreview(
        enabled: kIsWeb,
        builder: (context) => const MyApp(),
      )
  );
}

