# Vivia API - Guía de Integración para Aplicación Móvil

Esta documentación está diseñada para facilitar la integración de la app móvil con el backend de Vivia, enfocándose en la autenticación biométrica y la gestión de perfiles.

## 🚀 Información Base
- **URL Base:** `http://tu-ip-ec2:8080` (O el dominio configurado)
- **Content-Type:** `application/json`
- **Seguridad:** Bearer Token (JWT) para endpoints protegidos.

---

## 🔐 Autenticación Biométrica (WebAuthn / Passkeys)

Vivia utiliza WebAuthn para un login sin contraseñas basado en huella digital.

### 1. Registro Biométrico (Flujo de 2 pasos)

**Paso A: Solicitar Desafío (Challenge)**
- **Endpoint:** `POST /lessors/biometric/challenge` (o `/lessees/...`)
- **Body:** `RegisterLessorBiometricChallengeDto`
  ```json
  {
    "name": "Nombre",
    "paternalSurname": "Apellido",
    "maternalSurname": "Apellido",
    "email": "usuario@ejemplo.com",
    "phoneNumber": "1234567890"
  }
  ```
- **Acción Móvil:** Recibirás un JSON de configuración de WebAuthn. Debes pasarlo a la API nativa de Android/iOS (Credential Manager / ASAuthorizationController).

**Paso B: Verificar y Crear Cuenta**
- **Endpoint:** `POST /lessors/biometric/verify`
- **Body:** `RegisterLessorBiometricVerifyDto`
  ```json
  {
    "credentialResponseJson": "CADENA_JSON_DEL_DISPOSITIVO"
  }
  ```
- **Respuesta:** `AuthResponseDto` con JWT y Refresh Token.

### 2. Login Biométrico (Flujo de 2 pasos)

**Paso A: Solicitar Desafío de Login**
- **Endpoint:** `POST /auth/login/challenge`
- **Respuesta:** JSON de configuración de WebAuthn para "Discoverable Credentials" (permite elegir cuenta mediante biometría).

**Paso B: Verificar y Loguear**
- **Endpoint:** `POST /auth/login/verify`
- **Body:** `VerifyLoginDto`
  ```json
  {
    "credentialResponseJson": "CADENA_JSON_DEL_DISPOSITIVO"
  }
  ```
- **Respuesta:** `AuthResponseDto`.

---

## 📧 Autenticación Tradicional y Social

### Login con Contraseña
- **Endpoint:** `POST /auth/login`
- **Body:** `LoginRequestDto` (`identifier`, `password`)

### Login con Google
- **Endpoint:** `POST /auth/login/google`
- **Body:** `GoogleLoginRequestDto` (`idToken`, `role`)

---

## 🔄 Gestión de Sesión

### Refrescar Token
Cuando el JWT expire (401 Unauthorized), usa este endpoint:
- **Endpoint:** `POST /auth/refresh`
- **Body:** `RefreshTokenRequestDto` (`refreshToken`)
- **Nota:** Implementa rotación de tokens (el antiguo queda invalidado).

### Logout
- **Endpoint:** `POST /auth/logout`
- **Headers:** `Authorization: Bearer <JWT>`
- **Acción:** Invalida el Refresh Token en el servidor.

---

## 🛠 Manejo de Errores

La API utiliza códigos de estado HTTP semánticos y un objeto de respuesta estándar:

```json
{
  "status": 409,
  "error": "Domain Error",
  "message": "El correo electrónico ya está registrado.",
  "details": ["Exception class: UserAlreadyExistsException"]
}
```

- `401 Unauthorized`: Token inválido o expirado.
- `404 Not Found`: Usuario o recurso inexistente.
- `409 Conflict`: Datos duplicados (email) o conflictos de rol.
- `400 Bad Request`: Error de validación o desafío WebAuthn inválido.

---

## 📝 Notas para el Desarrollador Móvil
1. **Roles:** Los roles son `ROLE_LESSOR` y `ROLE_LESSEE`.
2. **WebAuthn:** En Android, se recomienda usar la librería `androidx.credentials`. El backend espera el JSON exacto que devuelve el dispositivo.
3. **Persistencia:** Almacena el `refreshToken` de forma segura (EncryptedSharedPreferences / Keychain).
