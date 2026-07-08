import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Captura de documentos para la verificación de identidad. Todo el
/// procesamiento (detección de bordes y recorte) ocurre en el dispositivo:
/// ML Kit en Android y VisionKit en iOS.
class VerifyCaptureHelper {
  VerifyCaptureHelper._();

  static final _picker = ImagePicker();

  /// Escanea una cara de la credencial con recorte automático. Solo cámara.
  /// Retorna la ruta local de la imagen recortada, o null si se canceló.
  static Future<String?> scanIdCard() async {
    try {
      final pictures = await CunningDocumentScanner.getPictures(
        noOfPages: 1,
        scannerSource: ScannerSource.camera,
      );
      if (pictures == null || pictures.isEmpty) return null;
      return pictures.first;
    } on PlatformException {
      return null;
    }
  }

  /// Toma la selfie con la cámara frontal. Retorna la ruta local, o null si
  /// se canceló o se denegó el permiso de cámara.
  static Future<String?> takeSelfie() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 1920,
      );
      return file?.path;
    } on PlatformException {
      return null;
    }
  }
}
