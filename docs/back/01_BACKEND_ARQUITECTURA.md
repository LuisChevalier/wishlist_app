# Arquitectura del Backend (Node.js + Express)

## 1. Visión General del Servidor
Para complementar nuestra aplicación Flutter, hemos diseñado un servidor robusto utilizando **Node.js** con el framework **Express**. Esta capa actúa como el cerebro centralizado del sistema, gestionando la lógica de negocio y asegurando que los datos sean consistentes para todos los clientes (móvil, web, etc.).

### ¿Por qué Node.js?
Node.js es ideal para aplicaciones con alta densidad de entrada/salida (I/O). Gracias a su modelo de **un solo hilo con bucle de eventos (Event Loop)**, puede manejar miles de conexiones simultáneas de forma eficiente sin la sobrecarga de crear hilos pesados por cada usuario.

### El rol de TypeScript
Aunque Node.js usa JavaScript de forma nativa, hemos implementado el servidor con **TypeScript**. Esto nos proporciona:
1.  **Tipado fuerte**: Evitamos errores de "undefined is not a function" en tiempo de ejecución.
2.  **Autocompletado**: Facilita enormemente el desarrollo y la navegación por el código.
3.  **Mantenibilidad**: Es mucho más sencillo escalar un proyecto cuando los contratos de datos están definidos explícitamente.

---

## 2. Capas de la Aplicación (Layered Architecture)
Para que el código sea limpio y fácil de mantener, seguimos un patrón de capas basado en **Separación de Responsabilidades**:

### A. Capa de Rutas (`routes/`)
Es la puerta de entrada. Su única responsabilidad es recibir la petición HTTP y derivarla al controlador correspondiente. No contiene lógica de negocio.

### B. Capa de Controladores (`controllers/`)
Actúa como intermediario. Recibe los datos de la petición (body, params, query), los valida y llama a la capa de servicios. Finalmente, decide qué respuesta HTTP enviar (200 OK, 400 Bad Request, 500 Internal Error).

### C. Capa de Servicios (`services/`)
Aquí vive la verdadera **Lógica de Negocio**. Se encarga de procesos como:
*   ¿El usuario tiene permisos para borrar este deseo?
*   ¿El precio es válido antes de guardarlo?
*   Coordinación de múltiples operaciones en la base de datos.

### D. Capa de Persistencia (`Prisma`)
Usamos **Prisma ORM** como nuestro motor de base de datos SQL. Prisma nos permite hablar con la base de datos de forma tipada, eliminando la necesidad de escribir SQL puro de forma manual para operaciones comunes (CRUD).

---

## 3. Seguridad y Autenticación
A diferencia del modo local (Hive), donde los datos estaban expuestos, el backend implementa:

1.  **JWT (JSON Web Tokens)**: Cuando un usuario hace login, el servidor le entrega un token firmado. Las siguientes peticiones deben incluir este token en la cabecera `Authorization`. Esto garantiza que solo el dueño de la lista pueda ver o modificar sus deseos.
2.  **Hasing de Contraseñas (`bcryptjs`)**: Nunca guardamos la contraseña "tal cual". Usamos un algoritmo de hash que transforma la contraseña en una cadena ilegible e irreversible. Incluso si alguien roba la base de datos, no podrá conocer las contraseñas originales.
3.  **CORS**: Limitamos qué dominios pueden hablar con nuestra API para evitar ataques maliciosos desde navegadores no autorizados.

---

## 4. Flujo de Trabajo (Development Cycle)
*   **Nodemon**: El servidor se reinicia automáticamente cada vez que guardas un archivo.
*   **Varcars**: Usamos variables de entorno (`.env`) para configurar puertos y claves secretas sin exponerlas en el código fuente.
