# Endpoints — Guía de Consumo (Cliente Móvil)

## `POST /api/llm/contents/generations`

Genera título y descripción de un anuncio con **inferencia real** (grafo v4 → resumen v6 → llama-server/Qwen3). Responde por **streaming SSE** (`text/event-stream`), no por un JSON único.

### URL

```
POST https://<host>/api/llm/contents/generations
```

Nginx enruta cualquier prefijo `/api/llm/*` al servicio `llm_local_service` (puerto interno `8003`). El cliente móvil nunca habla directo con el contenedor, siempre pasa por el proxy.

### Autenticación

Header obligatorio:

```
Authorization: Bearer <JWT>
```

- El JWT lo emite el backend transaccional (no este servicio); el móvil solo lo reenvía.
- Algoritmo esperado: `HS512`.
- Si falta el header, es inválido o expiró, el servicio responde **401** antes de abrir el stream (no llega como evento SSE):
    - `Authorization Bearer token missing`
    - `Token expired`
    - `Invalid token`
    - En los tres casos incluye el header `WWW-Authenticate: Bearer`.

### Headers de la petición

```
Content-Type: application/json
Authorization: Bearer <JWT>
Accept: text/event-stream
```

### Body (JSON)

```json
{
  "draft": {
    "id": "draft-001",
    "propertyType": { "id": "pt-house", "name": "Casa" },
    "address": { "neighborhoodName": "Prudencio Moscoso" },
    "availableToRent": true,
    "areaM2": 200.0,
    "bedrooms": 4,
    "bathrooms": 3,
    "parkingSpaces": 2,
    "constructionYear": 2025,
    "condominium": false,
    "listedPrice": 18500.0,
    "amenities": ["terraza", "jardín", "gimnasio"]
  }
}
```

Todos los campos de `draft` son **obligatorios** salvo `amenities` (default `[]`). Los nombres van en **camelCase** (el backend los mapea internamente a snake_case vía alias de Pydantic). Si falta un campo requerido, el servicio responde **422** antes de abrir el stream.

| Campo | Tipo | Notas |
|---|---|---|
| `id` | string | ID del draft de origen |
| `propertyType.id` / `propertyType.name` | string | — |
| `address.neighborhoodName` | string | — |
| `availableToRent` | bool | — |
| `areaM2` | number | — |
| `bedrooms` | int | — |
| `bathrooms` | number | acepta decimales (ej. `2.5`) |
| `parkingSpaces` | int | — |
| `constructionYear` | int | — |
| `condominium` | bool | — |
| `listedPrice` | number | — |
| `amenities` | string[] | opcional, default `[]` |

### Respuesta: stream SSE

`Content-Type: text/event-stream`. Cada mensaje tiene el formato estándar SSE:

```
event: <nombre>
data: <json>

```

Headers de la respuesta que el cliente debe respetar (no cachear, no cerrar por buffering):

```
Cache-Control: no-cache
X-Accel-Buffering: no
```

#### Contrato de eventos

| Evento | Cuándo ocurre | Payload | Cuántas veces |
|---|---|---|---|
| `queued` | mientras espera turno en la cola de generación | `{"position": 2}` | 0..n (se re-emite al avanzar de posición) |
| `title` | al completarse el título generado por el LLM | `{"text": "..."}` | exactamente 1 |
| `delta` | por cada fragmento de la descripción conforme se genera | `{"text": "..."}` | 0..n |
| `done` | al terminar exitosamente | `{"generationId": "<uuid>", "title": "...", "description": "..."}` | 1 (termina el stream) |
| `error` | ante cualquier fallo durante el pipeline | `{"detail": "..."}` | 1 (termina el stream, no llega `done`) |

El evento `done` es **lo único que el móvil necesita para persistir el resultado** (`generationId`, `title`, `description`). Todo lo demás (decisión del grafo, tiempos, tokens/s, RAM, versiones de modelo) se persiste server-side en `llm_generations` y se consulta con los endpoints de historial (abajo), no viaja en el stream.

