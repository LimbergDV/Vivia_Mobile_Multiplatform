# Plan de Refactorización — Vivia Mobile

> **Objetivo:** reorganizar `lib/` para que la arquitectura "grite" el dominio (marketplace de dos lados: **lessor / arrendador** y **lessee / arrendatario**), sacar todo lo que hoy se amontona en `home/`, y hacerlo **moviendo carpetas** (con sus `data/`, `domain/`, `presentation/`) sin cambiar la lógica de negocio.
>
> **Regla de oro:** después de **cada fase** el proyecto debe **compilar y correr** (`flutter analyze` sin errores + `flutter test` en verde). Nada de "cosas raras".

---

## 1. Principios

1. **Screaming Architecture por rol.** El dominio central de Vivia es el rol. Agrupamos por `lessee/` y `lessor/`, y todo lo verdaderamente transversal vive en `shared/` (no dentro de un rol).
2. **Clean Architecture intacta.** Cada feature conserva sus 3 capas: `data/` · `domain/` · `presentation/`. No se reescribe lógica al mover.
3. **MVVM intacto.** ViewModels siguen siendo `ChangeNotifier` cableados en `main.dart`.
4. **Movimientos mecánicos.** La navegación usa `MaterialPageRoute(builder: (_) => Page())` con referencias de clase, **no** strings de rutas → mover un archivo solo obliga a **actualizar imports**, nunca rutas.
5. **Cero cambios de comportamiento** salvo la separación explícita del catálogo (Fase 6), que se hace con tests primero (RED-GREEN-VALIDATE).

---

## 2. Diagnóstico actual

```
lib/features/
  auth/      ✅ correcto
  home/      ❌ sobrecargado: mezcla ~6 responsabilidades de ambos roles
  lessor/    ⚠️  ok, pero le falta la verificación (KYC) que hoy está en home
  user/      ✅ datos de usuario (perfil API)
```

Lo que hoy vive en `home/` y a dónde pertenece realmente:

| Bloque en `home/` | Rol real | Destino |
|---|---|---|
| `property_*` (data+domain), sugerencias, `property_detail`, categorías, favoritos, `property_card`, `nearby_property_card` | Base compartida + **Lessee** | `shared/property` (data+domain) + `lessee/catalog` (presentación) |
| `get_properties_me`, `get_properties_me_likes`, `delete_property` (mis publicaciones) | **Lessor** | `lessor/listings` (presentación) |
| `verify_*` pages + widgets `verify/` (KYC identidad) — ya usan `VerificationViewModel` de lessor | **Lessor** | `lessor/verification` |
| `report_*` pages, `report_viewmodel`, report data+domain | **Lessee** | `lessee/reports` |
| `profile_page`, `personal_info_page`, widgets `profile/` | **Compartido** | `user/presentation` (consolidar con feature `user`) |
| `gallery_page`, `video_player_page`, `fullscreen_image_viewer` | **Compartido** (visor) | `shared/media` |
| `home_page`, `bottom_nav_bar`, `home_header`, `home_search_bar`, `category_chip_list`, `empty_properties_state` | Shell compartido | `home/` (queda como shell delgado) |

Basura a eliminar: `lib/features/auth/data/example.dart`, `lib/features/home/data/example.dart`, y los `.DS_Store`.

---

## 3. Reparto de capacidades (lessor vs lessee)

**Lessee (arrendatario) puede:**
- Navegar el catálogo / sugerencias, buscar y filtrar por categoría.
- Ver detalle de propiedad + galería + video.
- Dar like / gestionar favoritos.
- Reportar una publicación.

**Lessor (arrendador) puede:**
- Verificar su identidad (KYC) — requisito para publicar.
- Crear y publicar un borrador de propiedad (fotos por categoría, tour en video, review).
- Gestionar sus propias publicaciones (ver "mis propiedades", eliminar).

