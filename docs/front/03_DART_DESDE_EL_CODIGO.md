# Dart explicado con el codigo real de `wishlist_app`

## 1. Dart no es solo la sintaxis de Flutter

En esta app, Dart no actua solo como "lenguaje para escribir widgets". Tambien modela datos, controla asincronia, define tipos, encapsula servicios y expresa reglas de negocio.

Eso es importante: aprender Flutter sin entender Dart suele producir codigo fragil. Este proyecto permite estudiar ambos a la vez.

## 2. Clases y constructores

El mejor ejemplo es `WishlistItem`:

```dart
class WishlistItem extends HiveObject {
  final String id;
  final String name;
  final Priority priority;
  ...
}
```

Aqui aparecen varios conceptos de Dart:

- definicion de clase
- herencia con `extends`
- propiedades inmutables con `final`
- constructor con parametros nombrados

El constructor:

```dart
WishlistItem({
  String? id,
  required this.name,
  required this.priority,
  ...
}) : id = id ?? const Uuid().v4(),
     createdAt = createdAt ?? DateTime.now();
```

ensena mucho:

- `required` obliga a pasar ciertos datos
- `String?` indica que `id` puede ser nulo al entrar
- `??` usa un valor por defecto si llega `null`
- la lista de inicializacion permite calcular campos antes del cuerpo del constructor

Esto es Dart muy idiomatico.

## 3. Null safety

La app usa null safety de forma constante.

Ejemplos:

- `String? currentUser`
- `String? error`
- `WishlistItem? _existingItem`
- `DateTime? createdAt`

Concepto:

- `String` significa "no puede ser nulo"
- `String?` significa "puede ser nulo"

Eso obliga al desarrollador a pensar explicitamente los casos opcionales.

Ejemplo practico en `AddEditScreen`:

```dart
if (_existingItem != null) {
  ...
}
```

Dart obliga a comprobarlo antes de usar el objeto como no nulo.

## 4. Metodos `copyWith`

`WishlistItem` incluye:

```dart
WishlistItem copyWith({...})
```

Este patron es clave en Dart y Flutter porque permite crear una copia modificada sin mutar el objeto original.

Ejemplo real:

```dart
final updated = item.copyWith(isPurchased: !item.isPurchased);
```

Ventajas:

- codigo mas predecible
- mejor integracion con arquitecturas reactivas
- evita efectos secundarios inesperados

En proyectos serios, este patron aparece constantemente.

## 5. Enums y extensiones

`Priority` esta definida como `enum`:

```dart
enum Priority {
  necessity,
  niceToHave,
  nonRelevant,
}
```

Esto da un conjunto cerrado de opciones. Es mucho mejor que usar strings sueltos como `"alta"` o `"baja"`.

Ademas, el proyecto usa una extension:

```dart
extension PriorityExtension on Priority {
  String get label { ... }
  Color get color { ... }
  IconData get icon { ... }
}
```

Esto es un recurso muy potente de Dart:

- permite anadir comportamiento a un tipo sin modificar su definicion base

En este caso, la prioridad no solo es un valor logico. Tambien sabe como presentarse en la UI.

## 6. Getters derivados

En `WishlistState` aparecen getters como:

- `totalItems`
- `estimatedCost`
- `necessityCount`
- `filteredItems`

Ejemplo:

```dart
double get estimatedCost =>
    filteredItems.where((i) => !i.isPurchased).fold(0, (sum, i) => sum + i.price);
```

Esto ensena varias ideas de Dart:

- un getter puede calcularse dinamicamente
- se pueden encadenar colecciones de forma expresiva
- `where`, `fold`, `map`, `sort` son herramientas muy importantes

Estos getters evitan duplicar logica por toda la UI.

## 7. Programacion funcional ligera sobre colecciones

La app usa muchas operaciones sobre listas:

- `where`
- `toList`
- `sort`
- `fold`

Por ejemplo, al filtrar y ordenar:

```dart
var filtered = items.where((i) => showPurchased || !i.isPurchased).toList();
```

Y despues:

```dart
filtered.sort((a, b) {
  switch (sortOption) {
    ...
  }
});
```

Esto muestra una fortaleza de Dart: se mueve muy bien entre estilo orientado a objetos y estilo funcional.

## 8. `switch` como expresion de negocio

La app usa `switch` para traducir enums en comportamiento.

