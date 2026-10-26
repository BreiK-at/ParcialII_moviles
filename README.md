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

### Frontend Flutter
| Paquete | Uso |
|---|---|
| `dio` | Peticiones HTTP a la API |
| `go_router` | Navegacion declarativa entre pantallas |
| `flutter_dotenv` | URL base de la API desde `.env` |

---

## Estructura del proyecto

```
ParcialII_moviles/
├── backend/
│   ├── src/
│   │   ├── config/
│   │   │   └── database.js       # Configuracion e inicializacion de SQLite
│   │   ├── controllers/
│   │   │   └── productoController.js   # Logica de negocio y validaciones
│   │   ├── models/
│   │   │   └── productoModel.js  # Consultas a la base de datos
│   │   ├── routes/
│   │   │   └── productoRoutes.js # Definicion de endpoints
│   │   ├── app.js                # Configuracion de Express
│   │   └── server.js             # Punto de entrada
│   ├── data/
│   │   └── inventario.db         # Base de datos SQLite persistente
│   ├── tests/
│   │   └── api.test.js           # Pruebas de integracion del API
│   ├── .env.example
│   └── package.json
│
└── inventario_app/
    └── lib/
        ├── config/
        │   └── app_config.dart   # Configuracion y acceso a dotenv
        ├── models/
        │   └── producto.dart     # Modelos con fromJson/toJson/copyWith
        ├── routes/
        │   └── app_router.dart   # Configuracion de go_router
        ├── services/
        │   └── producto_service.dart  # Peticiones HTTP con Dio
        ├── themes/
        │   └── app_theme.dart    # Tema global con Material 3
        ├── views/
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

| Metodo | Ruta | Funcionalidad |
|---|---|---|
| `GET` | `/api/health` | Verificar estado del servidor |
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
- `404 Not Found` — Producto no encontrado
- `409 Conflict` — Codigo de producto duplicado
- `422 Unprocessable Entity` — Datos de entrada invalidos
- `500 Internal Server Error` — Error interno del servidor

---

## Ejemplo de respuesta JSON

### GET /api/productos/1
```json
{
  "id": 1,
  "nombre": "Laptop Lenovo ThinkPad T14",
  "codigo": "PRD-001",
  "descripcion": "Procesador Ryzen 7, 16GB RAM, 512GB SSD PCIe NVMe",
  "precio": 3500000,
  "cantidad": 15,
  "categoria": "Computadores",
  "created_at": "2026-10-26T15:32:47.000Z",
  "updated_at": "2026-10-26T15:32:47.000Z"
}
```

### GET /api/productos/stats
```json
{
  "total_productos": 12,
  "total_unidades": 367,
  "valor_total_inventario": 72345000
}
```

---

## Rutas implementadas en go_router

| Ruta | Vista | Descripcion |
|---|---|---|
| `/` | `DashboardView` | Pantalla de inicio con estadisticas e indicadores |
| `/productos` | `ProductosListView` | Listado completo con busqueda y filtrado |
| `/productos/nuevo` | `ProductoFormView` | Formulario para crear un producto |
| `/productos/:id` | `ProductoDetailView` | Detalle completo del producto seleccionado |
| `/productos/:id/editar` | `ProductoFormView` | Formulario precargado para editar |

---

## Instrucciones para ejecutar

### Backend
```bash
cd backend
cp .env.example .env
npm install
node src/server.js
# Servidor disponible en http://localhost:3000
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

### Pruebas backend
```bash
cd backend
npm test
```

### Pruebas Flutter
```bash
cd inventario_app
flutter test
```

---

## Criterios implementados

- Cinco endpoints funcionales con validaciones y codigos HTTP correctos.
- Persistencia real en SQLite. Los datos sobreviven reinicios del servidor.
- 12 productos de prueba precargados al iniciar por primera vez.
- CRUD completo desde Flutter con confirmacion de eliminacion.
- Dashboard con indicadores calculados en tiempo real desde la API.
- Manejo de estados de carga, error con boton de reintento y lista vacia.
- Separacion estricta en capas: config, models, services, views, widgets, routes.
- Navegacion con go_router y paso de objetos mediante `extra`.
- Variables de entorno con `flutter_dotenv`.
- Busqueda en tiempo real en la lista de productos.
- Sin credenciales ni secretos en el repositorio.

---

**Estudiante:** Michael Stiven Vasco Cardenas — Codigo 230231047  
**Asignatura:** Electiva Profesional I — UCEVA
