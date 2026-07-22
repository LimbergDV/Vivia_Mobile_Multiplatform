class InputValidators {
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Ingresa tu correo';
    if (trimmed.length > 254) return 'Máximo 254 caracteres';
    if (!_email.hasMatch(trimmed)) return 'Correo no válido';
    return null;
  }

  static String? requiredField(String? value, {String message = 'Campo requerido'}) {
    return (value?.trim().isEmpty ?? true) ? message : null;
  }

  static String? name(String? value, {int max = 50}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Campo requerido';
    if (trimmed.length > max) return 'Máximo $max caracteres';
    return null;
  }

  static String? password(String? value, {int min = 8, int max = 40}) {
    final text = value ?? '';
    if (text.isEmpty) return 'Ingresa una contraseña';
    if (text.length < min) return 'Mínimo $min caracteres';
    if (text.length > max) return 'Máximo $max caracteres';
    return null;
  }

  static String? phone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Ingresa tu número de teléfono';
    if (!RegExp(r'^\d{10}$').hasMatch(trimmed)) return 'Debe tener 10 dígitos';
    return null;
  }

  static String? minLength(String? value, int min) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Campo requerido';
    if (trimmed.length < min) return 'Debe tener al menos $min caracteres';
    return null;
  }
}
