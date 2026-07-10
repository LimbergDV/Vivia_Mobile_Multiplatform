# Guía de integración — ViVia Maps API

Servicio propio de mapas de ViVia. Expone **geocodificación** (dirección ⇄
coordenadas) y el **basemap vectorial** que el cliente pinta. Cobertura:
**estado de Chiapas, México**.

- **Base URL (producción):** `https://vivia.aleosh.online/api/maps`
- **Swagger UI (contrato completo):** `https://vivia.aleosh.online/api/maps/docs`
- Todos los endpoints son `GET`, sin autenticación, con CORS abierto (solo lectura).

> Todos los ejemplos de respuesta de este documento son salidas reales del
> servicio con los datos OSM de Chiapas importados (julio 2026).

---

## 1. Librerías sugeridas

### Flutter (cliente principal)

| Librería | Uso | Nota |
|---|---|---|
| [`maplibre_gl`](https://pub.dev/packages/maplibre_gl) | Pintar el mapa vectorial | Se le pasa la URL de `/style.json` como `styleString`; no necesita API key |
| [`dio`](https://pub.dev/packages/dio) o [`http`](https://pub.dev/packages/http) | Llamar a `/geocode` y `/reverse` | `dio` facilita timeouts, reintentos e interceptores |
| [`geolocator`](https://pub.dev/packages/geolocator) *(opcional)* | GPS del dispositivo | Para centrar el mapa o hacer reverse de la posición actual |

> **No usar** `flutter_map` con este servicio: está orientado a tiles raster.
> El basemap aquí es vectorial (estilo MapLibre), por eso `maplibre_gl`.

### Web (si vivia-web lo necesita)

| Librería | Uso |
|---|---|
| [`maplibre-gl`](https://www.npmjs.com/package/maplibre-gl) (JS) | Mismo `style.json`; ver demo funcional en [test/map.html](../vps/vivia-maps/test/map.html) |
| `fetch` nativo | Geocodificación |

### Backend (vivia / vivia-ai)

Cualquier cliente HTTP (RestClient de Spring, `httpx` en Python). Dentro del
VPS conviene llamar directo por la red Docker: `http://vivia-maps-api:8004`
(sin pasar por el gateway).

---

## 2. Geocodificación

### 2.1 Dirección → coordenadas: `GET /geocode`

| Parámetro | Tipo | Descripción |
|---|---|---|
| `q` | string (mín. 3) | Dirección en texto libre |
| `limit` | int 1-20 (default 5) | Máximo de candidatos |

Devuelve una **lista ordenada por relevancia** (`importance` descendente); el
primer elemento suele ser el mejor. Lista vacía `[]` = sin resultados (no es
error). La búsqueda está acotada a Chiapas.

**Calle con ciudad:**

```bash
curl "https://vivia.aleosh.online/api/maps/geocode?q=Avenida%20Central%20Poniente,%20Tuxtla%20Guti%C3%A9rrez&limit=2"
```

```json
[
  {"lat": 16.7548846, "lon": -93.1273401, "display_name": "Avenida Central Poniente, Tuxtla Gutiérrez, Chiapas, 29060, México", "type": "primary", "importance": 0.053},
  {"lat": 16.7540935, "lon": -93.1191724, "display_name": "Avenida Central Poniente, Tuxtla Gutiérrez, Chiapas, 29040, México", "type": "primary", "importance": 0.053}
]
```

**Calle + código postal** (el CP desambigua mejor que la colonia):

```bash
curl ".../geocode?q=5a%20Avenida%20Norte%20Poniente,%2029000&limit=1"
# → 5a Avenida Norte Poniente, Terán, Tuxtla Gutiérrez, Chiapas, 29020, México (16.7567, -93.1666)
```

**Solo código postal** (devuelve el centroide de la zona):

```bash
curl ".../geocode?q=29000%20Tuxtla%20Guti%C3%A9rrez&limit=1"
```
```json
[{"lat": 16.7541266, "lon": -93.0905056, "display_name": "29000, Tuxtla Gutiérrez, Chiapas, México", "type": "postcode", "importance": 0.12}]
```

**Otras ciudades del estado:**

```bash
curl ".../geocode?q=Real%20de%20Guadalupe,%20San%20Crist%C3%B3bal%20de%20las%20Casas&limit=1"
# → Calle Real de Guadalupe, San Cristóbal de las Casas, 29200 (16.7379, -92.6282)

curl ".../geocode?q=4a%20Avenida%20Norte,%20Tapachula&limit=1"
# → 4a Avenida Norte, Colinas de Rey, Tapachula, 30710 (14.9224, -92.2569)
```

**Ciudad completa:**

```bash
curl ".../geocode?q=Tuxtla%20Guti%C3%A9rrez,%20Chiapas&limit=1"
# → type: "administrative", (16.7452, -93.1418)
```

**Ejemplo Flutter (dio):**

```dart
final dio = Dio(BaseOptions(
  baseUrl: "https://vivia.aleosh.online/api/maps",
  connectTimeout: const Duration(seconds: 10),
));

Future<({double lat, double lon, String name})?> geocode(String direccion) async {
  final r = await dio.get("/geocode", queryParameters: {"q": direccion, "limit": 1});
  final hits = r.data as List;
  if (hits.isEmpty) return null; // sin resultados: pedir al usuario reformular
  final h = hits.first;
  return (lat: h["lat"] as double, lon: h["lon"] as double, name: h["display_name"] as String);
}
```

### 2.2 Coordenadas → dirección: `GET /reverse`

| Parámetro | Tipo |
|---|---|
| `lat` | float [-90, 90] |
| `lon` | float [-180, 180] |

```bash
curl ".../reverse?lat=16.7369&lon=-92.6376"
```

```json
{
  "lat": 16.7366877,
  "lon": -92.6375835,
  "display_name": "31 de Marzo, San Cristóbal, San Cristóbal de las Casas, Chiapas, 29200, México",
  "address": {
    "road": "31 de Marzo",
    "neighbourhood": null,
    "suburb": null,
    "city": "San Cristóbal",
    "town": null,
    "village": null,
    "state": "Chiapas",
    "postcode": "29200",
    "country": "México"
  }
}
```

Uso típico: el usuario suelta un pin / hace tap en el mapa y se muestra la
dirección legible. Devuelve **404** si no hay nada cerca de la coordenada
(p.ej. en medio de la selva); manéjalo como "ubicación sin dirección", no como
falla del servicio.

### 2.3 Errores

| Código | Significado | Cómo manejarlo |
|---|---|---|
| `200` con `[]` | Sin resultados | Pedir al usuario reformular (ver §4) |
| `404` (solo `/reverse`) | Sin dirección cercana | Mostrar solo coordenadas |
| `422` | Parámetros inválidos (q corto, lat/lon fuera de rango) | Bug del cliente; validar antes de llamar |
| `502` | Nominatim caído | Reintentar con backoff; reportar |

---

## 3. Obtener el mapa

El "mapa" no es una imagen: es un **estilo MapLibre + vector tiles**. El
cliente solo necesita la URL del estilo; MapLibre descarga tiles y fuentes
solo.

| Endpoint | Qué es |
|---|---|
| `GET /style.json` | Documento de estilo MapLibre. **Único punto de entrada que el cliente configura.** |
| `GET /tiles/{z}/{x}/{y}` | Vector tiles protobuf (los pide MapLibre automáticamente; acepta sufijo `.pbf`) |
| `GET /glyphs/{fontstack}/{range}.pbf` | Fuentes de los labels (también automático) |

### Flutter con `maplibre_gl`

```dart
import 'package:maplibre_gl/maplibre_gl.dart';

MapLibreMap(
  styleString: "https://vivia.aleosh.online/api/maps/style.json",
  initialCameraPosition: const CameraPosition(
    target: LatLng(16.7528, -93.1156), // Tuxtla Gutiérrez
    zoom: 13,
  ),
  // límites recomendados: bounding box de Chiapas (fuera no hay tiles)
  cameraTargetBounds: CameraTargetBounds(
    LatLngBounds(
      southwest: const LatLng(14.53, -94.15),
      northeast: const LatLng(18.00, -90.35),
    ),
  ),
  minMaxZoomPreference: const MinMaxZoomPreference(0, 18),
)
```

**Flujo completo geocode → mapa** (buscar y volar al resultado):

```dart
final res = await geocode("Avenida Central Poniente, Tuxtla Gutiérrez");
if (res != null) {
  await mapController.animateCamera(
    CameraUpdate.newLatLngZoom(LatLng(res.lat, res.lon), 16),
  );
  await mapController.addSymbol(SymbolOptions(
    geometry: LatLng(res.lat, res.lon),
    iconImage: "marker-15",
  ));
}
```

### Web con MapLibre GL JS

```js
const map = new maplibregl.Map({
  container: "map",
  style: "https://vivia.aleosh.online/api/maps/style.json",
  center: [-93.1156, 16.7528],
  zoom: 13,
});
```

Demo completa (buscador + reverse con click): [test/map.html](../vps/vivia-maps/test/map.html).

### Notas técnicas de los tiles

- Datos hasta **zoom 15**; MapLibre sobre-escala (overzoom) hasta z18+ sin
  pedir más tiles — el detalle de calles se mantiene nítido por ser vectorial.
- Los tiles llevan `Cache-Control` de 7 días desde el gateway; el cliente los
  cachea solo.
- El estilo actual es el "light" de Protomaps con labels en español. Si se
  necesita modo oscuro, se puede exponer un segundo estilo (`DARK`) sin tocar
  los tiles — pedirlo al equipo de infraestructura.

---

## 4. Limitantes y recomendaciones

Los datos provienen de **OpenStreetMap** (extracto de Chiapas). La calidad del
geocoding depende de qué tan mapeada esté cada zona.

1. **Cobertura: solo Chiapas.** La búsqueda está acotada al bounding box del
   estado (`-94.15, 14.53 → -90.35, 18.00`) con `bounded=1`. Una dirección de
   CDMX u Oaxaca devuelve `[]`. Igual con los tiles: fuera del estado el mapa
   se ve vacío.

2. **Números exteriores casi nunca resuelven al predio.** OSM en Chiapas tiene
   muy pocos `addr:housenumber`. Ejemplo real: buscar
   `Avenida Central Poniente 554, Tuxtla Gutiérrez` devuelve el **eje de la
   calle** (type `primary`), no el número 554. Recomendación: trata el
   resultado como "a nivel calle" cuando `type` sea `primary`/`residential`/
   `secondary`, y deja que el usuario afine la posición arrastrando un pin
   (con `/reverse` para confirmar).

3. **Colonias: no anteponer la palabra "Colonia".** Ejemplo real:
   `Colonia Moctezuma, Tuxtla Gutiérrez` → `[]`, mientras que
   `Moctezuma, Tuxtla Gutiérrez` sí devuelve resultados. En general el mejor
   patrón de consulta es **`calle, ciudad`** o **`calle, CP`**; el CP funciona
   mejor que el nombre de la colonia para desambiguar.

4. **Sin puntos de interés (POIs).** El import usa `IMPORT_STYLE=address`
   (optimizado para direcciones, ahorra RAM/disco del VPS): comercios,
   parques o monumentos **no** son buscables — ejemplo real:
   `Parque de la Marimba, Tuxtla` → `[]`. Sí se buscan: calles, CPs,
   localidades y ciudades. Si el producto llega a necesitar búsqueda de POIs,
   hay que re-importar con `IMPORT_STYLE=full` (más recursos).

5. **Datos estáticos.** El extracto OSM se importó en julio 2026 y no se
   actualiza automáticamente. Calles nuevas o renombradas no aparecerán hasta
   re-ejecutar `scripts/download-data.sh` y re-importar (ver README).

6. **`importance` es relativo, no una confianza absoluta.** Valores típicos:
   ~0.05 para calles, ~0.12 para CPs, ~0.24 para ciudades. Úsalo solo para
   ordenar entre candidatos de la misma consulta, no como umbral de calidad.

7. **No es autocompletado.** `/geocode` está pensado para direcciones
   completas, no para "search-as-you-type". Llamarlo en cada tecla dará malos
   resultados y carga innecesaria; usa un botón de búsqueda o un debounce
   agresivo (≥800 ms con mínimo 5-6 caracteres). Si a futuro se requiere
   autocompletado real, la opción es agregar Photon al stack.

8. **Ortografía y acentos.** Nominatim tolera variaciones leves
   (mayúsculas/minúsculas, acentos), pero no hace corrección difusa de errores
   de dedo: `Tuxtla Gutierez` puede no encontrar nada.

9. **Un solo nodo, sin rate limit propio.** El servicio corre en el VPS de la
   plataforma sin límite de peticiones configurado; es para consumo de los
   clientes de ViVia, no para exponerse como API pública a terceros.
