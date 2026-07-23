# Documentación de Endpoints

---

# GET `/properties/posts` — Pre-check de elegibilidad para publicar

Verifica **antes de abrir el formulario de publicación** si el lessor autenticado puede publicar una
propiedad nueva. Sirve para no dejar que el usuario llene todo el formulario (datos + subida de
media a Cloudinary) para recién al final enterarse de que su plan no se lo permite.

- **Autenticación:** JWT (Bearer token) de un lessor. El `userId` se toma del token.
- **Quién lo llama:** la app móvil.
- **Cuándo llamarlo:** justo al tocar el botón de "Publicar propiedad" / "Agregar propiedad",
  **antes** de navegar a la pantalla del formulario.

## Regla de negocio

- Los usuarios **premium** no tienen límite → siempre `200`.
- Los usuarios **free** pueden tener máximo **2 propiedades activas**. Si ya alcanzaron ese límite →
  `402`.
- Las propiedades borradas (soft-delete) **no cuentan** para el límite.

## Cómo lo debe usar el móvil

1. Llamar `GET /properties/posts` con el Bearer token del lessor.
2. Según el código de estado:
    - **`200`** → el usuario puede publicar. Abrir el formulario de publicación normalmente.
    - **`402`** → el usuario **no** puede publicar. **No abrir el formulario.** Mostrar la pantalla /
      modal de suscripción usando el `message` de la respuesta, e invitarlo a hacerse Premium.
3. Interceptar el `402` en la capa de manejo de errores para tratarlo como "requiere suscripción",
   **no** como un error genérico ni como un fallo de red.

> El código `402 (Payment Required)` se eligió a propósito para que sea distinguible de un `403`
> (prohibido) o de errores de validación. Es la señal de "esta función requiere suscripción".

## Respuesta exitosa (`200 OK`) — puede publicar

Envelope `BaseResponse<Void>`:

```json
{
    "success": true,
    "data": null,
    "message": "Puedes publicar una nueva propiedad.",
    "status": "OK"
}
```

## Respuesta de límite alcanzado (`402 Payment Required`) — debe suscribirse

Envelope `ErrorResponse` (formato estándar de errores del backend):

```json
{
    "status": 402,
    "error": "Domain Error",
    "message": "Alcanzaste el límite gratuito de 2 propiedades. Hazte Premium para publicar más.",
    "details": [
        "Exception class: PremiumRequiredException"
    ]
}
```

| Campo | Tipo | Descripción |
|---|---|---|
| `status` | int | Código HTTP (`402`) |
| `error` | string | Categoría del error (`"Domain Error"`) |
| `message` | string | Mensaje listo para mostrar al usuario. Incluye el límite configurado |
| `details` | string[] | Metadatos técnicos. El móvil no necesita mostrarlos |

## Otros códigos

| Código | Cuándo |
|---|---|
| `401` | Falta el token o es inválido/expiró |

## Relación con la publicación real

`POST /properties/draft` (creación del draft, primer paso de la publicación real) aplica **la misma
validación** y también responde `402` con el mismo `message` si el lessor free supera el límite.
Es la barrera definitiva del lado del servidor: `GET /properties/posts` es solo un adelanto para
mejorar la experiencia, pero la regla se sigue haciendo cumplir al publicar aunque el cliente omita
el pre-check.

---

# Chat — Límite de conversaciones del lessor free

> ⚠️ **Estas respuestas las emite el servicio de chat (`WS-vivia`, NestJS), NO el backend `vivia`
> (Spring).** El formato de error **no** es el `ErrorResponse` de las secciones anteriores
> (`status` / `error` / `message` / `details`). Parséalas como se documenta aquí, no reutilices el
> parser de errores de vivia.

## Regla de negocio

- Un lessor **free** solo puede sostener **2 conversaciones activas** con lessees.
- El cupo se consume **cuando el lessor RESPONDE** (envía su primer mensaje en una conversación), no
  cuando el lessee lo contacta.
