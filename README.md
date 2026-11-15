# Parcial II moviles — Sistema de Gestion de Inventario

Proyecto desarrollado como segundo parcial practico de Electiva Profesional I en la UCEVA. Consiste en una API REST propia con base de datos persistente y una aplicacion movil Flutter que la consume mediante Dio.

---

## Descripcion general

La solucion integra dos proyectos independientes:

- **Backend** (`backend/`): API REST desarrollada con **Node.js + Express** y base de datos **SQLite** con persistencia en archivo `.db`. Gestiona el inventario de productos mediante cinco endpoints HTTP.
- **Frontend** (`inventario_app/`): Aplicacion movil desarrollada en **Flutter** que permite consultar, registrar, editar y eliminar productos directamente contra la API.

---

## Tecnologias utilizadas

### Backend
| Tecnologia | Uso |
|---|---|
| Node.js v26 | Entorno de ejecucion |
| Express 4 | Framework HTTP |
| SQLite (node:sqlite) | Base de datos persistente |
| dotenv | Variables de entorno |
| cors | Control de acceso cruzado |
| jsonwebtoken | Generacion y verificacion de tokens JWT |
| bcryptjs | Hash de contrasenas |

### Frontend Flutter
| Paquete | Uso |
|---|---|
| `dio` | Peticiones HTTP a la API con interceptores JWT |
| `go_router` | Navegacion declarativa con redirect guard |
| `flutter_dotenv` | URL base de la API desde `.env` |
| `flutter_secure_storage` | Almacenamiento seguro del access_token |
| `shared_preferences` | Almacenamiento de nombre y email del usuario |

---

## Autenticacion JWT

### Flujo general

```
Flutter                        Backend
  │                               │
  │  POST /api/auth/login         │
  │  { email, password }          │
  │ ─────────────────────────── > │  Valida credenciales con bcrypt
  │                               │  Genera token JWT (8h)
  │  200 { access_token, usuario }│
  │ < ─────────────────────────── │
  │                               │
  │  flutter_secure_storage       │
  │  .write(key='access_token')   │
  │                               │
  │  GET /api/productos           │
  │  Authorization: Bearer <tok>  │
  │ ─────────────────────────── > │  verifyToken middleware
  │                               │  Valida JWT, extrae payload
  │  200 [...productos]           │
  │ < ─────────────────────────── │
  │                               │
  │  GET /api/productos           │
  │  (sin token)                  │
  │ ─────────────────────────── > │
  │  401 Acceso denegado          │
  │ < ─────────────────────────── │
```

### Credenciales de prueba (usuario semilla)

| Campo | Valor |
|---|---|
| Email | `admin@uceva.edu.co` |
| Contrasena | `admin1234` |

El usuario se crea automaticamente al iniciar el servidor si la tabla esta vacia.

### Endpoints de autenticacion

| Metodo | Ruta | Acceso | Descripcion |
|---|---|---|---|
| `POST` | `/api/auth/login` | Publico | Valida credenciales, retorna JWT |
| `GET` | `/api/auth/me` | Protegido | Retorna datos del usuario autenticado |

### Proteccion de rutas

Todos los endpoints `/api/productos/*` requieren el header:
```
Authorization: Bearer <access_token>
```

Sin token valido, el backend responde `401 Unauthorized`.

### Almacenamiento local en Flutter

| Dato | Libreria | Razon |
|---|---|---|
| `access_token` | `flutter_secure_storage` | Dato sensible, cifrado en el dispositivo |
| `nombre` del usuario | `shared_preferences` | Dato no sensible |
| `email` del usuario | `shared_preferences` | Dato no sensible |

---

## Estructura del proyecto

```
ParcialII_moviles/
├── backend/
│   ├── src/
│   │   ├── config/
│   │   │   └── database.js           # Configuracion e inicializacion de SQLite
│   │   ├── controllers/
│   │   │   ├── authController.js     # Login y endpoint /me
│   │   │   └── productoController.js # Logica de negocio y validaciones
│   │   ├── middleware/
│   │   │   └── authMiddleware.js     # Middleware verifyToken para rutas protegidas
│   │   ├── models/
│   │   │   ├── productoModel.js      # Consultas de productos
│   │   │   └── usuarioModel.js       # Consultas de usuarios y seed inicial
│   │   ├── routes/
│   │   │   ├── authRoutes.js         # POST /login, GET /me
│   │   │   └── productoRoutes.js     # Endpoints CRUD de productos
│   │   ├── app.js                    # Configuracion de Express con JWT
│   │   └── server.js                 # Punto de entrada con init de tablas
│   ├── data/
│   │   └── inventario.db             # Base de datos SQLite persistente
│   ├── .env.example
│   └── package.json
│
└── inventario_app/
    └── lib/
        ├── config/
        │   └── app_config.dart       # Configuracion y acceso a dotenv
        ├── models/
        │   └── producto.dart         # Modelos con fromJson/toJson/copyWith
        ├── routes/
        │   └── app_router.dart       # go_router con redirect guard JWT
        ├── services/
        │   ├── auth_service.dart     # Login/logout con Dio
        │   ├── session_service.dart  # Almacenamiento seguro de sesion
        │   └── producto_service.dart # CRUD con interceptor Bearer token
        ├── themes/
        │   └── app_theme.dart        # Tema global con Material 3
        ├── views/
        │   ├── login_view.dart       # Pantalla de inicio de sesion
        │   ├── session_view.dart     # Informacion de sesion y logout
        │   ├── dashboard_view.dart
        │   ├── productos_list_view.dart
        │   ├── producto_detail_view.dart
        │   └── producto_form_view.dart
        ├── widgets/
        │   ├── estado_widgets.dart   # Loading, Error, Empty states
        │   └── producto_card.dart    # Tarjetas de producto y estadisticas
        └── main.dart
```

