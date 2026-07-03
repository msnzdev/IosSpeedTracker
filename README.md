<div align="center">

# 🏍️ Speed Tracker

### Velocidad, tiempo y distancia de tus rutas en moto — con el móvil bloqueado en el bolsillo

[![Platform](https://img.shields.io/badge/platform-iOS%2016%2B-black?logo=apple)](#)
[![Swift](https://img.shields.io/badge/Swift-5-orange?logo=swift)](#)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue)](#)
[![License](https://img.shields.io/badge/license-MIT-green)](#-licencia)
[![Generado con IA](https://img.shields.io/badge/código-generado%20con%20Claude%20AI-9b59b6)](#%EF%B8%8F-aviso-importante-proyecto-generado-por-ia)

</div>

---

## ⚠️ Aviso importante: proyecto generado por IA

**Todo el código, la documentación y los scripts de este repositorio fueron generados por Claude (el modelo de IA de Anthropic)**, a petición de un usuario y sin revisión previa por parte de un desarrollador iOS profesional.

Esto significa:

- ✅ El código compila y ha sido probado de forma iterativa hasta funcionar en un dispositivo real.
- ⚠️ **No ha pasado una auditoría de seguridad, rendimiento ni buenas prácticas por un humano experto.**
- ⚠️ Puede contener errores, casos límite sin cubrir, o decisiones de diseño mejorables.
- ⚠️ Úsalo bajo tu propia responsabilidad, especialmente si planeas publicarlo en el App Store o distribuirlo a terceros.

Si vas a usar esta app de forma seria (no solo para ti), te recomendamos que un desarrollador revise el código, especialmente `LocationManager.swift` (gestión de GPS y permisos) antes de confiar en los datos que registra.

---

## 📱 Qué hace la app

Speed Tracker registra tus rutas en moto usando el GPS del iPhone, incluso con la pantalla bloqueada:

| Función | Descripción |
|---|---|
| 🚀 Velocidad actual | Se muestra en tiempo real en km/h nada más abrir la app |
| ▶️ Empezar / ⏹️ Terminar ruta | Un botón inicia el cronómetro y el registro de datos |
| 📊 Velocidad media | Calculada como distancia recorrida ÷ tiempo transcurrido |
| 🏁 Velocidad máxima | La mayor velocidad instantánea detectada durante la ruta |
| ⏱️ Duración | Cronómetro en pantalla mientras la ruta está activa |
| 💾 Historial | Cada ruta terminada se guarda en el dispositivo |
| 📤 Compartir | Comparte el resumen de cualquier ruta por WhatsApp, Mensajes, etc. |
| 🗑️ Eliminar | Borra rutas del historial, con confirmación |
| 🔒 Segundo plano | Sigue midiendo con la pantalla apagada o el móvil en el bolsillo |

---

## 🗂️ Estructura del proyecto

```
SpeedTrackerApp/
├── project.yml                          # Especificación XcodeGen — genera el .xcodeproj
├── codemagic.yaml                       # Pipeline de build de pago (Codemagic + TestFlight)
├── .github/workflows/build.yml          # Pipeline de build gratis (GitHub Actions, sin firmar)
├── README.md                            # Este archivo
├── README-GRATIS.md                     # Guía: compilar e instalar gratis (GitHub Actions + AltStore)
└── SpeedTrackerApp/
    ├── SpeedTrackerApp.swift            # Punto de entrada de la app
    ├── ContentView.swift                # Pantalla principal (velocidad, cronómetro, botones)
    ├── HistoryView.swift                # Historial de rutas guardadas
    ├── LocationManager.swift            # GPS, velocidad, distancia y segundo plano
    ├── RouteRecord.swift                # Modelo de una ruta guardada
    ├── RouteStore.swift                 # Persistencia del historial (UserDefaults)
    ├── ActivityShareSheet.swift         # Hoja de "compartir" nativa de iOS
    └── Assets.xcassets/                 # Icono de la app
```

---

## 🚀 Cómo compilarla e instalarla

No hace falta Mac. Hay dos caminos según si quieres pagar o no:

### 🆓 Gratis — GitHub Actions + AltStore
Compila gratis en la nube y se instala con tu Apple ID normal (sin cuenta de developer).
Contrapartida: la app caduca cada 7 días si no la refrescas con AltStore.

👉 Sigue **[README-GRATIS.md](./README-GRATIS.md)**

### 💳 De pago — Codemagic + TestFlight (99 $/año)
Sin caducidad, distribución por TestFlight, más cómodo a largo plazo.

👉 Sigue las instrucciones dentro de **`codemagic.yaml`** y **`project.yml`** (requiere cuenta Apple Developer Program)

---

## 🔐 Permisos que pide la app

| Permiso | Para qué se usa |
|---|---|
| Ubicación — "Siempre" | Imprescindible para seguir midiendo velocidad con la pantalla bloqueada |
| Ubicación en segundo plano | Activado vía `UIBackgroundModes: location` en el `Info.plist` |

La app **no envía tu ubicación a ningún servidor**: todo el procesamiento y almacenamiento ocurre localmente en el dispositivo.

---

## 🛠️ Tecnologías

- **SwiftUI** — interfaz declarativa
- **CoreLocation** — GPS, velocidad y distancia
- **XcodeGen** — genera el proyecto Xcode desde `project.yml`, sin depender de un `.xcodeproj` binario en el repo
- **GitHub Actions** / **Codemagic** — compilación en la nube (CI/CD)

---

## 📄 Licencia

Este proyecto se distribuye bajo licencia MIT. Puedes usarlo, modificarlo y compartirlo libremente — pero recuerda el aviso del principio: es código generado por IA, sin garantías.

---

<div align="center">
<sub>Generado con 🤖 Claude (Anthropic) · Julio 2026</sub>
</div>
