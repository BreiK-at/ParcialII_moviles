const { db } = require('../config/database');

class ProductoModel {
  static getAll() {
    const stmt = db.prepare('SELECT * FROM productos ORDER BY id DESC');
    return stmt.all();
  }

  static getById(id) {
    const stmt = db.prepare('SELECT * FROM productos WHERE id = ?');
    return stmt.get(Number(id)) || null;
  }

  static getByCodigo(codigo) {
    const stmt = db.prepare('SELECT * FROM productos WHERE LOWER(codigo) = LOWER(?)');
    return stmt.get(codigo) || null;
  }

  static create({ nombre, codigo, descripcion, precio, cantidad, categoria }) {
    const stmt = db.prepare(`
      INSERT INTO productos (nombre, codigo, descripcion, precio, cantidad, categoria)
      VALUES (?, ?, ?, ?, ?, ?)
    `);
    const result = stmt.run(
      nombre.trim(),
      codigo.trim().toUpperCase(),
      descripcion ? descripcion.trim() : null,
      parseFloat(precio),
      parseInt(cantidad, 10),
      categoria.trim()
    );
    return this.getById(result.lastInsertRowid);
  }

  static update(id, { nombre, codigo, descripcion, precio, cantidad, categoria }) {
    const existing = this.getById(id);
    if (!existing) return null;

    const stmt = db.prepare(`
      UPDATE productos
      SET nombre = ?,
          codigo = ?,
          descripcion = ?,
          precio = ?,
          cantidad = ?,
          categoria = ?,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `);

    stmt.run(
      nombre !== undefined ? nombre.trim() : existing.nombre,
      codigo !== undefined ? codigo.trim().toUpperCase() : existing.codigo,
      descripcion !== undefined ? (descripcion ? descripcion.trim() : null) : existing.descripcion,
      precio !== undefined ? parseFloat(precio) : existing.precio,
      cantidad !== undefined ? parseInt(cantidad, 10) : existing.cantidad,
      categoria !== undefined ? categoria.trim() : existing.categoria,
      Number(id)
    );

    return this.getById(id);
  }

  static delete(id) {
    const existing = this.getById(id);
    if (!existing) return false;

    const stmt = db.prepare('DELETE FROM productos WHERE id = ?');
    stmt.run(Number(id));
    return true;
  }

  static getStats() {
    const stmt = db.prepare(`
      SELECT 
        COUNT(*) AS total_productos,
        COALESCE(SUM(cantidad), 0) AS total_unidades,
        COALESCE(SUM(precio * cantidad), 0) AS valor_total_inventario
      FROM productos
    `);
    return stmt.get();
  }
}

module.exports = ProductoModel;
