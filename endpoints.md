### Errores estructurados que devuelve el servicio de IA

Implementado en `POST /api/llm/contents/generations` (generación real de título/descripción). El cliente Flutter debe leer el campo `detail.code` (no el texto de `message`, que puede cambiar) para decidir qué UI mostrar.

#### `403` — Sin suscripción Premium

```json
{
  "detail": {
    "code": "premium_required",
    "message": "Requiere suscripción Premium para generar contenido con IA."
  }
}
```

- **Causa:** el JWT es válido, pero `GET /subscriptions/me` respondió `active: false`.
- **UI sugerida:** mostrar paywall / CTA de upgrade a Premium. No es un error transitorio — no reintentar automáticamente.

#### `503` — No se pudo verificar el estado de suscripción

```json
{
  "detail": {
    "code": "subscription_check_failed",
    "message": "No se pudo verificar el estado de suscripción, intenta más tarde."
  }
}
```

- **Causa:** timeout, error de red o respuesta no-200 al consultar `/subscriptions/me` (fail closed — no implica que el usuario no sea premium).
- **UI sugerida:** mensaje de "inténtalo de nuevo" / permitir reintento manual. Distinto de `premium_required`: aquí sí conviene reintentar.

#### `401` — JWT ausente, inválido o expirado

Ya cubierto arriba; se mantiene el formato existente (`detail` como string), sin cambios.

| `detail.code` | HTTP | Significado para el cliente |
|---|---|---|
| `premium_required` | 403 | Usuario autenticado pero sin Premium activo — mostrar paywall |
| `subscription_check_failed` | 503 | No se pudo verificar el estado — permitir reintento |

---