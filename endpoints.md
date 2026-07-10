# Documentación de Endpoints — Gestión de Medios de Propiedades Publicadas

Documentación de referencia para el cliente móvil sobre la gestión de medios (imágenes y videos) de propiedades **ya publicadas** (`/properties/media`). Cubre tres operaciones: agregar medios nuevos, cambiar la imagen principal y eliminar un medio.

> Estos endpoints operan sobre propiedades existentes. La subida inicial de medios durante la creación de una propiedad ocurre en el flujo de borradores (drafts) y no se documenta aquí.

## Convenciones generales

- **Autenticación:** todos los endpoints requieren JWT en el header `Authorization: Bearer <token>` y rol `LESSOR`. El arrendador se resuelve siempre desde el token; solo puede operar sobre medios de **sus propias** propiedades.
- **Content-Type:** `application/json` en request y response.
- **Formato de respuesta:** salvo el DELETE (que responde `204` sin body), los endpoints responden con el envelope `BaseResponse<T>`:

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
| `status`  | string  | Nombre del status HTTP (ej. `"OK"`, `"CREATED"`) |

- **Errores comunes a todos los endpoints:**
  - `400 Bad Request` — falla de validación del body (`@Valid`) u operación inválida (`InvalidMediaOperationException`).
  - `401 Unauthorized` — token ausente, inválido o expirado.
  - `403 Forbidden` — el usuario no tiene rol `LESSOR`, o el medio/propiedad no le pertenece (`MediaOwnershipException`, `PropertyOwnershipException`).
  - `404 Not Found` — el medio o la propiedad no existen (`MediaNotFoundException`, `PropertyNotFoundException`).

## Conceptos clave

- **Medio (`PropertyMedia`):** archivo asociado a una propiedad. Tiene `type` (`IMAGE` o `VIDEO`) y `classification` (texto libre: `MAIN`, `INTERIOR`, `EXTERIOR`, `BATHROOM`, `BEDROOM`, `OTHER`, etc.).
- **Imagen principal:** la imagen con `classification = MAIN`. Toda propiedad publicada tiene exactamente una; es la portada en listados. Por eso **no se puede eliminar directamente** ni se puede agregar una nueva con esa clasificación — solo se reasigna con el PATCH.
- **Sesión de subida (`MediaUploadSession`):** al agregar medios no se envían los binarios al backend. El POST crea una sesión temporal en Redis (TTL de 2 horas por defecto) y devuelve URLs prefirmadas de S3; el cliente sube los archivos directo a S3 y el backend los procesa de forma asíncrona (moderación de contenido incluida).

---

## 1. POST `/properties/media`

Agrega medios nuevos a una propiedad publicada. **No recibe los archivos** — recibe un *manifiesto* (lista de archivos con su metadata) y devuelve una URL PUT prefirmada de S3 por cada uno. Flujo:

1. Llamar este endpoint con el `propertyId` y el manifiesto de archivos.
2. Hacer `PUT` del binario de cada archivo a su `uploadUrl` (antes de que expire) con el header `Content-Type` igual al declarado en el manifiesto.
3. S3 notifica al backend por cada archivo subido (webhook interno vía Lambda). Cuando llegan todos los archivos de la sesión, el contenido pasa a **moderación automática asíncrona**.
4. Si el contenido es **aprobado**, los medios se asocian a la propiedad y quedan visibles; el arrendador recibe una notificación push ("Tus nuevos medios están disponibles"). Si es **rechazado**, los archivos se eliminan de S3 y llega una notificación con el motivo ("Los medios no pudieron publicarse").

- **Controlador:** `PropertyMediaController.addMedia`
- **Rol requerido:** `LESSOR` (dueño de la propiedad)
- **Request body** (`AddPropertyMediaDto`):

```json
{
    "propertyId": "550e8400-e29b-41d4-a716-446655440000",
    "mediaManifest": [
        { "fileKey": "sala-1",  "contentType": "image/jpeg", "sizeBytes": 204800, "classification": "INTERIOR" },
        { "fileKey": "fachada", "contentType": "image/png",  "sizeBytes": 512000, "classification": "EXTERIOR" },
        { "fileKey": "tour",    "contentType": "video/mp4",  "sizeBytes": 8388608, "classification": "OTHER" }
    ]
}
```

