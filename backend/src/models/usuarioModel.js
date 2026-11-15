const { db } = require('../config/database');

class UsuarioModel {
  static initTable() {
    db.exec(`
      CREATE TABLE IF NOT EXISTS usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );
    `);
  }

  static findByEmail(email) {
    const stmt = db.prepare('SELECT * FROM usuarios WHERE email = ?');
    return stmt.get(email) || null;
  }

  static findById(id) {
    const stmt = db.prepare('SELECT id, nombre, email, created_at FROM usuarios WHERE id = ?');
    return stmt.get(Number(id)) || null;
  }

  static create({ nombre, email, passwordHash }) {
    const stmt = db.prepare(
      'INSERT INTO usuarios (nombre, email, password_hash) VALUES (?, ?, ?)'
    );
    const result = stmt.run(nombre.trim(), email.trim().toLowerCase(), passwordHash);
    return this.findById(result.lastInsertRowid);
  }

  static seedIfEmpty() {
    const bcrypt = require('bcryptjs');
    const countRow = db.prepare('SELECT COUNT(*) AS total FROM usuarios').get();
    if (countRow.total === 0) {
      const hash = bcrypt.hashSync('admin1234', 10);
      db.prepare(
        'INSERT INTO usuarios (nombre, email, password_hash) VALUES (?, ?, ?)'
      ).run('Admin Inventario', 'admin@uceva.edu.co', hash);
      console.log('Usuario semilla creado: admin@uceva.edu.co / admin1234');
    }
  }
}

module.exports = UsuarioModel;
