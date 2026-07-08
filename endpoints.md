# Documentación de Endpoints — Verificación de Identidad del Arrendador

Documentación de referencia para el cliente móvil sobre el flujo de verificación de identidad del arrendador (`/lessors/verifications`).

## Convenciones generales

- **Autenticación:** todos los endpoints requieren JWT en el header `Authorization: Bearer <token>` y rol `LESSOR`. El arrendador objetivo siempre se resuelve desde el token (claim de identidad).
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
  - `403 Forbidden` — el usuario autenticado no tiene rol `LESSOR`.
  - `404 Not Found` — el arrendador del token no existe (`LessorNotFoundException`).

## Estados de verificación

El arrendador siempre está en uno de estos estados (`VerificationStatus`):

| Estado           | Significado                                                    |
|------------------|----------------------------------------------------------------|
| `UNVERIFIED`     | No ha iniciado el proceso o fue reiniciado                     |
| `PENDING_REVIEW` | Solicitó URLs de carga; documentos en revisión por un admin    |
| `VERIFIED`       | Identidad aprobada por el administrador                        |
| `REJECTED`       | Rechazada; los motivos vienen en `rejection`                   |

## Tipos de documento

Los documentos requeridos (`DocumentType`) son exactamente tres:

| Valor       | Documento               |
|-------------|-------------------------|
| `INE_FRONT` | INE — frente            |
| `INE_BACK`  | INE — reverso           |
| `SELFIE`    | Selfie del arrendador   |

---

## 1. POST `/lessors/verifications/upload-urls`

**No recibe las imágenes directamente.** Genera URLs prefirmadas (presigned PUT) de S3 para que el cliente suba los documentos de identidad por su cuenta, y cambia el estado de verificación a `PENDING_REVIEW`. Flujo:

1. Llamar este endpoint con la lista de documentos (tipo + `contentType` de cada uno).
2. Hacer `PUT` del binario de cada imagen a su `uploadUrl` (antes de que expire) con el header `Content-Type` igual al enviado.
3. Cada documento queda disponible en su `publicUrl`; el backend registra la subida y el admin revisa.

- **Controlador:** `LessorVerificationController.requestUploadUrls`
- **Rol requerido:** `LESSOR`
- **Request body** (`VerificationUploadRequestDto`):

```json
{
  "documents": [
    { "documentType": "INE_FRONT", "contentType": "image/jpeg" },
    { "documentType": "INE_BACK",  "contentType": "image/jpeg" },
    { "documentType": "SELFIE",    "contentType": "image/png" }
  ]
}
```

| Campo                      | Tipo   | Requerido | Validación                                               |
|----------------------------|--------|-----------|----------------------------------------------------------|
| `documents`                | array  | Sí        | Al menos un elemento                                     |
| `documents[].documentType` | string | Sí        | `INE_FRONT`, `INE_BACK` o `SELFIE`                       |
| `documents[].contentType`  | string | Sí        | `image/jpeg`, `image/png`, `image/heic` o `image/heif`   |

- **Respuesta 200** (`data` = `VerificationUploadResponseDto`):

```json
{
  "success": true,
  "data": {
    "uploads": [
      {
        "documentType": "INE_FRONT",
        "uploadUrl": "https://vivia-media-bucket.s3.us-east-1.amazonaws.com/verifications/<uuid>/INE_FRONT?X-Amz-Algorithm=AWS4-HMAC-SHA256&...",
        "publicUrl": "https://vivia-media-bucket.s3.us-east-1.amazonaws.com/verifications/<uuid>/INE_FRONT"
      }
    ],
    "expiresInSeconds": 300
  },
  "message": "URLs de carga generadas",
  "status": "OK"
}
```

| Campo                    | Tipo   | Descripción                                          |
|--------------------------|--------|------------------------------------------------------|
| `uploads[].documentType` | string | Tipo de documento al que corresponde la URL          |
| `uploads[].uploadUrl`    | string | URL PUT prefirmada de S3; expira                     |
| `uploads[].publicUrl`    | string | URL pública permanente donde quedará el documento    |
| `expiresInSeconds`       | int    | Segundos de vigencia de las presigned URLs           |

