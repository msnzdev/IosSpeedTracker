# Speed Tracker — Método 100% GRATIS desde Windows (sin Mac, sin pagar)

Este flujo no cuesta nada. Compensación: con Apple ID gratuito, cada instalación
**caduca a los 7 días** y hay que "refrescarla" — es una limitación de Apple, no de
esta guía. AltStore automatiza ese refresco si tienes tu PC encendido y en la misma
WiFi que el iPhone de vez en cuando.

## Resumen del flujo
GitHub (código) → GitHub Actions (compila gratis en un Mac en la nube, sin firmar)
→ descargas el `.ipa` → AltServer (en tu PC Windows) lo firma con tu Apple ID gratuito
e instala en tu iPhone vía AltStore.

---

## 1. Instalar AltStore / AltServer

1. Ve a https://altstore.io y descarga **AltServer para Windows**. Instálalo (te pedirá
   instalar también **iTunes** o al menos sus drivers de Apple Mobile Device — sigue el
   asistente, es normal).
2. Conecta tu iPhone al PC por cable USB al menos la primera vez.
3. Abre AltServer (queda en la bandeja del sistema, junto al reloj de Windows).
4. Clic derecho en el icono de AltServer → **Install AltStore** → elige tu iPhone.
5. Te pedirá tu **Apple ID y contraseña** (gratuito, no hace falta ser developer). Se
   usa solo localmente para firmar, no se envía a ningún servidor de terceros.
   - Recomendación: usa un Apple ID secundario dedicado a esto si tienes uno, ya que
     Apple limita a 10 "App IDs" creados cada 7 días por cuenta gratuita.
6. En el iPhone: **Ajustes → General → VPN y gestión de dispositivos** → confía en el
   perfil de tu Apple ID (aparecerá como certificado de desarrollador).
7. Ya tienes la app **AltStore** instalada en tu iPhone (icono en pantalla de inicio).

## 2. Subir el proyecto a GitHub

1. Crea un repositorio en https://github.com/new (puede ser público — así los minutos
   de GitHub Actions en macOS son **ilimitados y gratis**; si lo haces privado, tienes
   una cuota gratuita mensual que también te alcanza de sobra para esto).
2. Sube todo el contenido de esta carpeta, **incluida la carpeta oculta `.github/`**
   con el archivo `build.yml` dentro (en la web de GitHub, "Add file → Upload files"
   sube también las carpetas si arrastras la estructura completa; si no te deja arrastrar
   la carpeta `.github` directamente, créala manualmente desde la web: "Create new file",
   escribe `.github/workflows/build.yml` como nombre —GitHub crea las carpetas solas— y
   pega el contenido).

## 3. Lanzar la compilación

1. En tu repo de GitHub, pestaña **Actions**.
2. Verás el workflow "Build unsigned IPA". Si no se lanzó solo al subir el código,
   pulsa **Run workflow** manualmente.
3. Espera unos 3-6 minutos. Al terminar (check verde ✅), entra en esa ejecución y baja
   hasta **Artifacts** → descarga `SpeedTrackerApp-unsigned.zip`.
4. Descomprímelo — dentro está `SpeedTrackerApp.ipa`.

## 4. Instalar el .ipa en tu iPhone con AltServer

1. Conecta el iPhone al PC (USB, o por WiFi si ya configuraste el "WiFi sync" de
   AltServer — la primera vez es más fiable por cable).
2. Clic derecho en el icono de AltServer (bandeja del sistema) → **Install .ipa...**
3. Selecciona el `SpeedTrackerApp.ipa` que descargaste.
4. Elige tu iPhone en la lista → introduce tu Apple ID si te lo vuelve a pedir.
5. En unos segundos verás el icono de "Speed Tracker" en tu iPhone. Ábrela, dale
   permiso de ubicación **"Permitir siempre"**, y ya puedes usarla.

## 5. Mantenerla viva (refresco cada 7 días)

- Con Apple ID gratuito, iOS desinstala automáticamente la app pasados 7 días si no
  se "refirma".
- **Automático**: abre la app **AltStore** en el iPhone mientras tu PC (con AltServer
  abierto) esté en la misma red WiFi — AltStore refresca todas tus apps solo, en
  segundo plano, sin que tengas que repetir todo el proceso.
- **Manual**: si prefieres no depender de eso, repite el paso 4 cada semana con el
  mismo `.ipa` (no hace falta recompilar si no cambiaste el código).

## 6. Actualizar la app cuando cambies el código

1. Sube los cambios al repo de GitHub.
2. El Action se relanza solo (o pulsas "Run workflow" a mano).
3. Descargas el nuevo `.ipa` y repites el paso 4 — AltServer reemplaza la versión
   anterior.

---

## Límites a tener en cuenta (impuestos por Apple, no por esta guía)

- Máx. **3 apps** instaladas a la vez firmadas con "Personal Team" gratuito por
  dispositivo.
- Máx. **10 identificadores de app** nuevos cada 7 días por cuenta Apple — si borras
  y reinstalas muchas veces cambiando el bundle id, puedes agotarlo (normalmente no es
  un problema para este proyecto).
- Caducidad cada 7 días, como ya se explicó (se soluciona con el refresco de AltStore).

## Si más adelante quieres evitar todo esto

El mismo proyecto ya viene preparado con `codemagic.yaml` y `project.yml` para el
flujo de pago con Apple Developer Program (99 $/año) + TestFlight, que elimina la
caducidad de 7 días y el límite de 3 apps. Están en la carpeta por si en el futuro
decides dar el salto — no hace falta tocar nada del código, solo seguir esa otra guía.
