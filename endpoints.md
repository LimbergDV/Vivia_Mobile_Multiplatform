# Documentación de Endpoints

# PATCH `/properties/{id}` — Actualización parcial de una propiedad

Actualiza **únicamente los campos enviados** en el cuerpo de la request. Es un PATCH real: todo campo omitido (o enviado como `null`) conserva su valor actual en la base de datos. Puede enviarse desde un solo campo hasta el cuerpo completo.

- **Autenticación:** JWT con rol `LESSOR`. El arrendador se resuelve del token y **solo puede editar sus propias propiedades** (si no es el dueño → `403`).
- **Content-Type:** `application/json`.
- **Respuesta exitosa:** `200` con envelope `BaseResponse<PropertyResponseDto>` (la propiedad completa ya actualizada, incluyendo medios y amenidades).

## Regla de oro del PATCH parcial

| Cómo se envía el campo | Efecto |
|---|---|
| Omitido del JSON | No se modifica |
| `null` explícito | No se modifica (equivale a omitirlo) |
| Con valor | Se actualiza (y se valida) |

> Consecuencia: **no es posible "borrar" un valor mandando `null`.** Un `null` siempre significa "no tocar".
> Campos desconocidos en el JSON (ej. `"latitude"` al nivel raíz) se ignoran silenciosamente, sin error.

## Qué SÍ actualiza

### Campos escalares (nivel raíz)

| Campo | Tipo | Validación (solo si se envía) |
|---|---|---|
| `title` | string | 10–200 caracteres |
| `description` | string | 20–2000 caracteres |
| `areaM2` | decimal | > 0 |
| `bedrooms` | entero | ≥ 0 |
| `bathrooms` | decimal | ≥ 0.5 |
| `parkingSpaces` | entero | ≥ 0 |
| `constructionYear` | entero | — |
| `isCondominium` | boolean | — |
| `isAvailableToRent` | boolean | — |
| `listedPrice` | decimal | > 0 |

### `propertyTypeId` — tipo de propiedad

UUID de un tipo existente (casa, departamento, etc.). Si el ID no existe → `404`.

```json
{
    "propertyTypeId": "b1a2c3d4-5e6f-7890-abcd-ef1234567890"
}
```

### `address` — dirección (objeto embebido)

Objeto anidado, **también con semántica parcial**: dentro de `address` cada subcampo es opcional y solo se actualiza lo enviado. La dirección se modifica *in place* — el `addressId` de la propiedad **no cambia**, no se crea un registro nuevo.

| Subcampo | Tipo | Validación | Notas |
|---|---|---|---|
| `neighborhoodId` | UUID | Debe existir | `404` si no existe la colonia |
| `street` | string | 1–100 caracteres | |
| `exteriorNumber` | string | 1–10 caracteres | |
| `interiorNumber` | string | ≤ 10 caracteres | |
| `latitude` | decimal | -90 a 90 | **Debe venir junto con `longitude`** |
| `longitude` | decimal | -180 a 180 | **Debe venir junto con `latitude`** |

> ⚠️ **Regla lat/long:** enviar solo una de las dos coordenadas responde `400` con el mensaje `Both latitude and longitude must be provided together`. Juntas actualizan el punto geográfico (PostGIS) usado por las búsquedas por proximidad (`/properties/near-me`).

Cambiar solo la calle y el número:

```json
{
    "address": {
        "street": "Av. Insurgentes Sur",
        "exteriorNumber": "1457"
    }
}
```

Reubicar la propiedad (colonia + coordenadas):

```json
{
    "address": {
        "neighborhoodId": "c7e2a9f1-3d45-6789-bcde-f01234567890",
        "latitude": 19.372850,
        "longitude": -99.179615
    }
}
```

### `amenityIds` — amenidades (lista embebida)

Semántica de **reemplazo total**, no incremental: la lista enviada sustituye por completo a la actual. No existe "agregar una amenidad" — para agregar, el cliente debe enviar la lista completa (las actuales + la nueva).

| Valor enviado | Efecto |
|---|---|
| Omitido / `null` | Las amenidades no se tocan |
| `[]` (lista vacía) | Se **eliminan todas** las amenidades |
| `["id1", "id2"]` | La propiedad queda **exactamente** con esas amenidades |

Si algún ID no existe → `404` (`One or more amenities were not found`) y no se aplica ningún cambio (la operación es transaccional).

```json
{
    "amenityIds": [
        "550e8400-e29b-41d4-a716-446655440010",
        "550e8400-e29b-41d4-a716-446655440011"
    ]
}
```

### `pricePerM2` — campo derivado (no se envía)

