const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const UsuarioModel = require('../models/usuarioModel');

class AuthController {
  static login(req, res) {
    try {
      const { email, password } = req.body;

      if (!email || typeof email !== 'string' || email.trim() === '') {
        return res.status(422).json({ error: 'El campo email es obligatorio.' });
      }
      if (!password || typeof password !== 'string' || password.trim() === '') {
        return res.status(422).json({ error: 'El campo password es obligatorio.' });
      }

      const usuario = UsuarioModel.findByEmail(email.trim().toLowerCase());
      if (!usuario) {
        return res.status(401).json({ error: 'Credenciales incorrectas.' });
      }

      const passwordValida = bcrypt.compareSync(password, usuario.password_hash);
      if (!passwordValida) {
        return res.status(401).json({ error: 'Credenciales incorrectas.' });
      }

      const secret = process.env.JWT_SECRET;
      const expiresIn = process.env.JWT_EXPIRES_IN || '8h';

      const payload = {
        sub: usuario.id,
        nombre: usuario.nombre,
        email: usuario.email,
      };

      const token = jwt.sign(payload, secret, { expiresIn });

      return res.status(200).json({
        access_token: token,
        token_type: 'Bearer',
        expires_in: expiresIn,
        usuario: {
          id: usuario.id,
          nombre: usuario.nombre,
          email: usuario.email,
        },
      });
    } catch (error) {
      console.error('Error en login:', error);
      return res.status(500).json({ error: 'Error interno al procesar la autenticacion.' });
    }
  }

  static me(req, res) {
    try {
      const usuario = UsuarioModel.findById(req.usuario.sub);
      if (!usuario) {
        return res.status(404).json({ error: 'Usuario no encontrado.' });
      }
      return res.status(200).json(usuario);
    } catch (error) {
      console.error('Error en me:', error);
      return res.status(500).json({ error: 'Error interno al obtener datos del usuario.' });
    }
  }
}

module.exports = AuthController;
