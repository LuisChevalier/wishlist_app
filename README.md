# DreamList - Tu Lista de Deseos Premium 🌟

Bienvenido a **DreamList** (anteriormente Wishlist App), una aplicación móvil desarrollada en Flutter diseñada para proporcionar una experiencia de usuario de clase mundial (UI/UX) al momento de guardar y administrar tus deseos y metas de compra, ahora potenciada con soporte multi-usuario offline completo.

---

## 🚀 Características Principales

1. **Gestión Profesional de Finanzas Personales**: Archiva productos, asigna prioridades, estima fechas de compra y controla tu gasto total mediante el Dashboard Principal.
2. **Soporte Multi-Usuario Local Protegido**: Accede con tu nombre de usuario y contraseña con persistencia aislada para cada perfil en un mismo dispositivo. Soporta la creacion dinámica (primer uso) y validación local de credenciales de protección. Ideal para compartir el control financiero.
3. **Persistencia Ultrarrápida NoSQL**: Potenciada mediante [Hive](https://pub.dev/packages/hive), lo que garantiza lecturas/escrituras síncronas sin bloqueos ni retrasos.
4. **Sistema Avanzado de Logger Centralizado**: Control detallado de todo evento que ocurre bajo el capó (Debug, Info, Warn, Error) utilizando abstracciones robustas listas para producción.
5. **UI/UX Vanguardista (Material 3)**: Disfruta de animaciones fluidas (`flutter_animate`), tipografía pulida, tarjetas elevadas, gradientes y soporte inmaculado tanto en el modo claro (Light Theme) como oscuro (Dark Theme).

---

## 🛠 Arquitectura y Tecnologías Clave

- **Flutter / Dart SDK**: ~3.11.3
- **Gestión de Estado**: `flutter_riverpod` (Proveedores reactivos, inyección de dependencias y StateNotifiers de altísimo rendimiento).
- **Persistencia**: `hive_flutter` (Base de datos Local) y `shared_preferences` (Persistencia de Sesión Activa).
- **Animaciones**: `flutter_animate` (Sintaxis fluida para microinteracciones).
- **Core Trazabilidad**: `logger` (Trazabilidad nivel corporativo en la terminal).

> **Anotación de Arquitectura:**
> La aplicación está fuertemente separada en capas funcionales:
> * `lib/core/`: Utilidades transversales como el `LoggerService` y el `AppTheme`.
> * `lib/models/`: Especificaciones formales y adaptadores de Hive del dominio de la aplicación (`WishlistItem`, `Priority`).
> * `lib/services/`: Capa de infraestructura agnóstica (`AuthService`, `DatabaseService`).
> * `lib/viewmodels/`: Gestión de estado de Riverpod mediante la inyección del negocio a la vista.
> * `lib/views/`: Widgets modulares limpios y Screens (interfaz de usuario).

---

## 🔧 Guía Rápida de Instalación e Inicio

1. **Clona o descarga este repositorio**.
2. **Resuelve las dependencias globales:**
   Ejecuta en tu terminal para obtener todas las referencias al ecosistema pub.dev:
   ```bash
   flutter pub get
   ```
3. **Genera los adaptadores precompilados** *(Opcional, si hay cambios en modelos)*:
   Puesto que la aplicación utiliza anotaciones de Hive, en caso de extender el modelo ejecuta:
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```
4. **Acerca del Hot Reload** *(Información Importante)*:
   > ⚠️ **¡Aviso!** Si acabamos de añadir la persistencia (`shared_preferences`) la cual contiene código nativo, es probable que un simple 'Hot Reload' falle o cause comportamientos extraños si la app ya estaba abierta.
   > **Debes detener la depuración activa y ejecutar nuevamente**:
   ```bash
   flutter run
   ```
5. **Inicia sesión** colocando tu nombre en la elegante pantalla inicial y empieza a soñar tu lista de deseos.

---

## 💡 Desarrollado con 💙 y ✨

Código documentado metódicamente bajo estándares profesionales de desarrollo (10+ años de experiencia emulados). Cada clase y función vital contiene comentarios *DartDoc* que explicitan responsabilidades, ciclo de vida e interacciones.