`pricePerM2` **no se acepta en el body**: el servidor lo recalcula automáticamente como `listedPrice / areaM2` (redondeo HALF_UP a 2 decimales) cada vez que se envía un nuevo `listedPrice` o `areaM2`, combinando el valor nuevo con el vigente del otro campo.

```json
{
    "listedPrice": 15000.00
}
```

Con `areaM2` actual de `80.50` → el servidor guarda `pricePerM2 = 186.34` sin que el cliente lo calcule.

## Qué NO actualiza

| Dato | Cómo se modifica (si aplica) |
|---|---|
| `id` | Nunca cambia; solo viaja en la URL |
| `lessor` (arrendador) | Nunca cambia de dueño |
| `media` (fotos/videos) | Flujo de medios: `POST/PATCH/DELETE /properties/media` (ver arriba) |
| `pricePerM2` | Derivado; se recalcula solo (ver arriba) |
| `addressId` | La dirección se edita in place, el ID se conserva |
| `createdAt` / `updatedAt` | Automáticos (JPA); `updatedAt` se refresca en cada PATCH |
| `deletedAt` | Borrado lógico; solo lo afecta `DELETE /properties/{id}` |

## Ejemplo completo (todos los bloques a la vez)

```
PATCH /properties/a3f8c1d2-4b56-7890-abcd-ef1234567890
Authorization: Bearer <token>
Content-Type: application/json
```

```json
{
    "title": "Departamento remodelado cerca del metro",
    "listedPrice": 14500.00,
    "isAvailableToRent": true,
    "propertyTypeId": "b1a2c3d4-5e6f-7890-abcd-ef1234567890",
    "address": {
        "street": "Av. Universidad",
        "exteriorNumber": "3000",
        "interiorNumber": "12A",
        "neighborhoodId": "c7e2a9f1-3d45-6789-bcde-f01234567890",
        "latitude": 19.332607,
        "longitude": -99.186966
    },
    "amenityIds": [
        "550e8400-e29b-41d4-a716-446655440010",
        "550e8400-e29b-41d4-a716-446655440011"
    ]
}
```

Respuesta `200`:

```json
{
    "success": true,
    "data": {
        "id": "a3f8c1d2-4b56-7890-abcd-ef1234567890",
        "lessorId": "9f8e7d6c-5b4a-3210-fedc-ba0987654321",
        "propertyTypeId": "b1a2c3d4-5e6f-7890-abcd-ef1234567890",
        "addressId": "d4c3b2a1-0f9e-8d7c-6b5a-432109876543",
        "isAvailableToRent": true,
        "title": "Departamento remodelado cerca del metro",
        "description": "Departamento de 2 recámaras con vista a la calle...",
        "areaM2": 80.50,
        "bedrooms": 2,
        "bathrooms": 1.5,
        "parkingSpaces": 1,
        "constructionYear": 2012,
        "isCondominium": false,
        "listedPrice": 14500.00,
        "pricePerM2": 180.12,
        "createdAt": "2026-05-02T10:15:30",
        "updatedAt": "2026-07-11T18:42:05",
        "media": [
            {
                "id": "e5f6a7b8-9c0d-1e2f-3a4b-5c6d7e8f9a0b",
                "url": "https://vivia-bucket.s3.us-east-1.amazonaws.com/media/public/a3f8c1d2.../portada.jpg",
                "type": "IMAGE",
                "classification": "MAIN"
            }
        ],
        "amenities": [
            { "id": "550e8400-e29b-41d4-a716-446655440010", "name": "Estacionamiento" },
            { "id": "550e8400-e29b-41d4-a716-446655440011", "name": "Alberca" }
        ]
    },
    "message": "Propiedad actualizada exitosamente",
    "status": "OK"
}
```

## Errores

| Código | Causa | Ejemplo de detonante |
|---|---|---|
| `400 Bad Request` | Validación de campos (`@Valid`) | `title` de 5 caracteres, `latitude` de 100 |
| `400 Bad Request` | Coordenada incompleta | `latitude` sin `longitude` (o viceversa) |
| `401 Unauthorized` | Token ausente, inválido o expirado | — |
| `403 Forbidden` | Sin rol `LESSOR`, o la propiedad no es del arrendador autenticado | Editar una propiedad ajena |
| `404 Not Found` | Recurso referenciado inexistente | `id` de propiedad, `propertyTypeId`, `neighborhoodId` o algún `amenityIds` que no existe |

Todos los errores usan el formato `ErrorResponse` estándar del backend; los `404` indican en `details` la clase de excepción (`PropertyNotFoundException`, `PropertyTypeNotFoundException`, `NeighborhoodNotFoundException`, `AmenityNotFoundException`).