**Compartido (ambos roles / infraestructura):**
- Auth (login, registro, selección de rol, permisos de ubicación, splash).
- Perfil (datos personales, avatar, ajustes).
- Shell de `home` (bottom nav, header, search).
- Base de dominio/data de `property` (usada por catálogo y por listings).
- Visor de media (gallery / video / fullscreen).
- Usuario/API, notificaciones FCM.

---

## 4. Estructura destino

```
lib/
  core/                          # infra técnica (SIN cambios)
    http/                        #   auth_http_client
    utils/                       #   jwt_utils

  shared/                        # transversal a ambos roles
    theme/                       #   (ya existe)
    property/                    # ← BASE compartida del dominio propiedad
      data/                      #   property_remote_datasource, property_repository_impl, models
      domain/                    #   PropertyModel, PropertyDetail, PropertyMedia, PropertyType,
                                 #   PropertyCategory, SelectedCategory, PropertyRepository,
                                 #   usecases compartidos (get_by_id, get_media, toggle_like,
                                 #   get_property_types)
    media/                       # ← visor compartido
      presentation/pages/        #   gallery_page, video_player_page, fullscreen_image_viewer

  features/
    auth/                        # SIN cambios
    user/                        # datos usuario + AHORA también el perfil (UI)
      data/  domain/
      presentation/
        pages/                   #   profile_page, personal_info_page
        viewmodels/              #   user_viewmodel, profile_viewmodel, personal_info_viewmodel
        widgets/profile/         #   edit_info_sheet, personal_info_field, avatar_ring, etc.

    home/                        # SHELL delgado (role-aware dashboard)
      presentation/
        pages/                   #   home_page
        widgets/                 #   bottom_nav_bar, home_header, home_search_bar,
                                 #   category_chip_list, empty_properties_state

    lessee/
      catalog/
        domain/                  #   (usecases propios del lessee que envuelven la base)
        presentation/
          pages/                 #   property_detail_page
          viewmodels/            #   catalog_viewmodel  (ex-PropertyViewModel, rama lessee)
          widgets/               #   property_card, nearby_property_card
      reports/
        data/  domain/           #   report models, repo, usecases
        presentation/
          pages/                 #   report_reason/details/review/success_page
          viewmodels/            #   report_viewmodel
          widgets/report/        #   report_step_header

    lessor/
      listings/
        presentation/
          pages/                 #   (lista de "mis propiedades" si aplica)
          viewmodels/            #   listings_viewmodel (ex-PropertyViewModel, rama lessor)
      publishing/                #   ex-contenido de creación de propiedad de lessor/
        data/  domain/
        presentation/            #   add_property, category/space/property_photos,
                                 #   tour_video, review_property, gallery (de publicación),
                                 #   property_draft_viewmodel + widgets de formulario
      verification/              #   KYC — mueve verify_* de home + lessor_verification actual
        data/  domain/
        presentation/            #   verify_*_page, verify/ widgets, verification_viewmodel
```

> Nota: `shared/property` es un *shared kernel* deliberado. No es "hacer cosas raras": es lo correcto porque el modelo y el repositorio de propiedad los consumen **ambos** roles. Alternativa si prefieres máxima simplicidad: dejarlo como `features/property/` de nivel superior. **Decisión abierta — ver §9.**

---

## 5. Mapa de movimientos (origen → destino)

### 5.1 Base propiedad → `shared/property`
| Origen (`lib/features/home/...`) | Destino (`lib/shared/property/...`) |
|---|---|
| `data/datasources/remote/property_remote_datasource.dart` | `data/datasources/remote/` |
| `data/datasources/remote/constants/property_api_constants.dart` | `data/datasources/remote/constants/` |
| `data/models/property_summary_model.dart` | `data/models/` |
| `data/repositories/property_repository_impl.dart` | `data/repositories/` |
| `domain/models/property_model.dart`, `property_detail.dart`, `property_media.dart`, `property_type_model.dart`, `selected_category.dart` | `domain/models/` |
| `domain/enums/property_category.dart` | `domain/enums/` |
| `domain/repositories/property_repository.dart` | `domain/repositories/` |
| `domain/usecases/get_property_by_id_usecase.dart`, `get_property_media_usecase.dart`, `toggle_like_usecase.dart`, `get_property_types_usecase.dart` | `domain/usecases/` |

