# Seguridad en el Backend (JWT + bcrypt)

## 1. El Problema que Resolvemos

En la versión original de la app, las "contraseñas" se guardaban en texto plano dentro de Hive. Cualquier persona con acceso al almacenamiento del dispositivo podía leerlas.

Con el backend centralizado, implementamos dos mecanismos de seguridad esenciales en la industria.

---

## 2. bcryptjs: Hashing de Contraseñas

**Nunca guardamos contraseñas.** Lo que guardamos es un **hash** (huella digital criptográfica) de la contraseña.

### ¿Cómo funciona?

1.  El usuario se registra con la contraseña `"miClave123"`.
2.  `bcrypt` la transforma en algo como: `"$2a$10$K8eP...XqzA9m..."` (cadena irreversible).
3.  Este hash se guarda en la base de datos SQL.
4.  Al hacer login, `bcrypt.compare("miClave123", hash)` compara internamente sin revelar la clave original.

### ¿Por qué no usar MD5 o SHA-256?

Estos algoritmos son demasiado rápidos. Un atacante puede probar millones de combinaciones por segundo. `bcrypt` incluye un **factor de trabajo (salt rounds: 10)** que lo hace deliberadamente lento, haciendo los ataques de fuerza bruta inviables.

---

## 3. JWT: Sesiones sin Estado (Stateless)

En lugar de guardar sesiones en la base de datos del servidor (enfoque clásico con cookies), usamos **JSON Web Tokens (JWT)**.

### Estructura de un Token JWT

Un JWT tiene tres partes separadas por puntos:

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9   <- Header (algoritmo)
.eyJ1c2VySWQiOiJjbHk4eiIsInVzZXJuYW1lIjoibHVpcyJ9  <- Payload (datos del usuario)
.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c         <- Signature (firma secreta)
```

### Flujo de Autenticación

1.  **Login**: El servidor verifica las credenciales, crea el payload `{ userId, username }` y lo firma con `JWT_SECRET`.
2.  **API Protegida**: Flutter envía el token en la cabecera `Authorization: Bearer <token>`.
3.  **Verificación**: El middleware `auth.middleware.ts` verifica la firma. Si es válida, extrae `userId` y lo adjunta al `request`.
4.  **Control de acceso**: El controlador usa ese `userId` para filtrar solo los datos del usuario autenticado.

### ¿Por qué es seguro?

Si alguien interceptara el token, sin conocer el `JWT_SECRET` no puede modificarlo ni falsificarlo. Además, los tokens expiran (`expiresIn: '7d'`), limitando el daño si uno es robado.

---

## 4. CORS: Protección desde el Navegador

La cabecera **Cross-Origin Resource Sharing (CORS)** le dice al navegador qué dominios pueden hacer peticiones a nuestra API. En Flutter móvil no aplica (no hay navegador), pero en producción con un front web, es esencial configurar correctamente qué origins están permitidos.