---

## Entidad Producto

| Campo | Tipo | Descripcion |
|---|---|---|
| `id` | Entero | Identificador unico autogenerado |
| `nombre` | Texto | Nombre del producto (obligatorio) |
| `codigo` | Texto | Codigo unico del producto (obligatorio) |
| `descripcion` | Texto | Descripcion adicional (opcional) |
| `precio` | Decimal | Precio unitario (>= 0) |
| `cantidad` | Entero | Unidades disponibles (>= 0) |
| `categoria` | Texto | Categoria del producto (obligatorio) |
| `created_at` | DateTime | Fecha de creacion |
| `updated_at` | DateTime | Ultima actualizacion |

---

## Endpoints de la API

Base URL local: `http://localhost:3000`

### Autenticacion (publicos)
| Metodo | Ruta | Funcionalidad |
|---|---|---|
| `GET` | `/api/health` | Estado del servidor |
| `POST` | `/api/auth/login` | Autenticarse y obtener JWT |
| `GET` | `/api/auth/me` | Datos del usuario autenticado (requiere JWT) |

### Productos (protegidos — requieren JWT)
| Metodo | Ruta | Funcionalidad |
|---|---|---|
| `GET` | `/api/productos` | Listar todos los productos |
| `GET` | `/api/productos/stats` | Estadisticas del inventario |
| `GET` | `/api/productos/:id` | Obtener detalle de un producto |
| `POST` | `/api/productos` | Registrar nuevo producto |
| `PUT` | `/api/productos/:id` | Actualizar producto existente |
| `DELETE` | `/api/productos/:id` | Eliminar producto |

### Codigos de respuesta HTTP
- `200 OK` — Consulta o actualizacion exitosa
- `201 Created` — Producto creado
- `400 Bad Request` — Parametro ID invalido
- `401 Unauthorized` — Token ausente, invalido o expirado
- `404 Not Found` — Recurso no encontrado
- `409 Conflict` — Codigo de producto duplicado
- `422 Unprocessable Entity` — Datos de entrada invalidos
- `500 Internal Server Error` — Error interno del servidor

---

## Rutas implementadas en go_router

| Ruta | Vista | Protegida | Descripcion |
|---|---|---|---|
| `/login` | `LoginView` | No | Pantalla de inicio de sesion |
| `/` | `DashboardView` | Si | Inicio con estadisticas e indicadores |
| `/sesion` | `SessionView` | Si | Info de sesion y boton de logout |
| `/productos` | `ProductosListView` | Si | Listado completo con busqueda |
| `/productos/nuevo` | `ProductoFormView` | Si | Formulario para crear producto |
| `/productos/:id` | `ProductoDetailView` | Si | Detalle del producto |
| `/productos/:id/editar` | `ProductoFormView` | Si | Formulario de edicion |

---

## Instrucciones para ejecutar

### Backend
```bash
cd backend
cp .env.example .env
# Editar JWT_SECRET en .env con una clave segura
npm install
node src/server.js
# Servidor disponible en http://localhost:3000
# Usuario semilla: admin@uceva.edu.co / admin1234
```

### Flutter
```bash
cd inventario_app
flutter pub get
# Ajustar API_BASE_URL en .env segun el dispositivo:
# Android emulador: http://10.0.2.2:3000/api
# Dispositivo fisico (misma red): http://192.168.x.x:3000/api
flutter run
```

---

## Criterios implementados (Taller JWT)

- Endpoint de login que valida credenciales y retorna un token JWT firmado.
- Middleware `verifyToken` que rechaza con 401 peticiones sin token valido o expirado.
- Todos los endpoints CRUD de productos protegidos con JWT.
- Pantalla de login con validaciones y manejo de error de credenciales incorrectas.
- Interceptor Dio que adjunta automaticamente el Bearer token en cada peticion.
- `flutter_secure_storage` para almacenar el access_token de forma segura.
- `shared_preferences` para nombre y email (datos no sensibles).
- Redirect guard en go_router: sin sesion redirige a `/login`; con sesion redirige al dashboard desde `/login`.
- Pantalla de sesion con nombre, email, estado de autenticacion, preview del token y boton de logout.
- Logout que elimina todos los datos locales y redirige al login.
- Persistencia de sesion: la app verifica la sesion al abrirse y no pide login si el token aun existe.
- Sin credenciales ni secretos en el repositorio.

---

**Estudiante:** Michael Stiven Vasco Cardenas — Codigo 230231047
**Asignatura:** Electiva Profesional I — UCEVA
