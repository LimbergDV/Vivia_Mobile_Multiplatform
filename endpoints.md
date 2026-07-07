# Documentación de Endpoints — Perfil y Credenciales

Documentación de referencia para agentes y clientes de la API de Vivia.

## Convenciones generales

- **Autenticación:** todos los endpoints de este documento requieren JWT en el header `Authorization: Bearer <token>`. El usuario objetivo siempre se resuelve desde el token (claim de identidad), nunca desde la URL ni el body.
- **Content-Type:** `application/json` en request y response.
- **Formato de respuesta:** todos los endpoints responden con el envelope `BaseResponse<T>`:

```json
{
    "success": true,
    "data": null,
    "message": "Mensaje descriptivo",
    "status": "OK"
}
```

| Campo     | Tipo    | Descripción                                      |
|-----------|---------|--------------------------------------------------|
| `success` | boolean | `true` si la operación fue exitosa               |
| `data`    | T\|null | Payload de respuesta; `null` en operaciones void |
| `message` | string  | Mensaje legible en español                       |
| `status`  | string  | Nombre del status HTTP (ej. `"OK"`)              |

- **Errores comunes a todos los endpoints:**
  - `400 Bad Request` — falla de validación del body (`@Valid`); el mensaje indica el campo inválido.
  - `401 Unauthorized` — token ausente, inválido o expirado.
  - `403 Forbidden` — el rol del usuario no cumple el `@PreAuthorize` del endpoint.

---

## 1. PUT `/lessees/ubication`

Actualiza la latitud y longitud del arrendatario (lessee) autenticado.

- **Controlador:** `LesseeController.updateUbication`
- **Rol requerido:** `LESSEE`
- **Request body** (`UpdateLesseeUbicationDto`):

```json
{
    "latitude": 19.432608,
    "longitude": -99.133209
}
```

| Campo       | Tipo    | Requerido | Validación                  |
|-------------|---------|-----------|-----------------------------|
| `latitude`  | decimal | Sí        | Entre `-90.0` y `90.0`      |
| `longitude` | decimal | Sí        | Entre `-180.0` y `180.0`    |

- **Respuesta 200:**

```json
{
    "success": true,
    "data": null,
    "message": "Ubicación actualizada exitosamente",
    "status": "OK"
}
```

- **Errores específicos:** `404 Not Found` si el lessee no existe (`LesseeNotFoundException`).
- **Nota:** existe un endpoint equivalente `PATCH /users/me/ubication` (`LesseeProfileController`) que ejecuta la misma lógica de servicio.

---

## 2. PATCH `/auth/me/password`

Cambia la contraseña del usuario autenticado. Solo funciona si el usuario ya tiene una credencial de tipo `PASSWORD` registrada (no crea una nueva).

- **Controlador:** `AuthProfileController.updatePassword`
- **Rol requerido:** cualquier usuario autenticado
- **Request body** (`UpdatePasswordRequestDto`):

```json
{
    "password": "NuevaContraseña123"
}
```

| Campo      | Tipo   | Requerido | Validación             |
|------------|--------|-----------|------------------------|
| `password` | string | Sí        | Mínimo 8 caracteres    |

- **Respuesta 200:**

```json
{
    "success": true,
    "data": null,
    "message": "Contraseña actualizada",
    "status": "OK"
}
```

- **Errores específicos:** error de credencial (`InvalidCredentialException`) con mensaje `"Este usuario no tiene contraseña configurada."` si el usuario solo tiene login biométrico/Google.

---

## 3. PUT `/users/me/photo`

**No sube la imagen directamente.** Genera una URL prefirmada (presigned PUT) de S3 para que el cliente suba la foto de perfil por su cuenta. Flujo:

1. Llamar este endpoint con el `contentType` de la imagen.
2. Hacer `PUT` del binario de la imagen a `presignedUrl` (antes de que expire) con el header `Content-Type` igual al enviado.
3. La foto queda disponible públicamente en `photoUrl`.

- **Controlador:** `UserController.getPhotoUploadUrl`
- **Rol requerido:** cualquier usuario autenticado
- **Request body** (`PhotoPresignRequestDto`):

```json
{
    "contentType": "image/jpeg"
}
```

| Campo         | Tipo   | Requerido | Validación                              |
|---------------|--------|-----------|-----------------------------------------|
| `contentType` | string | Sí        | Solo `image/jpeg` o `image/png`         |