- **Errores específicos:** tipo de contenido no permitido (`InvalidLessorDocumentException`): `"Tipo de contenido no permitido: <tipo>. Solo se aceptan: [image/jpeg, image/png, image/heic, image/heif]"`.
- **Nota:** el estado pasa a `PENDING_REVIEW` desde el momento en que se generan las URLs, aun si el cliente todavía no sube los archivos.

---

## 2. GET `/lessors/verifications`

Devuelve el estado de verificación actual del arrendador autenticado. Si la verificación fue rechazada, incluye los motivos del rechazo.

- **Controlador:** `LessorVerificationController.getVerificationStatus`
- **Rol requerido:** `LESSOR`
- **Request body:** ninguno.
- **Respuesta 200** (`data` = `VerificationStatusResponseDto`):

```json
{
  "success": true,
  "data": {
    "verificationStatus": "REJECTED",
    "rejection": {
      "comment": "La imagen del INE está borrosa",
      "reasons": ["INE ilegible", "Selfie no coincide"],
      "createdAt": "2026-07-01T10:30:00-06:00"
    }
  },
  "message": "Estado de verificación obtenido",
  "status": "OK"
}
```

| Campo                | Tipo         | Descripción                                                          |
|----------------------|--------------|----------------------------------------------------------------------|
| `verificationStatus` | string       | `UNVERIFIED`, `PENDING_REVIEW`, `VERIFIED` o `REJECTED`              |
| `rejection`          | object\|null | Motivos del rechazo; `null` si no hay un rechazo activo             |
| `rejection.comment`  | string       | Comentario libre del administrador                                   |
| `rejection.reasons`  | string[]     | Situaciones predefinidas que motivaron el rechazo                    |
| `rejection.createdAt`| datetime     | Fecha en que se registró el rechazo (ISO 8601 con offset)            |

---

## 3. PATCH `/lessors/verifications`

Reinicia la verificación: resetea el estado a `UNVERIFIED`, elimina los registros de documentos subidos y borra el rechazo activo (si existe). Útil para reintentar después de un `REJECTED`. El arrendador se resuelve desde el JWT — no recibe ID ni body.

- **Controlador:** `LessorVerificationController.resetVerificationStatus`
- **Rol requerido:** `LESSOR`
- **Request body:** ninguno.
- **Respuesta 204:**

```json
{
    "success": true,
    "data": null,
    "message": "Verificación reiniciada",
    "status": "NO_CONTENT"
}
```

---

## Flujo completo desde el cliente móvil

1. `GET /lessors/verifications` → si el estado es `UNVERIFIED` o `REJECTED`, mostrar el flujo de captura de documentos.
2. `POST /lessors/verifications/upload-urls` con los tres documentos (`INE_FRONT`, `INE_BACK`, `SELFIE`).
3. Subir cada imagen con `PUT` a su `uploadUrl` antes de `expiresInSeconds`.
4. Consultar `GET /lessors/verifications` para reflejar `PENDING_REVIEW` y, tras la revisión del admin, `VERIFIED` o `REJECTED`.
5. Si fue `REJECTED` y el usuario quiere reintentar: `PATCH /lessors/verifications` y volver al paso 2.

## Resumen rápido

| Método | Ruta                                  | Rol    | Body (campos)                       | `data` de respuesta              |
|--------|---------------------------------------|--------|-------------------------------------|-----------------------------------|
| POST   | `/lessors/verifications/upload-urls`  | LESSOR | `documents[]` (tipo + contentType)  | `VerificationUploadResponseDto`   |
| GET    | `/lessors/verifications`              | LESSOR | —                                   | `VerificationStatusResponseDto`   |
| PATCH  | `/lessors/verifications`              | LESSOR | —                                   | `null` (204)                      |
