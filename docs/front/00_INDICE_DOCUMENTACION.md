# Documentacion tecnica de `wishlist_app`

Esta carpeta complementa el `README.md` y la `GUIA_PRINCIPIANTES_FLUTTER.md` existente con una lectura mas profunda, centrada en el codigo real de la app.

## Archivos incluidos

### `01_ARQUITECTURA_APP.md`
Explica como esta organizada la aplicacion, que responsabilidad tiene cada carpeta y por que la separacion en capas mejora el mantenimiento.

### `02_FLUTTER_DESDE_EL_CODIGO.md`
Explica los conceptos principales de Flutter usando ejemplos reales de esta app: widgets, `BuildContext`, `StatelessWidget`, `StatefulWidget`, `ConsumerWidget`, layout, navegacion, formularios y renderizado reactivo.

### `03_DART_DESDE_EL_CODIGO.md`
Explica Dart aplicado al proyecto: clases, constructores, `final`, enums, extensiones, asincronia con `Future`, null safety, getters derivados, genericos y metodos como `copyWith`.

### `04_FLUJO_DATOS_Y_PATRONES.md`
Recorre el flujo completo de la aplicacion: arranque, login, inicializacion de Hive, actualizacion de Riverpod, pintado de la UI y persistencia local.

## Como leer esta documentacion

Si tu objetivo es aprender desde cero, el mejor orden es este:

1. `01_ARQUITECTURA_APP.md`
2. `02_FLUTTER_DESDE_EL_CODIGO.md`
3. `03_DART_DESDE_EL_CODIGO.md`
4. `04_FLUJO_DATOS_Y_PATRONES.md`

Si tu objetivo es entender rapido el proyecto para modificarlo, empieza por:

1. `04_FLUJO_DATOS_Y_PATRONES.md`
2. `01_ARQUITECTURA_APP.md`

## Idea central

La app esta bien orientada para aprender porque no mezcla toda la logica en un unico archivo. Cada concepto de Flutter y Dart aparece en una pieza concreta:

- UI en `views/`
- estado y casos de uso en `viewmodels/`
- acceso a datos en `services/`
- modelo de dominio en `models/`
- recursos transversales en `core/`

Eso hace que el codigo sirva a la vez como producto y como material didactico.