- **Respuesta 200** (`data` = `PhotoPresignResponseDto`):

```json
{
    "success": true,
    "data": {
        "presignedUrl": "https://vivia-media-bucket.s3.us-east-1.amazonaws.com/profile-photos/<uuid>/avatar?X-Amz-Algorithm=AWS4-HMAC-SHA256&...",
        "photoUrl": "https://vivia-media-bucket.s3.us-east-1.amazonaws.com/profile-photos/<uuid>/avatar",
        "expiresInSeconds": 300
    },
    "message": "URL generada",
    "status": "OK"
}
```

| Campo              | Tipo   | Descripción                                             |
|--------------------|--------|---------------------------------------------------------|
| `presignedUrl`     | string | URL PUT prefirmada de S3; expira                        |
| `photoUrl`         | string | URL pública permanente donde quedará la foto            |
| `expiresInSeconds` | int    | Segundos de vigencia de la presigned URL                |

- **Errores específicos:** tipo de contenido no permitido (`InvalidPhotoException`): `"Tipo de contenido no permitido: solo image/jpeg o image/png"`.

---

## 4. PATCH `/users/me/name`

Actualiza el nombre y apellidos del usuario autenticado.

- **Controlador:** `UserController.updateName`
- **Rol requerido:** cualquier usuario autenticado
- **Request body** (`UpdateUserNameRequestDto`):

```json
{
    "name": "Alexis",
    "paternalSurname": "Guzmán",
    "maternalSurname": "González"
}
```

| Campo             | Tipo   | Requerido | Validación   |
|-------------------|--------|-----------|--------------|
| `name`            | string | Sí        | No vacío     |
| `paternalSurname` | string | Sí        | No vacío     |
| `maternalSurname` | string | No        | —            |

- **Respuesta 200:**

```json
{
    "success": true,
    "data": null,
    "message": "Nombre actualizado",
    "status": "OK"
}
```

---

## 5. PATCH `/users/me/email`

Actualiza el correo electrónico del usuario autenticado.

- **Controlador:** `UserController.updateEmail`
- **Rol requerido:** cualquier usuario autenticado
- **Request body** (`UpdateUserEmailRequestDto`):

```json
{
    "email": "nuevo@example.com"
}
```

| Campo   | Tipo   | Requerido | Validación                       |
|---------|--------|-----------|----------------------------------|
| `email` | string | Sí        | No vacío, formato de email válido |

- **Respuesta 200:**

```json
{
    "success": true,
    "data": null,
    "message": "Correo actualizado",
    "status": "OK"
}
```

---

## 6. PATCH `/users/me/phone`

Actualiza el número de teléfono del arrendador (lessor) autenticado.

- **Controlador:** `LessorProfileController.updatePhone`
- **Rol requerido:** `LESSOR` (otros roles reciben `403`)
- **Request body** (`UpdateLessorPhoneRequestDto`):

```json
{
    "phoneNumber": "5512345678"
}
```

| Campo         | Tipo   | Requerido | Validación                                          |
|---------------|--------|-----------|-----------------------------------------------------|
| `phoneNumber` | string | Sí        | 10 a 15 dígitos, prefijo `+` opcional (`^\+?[0-9]{10,15}$`) |

- **Respuesta 200:**

```json
{
    "success": true,
    "data": null,
    "message": "Teléfono actualizado",
    "status": "OK"
}
```

---

## Resumen rápido

| Método | Ruta                 | Rol      | Body (campos)                              | `data` de respuesta        |
|--------|----------------------|----------|--------------------------------------------|-----------------------------|
| PUT    | `/lessees/ubication` | LESSEE   | `latitude`, `longitude`                    | `null`                      |
| PATCH  | `/auth/me/password`  | Auth     | `password`                                 | `null`                      |
| PUT    | `/users/me/photo`    | Auth     | `contentType`                              | `PhotoPresignResponseDto`   |
| PATCH  | `/users/me/name`     | Auth     | `name`, `paternalSurname`, `maternalSurname` | `null`                    |
| PATCH  | `/users/me/email`    | Auth     | `email`                                    | `null`                      |
| PATCH  | `/users/me/phone`    | LESSOR   | `phoneNumber`                              | `null`                      |