| Campo                          | Tipo   | Requerido | Validación                                                        |
|--------------------------------|--------|-----------|-------------------------------------------------------------------|
| `propertyId`                   | UUID   | Sí        | Propiedad existente, no eliminada, del arrendador autenticado      |
| `mediaManifest`                | array  | Sí        | Al menos un elemento; sin `fileKey` duplicados                     |
| `mediaManifest[].fileKey`      | string | Sí        | Solo letras, números, guiones y guiones bajos (`[a-zA-Z0-9_-]+`); único dentro de la sesión |
| `mediaManifest[].contentType`  | string | Sí        | MIME de imagen o video (`image/*` o `video/*`)                    |
| `mediaManifest[].sizeBytes`    | long   | Sí        | Mayor a cero                                                       |
| `mediaManifest[].classification` | string | Sí      | Clasificación del medio (`INTERIOR`, `EXTERIOR`, etc.). **No puede ser `MAIN`** |

- **Respuesta 201** (`data` = `MediaUploadSessionResponseDto`):

```json
{
    "success": true,
    "data": {
        "sessionId": "7f8a9b0c-1d2e-4f3a-8b4c-5d6e7f8a9b0c",
        "propertyId": "550e8400-e29b-41d4-a716-446655440000",
        "status": "MEDIA_UPLOAD_PENDING",
        "expiresAt": "2026-07-09T20:00:00Z",
        "uploads": [
            {
                "fileKey": "sala-1",
                "uploadUrl": "https://vivia-media-bucket.s3.amazonaws.com/media/property-staging/7f8a9b0c-.../sala-1?X-Amz-Algorithm=AWS4-HMAC-SHA256&...",
                "storageKey": "media/property-staging/7f8a9b0c-1d2e-4f3a-8b4c-5d6e7f8a9b0c/sala-1",
                "expiresInSeconds": 900
            }
        ]
    },
    "message": "Sesión de subida creada. Usa las URLs de 'uploads' para subir los archivos directamente a S3.",
    "status": "CREATED"
}
```

| Campo                        | Tipo     | Descripción                                                       |
|------------------------------|----------|--------------------------------------------------------------------|
| `sessionId`                  | UUID     | ID de la sesión de subida (vive en Redis hasta `expiresAt`)        |
| `propertyId`                 | UUID     | Propiedad a la que se asociarán los medios                        |
| `status`                     | string   | Estado inicial de la sesión: `MEDIA_UPLOAD_PENDING`               |
| `expiresAt`                  | datetime | Expiración de la sesión (ISO 8601 UTC); TTL de 2 horas por defecto |
| `uploads[].fileKey`          | string   | Identificador del archivo, igual al enviado en el manifiesto      |
| `uploads[].uploadUrl`        | string   | URL PUT prefirmada de S3; expira                                  |
| `uploads[].storageKey`       | string   | Ruta del archivo en el bucket (staging)                           |
| `uploads[].expiresInSeconds` | int      | Segundos de vigencia de la URL prefirmada                          |

- **Errores específicos:**
  - `400` — algún elemento del manifiesto trae `classification = "MAIN"`: `"Media manifest cannot contain MAIN classification"`.
  - `400` — `fileKey` repetido: `"Duplicate fileKey in manifest: <fileKey>"`.
  - `403` — la propiedad no pertenece al arrendador del token.
  - `404` — `propertyId` no existe o la propiedad está eliminada.
- **Notas:**
  - El endpoint responde de inmediato; la publicación de los medios es **eventual** (segundos o minutos después de subir, tras la moderación). El cliente debe reflejarlo como "en revisión" y confiar en la notificación push para actualizar la vista.
  - Si la sesión expira antes de que se suban todos los archivos, los medios no se publican y hay que crear una sesión nueva.

---

## 2. PATCH `/properties/media`

Cambia la imagen principal de una propiedad en una sola operación atómica: la imagen actual con `classification = MAIN` pasa a `OTHER`, y la imagen indicada pasa a `MAIN`. Ambas deben pertenecer a la misma propiedad del arrendador autenticado.

- **Controlador:** `PropertyMediaController.changeMainImage`
- **Rol requerido:** `LESSOR` (dueño de ambas imágenes)
- **Request body** (`ChangeMainImageDto`) — ojo: los campos van en `snake_case`:

```json
{
    "main_image_id": "b1e2c3d4-5f6a-4b7c-8d9e-0a1b2c3d4e5f",
    "new_main_image_id": "c2f3d4e5-6a7b-4c8d-9e0f-1a2b3c4d5e6f"
}
```

| Campo               | Tipo | Requerido | Validación                                                       |
|---------------------|------|-----------|-------------------------------------------------------------------|
| `main_image_id`     | UUID | Sí        | Medio existente con `classification = MAIN`                       |
| `new_main_image_id` | UUID | Sí        | Medio existente de tipo `IMAGE`; distinto de `main_image_id`; misma propiedad |

- **Respuesta 200:**

```json
{
    "success": true,
    "data": null,
    "message": "Imagen principal actualizada correctamente",
    "status": "OK"
}
```

- **Errores específicos:**
  - `400` — ambos IDs son iguales: `"main_image_id and new_main_image_id must be different"`.
  - `400` — las imágenes son de propiedades distintas: `"Both images must belong to the same property"`.
  - `400` — `main_image_id` no es la imagen MAIN actual: `"main_image_id does not have classification MAIN"`.
  - `400` — el nuevo medio es un video: `"New main image must be an IMAGE"`.
  - `403` — alguno de los medios no pertenece al arrendador del token.
  - `404` — alguno de los IDs no existe.

---

## 3. DELETE `/properties/media/{id}`

Elimina un medio de la propiedad. El borrado es definitivo y transaccional: primero elimina el archivo de S3 y después el registro de la base de datos. **La imagen principal (`MAIN`) no se puede eliminar** — para quitarla hay que primero promover otra imagen con el PATCH y luego eliminarla (ya como `OTHER`).

- **Controlador:** `PropertyMediaController.deleteMedia`
- **Rol requerido:** `LESSOR` (dueño del medio)
- **Path param:** `id` (UUID) — ID del medio a eliminar.
- **Request body:** ninguno.
- **Respuesta 204:** sin body (a diferencia de los otros endpoints, no usa el envelope `BaseResponse`).
- **Errores específicos:**
  - `403` — el medio no pertenece al arrendador del token: `"Media does not belong to the authenticated lessor"`.
  - `404` — el medio no existe: `"Media not found with id: <id>"`.
  - `409 Conflict` — el medio es la imagen `MAIN` (`MainImageDeletionException`): `"You cannot delete the main image of the property."`.

**Ejemplo:**

```
DELETE /properties/media/c2f3d4e5-6a7b-4c8d-9e0f-1a2b3c4d5e6f
Authorization: Bearer <token>

→ 204 No Content
```

---

## Flujo completo desde el cliente móvil

Contexto típico: pantalla de "editar propiedad" del arrendador, sección de galería.

**Agregar fotos/videos:**

1. El usuario selecciona archivos nuevos en la galería.
2. `POST /properties/media` con el manifiesto (una clasificación por archivo, nunca `MAIN`).
3. Subir cada binario con `PUT` a su `uploadUrl` antes de `expiresInSeconds`, con el `Content-Type` declarado.
4. Mostrar los medios como "en revisión". La confirmación llega por notificación push: aprobados (visibles en la propiedad) o rechazados por moderación (con motivo).

**Cambiar la portada:**

1. El usuario elige otra imagen de la galería como principal.
2. `PATCH /properties/media` con el ID de la imagen `MAIN` actual y el de la nueva.
3. Refrescar la galería: la portada anterior queda como `OTHER`.

**Eliminar un medio:**

1. El usuario borra una foto o video de la galería.
2. `DELETE /properties/media/{id}`.
3. Si el servidor responde `409`, la imagen es la portada: pedir al usuario que primero elija otra portada (PATCH) y reintentar.

## Resumen rápido

| Método | Ruta                     | Rol    | Body (campos)                          | Respuesta exitosa                          |
|--------|--------------------------|--------|-----------------------------------------|---------------------------------------------|
| POST   | `/properties/media`      | LESSOR | `propertyId`, `mediaManifest[]`         | `201` — `MediaUploadSessionResponseDto`     |
| PATCH  | `/properties/media`      | LESSOR | `main_image_id`, `new_main_image_id`    | `200` — `data: null`                        |
| DELETE | `/properties/media/{id}` | LESSOR | — (ID en la ruta)                       | `204` — sin body                            |