### 5.2 Catálogo (lessee) → `lessee/catalog`
| Origen | Destino |
|---|---|
| `home/presentation/pages/property_detail_page.dart` | `lessee/catalog/presentation/pages/` |
| `home/presentation/viewmodels/property_viewmodel.dart` | `lessee/catalog/presentation/viewmodels/catalog_viewmodel.dart` (rama lessee — ver Fase 6) |
| `home/presentation/widgets/shared/property_card.dart` | `lessee/catalog/presentation/widgets/` |
| `home/presentation/widgets/lessee/nearby_property_card.dart` | `lessee/catalog/presentation/widgets/` |
| `home/domain/usecases/get_property_suggestions_usecase.dart`, `get_properties_me_likes_usecase.dart` | `lessee/catalog/domain/usecases/` |

### 5.3 Listings (lessor) → `lessor/listings`
| Origen | Destino |
|---|---|
| `home/domain/usecases/get_properties_me_usecase.dart`, `delete_property_usecase.dart` | `lessor/listings/domain/usecases/` |
| (rama lessor de `property_viewmodel.dart`) | `lessor/listings/presentation/viewmodels/listings_viewmodel.dart` (ver Fase 6) |

### 5.4 Reportes (lessee) → `lessee/reports`
| Origen (`home/...`) | Destino (`lessee/reports/...`) |
|---|---|
| `data/datasources/remote/report_remote_datasource.dart` (+ `constants/report_api_constants.dart`) | `data/datasources/remote/` |
| `data/models/report_reason_dto.dart`, `report_request_model.dart` | `data/models/` |
| `data/repositories/report_repository_impl.dart` | `data/repositories/` |
| `domain/models/report_reason_model.dart`, `repositories/report_repository.dart`, `usecases/get_report_reasons_usecase.dart`, `submit_report_usecase.dart` | `domain/...` |
| `presentation/pages/report_reason/details/review/success_page.dart` | `presentation/pages/` |
| `presentation/viewmodels/report_viewmodel.dart` | `presentation/viewmodels/` |
| `presentation/widgets/report/report_step_header.dart` | `presentation/widgets/` |

### 5.5 Verificación KYC (lessor) → `lessor/verification`
| Origen | Destino |
|---|---|
| `home/presentation/pages/verify_*_page.dart` (intro, entry, front_id, back_id, face, results, verified, invalid) | `lessor/verification/presentation/pages/` |
| `home/presentation/widgets/verify/*` | `lessor/verification/presentation/widgets/` |
| `lessor/data|domain` de `lessor_verification_*` + `verification_viewmodel.dart` | consolidar bajo `lessor/verification/` |

### 5.6 Perfil (compartido) → `user`
| Origen (`home/...`) | Destino (`user/presentation/...`) |
|---|---|
| `pages/profile_page.dart`, `pages/personal_info_page.dart` | `pages/` |
| `viewmodels/profile_viewmodel.dart`, `personal_info_viewmodel.dart` | `viewmodels/` |
| `widgets/profile/*` | `widgets/profile/` |

### 5.7 Visor de media (compartido) → `shared/media`
| Origen (`home/presentation/pages/`) | Destino (`shared/media/presentation/pages/`) |
|---|---|
| `gallery_page.dart`, `video_player_page.dart`, `fullscreen_image_viewer.dart` | `presentation/pages/` |

> ⚠️ `lessor/presentation/pages/gallery_page.dart` es **otra** galería (selección de fotos al publicar). **No se fusiona**; se queda en `lessor/publishing/`.

### 5.8 Publicación (lessor) → `lessor/publishing`
El contenido actual de `lessor/` que NO es verificación (add_property, *_photos, tour_video, review, draft VM, widgets de formulario, sus data/domain de amenities/neighborhoods/draft) se mueve bajo `lessor/publishing/`.

---

## 6. Separación del ViewModel de catálogo (la única parte "no trivial")

