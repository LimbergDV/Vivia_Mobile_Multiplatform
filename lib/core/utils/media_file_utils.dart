/// Helpers para derivar metadata de archivos de media locales antes de
/// construir un manifiesto de subida (drafts y galería de propiedades).
class MediaFileUtils {
  MediaFileUtils._();

  /// Nombre del archivo sin extensión (base para el fileKey del manifiesto).
  static String fileKey(String path) {
    final filename = path.split('/').last.split('\\').last;
    final dotIndex = filename.lastIndexOf('.');
    return dotIndex != -1 ? filename.substring(0, dotIndex) : filename;
  }

  /// fileKey único dentro de un manifiesto: agrega sufijos _1, _2, ... si
  /// ya existe en [existing].
  static String uniqueFileKey(String path, Map<String, String> existing) {
    String key = fileKey(path);
    int suffix = 1;
    while (existing.containsKey(key)) {
      key = '${fileKey(path)}_$suffix';
      suffix++;
    }
    return key;
  }

  /// MIME type a partir de la extensión del archivo.
  static String contentType(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'mp4' => 'video/mp4',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }
}
