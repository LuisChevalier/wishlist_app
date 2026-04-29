# Flujo de datos y patrones en `wishlist_app`

## 1. Objetivo de este documento

Aqui no vamos a ver la app por carpetas, sino como sistema vivo. La pregunta es:

"Cuando el usuario abre la app, inicia sesion, anade un deseo o marca una compra, que pasa exactamente?"

Responder eso da una vision de ingenieria mucho mas profunda.

## 2. Flujo de arranque

El arranque comienza en `lib/main.dart`.

### Paso 1. Inicializacion del framework

```dart
WidgetsFlutterBinding.ensureInitialized();
```

Esto prepara el puente entre Dart y el motor de Flutter. Es obligatorio cuando antes de `runApp()` vas a hacer tareas asincronas o inicializaciones nativas.

### Paso 2. Inicializacion de Hive

```dart
await Hive.initFlutter();
Hive.registerAdapter(WishlistItemAdapter());
Hive.registerAdapter(PriorityAdapter());
```

Aqui se prepara la persistencia local y se registran los adapters para serializar tipos personalizados.

### Paso 3. Inyeccion de dependencias

```dart
ProviderScope(
  overrides: [
    databaseServiceProvider.overrideWithValue(dbService),
  ],
  child: const WishlistApp(),
)
```

Este bloque es fundamental. Riverpod recibe la implementacion concreta de `DatabaseService`.

Patron aplicado:

- dependencia por abstraccion
- implementacion concreta inyectada en el punto de composicion

Esto es muy propio de una arquitectura madura.

## 3. Seleccion de pantalla inicial

Dentro de `WishlistApp`, la pantalla mostrada depende de `AuthState`:

- si esta cargando: spinner
- si hay usuario: `HomeScreen`
- si no hay usuario: `LoginScreen`

Eso se expresa declarativamente:

```dart
home: authState.isLoading
    ? const Scaffold(body: Center(child: CircularProgressIndicator()))
    : (authState.currentUser != null ? const HomeScreen() : const LoginScreen())
```

Es un patron muy Flutter:

- la navegacion inicial se resuelve en base al estado
- no con ifs dispersos por muchas partes

## 4. Flujo de autenticacion

### Componentes implicados

- `LoginScreen`
- `AuthViewModel`
- `AuthService`
- `SharedPreferences`
- `DatabaseService`

### Secuencia real

1. el usuario escribe usuario y contrasena
2. `LoginScreen` valida el formulario
3. llama a `authViewModelProvider.notifier.login(...)`
4. `AuthViewModel` delega en `AuthService`
5. `AuthService` comprueba si el usuario existe en Hive
6. si existe, compara contrasena
7. si no existe, lo registra automaticamente
8. guarda el usuario actual en `SharedPreferences`
9. `AuthViewModel` llama a `_initUserDatabase(username)`
10. se inicializa el box de wishlist de ese usuario
11. se invalida el provider de wishlist
12. la UI se reconstruye y entra en `HomeScreen`

## 5. Aislamiento de datos por usuario

Esta es una de las decisiones mas interesantes del proyecto.

En `HiveWishlistService.init(String userId)` se hace:

```dart
final boxName = 'wishlist_box_$userId';
```

Es decir, cada usuario tiene su propia caja.

Consecuencia tecnica:

- la app no necesita filtrar todos los items por usuario
- directamente abre un almacenamiento separado para cada uno

Esto simplifica mucho el modelo mental y reduce errores de mezcla de datos.

## 6. Provider invalidation: una jugada muy importante

En `AuthViewModel._initUserDatabase` aparece una linea clave:

```dart
_ref.invalidate(wishlistViewModelProvider);
```

Que significa esto en la practica:

- el provider actual de wishlist deja de ser valido
- Riverpod lo recrea
- el nuevo `WishlistViewModel` se construye usando el box del usuario recien iniciado

Este patron es especialmente util cuando cambia el contexto global de la aplicacion, por ejemplo:

- sesion activa
- tenant actual
- entorno
- organizacion seleccionada

## 7. Flujo CRUD de la wishlist

### Crear

`AddEditScreen` recoge datos del formulario y crea:

```dart
final newItem = WishlistItem(...)
```

Despues llama a:

