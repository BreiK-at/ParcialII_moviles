const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const productoRoutes = require('./routes/productoRoutes');
const { verifyToken } = require('./middleware/authMiddleware');

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

// Endpoint de salud — publico
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    servicio: 'API Gestion de Inventario',
    version: '2.0.0',
    autenticacion: 'JWT habilitado',
    timestamp: new Date().toISOString()
  });
});

// Rutas de autenticacion — publicas excepto /me
app.use('/api/auth', authRoutes);

// Rutas de productos — protegidas con JWT
app.use('/api/productos', verifyToken, productoRoutes);

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
    error: 'Ocurrio un error inesperado en el servidor',
    detalle: err.message
  });
});

module.exports = app;
