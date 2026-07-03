# Speed Tracker — Compilar desde Windows con Codemagic (sin Mac)

Este flujo compila, firma y publica la app en TestFlight automáticamente, todo desde
el navegador en Windows. Requiere la **Apple Developer Program (99 $/año)** — es
imprescindible para poder crear certificados y perfiles sin usar Xcode.

## Resumen del flujo
GitHub (código) → Codemagic (compila con XcodeGen + Xcode en un runner Mac en la nube)
→ App Store Connect → TestFlight → tu iPhone.

No necesitas abrir Xcode ni tener un Mac en ningún momento.

---

## 1. Crear cuenta de Apple Developer

1. Ve a https://developer.apple.com/programs/enroll/ e inscríbete (99 $/año). Se hace
   desde el navegador, solo pide tu Apple ID y datos de pago/identidad.
2. Espera la confirmación (suele tardar de minutos a un día).

## 2. Crear el identificador de la app (App ID)

1. Entra en https://developer.apple.com/account/resources/identifiers/list
2. **+** → **App IDs** → **App**.
3. Description: `Speed Tracker`. Bundle ID: **explicit**, escribe algo como
   `com.tunombre.speedtracker` (cámbialo también en `project.yml` y `codemagic.yaml`,
   sustituyendo `com.tuusuario.speedtracker`).
4. En Capabilities no necesitas marcar nada especial (la ubicación en background no
   requiere ninguna capability adicional aquí, solo el Info.plist que ya está configurado).
5. Guarda.

## 3. Crear el registro de la app en App Store Connect

1. Ve a https://appstoreconnect.apple.com/apps → **+** → **New App**.
2. Plataforma iOS, nombre "Speed Tracker", idioma principal, elige el Bundle ID que
   creaste en el paso 2, y un SKU cualquiera (ej. `speedtracker001`).
3. Crea la app. No hace falta rellenar nada más por ahora — es solo para poder subir
   builds a TestFlight.

## 4. Crear una API Key de App Store Connect (para firma automática)

1. Ve a https://appstoreconnect.apple.com/access/api → pestaña **Keys**.
2. **+** → nombre "Codemagic", acceso **Admin** (o "App Manager" como mínimo).
3. Descarga el archivo `.p8` (**solo se puede descargar una vez**, guárdalo bien) y
   apunta el **Key ID** y el **Issuer ID** que aparecen en la página.

## 5. Subir el proyecto a GitHub

1. Crea un repositorio nuevo en https://github.com/new (puede ser privado).
2. Sube ahí **todo** el contenido de esta carpeta (`SpeedTrackerApp/`), incluyendo
   `project.yml`, `codemagic.yaml` y la carpeta `SpeedTrackerApp/` con los `.swift`.
   Puedes hacerlo directamente desde la web de GitHub arrastrando los archivos
   ("Add file → Upload files"), sin necesidad de usar git en línea de comandos.

## 6. Configurar Codemagic

1. Regístrate en https://codemagic.io con tu cuenta de GitHub.
2. **Add application** → selecciona el repositorio que acabas de subir.
3. Cuando te pregunte el tipo de proyecto, elige **"Other"** (usaremos nuestro propio
   `codemagic.yaml`, no el asistente automático).
4. Ve a **Teams > Integrations > App Store Connect** → añade una integración nueva,
   pega el Key ID, Issuer ID, y sube el archivo `.p8` del paso 4. Ponle de nombre
   exactamente `codemagic_api_key` (o cambia ese nombre también dentro de
   `codemagic.yaml`, en la línea `app_store_connect: codemagic_api_key`).
5. En la configuración de la app dentro de Codemagic, asegúrate de que usa el
   `codemagic.yaml` del repo (Codemagic lo detecta solo si está en la raíz).

## 7. Ajustar el bundle identifier

Edita estos dos archivos y sustituye `com.tuusuario.speedtracker` por el Bundle ID
real que creaste en el paso 2 (debe ser idéntico en ambos):

- `project.yml` → línea `PRODUCT_BUNDLE_IDENTIFIER`
- `codemagic.yaml` → línea `bundle_identifier`

## 8. Lanzar el build

1. En Codemagic, pulsa **Start new build**, elige la rama y el workflow
   `ios-speedtracker`.
2. El runner macOS en la nube instalará XcodeGen, generará el proyecto Xcode a partir
   de `project.yml`, compilará, firmará automáticamente (usando tu API Key) y subirá el
   `.ipa` a TestFlight. Tarda entre 5 y 15 minutos.
3. Si falla, revisa el log del build en la web de Codemagic — normalmente son errores
   de bundle id no coincidente o de la integración de App Store Connect mal nombrada.

## 9. Instalar en tu iPhone vía TestFlight

1. Ve a https://appstoreconnect.apple.com/apps → tu app → pestaña **TestFlight**.
2. En **Internal Testing**, añade tu propio Apple ID como tester interno.
3. Instala la app **TestFlight** desde el App Store en tu iPhone.
4. Te llegará una invitación (email o directamente visible en la app TestFlight) →
   acepta → instala Speed Tracker.
5. Cada vez que subas un build nuevo desde Codemagic, te llegará como actualización
   en TestFlight, igual que una app normal.

## 10. Primer uso

Al abrir la app te pedirá permiso de ubicación. Elige **"Permitir siempre"** — es
imprescindible para que funcione con el móvil bloqueado en el bolsillo.

---

## Notas

- Los builds de TestFlight caducan a los **90 días**; simplemente vuelve a lanzar un
  build en Codemagic cuando falte poco (puedes automatizarlo con un cron trigger en
  Codemagic si quieres).
- Si en el futuro quieres publicarla de verdad en el App Store (no solo TestFlight),
  el mismo pipeline sirve — solo tendrías que rellenar la ficha de la app (capturas,
  descripción, etc.) en App Store Connect y cambiar `submit_to_testflight` por el
  proceso de release en App Store Connect.
- Alternativa más barata si no quieres pagar los 99 $/año: alquilar un Mac por horas
  (MacinCloud) solo para firmar con "Personal Team" gratuito desde Xcode — pero esos
  builds caducan cada 7 días y tendrías que repetir el proceso manualmente cada semana.
