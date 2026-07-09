# Refactorización realizada — Vivia Mobile

> Reorganización de `lib/` hacia **Screaming Architecture por rol** (lessor / lessee) + `shared`, manteniendo **MVVM + Clean Architecture**. Solo se **movieron carpetas** (con sus `data/` · `domain/` · `presentation/`) y se actualizaron imports. **No se cambió lógica de negocio.**

---

## Estado del trabajo

- Rama: `limberg/refactor` (sin commits nuevos, HEAD en el commit original `a1e8951`).
- Cambios dejados **sin registrar** (sin `commit`, sin `add`, sin `push`): archivos borrados en su ruta vieja + archivos nuevos sin rastrear.
- Verificación: `flutter analyze` → **0 errores** (mismos 146 `info` de estilo preexistentes). `flutter test` → **3/3 pasan**.

---

## Reparto de capacidades (lessor vs lessee)

**Lessee (arrendatario):** navegar catálogo/sugerencias, buscar y filtrar por categoría, ver detalle + galería + video, favoritos, **reportar** publicaciones.

**Lessor (arrendador):** **verificar identidad (KYC)**, crear/publicar borrador de propiedad (fotos, tour video, review), gestionar sus publicaciones (ver "mis propiedades", eliminar).

**Compartido:** auth, perfil, shell de `home` (bottom nav), base de dominio/data de `property`, visor de media, usuario/API, notificaciones.

---

## Cambios por fase

| Fase | Qué se hizo |
|---|---|
| **0** | Eliminados `example.dart` vacíos y `.DS_Store` no usados. |
| **1** | Dominio + data de propiedad (modelos, repo, datasource, usecases base) → **`shared/property`** (kernel usado por ambos roles). |
| **2** | Visor `gallery_page` / `video_player_page` / `fullscreen_image_viewer` + `gallery_viewmodel` → **`shared/media`**. |
| **3** | Perfil (`profile_page`, `personal_info_page`, sus VMs y widgets `profile/`) → **`user/presentation`**. |
| **4** | Reportes (data + domain + pages + VM + widget) → **`lessee/reports`**. |
| **5** | `lessor` dividido en **`lessor/publishing`** y **`lessor/verification`**. El KYC (`verify_*` pages y widgets) migró desde `home`, que es donde no correspondía. `lessor_api_constants.dart` se mantuvo en la raíz de `lessor` por ser compartido entre ambos sub-features. |
| **6** | `home` reducido a **shell** (dashboard role-aware). Los usecases de propiedad restantes (`get_properties_me`, `get_properties_me_likes`, `get_property_suggestions`, `delete_property`) → `shared/property`. |

`home` pasó de ~50 archivos mezclados a **11** (solo el shell).

---

## Estructura resultante

```
lib/
  core/                          # infra técnica (sin cambios): http, utils
  shared/
    theme/
    property/                    # BASE compartida: models, repo, datasource,
      data/ domain/              #   y usecases de propiedad (ambos roles)
    media/
      presentation/
        pages/                   # gallery, video_player, fullscreen
        viewmodels/              # gallery_viewmodel
  features/
    auth/                        # sin cambios
    user/                        # datos usuario + perfil (UI): profile, personal_info
    home/                        # SHELL: home_page, property_detail (role-aware),
                                 #   bottom_nav, header, search, cards, VMs
    lessee/
      reports/                   # reportar publicación (data/domain/presentation)
    lessor/
      data/datasources/remote/constants/lessor_api_constants.dart   # compartido lessor
      publishing/                # crear/publicar propiedad (data/domain/presentation)
      verification/              # KYC identidad (data/domain/presentation)
```

---

## Decisión: el `PropertyViewModel` NO se partió (a propósito)

Se evaluó separarlo en `CatalogViewModel` (lessee) y `ListingsViewModel` (lessor), pero **se dejó unificado** porque partirlo rompía funcionalidad:

- Los providers se crean **una sola vez** en `main()` y el VM lee el rol dinámicamente (`authRepository.savedRole`).
- Desde el perfil se puede entrar como el otro rol (`RoleSelectorPage` → `ChooseOptionPage`). Con dos VMs fijos por rol, tras cambiar de cuenta sin reiniciar la app el usuario quedaría con el VM equivocado.
- Preservar ese comportamiento exigía plumbing de doble provider (más riesgo de bug).

La diferencia real por rol era **una sola línea** (qué usecase carga las propiedades); todo lo demás era idéntico. Se dejó el VM unificado apoyado en `shared/property`. **Cero regresión.**

---

## Notas / pendientes opcionales

- Dentro de `home/presentation/widgets/` quedaron subcarpetas `shared/` y `lessee/` heredadas; se pueden aplanar más adelante (cosmético).
- Falta hacer el/los **commit(s)** manualmente cuando se valide la app corriendo en ambos roles.
- `REFACTOR_PLAN.md` (plan previo) y este `REFACTOR_DONE.md` son documentación; se pueden borrar.
