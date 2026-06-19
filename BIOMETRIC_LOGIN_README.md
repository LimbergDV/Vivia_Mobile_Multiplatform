# Login con Autenticación Biométrica

## Implementación Completada

Se ha implementado el login biométrico usando WebAuthn/FIDO2 que consume los endpoints del backend.

## Endpoints Utilizados

### 1. POST `/auth/login/challenge`
Solicita el desafío de login. No requiere parámetros.

**Response:**
```json
{
  "success": true,
  "data": {
    "publicKey": {
      "challenge": "...",
      "rpId": "vivia-api.aleosh.online",
      "userVerification": "preferred",
      "allowCredentials": [...]
    }
  },
  "message": "Challenge de login generado",
  "status": "OK"
}
```

### 2. POST `/auth/login/verify`
Verifica la credencial biométrica y devuelve los tokens JWT.

**Request:**
```json
{
  "credentialResponseJson": "{...credential response...}"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "d9b2d63d-a233-4123-8478-..."
  },
  "message": "Login exitoso",
  "status": "OK"
}
```

## Flujo de Login

```
1. Usuario presiona "Entrar con Huella"
   ↓
2. Se verifica que el dispositivo tenga biometría configurada
   ↓
3. Se solicita el challenge al servidor (/auth/login/challenge)
   ↓
4. Se autentica con PasskeyAuthenticator (verifica huella y selecciona credencial)
   ↓
5. Se envía la credencial al servidor (/auth/login/verify)
   ↓
6. Se reciben y guardan los tokens de sesión
```

## Diferencias con el Registro

| Aspecto | Registro | Login |
|---------|----------|-------|
| **Método de Passkeys** | `register()` | `authenticate()` |
| **Endpoint Challenge** | `/lessors/biometric/challenge` | `/auth/login/challenge` |
| **Endpoint Verify** | `/lessors/biometric/verify` | `/auth/login/verify` |
| **Datos Requeridos** | Email, nombre, teléfono, apellidos | Ninguno (solo huella) |
| **Credencial** | Se crea nueva | Se usa existente |
| **Challenge** | Incluye info del usuario nuevo | Solo rpId y allowCredentials |

## Código Implementado

### AuthViewModel

El método `loginWithBiometrics()` en `lib/features/auth/presentation/viewmodels/auth_viewmodel.dart` maneja todo el flujo:

```dart
await authViewModel.loginWithBiometrics();
```

## UI

El botón ya está implementado en `LoginPage`:

```dart
AuthBiometricButton(
  label: 'Entrar con Huella',
  onPressed: isLoading ? null : () => viewModel.loginWithBiometrics(),
)
```

## Gestión de Estados

Estados durante el login:

- `AuthStatus.loading` - Durante el proceso
- `AuthStatus.success` - Login exitoso (token guardado)
- `AuthStatus.error` - Error (mensaje en `errorMessage`)
- `AuthStatus.idle` - Estado inicial

## Manejo de Errores

### Errores Comunes

1. **"Biometría no disponible"**
   - Causa: El dispositivo no tiene sensor biométrico o no está configurado
   - Solución: Configurar huella digital en el dispositivo

2. **"No tienes credenciales registradas"**
   - Causa: El usuario nunca completó el registro con huella
   - Solución: Completar el registro biométrico primero

3. **"Error al autenticar con biometría"**
   - Causa: El usuario canceló, la huella no coincide, o error de plataforma
   - Solución: Intentar de nuevo o verificar configuración del sensor

4. **"Error al verificar login (400)"**
   - Causa: La credencial no es válida o expiró
   - Solución: Revisar logs del servidor para detalles

5. **"RP ID cannot be validated"**
   - Causa: El archivo `assetlinks.json` no está configurado correctamente
   - Solución: Verificar que `https://vivia-api.aleosh.online/.well-known/assetlinks.json` sea accesible

## Debugging

### Logs en Flutter

El código genera logs detallados durante el proceso:

```
=== RESPUESTA LOGIN CHALLENGE ===
Status: 200
Data: {...}
==================================

=== PUBLIC KEY JSON PARA LOGIN ===
{...publicKey options...}
==================================

=== CREDENTIAL JSON LOGIN A ENVIAR ===
{...authentication assertion...}
=======================================

=== RESPUESTA DE VERIFICACIÓN LOGIN ===
Status: 200
Data: {...tokens...}
========================================
```

### Logs de Error

```
=== ERROR DE VERIFICACIÓN LOGIN (DioException) ===
Status Code: 400
Response Data: {...}
Error Message: ...
===================================================
```

## Seguridad

### Flujo Seguro

1. **Sin contraseñas**: No se transmite ninguna contraseña
2. **Credenciales locales**: La clave privada nunca sale del dispositivo
3. **Challenge único**: Cada login genera un challenge aleatorio
4. **Firma criptográfica**: La credencial firma el challenge con la clave privada
5. **Verificación servidor**: El servidor verifica la firma con la clave pública

### Requisitos de Seguridad

- ✅ HTTPS obligatorio (WebAuthn no funciona en HTTP)
- ✅ RP ID debe coincidir con el dominio del API
- ✅ Digital Asset Links configurados correctamente
- ✅ Challenge debe ser aleatorio y de un solo uso
- ✅ Timeouts configurados (default: 60 segundos)

## Testing

### En Emulador Android

1. Configurar huella digital virtual:
   - Settings → Security → Fingerprint
   - Agregar huella
2. Durante testing:
   - Extended Controls → Fingerprint → Touch Sensor

### En Dispositivo Real

- Recomendado para testing completo
- Verificar que tenga huella configurada

## Próximos Pasos

1. ✅ Login implementado
2. ⏳ Guardar tokens en almacenamiento persistente (SharedPreferences/SecureStorage)
3. ⏳ Implementar refresh token
4. ⏳ Gestión de sesión (verificar token válido)
5. ⏳ Logout y limpieza de sesión
6. ⏳ Manejo de múltiples credenciales por usuario
7. ⏳ Testing unitario y de integración

## Notas Importantes

### Configuración Actual

- **RP ID**: `vivia-api.aleosh.online`
- **Package Name**: `com.quantum.vivia_mobile`
- **Debug SHA256**: `BA:C5:A8:B4:59:79:42:7A:70:BE:05:DB:18:4A:BF:11:20:54:52:E6:59:F0:D4:7B:32:62:96:2D:5B:F5:10:A6`
- **Asset Links**: `https://vivia-api.aleosh.online/.well-known/assetlinks.json`

### Para Producción

- Agregar el SHA256 del release keystore al `assetlinks.json`
- Configurar ProGuard/R8 para no ofuscar clases de WebAuthn
- Implementar fallback a login con contraseña
- Agregar métricas y analytics

## Troubleshooting

### El login no muestra el selector de credenciales

- **Causa**: No hay credenciales registradas para ese RP ID
- **Solución**: Completar el registro biométrico primero

### "Network error" o timeout

- **Causa**: El servidor no responde o hay problemas de red
- **Solución**: Verificar conectividad y logs del servidor

### "Invalid signature"

- **Causa**: El challenge o la credencial están corruptos
- **Solución**: Revisar logs del servidor para ver el error específico

## Referencias

- [WebAuthn Specification](https://www.w3.org/TR/webauthn-2/)
- [Passkeys Package](https://pub.dev/packages/passkeys)
- [Android Digital Asset Links](https://developer.android.com/training/app-links/verify-android-applinks)