- Los **lessees nunca se bloquean**: siempre pueden escribirle al lessor; simplemente el lessor no
  podrá responderles hasta hacerse Premium o liberar cupo.
- Los usuarios **premium** no tienen límite.
- No hay pre-check: la barrera se aplica **al enviar el mensaje**. Solo puede bloquearse un envío del
  **propio lessor**; nunca un envío del lessee.

Hay **dos** puntos donde el lessor manda mensajes, cada uno responde por su canal:

| Canal | Acción | Respuesta al bloquear |
|---|---|---|
| WebSocket | Enviar mensaje de texto (evento `newMessage`) | Evento `error` con `code` |
| HTTP | Subir documento (`POST /chat/conversations/:id/documents`) | `402 Payment Required` |

---

## WebSocket — evento `newMessage` (texto)

**Éxito (el lessor puede responder):** el servidor emite el evento `newMessage` con el mensaje
creado (mismo evento que reciben los demás participantes). Flujo normal, sin cambios.

**Bloqueado (lessor free en el límite):** el servidor emite un evento `error`. Se agregó un campo
`code` (legible por máquina) además del `reason` de texto:

```json
{
    "event": "error",
    "payload": {
        "reason": "Alcanzaste el límite gratuito de 2 conversaciones. Hazte Premium para responder a más lessees.",
        "code": "CONVERSATION_LIMIT_REACHED"
    }
}
```

| Campo | Tipo | Descripción |
|---|---|---|
| `event` | string | Siempre `"error"` para fallos |
| `payload.reason` | string | Mensaje listo para mostrar al usuario |
| `payload.code` | string? | Código accionable. `"CONVERSATION_LIMIT_REACHED"` = requiere suscripción. **Ausente** en errores genéricos |

**Cómo debe reaccionar el móvil:**

1. Al recibir un `error`, revisar `payload.code`.
2. Si `code === "CONVERSATION_LIMIT_REACHED"` → tratarlo como "requiere suscripción": mostrar la
   pantalla / modal de Premium usando `payload.reason`. **No** mostrarlo como error genérico ni como
   fallo de red.
3. Si `code` viene ausente → es un error normal del chat (validación, no participante, etc.); usar
   solo `reason`.

> El texto del mensaje siempre sigue en `reason` (retrocompatible). Los clientes que aún no leen
> `code` no se rompen, pero **para distinguir el caso de suscripción hay que usar `code`**, no
> comparar el texto.

---

## HTTP — `POST /chat/conversations/:id/documents` (subir documento)

- **Autenticación:** JWT (Bearer token). El `senderId` se toma del token.

**Éxito (`201 Created`):** devuelve el `MessageResponseDto` del documento subido (flujo normal).

**Bloqueado (`402 Payment Required`) — lessor free en el límite:** formato de error **nativo de
NestJS** (no el `ErrorResponse` de vivia):

```json
{
    "statusCode": 402,
    "message": "Alcanzaste el límite gratuito de 2 conversaciones. Hazte Premium para responder a más lessees."
}
```

| Campo | Tipo | Descripción |
|---|---|---|
| `statusCode` | int | Código HTTP (`402`) |
| `message` | string | Mensaje listo para mostrar al usuario |

**Cómo debe reaccionar el móvil:**

1. Interceptar el `402` de este endpoint como "requiere suscripción" → mostrar la pantalla de
   Premium usando `message`. **No** tratarlo como error genérico ni de red.
2. El `402` aquí es semánticamente el mismo concepto que el `402` de propiedades ("esta función
   requiere suscripción"), aunque el **cuerpo tenga otra forma** por venir de otro servicio.

## Otros códigos (chat)

| Código / Evento | Cuándo |
|---|---|
| `401` (HTTP) / cierre `4001` (WS) | Falta el token o es inválido/expiró |
| `403` (HTTP) / `error` sin `code` | El usuario no es participante de la conversación |
