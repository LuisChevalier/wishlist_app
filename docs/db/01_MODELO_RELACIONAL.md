# Diseño de la Base de Datos (SQL + Prisma)

## 1. De Local (Hive) a SQL (Relacional)
En el modo local, cada usuario tenía su propia "caja" de Hive, lo que facilitaba el aislamiento pero dificultaba las consultas complejas. Al migrar a un backend con Node.js, hemos optado por una base de datos **SQL (Relacional)** por las siguientes razones:

1.  **Integridad de Datos**: Usamos **Claves Foráneas (FK)** para asegurar que un deseo siempre pertenezca a un usuario real.
2.  **Consultas Robustas**: El lenguaje SQL es el estándar de la industria para filtrar, agregar y ordenar datos de forma masiva.
3.  **ACID**: Garantizamos que las transacciones sean Atómicas, Consistentes, Aisladas y Duraderas. Si un usuario borra un ítem, el cambio es irreversible y se refleja de inmediato.

---

## 2. El Modelo Entidad-Relación (ER)

Diseñamos dos entidades principales: `User` y `WishlistItem`.

### A. Tabla `User` (Usuarios)
Contiene la identidad y el acceso.
*   `id` (String - CUID/UUID): Identificador único global.
*   `username` (String): El alias del usuario (debe ser único en toda la app).
*   `password_hash` (String): La contraseña cifrada con bcrypt. No se puede descifrar, solo comparar.

### B. Tabla `WishlistItem` (Deseos)
Contiene la información de los productos.
*   `id` (String - CUID/UUID): Identificador único.
*   `userId` (String - FK): Conecta el deseo con su dueño en la tabla `User`.
*   `name` (String): Nombre del producto (Obligatorio).
*   `price` (Float): Precio (Opcional, default 0).
*   `priority` (Int): Nivel de prioridad (mapeado desde el enum de Flutter).
*   `isCompleted` (Boolean): Marca de compra.
*   `imageUrl` (String): Link a la imagen (Opcional).

---

## 3. ¿Por qué Prisma ORM?
Prisma es una capa moderna entre el código Node.js y la base de datos SQL. Lo elegimos por:

*   **Esquema como Fuente de Verdad**: El archivo `schema.prisma` define tanto la estructura de la BD como los tipos de TypeScript.
*   **Seguridad de Tipos**: Si intentas guardar un precio (float) donde debería ir un ID (string), el compilador te avisará antes de que la app falle.
*   **Migraciones Automáticas**: Prisma detecta cambios en el modelo y genera los scripts SQL necesarios para actualizar la base de datos sin perder datos.

---

## 4. Diferencia entre Ambientes (PostgreSQL vs SQLite)
Para el desarrollo local, usaremos **SQLite**, que es una base de datos ligera guardada en un solo archivo dentro de nuestra carpeta `backend/prisma/`. 

Sin embargo, Prisma nos permite cambiar a **PostgreSQL** (el estándar de oro para producción) simplemente cambiando una línea en el archivo de configuración. Todo el código Node.js seguirá funcionando exactamente igual.

---

## 5. Mantenimiento y Optimizaciones
1.  **Índices**: Hemos indexado el campo `username` para que el login sea instantáneo, incluso con miles de usuarios.
2.  **Cascading**: Si un usuario decide borrar su cuenta, sus deseos se borrarán automáticamente mediante `ON DELETE CASCADE`, evitando "datos huérfanos" que ocupen espacio innecesario.
