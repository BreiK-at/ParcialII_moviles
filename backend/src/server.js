require('dotenv').config();
const app = require('./app');
const { initializeDatabase } = require('./config/database');

const PORT = process.env.PORT || 3000;

try {
  initializeDatabase();
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor API REST de Inventario ejecutandose en el puerto ${PORT}`);
    console.log(`URL local: http://localhost:${PORT}/api/productos`);
    console.log(`Salud del servicio: http://localhost:${PORT}/api/health`);
  });
} catch (error) {
  console.error('Fallo al iniciar el servidor:', error);
  process.exit(1);
}
