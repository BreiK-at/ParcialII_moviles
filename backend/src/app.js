const express = require('express');
const cors = require('cors');
const productoRoutes = require('./routes/productoRoutes');

const app = express();

// Middlewares globales
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Log simple de peticiones en consola
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} -> ${res.statusCode} (${duration}ms)`);
  });
  next();
});

// Endpoint de salud
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    servicio: 'API Gestion de Inventario',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// Montar rutas de negocio
app.use('/api/productos', productoRoutes);

// Manejador para rutas no encontradas
app.use((req, res) => {
  res.status(404).json({
    error: `Ruta ${req.method} ${req.originalUrl} no encontrada en esta API`
  });
});

// Manejador global de errores
app.use((err, req, res, next) => {
  console.error('Error no controlado:', err);
  res.status(500).json({
    error: 'Ocurrió un error inesperado en el servidor',
    detalle: err.message
  });
});

module.exports = app;
