# Deep links — compartir propiedad (`https://vivia.aleosh.online/property/{id}`)

Para que el enlace compartido sea **clickeable** en WhatsApp/Telegram/etc. y
**abra la app** en el detalle de la propiedad, hay que servir dos archivos en el
dominio `vivia.aleosh.online`. Un esquema propio (`vivia://`) NO es clickeable en
los chats; por eso compartimos una URL `https`.

## 1. Android App Links

### 1a. Ruta EXACTA (crítico)

El archivo TIENE que responder en la **raíz** del dominio, por HTTPS, con
`Content-Type: application/json` y **sin redirecciones**:

    https://vivia.aleosh.online/.well-known/assetlinks.json     ✅ única válida
    https://vivia.aleosh.online/api/.well-known/assetlinks.json ❌ Android NO la consulta

Es parte fija de la especificación (Digital Asset Links): siempre
`https://DOMINIO/.well-known/...`, sin prefijos como `/api`. Aunque el backend
viva bajo `/api/`, este archivo debe servirse en la raíz.

Cómo servirlo en la raíz según el montaje:
- **Nginx (reverse proxy):** añadir antes del `location /` que proxea al backend:

      location = /.well-known/assetlinks.json {
          default_type application/json;
          alias /ruta/a/assetlinks.json;   # o root con el archivo dentro de .well-known/
      }

- **Spring Boot** (si el backend responde también la raíz del dominio): colocar
  el archivo en `src/main/resources/static/.well-known/assetlinks.json`. Spring
  lo sirve tal cual en `/.well-known/assetlinks.json`.
- **Apache:** `Alias /.well-known/assetlinks.json /ruta/a/assetlinks.json` con su
  `<Files>` permitiendo acceso.

### 1b. Huella de firma (prueba cerrada = Play App Signing)

Contenido: `deeplinks/.well-known/assetlinks.json`. El array trae dos huellas:

1. `REEMPLAZAR_CON_SHA256_DE_PLAY_APP_SIGNING` → **reemplazar** por la SHA-256 real.
   Como la app está en prueba cerrada, Google re-firma el AAB (Play App Signing),
   así que la huella válida es la que muestra:

       Play Console → tu app → Prueba y lanzamiento → Integridad de la app
       → Certificado de la clave de firma de la app → SHA-256

   (Copiar la de "clave de firma de la app", NO la de "clave de subida".)

2. La segunda es la del **keystore de debug** de esta máquina; déjala para poder
   probar también con `flutter run` en debug.

- `package_name`: `com.quantum.vivia_mobile`

### Verificar (con la app instalada y el archivo publicado)

    # Fuerza la reverificación del dominio
    adb shell pm verify-app-links --re-verify com.quantum.vivia_mobile
    adb shell pm get-app-links com.quantum.vivia_mobile
    # 'vivia.aleosh.online' debe salir como: verified

    # Probar la apertura directa
    adb shell am start -a android.intent.action.VIEW \
      -d "https://vivia.aleosh.online/property/UN_ID_REAL"

Si `get-app-links` no dice `verified`, revisar que el JSON se sirva por HTTPS
válido, sin redirect y con la huella correcta. Mientras no verifique, el enlace
sigue siendo clickeable pero abrirá el navegador en vez de la app.

## 2. iOS Universal Links

Servir el archivo en:

    https://vivia.aleosh.online/.well-known/apple-app-site-association

Contenido: `deeplinks/.well-known/apple-app-site-association` (sin extensión,
`Content-Type: application/json`, sin redirecciones).

- Reemplazar `TEAMID` por el **Apple Team ID** real (Apple Developer → Membership).
- En Xcode: abrir `ios/Runner.xcworkspace`, target Runner → *Signing &
  Capabilities* → **+ Capability → Associated Domains**, y añadir
  `applinks:vivia.aleosh.online`. Esto usa `ios/Runner/Runner.entitlements`
  (ya creado). Requiere cuenta de desarrollador; no se puede probar en Linux.

## 3. Página de respaldo `/property/{id}` (app no instalada → Google Play)

Con App Links verificados: si la app está instalada, Android la abre y esta
página **nunca se carga**. Solo se carga cuando la app NO está instalada (o el
enlace se abrió en un navegador que no honra App Links) → ahí redirige a Play.

Archivo: `deeplinks/property.html` (estático, sirve para **cualquier** id: lee el
id del path con JavaScript, no necesita templating en el backend).

Qué hace:
- **Android:** redirige a un `intent://` que abre la app y, si no está instalada,
  cae solo a `https://play.google.com/store/apps/details?id=com.quantum.vivia_mobile`.
- **iOS:** intenta `vivia://property/{id}`. Ya que aún no hay app iOS publicada,
  editar `IOS_STORE_URL` en el HTML cuando exista (por ahora usa Play como texto).
- **Escritorio:** botón a Google Play.

Servir el MISMO archivo para toda la ruta `/property/*`:

- **Nginx:**

      location ^~ /property/ {
          default_type text/html;
          alias /ruta/a/property.html;   # sirve el mismo HTML para /property/<lo-que-sea>
      }

  (o `try_files` apuntando siempre a `property.html`).
- **Spring Boot / backend:** un controlador `GET /property/{id}` que devuelva el
  contenido de `property.html` (o un `@GetMapping` que haga `forward:`/`return`
  del recurso estático).
- **Apache:** `FallbackResource /property.html` bajo `<Directory>` o un
  `RewriteRule ^/property/.*$ /property.html [L]`.

> Nota (prueba cerrada): el enlace a Play mostrará "no encontrado" para quien NO
> sea tester del track, hasta que la app sea pública. Es esperado.

## Resumen de lo que ya quedó en la app (repo)

- Se comparte `https://vivia.aleosh.online/property/{id}` (clickeable).
- `AndroidManifest.xml`: intent-filter `autoVerify` para
  `https://vivia.aleosh.online/property/*` + respaldo `vivia://property/*`.
- `ios/Runner/Runner.entitlements`: associated domain `applinks:...`.
- `lib/app.dart` + `PropertyDeepLinkPage`: al recibir el enlace, carga la
  propiedad por id y abre el detalle.

Lo único que falta es **publicar los dos archivos `.well-known/`** en el dominio.
