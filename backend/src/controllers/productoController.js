const ProductoModel = require('../models/productoModel');

class ProductoController {
  static getAll(req, res) {
    try {
      const productos = ProductoModel.getAll();
      return res.status(200).json(productos);
    } catch (error) {
      console.error('Error al obtener productos:', error);
      return res.status(500).json({ error: 'Error interno al consultar productos' });
    }
  }

  static getById(req, res) {
    try {
      const { id } = req.params;
      if (!id || isNaN(Number(id))) {
        return res.status(400).json({ error: 'El parámetro id debe ser un número entero válido' });
      }

      const producto = ProductoModel.getById(id);
      if (!producto) {
        return res.status(404).json({ error: `Producto con id ${id} no encontrado` });
      }

      return res.status(200).json(producto);
    } catch (error) {
      console.error('Error al obtener producto por id:', error);
      return res.status(500).json({ error: 'Error interno al consultar el producto' });
    }
  }

  static create(req, res) {
    try {
      const { nombre, codigo, descripcion, precio, cantidad, categoria } = req.body;

      // Validar campos obligatorios
      if (!nombre || typeof nombre !== 'string' || nombre.trim() === '') {
        return res.status(422).json({ error: 'El campo nombre es obligatorio y debe ser texto' });
      }
      if (!codigo || typeof codigo !== 'string' || codigo.trim() === '') {
        return res.status(422).json({ error: 'El campo codigo es obligatorio y debe ser texto' });
      }
      if (categoria === undefined || typeof categoria !== 'string' || categoria.trim() === '') {
        return res.status(422).json({ error: 'El campo categoria es obligatorio y debe ser texto' });
      }

      const numPrecio = parseFloat(precio);
      if (isNaN(numPrecio) || numPrecio < 0) {
        return res.status(422).json({ error: 'El campo precio debe ser un número decimal mayor o igual a 0' });
      }

      const numCantidad = parseInt(cantidad, 10);
      if (isNaN(numCantidad) || numCantidad < 0) {
        return res.status(422).json({ error: 'El campo cantidad debe ser un número entero mayor o igual a 0' });
      }

      // Validar unicidad de código
      const productoExistente = ProductoModel.getByCodigo(codigo);
      if (productoExistente) {
        return res.status(409).json({ error: `Ya existe un producto registrado con el código '${codigo.trim().toUpperCase()}'` });
      }

      const nuevoProducto = ProductoModel.create({
        nombre,
        codigo,
        descripcion,
        precio: numPrecio,
        cantidad: numCantidad,
        categoria
      });

      return res.status(201).json(nuevoProducto);
    } catch (error) {
      console.error('Error al crear producto:', error);
      return res.status(500).json({ error: 'Error interno al registrar el producto' });
    }
  }

  static update(req, res) {
    try {
      const { id } = req.params;
      if (!id || isNaN(Number(id))) {
        return res.status(400).json({ error: 'El parámetro id debe ser un número entero válido' });
      }

      const productoExistente = ProductoModel.getById(id);
      if (!productoExistente) {
        return res.status(404).json({ error: `Producto con id ${id} no encontrado para actualizar` });
      }

      const { nombre, codigo, descripcion, precio, cantidad, categoria } = req.body;

      if (nombre !== undefined && (typeof nombre !== 'string' || nombre.trim() === '')) {
        return res.status(422).json({ error: 'El campo nombre no puede ser una cadena vacía' });
      }

      if (categoria !== undefined && (typeof categoria !== 'string' || categoria.trim() === '')) {
        return res.status(422).json({ error: 'El campo categoria no puede ser una cadena vacía' });
      }

      let parsedPrecio;
      if (precio !== undefined) {
        parsedPrecio = parseFloat(precio);
        if (isNaN(parsedPrecio) || parsedPrecio < 0) {
          return res.status(422).json({ error: 'El campo precio debe ser un número decimal mayor o igual a 0' });
        }
      }

      let parsedCantidad;
      if (cantidad !== undefined) {
        parsedCantidad = parseInt(cantidad, 10);
        if (isNaN(parsedCantidad) || parsedCantidad < 0) {
          return res.status(422).json({ error: 'El campo cantidad debe ser un número entero mayor o igual a 0' });
        }
      }

      if (codigo !== undefined) {
        if (typeof codigo !== 'string' || codigo.trim() === '') {
          return res.status(422).json({ error: 'El campo codigo no puede ser una cadena vacía' });
        }
        const codigoRepetido = ProductoModel.getByCodigo(codigo);
        if (codigoRepetido && codigoRepetido.id !== Number(id)) {
          return res.status(409).json({ error: `El código '${codigo.trim().toUpperCase()}' ya pertenece a otro producto` });
        }
      }

      const productoActualizado = ProductoModel.update(id, {
        nombre,
        codigo,
        descripcion,
        precio: parsedPrecio,
        cantidad: parsedCantidad,
        categoria
      });

      return res.status(200).json(productoActualizado);
    } catch (error) {
      console.error('Error al actualizar producto:', error);
      return res.status(500).json({ error: 'Error interno al actualizar el producto' });
    }
  }

  static delete(req, res) {
    try {
      const { id } = req.params;
      if (!id || isNaN(Number(id))) {
        return res.status(400).json({ error: 'El parámetro id debe ser un número entero válido' });
      }

      const eliminado = ProductoModel.delete(id);
      if (!eliminado) {
        return res.status(404).json({ error: `Producto con id ${id} no encontrado para eliminar` });
      }

      return res.status(200).json({
        message: 'Producto eliminado exitosamente',
        id: Number(id)
      });
    } catch (error) {
      console.error('Error al eliminar producto:', error);
      return res.status(500).json({ error: 'Error interno al eliminar el producto' });
    }
  }

  static getStats(req, res) {
    try {
      const stats = ProductoModel.getStats();
      return res.status(200).json(stats);
    } catch (error) {
      console.error('Error al obtener estadísticas:', error);
      return res.status(500).json({ error: 'Error interno al calcular estadísticas' });
    }
  }
}

module.exports = ProductoController;
