require('dotenv').config();
const app = require('./app');
const { initializeDatabase } = require('./config/database');
const UsuarioModel = require('./models/usuarioModel');

const PORT = process.env.PORT || 3000;

try {
  initializeDatabase();
  UsuarioModel.initTable();
  UsuarioModel.seedIfEmpty();

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor API REST de Inventario ejecutandose en el puerto ${PORT}`);
    console.log(`Autenticacion: POST http://localhost:${PORT}/api/auth/login`);
    console.log(`Productos (protegidos): http://localhost:${PORT}/api/productos`);
    console.log(`Salud del servicio: http://localhost:${PORT}/api/health`);
  });
} catch (error) {
  console.error('Fallo al iniciar el servidor:', error);
  process.exit(1);
}