Ejemplos:

- `PriorityExtension.label`
- `PriorityExtension.color`
- ordenacion en `filteredItems`

Ese uso es recomendable porque:

- deja explicitos todos los casos
- hace el codigo mas legible
- evita cadenas de `if` menos mantenibles

## 9. Asincronia con `Future` y `async/await`

Esta app tiene bastante asincronia real:

- abrir cajas de Hive
- leer `SharedPreferences`
- iniciar sesion
- guardar datos
- reproducir audio

Por eso aparecen firmas como:

```dart
Future<void> init(String userId)
Future<void> login(String username, String password)
Future<void> addItem(WishlistItem item)
```

Y dentro:

```dart
await _dbService.saveItem(item);
await _authService.login(username, password);
```

Esto ensena que Dart maneja muy bien operaciones no bloqueantes sin convertir el codigo en algo dificil de leer.

## 10. Excepciones

`AuthService` lanza una excepcion si la contrasena no coincide:

```dart
throw Exception('Contrasena incorrecta');
```

Luego `LoginScreen` la captura:

```dart
try {
  await ref.read(authViewModelProvider.notifier).login(username, password);
} catch (e) {
  ...
}
```

Esto muestra un principio importante:

- la capa de servicio detecta el problema
- la capa de UI decide como comunicarlo

Esa separacion mejora mucho el diseno.

## 11. Genericos

Dart usa genericos en toda la app. Ejemplos:

- `Provider<DatabaseService>`
- `StateNotifier<WishlistState>`
- `Box<WishlistItem>`
- `DropdownButtonFormField<Priority>`

Los genericos sirven para dar tipos concretos a estructuras reutilizables. Gracias a eso:

- el compilador detecta errores antes
- el IDE ofrece autocompletado fiable
- se reduce el casting manual

## 12. Inmutabilidad practica

Aunque la app no usa una libreria de inmutabilidad avanzada, sigue una filosofia bastante sana:

- el estado se reemplaza, no se edita parcialmente a mano
- `WishlistState.copyWith(...)` genera un nuevo estado
- `WishlistItem.copyWith(...)` genera un nuevo item

En Riverpod esto es especialmente util porque hace mas facil saber cuando cambia algo.

## 13. Clases abstractas e interfaces

`DatabaseService` esta declarado como clase abstracta:

```dart
abstract class DatabaseService {
  Future<void> init(String userId);
  List<WishlistItem> getItems();
  Future<void> saveItem(WishlistItem item);
  Future<void> deleteItem(String id);
}
```

Luego `HiveWishlistService` la implementa.

Este punto es muy valioso desde el punto de vista de ingenieria:

- el resto de la app depende del contrato
- no de una implementacion concreta

Eso permite cambiar Hive por otro backend con menos impacto.

## 14. Singleton

El proyecto usa singleton en `SoundService` y `LoggerService`.

Ejemplo:

```dart
static final SoundService _instance = SoundService._internal();
factory SoundService() => _instance;
```

Esto garantiza una unica instancia compartida en toda la app. Es util para recursos globales como audio o logging, aunque en proyectos grandes a veces conviene integrarlo tambien por inyeccion de dependencias.

## 15. Metodos, visibilidad y convenciones

En Dart, el guion bajo inicial marca miembros privados a nivel de libreria:

- `_box`
- `_login()`
- `_selectDate()`
- `_buildInputDecoration()`

Esto ayuda a delimitar que partes son API publica y cuales son detalle interno.

## 16. Anotaciones y generacion de codigo

Hive usa anotaciones como:

- `@HiveType`
- `@HiveField`

Y por eso aparecen archivos generados:

- `priority.g.dart`
- `wishlist_item.g.dart`

Esto ensena un patron habitual en Dart:

- se escriben modelos con metadatos
- una herramienta genera codigo auxiliar

En este caso, los adapters de serializacion para Hive.

## 17. Conclusion

El codigo de `wishlist_app` es un muy buen campo de practica para Dart porque toca casi todas las piezas importantes del lenguaje moderno:

- clases
- null safety
- enums
- extensiones
- asincronia
- interfaces
- genericos
- colecciones
- manejo de errores
- inmutabilidad practica

Aprender estos conceptos aqui tiene mucho mas valor que estudiarlos por separado, porque se ve inmediatamente para que sirven dentro de una aplicacion real.
