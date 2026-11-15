const express = require('express');
const router = express.Router();
const AuthController = require('../controllers/authController');
const { verifyToken } = require('../middleware/authMiddleware');

// POST /api/auth/login — publico, genera el token JWT
router.post('/login', AuthController.login);

// GET /api/auth/me — protegido, retorna datos del usuario autenticado
router.get('/me', verifyToken, AuthController.me);

module.exports = router;
