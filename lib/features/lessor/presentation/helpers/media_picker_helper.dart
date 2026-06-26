import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

enum MediaPickerError { cameraDenied, cancelled }

class MediaPickerResult {
  final String? path;
  final MediaPickerError? error;

  const MediaPickerResult._({this.path, this.error});

  factory MediaPickerResult.success(String path) =>
      MediaPickerResult._(path: path);

  factory MediaPickerResult.fromError(MediaPickerError error) =>
      MediaPickerResult._(error: error);

  factory MediaPickerResult.cancelled() =>
      const MediaPickerResult._(error: MediaPickerError.cancelled);

  bool get isSuccess => path != null;
  bool get isCameraDenied => error == MediaPickerError.cameraDenied;
}

class MediaPickerHelper {
  static final _picker = ImagePicker();

  static Future<MediaPickerResult> pickImageFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1920,
    );
    if (file == null) return MediaPickerResult.cancelled();
    return MediaPickerResult.success(file.path);
  }

  static Future<List<String>> pickMultipleImages() async {
    final files = await _picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1920,
    );
    return files.map((f) => f.path).toList();
  }

  static Future<MediaPickerResult> takePhoto() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
      );
      if (file == null) return MediaPickerResult.cancelled();
      return MediaPickerResult.success(file.path);
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied') {
        return MediaPickerResult.fromError(MediaPickerError.cameraDenied);
      }
      rethrow;
    }
  }

  static Future<MediaPickerResult> pickVideoFromGallery() async {
    final file = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 3),
    );
    if (file == null) return MediaPickerResult.cancelled();
    return MediaPickerResult.success(file.path);
  }

  static Future<MediaPickerResult> recordVideo() async {
    try {
      final file = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 3),
      );
      if (file == null) return MediaPickerResult.cancelled();
      return MediaPickerResult.success(file.path);
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied') {
        return MediaPickerResult.fromError(MediaPickerError.cameraDenied);
      }
      rethrow;
    }
  }
}