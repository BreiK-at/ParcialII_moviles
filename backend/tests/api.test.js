const assert = require('assert');
const http = require('http');
const app = require('../src/app');
const { initializeDatabase, db } = require('../src/config/database');

initializeDatabase();

const server = app.listen(0);
const port = server.address().port;
const baseUrl = `http://127.0.0.1:${port}`;

function request(method, path, data = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, baseUrl);
    const options = {
      method,
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          const parsed = body ? JSON.parse(body) : null;
          resolve({ status: res.statusCode, data: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, raw: body });
        }
      });
    });

    req.on('error', reject);
    if (data) req.write(JSON.stringify(data));
    req.end();
  });
}

async function runTests() {
  console.log('Iniciando pruebas de la API REST...');

  // 1. GET /api/health
  let res = await request('GET', '/api/health');
  assert.strictEqual(res.status, 200);
  assert.strictEqual(res.data.status, 'ok');
  console.log('Prueba 1 superada: Health check responde 200 OK');

  // 2. GET /api/productos
  res = await request('GET', '/api/productos');
  assert.strictEqual(res.status, 200);
  assert(Array.isArray(res.data));
  assert(res.data.length >= 10, 'Debe contener al menos 10 productos de prueba');
  console.log(`Prueba 2 superada: Listado de productos retorna ${res.data.length} elementos`);

  // 3. GET /api/productos/:id
  const firstId = res.data[0].id;
  res = await request('GET', `/api/productos/${firstId}`);
  assert.strictEqual(res.status, 200);
  assert.strictEqual(res.data.id, firstId);
  console.log('Prueba 3 superada: Consulta de detalle por ID retorna 200 OK');

  // 4. POST /api/productos (Exitoso)
  const nuevoCodigo = `TEST-${Date.now()}`;
  const nuevoProducto = {
    nombre: 'Tablet Grafica Wacom Intuos',
    codigo: nuevoCodigo,
    descripcion: 'Tableta digitalizadora de precisión con lápiz 4K',
    precio: 320000.50,
    cantidad: 8,
    categoria: 'Diseno'
  };
  res = await request('POST', '/api/productos', nuevoProducto);
  assert.strictEqual(res.status, 201);
  assert.strictEqual(res.data.nombre, nuevoProducto.nombre);
  assert.strictEqual(res.data.codigo, nuevoCodigo);
  const createdId = res.data.id;
  console.log('Prueba 4 superada: Registro de nuevo producto retorna 201 Created');

  // 5. POST /api/productos (Validación código duplicado -> 409 Conflict)
  res = await request('POST', '/api/productos', nuevoProducto);
  assert.strictEqual(res.status, 409);
  console.log('Prueba 5 superada: Intento de código duplicado retorna 409 Conflict');

  // 6. POST /api/productos (Validación campos faltantes -> 422 Unprocessable Entity)
  res = await request('POST', '/api/productos', { nombre: 'Incompleto' });
  assert.strictEqual(res.status, 422);
  console.log('Prueba 6 superada: Datos incompletos retorna 422 Unprocessable Entity');

  // 7. PUT /api/productos/:id (Actualizar existente)
  res = await request('PUT', `/api/productos/${createdId}`, {
    precio: 350000.00,
    cantidad: 15,
    descripcion: 'Descripcion actualizada para prueba'
  });
  assert.strictEqual(res.status, 200);
  assert.strictEqual(res.data.precio, 350000);
  assert.strictEqual(res.data.cantidad, 15);
  console.log('Prueba 7 superada: Actualización de producto retorna 200 OK');

  // 8. DELETE /api/productos/:id (Eliminar)
  res = await request('DELETE', `/api/productos/${createdId}`);
  assert.strictEqual(res.status, 200);
  console.log('Prueba 8 superada: Eliminación de producto retorna 200 OK');

  // 9. GET /api/productos/:id (Verificar que ya no existe -> 404 Not Found)
  res = await request('GET', `/api/productos/${createdId}`);
  assert.strictEqual(res.status, 404);
  console.log('Prueba 9 superada: Verificación de producto eliminado retorna 404 Not Found');

  // 10. GET /api/productos/stats
  res = await request('GET', '/api/productos/stats');
  assert.strictEqual(res.status, 200);
  assert(res.data.total_productos >= 10);
  assert(res.data.total_unidades > 0);
  assert(res.data.valor_total_inventario > 0);
  console.log('Prueba 10 superada: Endpoint de estadísticas retorna datos calculados');

  server.close();
  console.log('Todas las pruebas del backend pasaron exitosamente.');
}

runTests().catch((err) => {
  console.error('Fallo en las pruebas:', err);
  if (server) server.close();
  process.exit(1);
});