#### Ejemplo de stream completo

```
event: title
data: {"text": "Casa en Prudencio Moscoso para renta"}

event: delta
data: {"text": "Un espacio "}

event: delta
data: {"text": "pensado para la familia,"}

event: done
data: {"generationId": "8f14e45f-cecc-4a06-bfef-3b8d29c28fd7", "title": "Casa en Prudencio Moscoso para renta", "description": "Un espacio pensado para la familia…"}

```

### Códigos de error

| Código | Cuándo | ¿Cómo llega? |
|---|---|---|
| `401` | JWT ausente, inválido o expirado | Respuesta HTTP plana (antes de abrir el stream) |
| `422` | El `draft` no cumple el schema (falta un campo requerido) | Respuesta HTTP plana (antes de abrir el stream) |
| `503` | Cola de generación llena, o llama-server no disponible al iniciar el stream | Respuesta HTTP plana si ocurre antes de abrir el stream; si ocurre ya empezado el stream, llega como evento `error` |

Importante para el cliente: un fallo **antes** de que arranque el stream es un error HTTP normal (401/422/503). Un fallo **durante** el stream (ya con `Content-Type: text/event-stream` en la respuesta) llega como evento `error` con `status 200` — el cliente debe parsear el body igual y detectar el evento `error` en vez de esperar un código HTTP distinto.

### Recomendaciones de implementación para el cliente móvil

- Usar un cliente HTTP con soporte nativo de streaming (no esperar a que la conexión cierre para leer el body).
- Parsear línea por línea el formato SSE (`event:` / `data:` separados por línea en blanco).
- Mostrar el `title` en cuanto llegue el evento `title`, y concatenar los `delta.text` en orden de llegada para renderizar la descripción incrementalmente.
- Al recibir `done`, cerrar la conexión y usar `generationId` para referenciar la generación después (ver endpoints de historial).
- Al recibir `error`, cerrar la conexión y mostrar `detail` al usuario; no hay reintento automático del lado del servidor.
- No hay reconexión/resume de stream: si la conexión se corta a medias, hay que reintentar la petición completa (se generará una nueva `generationId`).

---

## Endpoints relacionados (historial)

Útiles para que el móvil consulte generaciones ya hechas sin volver a llamar al LLM.

### `GET /api/llm/contents/generations`

Historial paginado. Requiere el mismo `Authorization: Bearer <JWT>`.

Query params:

| Param | Tipo | Default | Notas |
|---|---|---|---|
| `draftId` | string | — | opcional, filtra por draft de origen |
| `limit` | int | 50 | 1–200 |
| `offset` | int | 0 | — |

Respuesta `200`:

```json
{
  "total": 1,
  "limit": 50,
  "offset": 0,
  "items": [
    {
      "id": "8f14e45f-cecc-4a06-bfef-3b8d29c28fd7",
      "draftId": "draft-001",
      "title": "Casa en Prudencio Moscoso para renta",
      "description": "Un espacio pensado para la familia…",
      "decision": { "...": "..." },
      "warnings": [],
      "graphMs": 12.4,
      "llmS": 1.8,
      "durationS": 1.85,
      "promptTokens": 210,
      "outputTokens": 96,
      "tokensPerSecond": 53.3,
      "ramMb": 412.1,
      "modelFile": "qwen3-1.7b-q4_k_m.gguf",
      "promptVersion": "v6",
      "graphVersion": "v4",
      "source": "http",
      "createdAt": "2026-07-16T18:30:00Z"
    }
  ]
}
```

### `GET /api/llm/contents/generations/{generationId}`

Detalle de una generación puntual (mismo shape que un item de `items` arriba).

| Código | Cuándo |
|---|---|
| `401` | JWT ausente, inválido o expirado |
| `404` | No existe una generación con ese ID |
