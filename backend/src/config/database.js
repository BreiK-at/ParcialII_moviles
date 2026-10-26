const fs = require('fs');
const path = require('path');
const { DatabaseSync } = require('node:sqlite');

const dbPath = process.env.DB_PATH || path.join(__dirname, '../../data/inventario.db');
const dbDir = path.dirname(dbPath);

if (!fs.existsSync(dbDir)) {
  fs.mkdirSync(dbDir, { recursive: true });
}

const db = new DatabaseSync(dbPath);

function initializeDatabase() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS productos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      codigo TEXT NOT NULL UNIQUE,
      descripcion TEXT,
      precio REAL NOT NULL CHECK(precio >= 0),
      cantidad INTEGER NOT NULL CHECK(cantidad >= 0),
      categoria TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `);

  const countRow = db.prepare('SELECT COUNT(*) AS total FROM productos').get();
  if (countRow.total === 0) {
    console.log('Base de datos vacía. Insertando 12 productos iniciales...');
    const insertStmt = db.prepare(`
      INSERT INTO productos (nombre, codigo, descripcion, precio, cantidad, categoria)
      VALUES (?, ?, ?, ?, ?, ?)
    `);

    const initialProducts = [
      ['Laptop Lenovo ThinkPad T14', 'PRD-001', 'Procesador Ryzen 7, 16GB RAM, 512GB SSD PCIe NVMe', 3500000, 15, 'Computadores'],
      ['Monitor Dell UltraSharp 27"', 'PRD-002', 'Resolución 4K UHD, panel IPS, 99% sRGB con hub USB-C', 1250000, 20, 'Pantallas'],
      ['Teclado Mecanico Keychron K2', 'PRD-003', 'Switches Gateron Brown, inalámbrico Bluetooth 5.1 y RGB', 380000, 35, 'Perifericos'],
      ['Mouse Logitech MX Master 3S', 'PRD-004', 'Sensor Darkfield 8000 DPI con desplazamiento electromagnético', 420000, 40, 'Perifericos'],
      ['Disco SSD Samsung 980 Pro 1TB', 'PRD-005', 'PCIe 4.0 NVMe M.2 con velocidades de lectura hasta 7000 MB/s', 490000, 25, 'Almacenamiento'],
      ['Memoria RAM Corsair Vengeance 16GB', 'PRD-006', 'DDR4 3200MHz CL16 con disipador de calor de aluminio', 210000, 50, 'Componentes'],
      ['Auriculares Sony WH-1000XM5', 'PRD-007', 'Cancelación activa de ruido con procesador V1 y LDAC', 1450000, 12, 'Audio'],
      ['Silla Ergonomica Sihoo M57', 'PRD-008', 'Malla transpirable, soporte lumbar bidireccional y brazos 3D', 890000, 18, 'Mobiliario'],
      ['Camara Web Logitech Brio 4K', 'PRD-009', 'Sensor Ultra HD 4K con HDR y reconocimiento facial Windows Hello', 780000, 15, 'Video'],
      ['Impresora Epson EcoTank L3250', 'PRD-010', 'Sistema de tanque de tinta continua WiFi con escáner integrado', 820000, 10, 'Impresion'],
      ['Router TP-Link Archer AX73 WiFi 6', 'PRD-011', 'Doble banda Gigabit hasta 5400 Mbps con 6 antenas de alta ganancia', 540000, 22, 'Redes'],
      ['Cable HDMI 2.1 Ultra High Speed 2m', 'PRD-012', 'Soporta 8K 60Hz y 4K 120Hz con ancho de banda de 48 Gbps', 45000, 100, 'Accesorios']
    ];

    for (const prod of initialProducts) {
      insertStmt.run(...prod);
    }
    console.log('12 productos iniciales insertados con éxito.');
  }
}

module.exports = {
  db,
  initializeDatabase
};
