const express = require('express');
const router = express.Router();
const ProductoController = require('../controllers/productoController');

// Rutas de productos
router.get('/stats', ProductoController.getStats);
router.get('/', ProductoController.getAll);
router.get('/:id', ProductoController.getById);
router.post('/', ProductoController.create);
router.put('/:id', ProductoController.update);
router.delete('/:id', ProductoController.delete);

module.exports = router;
