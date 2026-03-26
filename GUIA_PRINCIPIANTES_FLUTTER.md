# 📱 Guía para Principiantes: Entendiendo la Wishlist App

¡Hola y bienvenido(a) a tu viaje de aprendizaje con Flutter! 👋

Este documento ha sido creado especialmente para ti, como una guía amigable para entender cómo está construida esta aplicación (una **Lista de Deseos** o *Wishlist*) desde sus cimientos. No te preocupes si ves muchos archivos o conceptos nuevos al principio; es completamente normal. Vamos a desglosarlo paso a paso, enfocándonos en el **por qué** detrás de las decisiones técnicas.

---

## 🏗️ La Arquitectura: MVVM (Model-View-ViewModel)

Cuando construimos una casa, no tiramos los ladrillos, las tuberías y los cables en la misma habitación, ¿verdad? Los organizamos lógicamente. En el desarrollo de software hacemos lo mismo mediante **patrones de arquitectura**.

Esta aplicación utiliza el patrón **MVVM**, que divide nuestro código en tres capas principales. El objetivo es que la parte visual (pantallas) no se mezcle con la lógica (reglas de negocio) ni con los datos.

1. **Model (Modelo)**: Representa los "datos puros" de la aplicación. Por ejemplo, qué es un "*Deseo*" (tiene un título, un precio, un enlace, una prioridad).
2. **View (Vista)**: Es lo que el usuario ve y toca (Botones, Textos, Pantallas). En Flutter, son los famosos *Widgets*.
3. **ViewModel**: Es el "cerebro intermedio" o puente. Recibe las interacciones de la Vista (ejemplo: hacer clic en "Guardar"), procesa esa información y actualiza la Vista.

### 📂 Estructura de Carpetas (El porqué de cada cosa)

Si abres la carpeta `lib/` (donde vive todo nuestro código Dart), verás que está dividida estratégicamente:

- **`models/`**: Aquí definimos **qué** es nuestra información. Verás archivos como `wishlist_item.dart` y `priority.dart`. Son solo clases que moldean nuestros objetos.
- **`views/`**: Aquí está todo lo visual. Se divide en:
  - `screens/`: Pantallas completas (ej. Pantalla de Inicio, Pantalla de Login).
  - `widgets/`: Pedazos de interfaz reutilizables (un botón personalizado, una tarjetita para mostrar un producto).
- **`viewmodels/`**: El puente del que hablamos. Aquí vive `wishlist_viewmodel.dart` (controla la lista de deseos) y `auth_viewmodel.dart` (controla quién está logueado).
- **`services/`**: Son los "trabajadores pesados". Si el ViewModel necesita guardar algo en la memoria del celular, le pide este favor a un servicio (ej. `database_service.dart`).
- **`core/`**: Configuraciones centrales que se usan en toda la app, como el **tema visual** (`theme.dart` - modos claro y oscuro) y un **sistema de registro de errores** (`logger_service.dart`).

---

## 🛠️ Las Tecnologías Clave (y por qué las elegimos)

### 1. 🌊 Riverpod (Manejo de Estado)
**¿Qué es?** Es una librería que nos ayuda a gestionar el "estado" de la aplicación.
**El Concepto:** Imagina que tienes un "carrito de compras" que se muestra en varias pantallas a la vez. Si el usuario agrega un producto, ¿cómo le avisas a todas las pantallas para que se actualicen mágicamente al mismo tiempo? Riverpod hace exactamente eso de una manera segura y predecible. Lo usamos para inyectar y escuchar nuestros *ViewModels*.

### 2. 🐝 Hive (Base de Datos Local)
**¿Qué es?** Es una base de datos muy rápida y ligera que vive dentro del celular del usuario (no requiere internet).
**El Concepto:** Cuando cierras la aplicación y la vuelves a abrir, tus "deseos" siguen ahí. Hive se encarga de guardar esa información en archivos locales. Se eligió Hive en lugar de otras opciones porque es extremadamente rápido y está optimizado nativamente para Flutter y Dart.

### 3. 🎨 Flutter Animate y Temas
La aplicación está diseñada para verse moderna y profesional.
- **`flutter_animate`**: Nos permite agregar animaciones suaves (fade, slide, escalado) sin tener que escribir cientos de líneas de código complejo.
- **Temas (ThemeData)**: En lugar de darle un color verde al Botón A, otro verde al Botón B, etc., definimos una "paleta general" en la carpeta `core/theme.dart`. Así, si mañana queremos que la app sea azul en lugar de verde, cambiamos una sola línea y todo se adapta.

---

## 🔄 El Flujo de Trabajo (El viaje de un "Deseo")

Para que lo veas en acción, imagina que presionas el botón "Agregar a mis deseos":

1. **La Vista (View)** detecta que tocaste el botón "Guardar".
2. La Vista llama al **ViewModel** diciéndole: *"Oye, el usuario quiere agregar unos nuevos zapatos de $50"*.
3. El **ViewModel** verifica que los datos estén bien, crea un **Objeto Modelo** (`WishlistItem`) y llama al **Servicio de Base de datos** (`database_service.dart`).
4. El **Servicio** toma el objeto y lo guarda físicamente en el celular usando **Hive**.
5. Una vez guardado con éxito, el **ViewModel** actualiza su lista interna de deseos.
6. Gracias a **Riverpod**, la **Vista** nota que el ViewModel cambió y se **re-dibuja** sola, mostrando ahora tus zapatos de $50 en la pantalla.

---

## 💡 Consejos para Principiantes

Si quieres empezar a estudiar el código de esta app, te sugiero este orden:

1. **Entra a `lib/main.dart`**: Es la puerta de entrada. Ahí verás cómo se inicializa la app, el tema visual y las rutas principales.
2. **Mira los Modelos (`lib/models/wishlist_item.dart`)**: Observa lo sencillos que son; solo tienen propiedades (nombre, precio, fecha).
3. **Explora una Pantalla Visual (`lib/views/screens/home_screen.dart`)**: Mira cómo se dibuja la interfaz de usuario (columnas, listas, textos).
4. **Finalmente, el cerebro (`lib/viewmodels/wishlist_viewmodel.dart`)**: Descubre la magia de Riverpod y cómo se comunican las pantallas con la base de datos.

¡Y sobre todo, no tengas miedo de romper cosas! La mejor forma de aprender Flutter es cambiar un color, guardar (Hot Reload) y ver qué pasa. 

¡Mucho éxito en tu aprendizaje! 🚀