Hoy `PropertyViewModel` sirve a los dos roles con `if (isLessor)`. Lo partimos en dos, reutilizando la **misma** `shared/property` (data+domain):

- `CatalogViewModel` (lessee): `get_property_suggestions`, tipos, categorías, favoritos, detalle.
- `ListingsViewModel` (lessor): `get_properties_me`, `delete_property`, `prependProperty` al publicar.

**Se hace con TDD (RED → GREEN → VALIDATE):**
1. **RED:** escribir tests de `CatalogViewModel` y `ListingsViewModel` (carga por rol, favoritos, prepend, reset) que fallen.
2. **GREEN:** extraer cada rama del `PropertyViewModel` original hasta pasar los tests.
3. **VALIDATE:** `flutter analyze` + `flutter test` con cobertura ≥ 80% de los VM nuevos.
4. Cablear ambos en `main.dart` y en `home_page` seleccionar el VM según rol.

Esta fase va **al final** para que todos los movimientos de carpeta (seguros) ocurran antes y la app siga funcional en cada paso.

---

## 7. Fases de ejecución (cada fase deja la app compilando)

| Fase | Alcance | Riesgo |
|---|---|---|
| **0** | Limpieza: borrar `example.dart` y `.DS_Store`; añadir `**/.DS_Store` a `.gitignore`. | Nulo |
| **1** | Crear `shared/property` y mover base propiedad (§5.1). Actualizar imports (incl. `main.dart`). | Bajo |
| **2** | Crear `shared/media` y mover visor (§5.7). | Bajo |
| **3** | Mover perfil a `user` (§5.6). | Bajo |
| **4** | Crear `lessee/reports` y mover reportes (§5.4). | Bajo |
| **5** | Crear `lessor/verification` (mover verify_* de home + consolidar KYC) y `lessor/publishing` (§5.5, §5.8). | Medio |
| **6** | Mover `home` → shell delgado; mover catálogo a `lessee/catalog` y **separar el ViewModel** (§6). | Medio-alto |
| **7** | Revisión final: `flutter analyze`, `flutter test`, correr la app en ambos roles. | — |

Tras cada fase: `flutter analyze` (0 errores) y `flutter test`. Commit atómico por fase (`refactor(fase-N): ...`).

---

## 8. Validación / gates

- **Compilación:** `flutter analyze` sin errores tras cada fase.
- **Tests:** `flutter test` en verde; para los VM nuevos (Fase 6) cobertura ≥ 80%.
- **Humo manual:** login como lessee (ver catálogo, detalle, favorito, reportar) y como lessor (verificar, publicar, ver mis propiedades).
- **DI:** `main.dart` sigue cableando todo; solo cambian rutas de import (Fase 6 añade 2 providers de VM).

---

## 9. Decisiones abiertas (necesito tu OK)

1. **`shared/property` vs `features/property`.** Recomiendo `shared/property` (kernel compartido). ¿Ok o lo prefieres como feature top-level?
2. **`listings` (lessor).** Hoy NO hay una página dedicada de "mis propiedades"; se muestran en el `home_page` role-aware. ¿Creamos `ListingsViewModel` alimentando el mismo shell (recomendado, mínimo cambio), o quieres además una página separada de gestión?
3. **Perfil dentro de `user`** vs feature `profile/` propia. Recomiendo consolidar en `user`. ¿De acuerdo?

---

## 10. Qué NO se toca (para bajar riesgo)

- `auth/` completo.
- `core/` (http, utils).
- Firebase / notificaciones en `main.dart` (solo se actualizan imports).
- Lógica de negocio dentro de repos/usecases/datasources (solo cambian de carpeta).
- Las dos galerías se mantienen separadas (visor lessee ≠ galería de publicación lessor).

---

## 11. Checklist de arranque

- [ ] Aprobar decisiones abiertas (§9).
- [ ] Fase 0 — limpieza.
- [ ] Fases 1–5 — movimientos seguros + imports.
- [ ] Fase 6 — shell + split de ViewModel con TDD.
- [ ] Fase 7 — validación y humo en ambos roles.
