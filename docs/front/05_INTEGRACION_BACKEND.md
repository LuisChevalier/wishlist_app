# Integración Frontend (Flutter) ↔ Backend (Node.js)

## 1. De Hive a REST API: El Gran Salto

La integración más importante de este proyecto es la transición de una persistencia **local (Hive)** a una **remota (REST API sobre Node.js)**. Para que la UI del Flutter no tenga que saber nada de este cambio, aprovechamos el patrón **Interfaz + Inyección de Dependencias**.

La clave es que `DatabaseService` es un contrato **abstracto**. La implementación concreta (antes `HiveWishlistService`, ahora `ApiDatabaseService`) se intercambia en Riverpod sin que ninguna pantalla lo note.

---

## 2. Stack Tecnológico del Cliente (Flutter)

| Herramienta | Propósito |
|-------------|----------|
| `dio` | Cliente HTTP para peticiones a la API REST. Maneja JSON, timeouts, y interceptores. |
| `flutter_secure_storage` | Almacena el Token JWT de forma cifrada en el llavero del sistema operativo (Keystore en Android, Keychain en iOS, Credential Manager en Windows). |
| `flutter_riverpod` | Gestión del estado e inyección de dependencias. Se usa para "conectar" los servicios de API con los ViewModels. |

---

## 3. Flujo de Autenticación con JWT

```
[LoginScreen]
    │  usuario introduce credenciales
    ▼
[AuthViewModel] → llama a ApiAuthService.login()
    │
    ▼
[ApiAuthService] → POST /api/auth/login  ──→  [Node.js Server]
    │                                             │ valida contraseña con bcrypt
    │  ◄─── { token: "eyJh..." } ◄───────────────┘
    │
    ▼ Guarda el JWT en flutter_secure_storage
    
[AuthViewModel] → llama a _initUserDatabase(username)
    │
    ▼
[ApiDatabaseService] → inyecta el token en cada petición via Dio Interceptor
    │
    ▼
[WishlistViewModel] → refreshFromServer() → GET /api/wishlist
    │
    ▼
[HomeScreen] muestra los deseos reales del usuario
```

---

## 4. El Interceptor de Dio: Magia Automática

El truco más elegante del cliente HTTP es el **Interceptor de Dio**. En lugar de añadir manualmente la cabecera `Authorization: Bearer <token>` en cada petición, el interceptor lo hace de forma automática y transparente:

```dart
_dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await _authService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options); // Continuar con la petición modificada
  },
));
```

El servidor Node.js recibe la cabecera, verifica la firma JWT con el `JWT_SECRET`, y si es válida, deja pasar la petición al controlador.

---

## 5. URL Base y Entornos

La URL base está configurada como `http://10.0.2.2:3000/api`. **¿Por qué `10.0.2.2` y no `localhost`?**

Cuando Flutter corre en un **emulador de Android**, el dispositivo virtual tiene su propio `localhost` (dentro de la máquina virtual). Para acceder al `localhost` real del PC anfitrión, Android usa la ruta especial `10.0.2.2`.

| Plataforma | URL a usar |
|---|---|
| Emulador Android | `http://10.0.2.2:3000` |
| iOS Simulator / Windows Desktop | `http://localhost:3000` |
| Dispositivo físico (misma red) | `http://[IP-local-del-PC]:3000` |

---

## 6. Serialización: fromJson / toJson

Para que Flutter y Node.js se entiendan, el modelo `WishlistItem` ahora tiene dos métodos clave:

*   **`fromJson(Map<String, dynamic> json)`**: Convierte la respuesta JSON del servidor en un objeto Dart tipado.
*   **`toJson()`**: Convierte el objeto Dart en un `Map<String, dynamic>` que Dio puede enviar como JSON al servidor.

El campo `isCompleted` (nombre en la BD SQL) se mapea al campo `isPurchased` (nombre en Dart), reflejando la semántica de negocio de la aplicación original.
