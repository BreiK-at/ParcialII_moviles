const jwt = require('jsonwebtoken');

function verifyToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Acceso denegado. Se requiere token de autenticacion.' });
  }

  const token = authHeader.split(' ')[1];
  const secret = process.env.JWT_SECRET;
  if (!secret) {
    console.error('JWT_SECRET no definido en variables de entorno.');
    return res.status(500).json({ error: 'Error de configuracion del servidor.' });
  }

  try {
    const payload = jwt.verify(token, secret);
    req.usuario = payload;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'El token ha expirado. Inicia sesion nuevamente.' });
    }
    return res.status(401).json({ error: 'Token invalido. Inicia sesion nuevamente.' });
  }
}

module.exports = { verifyToken };
