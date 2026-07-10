/// El backend responde 409 al intentar eliminar la imagen MAIN de una
/// propiedad: primero hay que promover otra imagen como principal.
class MainImageDeletionException implements Exception {
  final String message;

  const MainImageDeletionException([
    this.message = 'No puedes eliminar la imagen principal de la propiedad.',
  ]);

  @override
  String toString() => message;
}