```dart
ref.read(wishlistViewModelProvider.notifier).addItem(newItem);
```

El `ViewModel` guarda en BD y recarga el estado.

### Editar

Si llega un `itemId`, la pantalla busca el item existente dentro del estado actual y precarga controladores y propiedades locales.

Despues usa:

```dart
final updated = _existingItem!.copyWith(...)
```

Y lo persiste con `updateItem`.

### Borrar

El borrado existe de dos maneras:

- desde el gesto `Dismissible` en la tarjeta
- desde el icono de borrar en `AddEditScreen`

Ambas rutas convergen en:

```dart
deleteItem(String id)
```

### Marcar como comprado

La tarjeta no cambia el modelo directamente. Solo emite el gesto:

```dart
onPurchasedToggled: (_) => notifier.togglePurchased(item.id)
```

Luego el `ViewModel` localiza el item, crea una copia invertida y la guarda.

Ese detalle es importante: la UI dispara intenciones, no implementa la logica.

## 8. Estado derivado frente a estado almacenado

`WishlistState` contiene:

- `items`
- `sortOption`
- `showPurchased`

Pero no guarda directamente:

- `totalItems`
- `estimatedCost`
- contadores por prioridad
- lista filtrada y ordenada final

Eso se calcula mediante getters.

Esta decision es excelente porque evita inconsistencias. Si guardases por separado `items` y `totalItems`, tarde o temprano alguno quedaria desincronizado.

## 9. Patron de lectura y escritura con Riverpod

En `HomeScreen` se ve un patron muy sano:

```dart
final state = ref.watch(wishlistViewModelProvider);
final notifier = ref.read(wishlistViewModelProvider.notifier);
```

Diferencia conceptual:

- `watch`: observa estado reactivo y reconstruye
- `read`: obtiene acceso a acciones sin suscribirse

Esto evita rebuilds innecesarios y mantiene el codigo claro.

## 10. Integracion entre estado local y estado global

El proyecto usa dos niveles de estado:

### Estado global

Lo gestiona Riverpod:

- autenticacion
- wishlist
- filtros
- ordenacion

### Estado local de pantalla

Lo gestiona Flutter dentro del `State`:

- texto de inputs
- visibilidad de contrasena
- fecha temporal seleccionada
- item precargado

Esta mezcla esta bien resuelta. No todo debe ir a Riverpod. Un error comun en proyectos menos maduros es subir a estado global cosas que solo importan a una pantalla concreta.

## 11. Separacion de responsabilidades

La app aplica bastante bien el principio de responsabilidad unica:

- `AuthService` autentica y guarda sesion
- `HiveWishlistService` persiste items
- `AuthViewModel` coordina login con la inicializacion de datos
- `WishlistViewModel` transforma acciones de UI en cambios de estado
- `HomeScreen` representa
- `WishlistCard` visualiza un item

Eso facilita depuracion y evolucion.

## 12. Patrones de FullStack aplicados aunque sea una app local

Aunque la app no tenga backend remoto, ya esta usando ideas muy propias de aplicaciones FullStack serias:

- contratos abstractos (`DatabaseService`)
- inyeccion de dependencias
- capa de presentacion separada
- estado derivado
- aislamiento por usuario
- servicios compartidos
- logging centralizado

Esto hace que, si en el futuro quisieras cambiar Hive por una API REST o Firebase, el salto conceptual fuese mucho menor.

## 13. Riesgos y mejoras futuras

Viendo el flujo completo, estas serian mejoras razonables:

- convertir metodos de carga como `_loadItems()` en procesos mas observables o reactivos
- mover validaciones de dominio mas alla del formulario
- cifrar credenciales de forma robusta
- introducir repositorios si se anade backend remoto
- unificar estrategia de audio local/remoto

## 14. Conclusiones de ingenieria

La app funciona porque hay una cadena clara de responsabilidad:

1. la vista captura intenciones del usuario
2. el viewmodel decide que hacer
3. el servicio persiste o recupera datos
4. el estado cambia
5. Flutter vuelve a construir la interfaz

Cuando un proyecto mantiene esta disciplina, crecer deja de ser un caos. Y precisamente por eso `wishlist_app` es un ejemplo muy util para estudiar desarrollo moderno con Flutter y Dart.
