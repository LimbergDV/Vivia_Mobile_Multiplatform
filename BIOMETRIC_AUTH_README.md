# Implementación de Autenticación Biométrica con WebAuthn

## Resumen

Se ha implementado el registro biométrico (huella digital) usando la API de WebAuthn/FIDO2 consumiendo los endpoints reales del backend.

## Endpoints Consumidos

1. **POST `/lessors/biometric/challenge`** - Solicita el desafío de registro
   - Request: `email`, `name`, `paternalSurname`, `maternalSurname`, `phoneNumber`
   - Response: Challenge en formato JSON string

2. **POST `/lessors/biometric/verify`** - Verifica la credencial y registra al usuario
   - Request: `credentialResponseJson` (string)
   - Response: `accessToken` y `refreshToken`

## Flujo Implementado

```
1. Usuario completa el formulario de registro
   ↓
2. Se valida el formulario
   ↓
3. Se verifica que el dispositivo soporte biometría
   ↓
4. Se solicita el challenge al servidor (/lessors/biometric/challenge)
   ↓
5. Se crea una credencial biométrica local usando PasskeyAuthenticator
   ↓
6. Se envía la credencial al servidor (/lessors/biometric/verify)
   ↓
7. Se reciben y guardan los tokens de sesión
```

## Archivos Modificados/Creados

### Nuevos Archivos
- `lib/features/auth/data/models/biometric_challenge_response.dart` - Modelo para la respuesta del challenge
- `lib/features/auth/data/models/biometric_auth_response.dart` - Modelo para la respuesta de autenticación
- `lib/features/auth/data/models/models.dart` - Archivo índice de modelos

### Archivos Modificados
- `pubspec.yaml` - Agregado paquete `passkeys: ^2.20.3`
- `lib/features/auth/presentation/viewmodels/auth_viewmodel.dart` - Implementada función `registerWithBiometrics()`
- `android/app/build.gradle.kts` - Actualizado minSdk a 28 (requerido para WebAuthn)
- `android/app/src/main/AndroidManifest.xml` - Agregados permisos de INTERNET y USE_BIOMETRIC

## Dependencias Agregadas

```yaml
passkeys: ^2.20.3  # WebAuthn/FIDO2 para autenticación biométrica
```

### Paquetes Instalados Automáticamente
- `passkeys_android` - Implementación para Android
- `passkeys_darwin` - Implementación para iOS/macOS
- `passkeys_web` - Implementación para Web
- `passkeys_windows` - Implementación para Windows
- `passkeys_doctor` - Herramienta de diagnóstico

## Requisitos de Plataforma

### Android
- **minSdk**: 28 (Android 9.0+)
- **Permisos**:
  - `android.permission.INTERNET`
  - `android.permission.USE_BIOMETRIC`

### iOS
- iOS 13.0 o superior (configuración ya existente en el proyecto)

## Uso

La función `registerWithBiometrics()` en el `AuthViewModel` maneja todo el flujo:

```dart
// Desde la UI (ya implementado en RegisterPage)
final authViewModel = Provider.of<AuthViewModel>(context);
await authViewModel.registerWithBiometrics();

// El AuthViewModel maneja automáticamente:
// 1. Validación del formulario
// 2. Verificación de biometría
// 3. Llamadas al API
// 4. Gestión de estados (loading, success, error)
```

## Gestión de Estados

El ViewModel gestiona automáticamente los siguientes estados:

- `AuthStatus.idle` - Estado inicial
- `AuthStatus.loading` - Durante el proceso de registro
- `AuthStatus.success` - Registro exitoso (token guardado)
- `AuthStatus.error` - Error en el proceso (mensaje en `errorMessage`)

## Manejo de Errores

La implementación maneja los siguientes casos:

1. **Dispositivo sin biometría**: Muestra error si `canCheckBiometrics` es false
2. **Challenge inválido**: Valida que el servidor devuelva un challenge válido
3. **Credencial no creada**: Detecta si el usuario cancela la autenticación biométrica
4. **Error de verificación**: Captura errores del endpoint de verificación
5. **Errores de red**: Maneja DioException con mensajes apropiados
6. **Errores de plataforma**: Captura PlatformException (problemas con el sensor biométrico)

## Notas Importantes

### Seguridad
- Las credenciales biométricas **nunca** salen del dispositivo
- Solo se envía el challenge firmado al servidor
- El servidor verifica la firma usando WebAuthn
- Los tokens son generados únicamente después de verificación exitosa

### Testing en Desarrollo
- **Android Emulator**: Requiere configuración de sensor de huella digital virtual
- **iOS Simulator**: Requiere Face ID/Touch ID configurado
- **Dispositivo Real**: Recomendado para testing completo

### Configuración del Emulador Android
1. Settings → Security → Fingerprint
2. Agregar huella digital virtual
3. Usar "Extended Controls" → Fingerprint para simular durante el testing

### Configuración del Simulator iOS
1. Features → Face ID/Touch ID → Enrolled
2. Durante testing: Features → Face ID/Touch ID → Matching Touch/Face

## Próximos Pasos Sugeridos

1. **Implementar Login Biométrico**: Similar al registro, pero usando el endpoint de login
2. **Gestión de Múltiples Credenciales**: Permitir múltiples dispositivos por usuario
3. **Recuperación de Cuenta**: Flujo para cuando el usuario pierde acceso biométrico
4. **Testing**: Crear tests unitarios y de integración
5. **UI/UX**: Mejorar feedback visual durante el proceso biométrico

## Troubleshooting

### Error: "Biometric authentication not available"
- Verificar que el dispositivo tenga sensor biométrico configurado
- En emulador/simulator, asegurar que esté configurado correctamente

### Error: "Target of URI doesn't exist: 'package:passkeys/passkeys.dart'"
- Ejecutar `flutter clean && flutter pub get`
- Reiniciar el IDE/Editor

### Error en Android: "minSdk too low"
- Verificar que `minSdk = 28` en `android/app/build.gradle.kts`

### Error: "Challenge invalid"
- Verificar que el servidor esté devolviendo un JSON string válido
- Revisar logs del servidor para ver el formato del challenge

## Referencias

- [Passkeys Package](https://pub.dev/packages/passkeys)
- [WebAuthn Specification](https://www.w3.org/TR/webauthn/)
- [FIDO2 Overview](https://fidoalliance.org/fido2/)

## Contacto

Para dudas o problemas con la implementación, revisar:
- Logs de la aplicación con `flutter logs`
- Logs del servidor para ver detalles de los endpoints
- Debug mode del PasskeyAuthenticator: `PasskeyAuthenticator(debugMode: true)`
