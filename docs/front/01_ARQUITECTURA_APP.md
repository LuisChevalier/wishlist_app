# Arquitectura de `wishlist_app`

## 1. Vision general

`wishlist_app` es una aplicacion Flutter multiplataforma con persistencia local. Su funcion principal es permitir que varios usuarios gestionen listas de deseos en el mismo dispositivo, manteniendo sesiones recordadas y datos aislados por usuario.

Aunque es una app pequena, la estructura esta organizada con un criterio profesional: separar interfaz, estado, dominio e infraestructura.

## 2. Estructura real del proyecto

La carpeta `lib/` esta dividida asi:

```text
lib/
  core/
  models/
  services/
  viewmodels/
  views/
  main.dart
```

### `lib/main.dart`

Es el punto de entrada. Aqui se hace el arranque tecnico de la app:

- se asegura la inicializacion de Flutter con `WidgetsFlutterBinding.ensureInitialized()`
- se inicializa Hive con `Hive.initFlutter()`
- se registran los adapters de Hive
- se crea el servicio de base de datos
- se prepara la localizacion de fechas en espanol
- se monta `ProviderScope` para que Riverpod pueda inyectar dependencias

Esto es importante porque en Flutter el `main()` no solo lanza la UI: muchas veces coordina recursos nativos, bases de datos, localizacion o servicios globales antes del primer frame.

### `lib/core/`

Aqui viven utilidades transversales:

- `theme.dart`: centraliza la configuracion visual de Material 3
- `logger_service.dart`: encapsula el logger
- `sound_service.dart`: maneja musica y efectos de sonido

La idea de esta carpeta es evitar que componentes de negocio o pantallas repitan configuraciones globales.

### `lib/models/`

Representa el dominio de negocio, es decir, los datos con los que realmente trabaja la app.

Ejemplos:

- `wishlist_item.dart`: define que es un deseo
- `priority.dart`: define las prioridades posibles
- `sort_option.dart`: define los modos de ordenacion

Esta capa no deberia depender de pantallas concretas. Su trabajo es modelar informacion.

### `lib/services/`

Representa la infraestructura y el acceso a datos.

Ejemplos:

- `database_service.dart`: define una interfaz `DatabaseService` y su implementacion con Hive
- `auth_service.dart`: gestiona el usuario actual, credenciales locales y sesion persistida

Esta separacion tiene mucho valor: la UI no habla con Hive directamente. Habla con un servicio. Eso permite cambiar la tecnologia sin rehacer toda la app.

### `lib/viewmodels/`

Es la capa intermedia entre la interfaz y los servicios. Aqui se usa Riverpod con `StateNotifier`.

Ejemplos:

- `auth_viewmodel.dart`: coordina login, logout e inicializacion de datos por usuario
- `wishlist_viewmodel.dart`: gestiona alta, modificacion, borrado, ordenacion y filtros

En otras palabras: aqui vive la logica de aplicacion.

### `lib/views/`

Es la capa visual:

- `screens/`: pantallas completas
- `widgets/`: piezas reutilizables

Ejemplos:

- `login_screen.dart`
- `home_screen.dart`
- `add_edit_screen.dart`
- `wishlist_card.dart`
- `stats_header.dart`

Esto sigue una idea muy sana en Flutter: una pantalla grande se compone de widgets mas pequenos y especializados.

## 3. Patron arquitectonico que se aprecia

No esta etiquetado formalmente como MVVM puro, pero el proyecto se acerca bastante:

- `Model`: `WishlistItem`, `Priority`, `SortOption`
- `View`: pantallas y widgets en `views/`
- `ViewModel`: `AuthViewModel` y `WishlistViewModel`

Ademas hay una capa de servicios para aislar la infraestructura.

En proyectos FullStack y moviles esto es buena practica porque:

- reduce acoplamiento
- mejora testabilidad
- evita meter logica de negocio dentro del `build()`
- permite evolucionar la persistencia sin romper la UI

## 4. Flujo de dependencias

La direccion ideal de dependencias en esta app es:

```text
views -> viewmodels -> services -> models / almacenamiento
```

Ejemplo real:

1. `HomeScreen` escucha `wishlistViewModelProvider`
2. el `WishlistViewModel` usa `DatabaseService`
3. `HiveWishlistService` guarda y recupera `WishlistItem`
4. la UI se reconstruye al cambiar el estado

Esto es exactamente el tipo de flujo que conviene en aplicaciones mantenibles.

## 5. Decisiones tecnicas destacables

### Riverpod para gestion de estado

La app usa Riverpod para:

- inyeccion de dependencias
- exponer estado reactivo
- invalidar y recrear providers cuando cambia el usuario

Eso se ve muy claro en `auth_viewmodel.dart`, donde al iniciar base de datos de un usuario se hace:

```dart
_ref.invalidate(wishlistViewModelProvider);
```

Con esa linea, la app fuerza a que la wishlist se reconstruya con el box del nuevo usuario. Es una solucion elegante y limpia.

### Hive para persistencia local

Hive encaja bien en esta app porque:

- es rapido
- no necesita servidor
- funciona muy bien con modelos sencillos
- es ideal para apps offline-first pequenas o medianas

La clase `WishlistItem` usa anotaciones `@HiveType` y `@HiveField`, lo que obliga a pensar el modelo de forma estable.

### SharedPreferences para sesion

El usuario actual no se guarda en la misma caja de deseos, sino en `SharedPreferences`. Esto separa correctamente:

- datos de autenticacion ligera
- datos de dominio de la wishlist

### Widgets reutilizables

La app no dibuja todo directamente dentro de `HomeScreen`. Extrae componentes como:

- `WishlistCard`
- `StatsHeader`
- `EmptyState`

Ese desacoplamiento es una de las claves para que Flutter escale bien.

## 6. Puntos fuertes de la arquitectura

- La estructura por carpetas es clara y entendible.
- La inyeccion de dependencias con Riverpod esta bien aplicada.
- La persistencia por usuario esta resuelta con poco codigo y buena separacion.
- La UI tiene componentes reutilizables.
- La logica de negocio no esta embebida masivamente dentro de las pantallas.

## 7. Puntos a vigilar si la app creciera

Desde una mirada de ingenieria senior, hay varias mejoras posibles si el proyecto evoluciona:

- `AuthService` guarda contrasenas en local sin cifrado fuerte. Para una app real, convendria almacenamiento seguro.
- `SoundService` mezcla assets locales con efectos remotos por URL. En produccion, conviene homogeneizar estrategia.
- `WishlistViewModel` recarga toda la lista tras cada operacion. En apps mayores podria hacerse actualizacion incremental.
- La validacion y conversion de precios estan en la pantalla. Parte de esa logica podria moverse a una capa mas centrada en negocio.

Nada de eso invalida el proyecto. Solo marca el siguiente nivel de madurez.

## 8. Conclusion

La arquitectura de `wishlist_app` esta bien planteada para aprender y para evolucionar. No es solo una app visualmente atractiva: tambien muestra decisiones tecnicas correctas sobre separacion de capas, gestion de estado y persistencia local.

Eso la hace especialmente util como ejemplo real para estudiar Flutter y Dart con una base cercana a un proyecto profesional.
