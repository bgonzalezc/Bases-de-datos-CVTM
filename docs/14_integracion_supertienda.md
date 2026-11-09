# Integración con SuperTienda

## Descripción

Este documento describe la integración entre el sistema CVTM (Centro Veterinario y Tienda de Mascotas) y el sistema SuperTienda. La integración permite sincronizar información de productos, ventas y proveedores entre ambos sistemas.

## Objetivos de la Integración

1. **Sincronización de Productos**: Mantener actualizado el catálogo de productos entre CVTM y SuperTienda
2. **Gestión de Inventario**: Compartir información de stock entre ambos sistemas
3. **Sincronización de Ventas**: Registrar ventas de CVTM en SuperTienda para consolidación de reportes
4. **Gestión de Proveedores**: Compartir información de proveedores comunes
5. **Reportes Consolidados**: Generar reportes combinados de ventas de ambos sistemas

## Arquitectura de Integración
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                        SISTEMA CVTM                                      │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                  │
│  │   Producto  │    │    Venta    │    │  Proveedor  │                  │
│  └─────────────┘    └─────────────┘    └─────────────┘                  │
│         │                  │                  │                         │
│         └──────────────────┼──────────────────┘                         │
│                            │                                     │
│                            ▼                                     │
│              ┌─────────────────────────────────────────────────┐          │
│              │       API de Integración       │                  │
│              │   (REST API / Web Services)    │                  │
│              └─────────────────────────────────────────────────┘          │
│                                │                                    │
│                                ▼                                    │
│  ┌───────────────────────────────────────────────────────────────────────┤
│  │                        RED (Internet)                             │  │
│  └───────────────────────────────────────────────────────────────────────┘
│                                │
│                                ▼
│              ┌─────────────────────────────────────────────────┐
│              │     API Gateway SuperTienda     │
│              └─────────────────────────────────────────────────┘
│         ┌──────────────▼──────────────▼──────────────▼
│  ┌─────────────┐        ┌─────────────┐        ┌─────────────┐
│  │  Productos  │        │   Ventas    │        │ Proveedores │
│  └─────────────┘        └─────────────┘        └─────────────┘
│
│                     SISTEMA SUPERTIENDA
└─────────────────────────────────────────────────────────────────────────────────────────┘

## Métodos de Integración

### 1. API REST

La integración principal se realiza mediante una API REST que exponen ambos sistemas.

#### Endpoints de CVTM

| Endpoint | Método | Descripción | Autenticación |
|----------|--------|-------------|---------------|
| `/api/productos` | GET | Listar productos | API Key |
| `/api/productos/{id}` | GET | Obtener producto por ID | API Key |
| `/api/productos` | POST | Crear producto | API Key |
| `/api/productos/{id}` | PUT | Actualizar producto | API Key |
| `/api/productos/{id}` | DELETE | Eliminar producto | API Key |
| `/api/ventas` | GET | Listar ventas | API Key |
| `/api/ventas` | POST | Crear venta | API Key |
| `/api/proveedores` | GET | Listar proveedores | API Key |
| `/api/proveedores/{id}` | GET | Obtener proveedor por ID | API Key |

#### Endpoints de SuperTienda

| Endpoint | Método | Descripción | Autenticación |
|----------|--------|-------------|---------------|
| `/api/inventario/productos` | GET | Listar productos | OAuth 2.0 |
| `/api/inventario/productos` | POST | Crear/Actualizar producto | OAuth 2.0 |
| `/api/ventas` | GET | Listar ventas | OAuth 2.0 |
| `/api/ventas` | POST | Crear venta | OAuth 2.0 |
| `/api/proveedores` | GET | Listar proveedores | OAuth 2.0 |
| `/api/proveedores` | POST | Crear/Actualizar proveedor | OAuth 2.0 |

### 2. Sincronización por Archivos

Para sistemas con conectividad limitada, se implementa sincronización mediante archivos CSV/JSON.

#### Formato de Archivos

**Productos (CSV):**
```csv
ID_Producto,Nombre_Producto,Precio_Unitario,Stock,Rut_Proveedor,Fecha_Vencimiento
1,Antiparasitario Bravecto,32000.00,25,76.123.456-0,2026-11-30
2,Alimento Premium,48990.00,40,77.987.654-1,2027-03-15
Ventas (JSON):

{
  "ventas": [
    {
      "ID_Venta": 1,
      "Fecha_Pago": "2026-10-10",
      "Monto_Venta": 52000.00,
      "Forma_Pago": "Tarjeta Débito",
      "Rut_Cliente": "15.420.311-8",
      "Rut_Cajero": "19.876.543-1",
      "detalles": [
        {
          "ID_Producto": 1,
          "Cantidad": 1,
          "Subtotal": 32000.00
        }
      ]
    }
  ]
}
3. Base de Datos Distribuida
Para integración en tiempo real, se puede implementar una arquitectura de base de datos distribuida usando:

Replicación de MySQL
Federated Storage Engines
Middleware de integración como Apache Kafka
Implementación de la API REST
Autenticación
API Key (CVTM)
-- Tabla para almacenar API Keys
CREATE TABLE IF NOT EXISTS Api_Keys (
    ID_Key INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Api_Key VARCHAR(64) NOT NULL UNIQUE,
    Secret_Key VARCHAR(64) NOT NULL,
    Fecha_Creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Fecha_Expiracion DATETIME,
    Activo BOOLEAN NOT NULL DEFAULT TRUE,
    Permisos JSON NOT NULL
);

-- Insertar API Key para SuperTienda
INSERT INTO Api_Keys (Nombre, Api_Key, Secret_Key, Permisos)
VALUES (
    'SuperTienda Integración',
    'st-cvtm-api-key-2024',
    'st-cvtm-secret-key-2024',
    '{"productos": ["read", "write"], "ventas": ["write"], "proveedores": ["read"]}'
);
OAuth 2.0 (SuperTienda)
Para autenticarse con SuperTienda, CVTM debe:

Registrarse como cliente OAuth en SuperTienda
Obtener un Client ID y Client Secret
Usar el flujo Client Credentials para obtener un token
# Obtener token OAuth
curl -X POST https://api.supertienda.cl/oauth/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=CLIENT_ID&client_secret=CLIENT_SECRET"
Endpoints de la API CVTM
Productos
GET /api/productos - Listar productos

Request:
  Headers: Authorization: Bearer API_KEY
  Query Params: limite=100, pagina=1

Response:
  {
    "productos": [
      {
        "ID_Producto": 1,
        "Nombre_Producto": "Antiparasitario Bravecto",
        "Precio_Unitario": 32000.00,
        "Stock": 25,
        "Fecha_Vencimiento": "2026-11-30",
        "Rut_Proveedor": "76.123.456-0"
      }
    ],
    "total": 10,
    "pagina": 1,
    "limite": 100
  }
POST /api/productos - Crear/Actualizar producto

Request:
  Headers: Authorization: Bearer API_KEY
  Body:
    {
      "ID_Producto": 1,
      "Nombre_Producto": "Antiparasitario Bravecto",
      "Precio_Unitario": 32000.00,
      "Stock": 25,
      "Fecha_Vencimiento": "2026-11-30",
      "Rut_Proveedor": "76.123.456-0"
    }

Response:
  {
    "success": true,
    "ID_Producto": 1,
    "message": "Producto actualizado"
  }
Ventas
POST /api/ventas - Registrar venta en SuperTienda

Request:
  Headers: Authorization: Bearer API_KEY
  Body:
    {
      "ID_Venta": 1,
      "Fecha_Pago": "2026-10-10",
      "Monto_Venta": 52000.00,
      "Forma_Pago": "Tarjeta Débito",
      "Rut_Cliente": "15.420.311-8",
      "detalles": [
        {
          "ID_Producto": 1,
          "Cantidad": 1,
          "Subtotal": 32000.00
        },
        {
          "ID_Prestacion": 1,
          "Cantidad": 1,
          "Subtotal": 20000.00
        }
      ]
    }

Response:
  {
    "success": true,
    "ID_Venta_SuperTienda": "ST-001",
    "message": "Venta registrada en SuperTienda"
  }
Proveedores
GET /api/proveedores - Listar proveedores

Request:
  Headers: Authorization: Bearer API_KEY

Response:
  {
    "proveedores": [
      {
        "Rut_Proveedor": "76.123.456-0",
        "Nombre_Proveedor": "Distribuidora FarmaVet SpA",
        "Telefono": "+5622334455",
        "Correo_Electronico": "contacto@farmavet.cl",
        "Direccion": "Av. Industrial 1230, Santiago"
      }
    ]
  }
Implementación en MySQL
Procedimientos Almacenados para Sincronización
-- Procedimiento para sincronizar productos con SuperTienda
DELIMITER //
CREATE PROCEDURE sincronizar_productos_supertienda()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE p_id INT;
    DECLARE p_nombre VARCHAR(100);
    DECLARE p_precio DECIMAL(10,2);
    DECLARE p_stock INT;
    DECLARE p_proveedor VARCHAR(12);
    DECLARE p_vencimiento DATE;

    -- Cursor para recorrer productos
    DECLARE cur CURSOR FOR
        SELECT ID_Producto, Nombre_Producto, Precio_Unitario, Stock,
               Rut_Proveedor, Fecha_Vencimiento
        FROM Producto
        WHERE Stock > 0 OR Stock IS NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO p_id, p_nombre, p_precio, p_stock, p_proveedor, p_vencimiento;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Aquí iría la llamada a la API de SuperTienda
        -- Para este ejemplo, solo mostramos el producto
        SELECT CONCAT('Sincronizando producto: ', p_id, ' - ', p_nombre) AS Mensaje;
    END LOOP;

    CLOSE cur;
    SELECT 'Sincronización de productos completada' AS Mensaje;
END //
DELIMITER ;

-- Procedimiento para sincronizar ventas con SuperTienda
DELIMITER //
CREATE PROCEDURE sincronizar_ventas_supertienda(IN p_fecha_inicio DATE, IN p_fecha_fin DATE)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id INT;
    DECLARE v_fecha DATE;
    DECLARE v_monto DECIMAL(10,2);
    DECLARE v_forma_pago VARCHAR(20);
    DECLARE v_rut_cliente VARCHAR(12);

    -- Cursor para ventas en el período
    DECLARE cur CURSOR FOR
        SELECT ID_Venta, Fecha_Pago, Monto_Venta, Forma_Pago, Rut_Cliente
        FROM Venta
        WHERE Fecha_Pago BETWEEN p_fecha_inicio AND p_fecha_fin
        AND ID_Venta NOT IN (
            SELECT ID_Venta FROM Venta_Sincronizada
            WHERE Sistema_Destino = 'SuperTienda'
        );

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_id, v_fecha, v_monto, v_forma_pago, v_rut_cliente;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Enviar venta a SuperTienda
        SELECT CONCAT('Sincronizando venta: ', v_id) AS Mensaje;

        -- Registrar que la venta fue sincronizada
        INSERT INTO Venta_Sincronizada (ID_Venta, Sistema_Destino, Fecha_Sincronizacion)
        VALUES (v_id, 'SuperTienda', NOW());
    END LOOP;

    CLOSE cur;
    SELECT CONCAT('Sincronización de ventas completada (', p_fecha_inicio, ' a ', p_fecha_fin, ')') AS Mensaje;
END //
DELIMITER ;

-- Tabla para registrar ventas sincronizadas
CREATE TABLE IF NOT EXISTS Venta_Sincronizada (
    ID_Sincronizacion INT AUTO_INCREMENT PRIMARY KEY,
    ID_Venta INT NOT NULL,
    Sistema_Destino VARCHAR(50) NOT NULL,
    Fecha_Sincronizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Exitoso BOOLEAN NOT NULL DEFAULT TRUE,
    Mensaje_Error VARCHAR(500),
    FOREIGN KEY (ID_Venta) REFERENCES Venta(ID_Venta)
);
Triggers para Sincronización Automática
-- Trigger para sincronizar productos al actualizarlos
DELIMITER //
CREATE TRIGGER after_producto_update
AFTER UPDATE ON Producto
FOR EACH ROW
BEGIN
    -- Insertar en una tabla de cola de sincronización
    INSERT INTO Sincronizacion_Pendiente (
        Tabla, ID_Registro, Operacion, Fecha_Creacion
    ) VALUES (
        'Producto', NEW.ID_Producto, 'UPDATE', NOW()
    );
END //
DELIMITER ;

-- Trigger para sincronizar ventas al crearlas
DELIMITER //
CREATE TRIGGER after_venta_insert
AFTER INSERT ON Venta
FOR EACH ROW
BEGIN
    -- Insertar en la cola de sincronización
    INSERT INTO Sincronizacion_Pendiente (
        Tabla, ID_Registro, Operacion, Fecha_Creacion
    ) VALUES (
        'Venta', NEW.ID_Venta, 'INSERT', NOW()
    );
END //
DELIMITER ;

-- Tabla para cola de sincronización
CREATE TABLE IF NOT EXISTS Sincronizacion_Pendiente (
    ID_Pendiente INT AUTO_INCREMENT PRIMARY KEY,
    Tabla VARCHAR(50) NOT NULL,
    ID_Registro INT NOT NULL,
    Operacion VARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
    Fecha_Creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Intentos INT NOT NULL DEFAULT 0,
    Procesado BOOLEAN NOT NULL DEFAULT FALSE
);
Proceso de Sincronización
1. Sincronización Inicial
Exportar datos de CVTM:

mysqldump -u root -p --no-create-info --where="1=1" veterinaria_db Producto Proveedor > inicial_productos_proveedores.sql
Transformar datos al formato de SuperTienda

Importar en SuperTienda usando su API o herramientas de carga masiva

Verificar la sincronización comparando conteos de registros

2. Sincronización Incremental
Identificar cambios desde la última sincronización:

SELECT * FROM Sincronizacion_Pendiente
WHERE Procesado = FALSE AND Intentos < 3
ORDER BY Fecha_Creacion;
Procesar cada cambio:

Para INSERT/UPDATE: Enviar datos a SuperTienda
Para DELETE: Enviar solicitud de eliminación a SuperTienda
Marcar como procesado:

UPDATE Sincronizacion_Pendiente
SET Procesado = TRUE, Intentos = Intentos + 1
WHERE ID_Pendiente = [id];
Manejar errores:

Si falla, incrementar Intentos
Si Intentos >= 3, notificar al administrador
3. Sincronización Bidireccional
Para sincronización bidireccional, se necesita:

Timestamp de última actualización en cada tabla
Identificador único para cada registro
Lógica de resolución de conflictos
-- Añadir columnas para sincronización
ALTER TABLE Producto ADD COLUMN Ultima_Sincronizacion DATETIME;
ALTER TABLE Producto ADD COLUMN Origen_Sincronizacion VARCHAR(20);
Manejo de Conflictos
Tipos de Conflictos
Conflicto de actualización: El mismo registro se actualiza en ambos sistemas
Conflicto de eliminación: Un registro se elimina en un sistema pero se actualiza en el otro
Conflicto de creación: Se crea un registro con el mismo ID en ambos sistemas
Estrategias de Resolución

Estrategia

Descripción

Cuándo usar

Last Write Wins
La última actualización prevalece
Sincronización frecuente, baja probabilidad de conflictos
Source Priority
Un sistema tiene prioridad
CVTM es el sistema principal
Manual Resolution
Requiere intervención humana
Conflictos críticos
Merge
Combinar cambios
Cambios aditivos (ej: actualizar stock)
Implementación de Resolución de Conflictos
-- Tabla para registrar conflictos
CREATE TABLE IF NOT EXISTS Sincronizacion_Conflictos (
    ID_Conflicto INT AUTO_INCREMENT PRIMARY KEY,
    Tabla VARCHAR(50) NOT NULL,
    ID_Registro INT NOT NULL,
    Fecha_Deteccion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Datos_CVTM JSON,
    Datos_SuperTienda JSON,
    Estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente', -- Pendiente, Resuelto, Ignorado
    Resolucion VARCHAR(500),
    Resuelto_Por VARCHAR(100),
    Fecha_Resolucion DATETIME
);

-- Procedimiento para resolver conflictos
DELIMITER //
CREATE PROCEDURE resolver_conflicto(
    IN p_id_conflicto INT,
    IN p_resolucion VARCHAR(500),
    IN p_resuelto_por VARCHAR(100)
)
BEGIN
    UPDATE Sincronizacion_Conflictos
    SET
        Estado = 'Resuelto',
        Resolucion = p_resolucion,
        Resuelto_Por = p_resuelto_por,
        Fecha_Resolucion = NOW()
    WHERE ID_Conflicto = p_id_conflicto;

    -- Aplicar la resolución según la tabla
    DECLARE v_tabla VARCHAR(50);
    DECLARE v_id_registro INT;

    SELECT Tabla, ID_Registro INTO v_tabla, v_id_registro
    FROM Sincronizacion_Conflictos
    WHERE ID_Conflicto = p_id_conflicto;

    IF v_tabla = 'Producto' THEN
        -- Aplicar resolución para productos
    END IF;
END //
DELIMITER ;
Monitoreo y Logging
-- Tabla de log de sincronización
CREATE TABLE IF NOT EXISTS Sincronizacion_Log (
    ID_Log INT AUTO_INCREMENT PRIMARY KEY,
    Fecha_Hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Operacion VARCHAR(50) NOT NULL, -- 'Sincronizar Productos', 'Sincronizar Ventas', etc.
    Tabla_Afectada VARCHAR(50),
    ID_Registro INT,
    Estado VARCHAR(20) NOT NULL, -- 'Iniciado', 'Exitoso', 'Fallido'
    Mensaje VARCHAR(500),
    Duracion_Segundos INT
);

-- Vista para monitoreo
CREATE VIEW vw_monitoreo_sincronizacion AS
SELECT
    DATE(Fecha_Hora) AS Fecha,
    Operacion,
    COUNT(*) AS Total,
    SUM(CASE WHEN Estado = 'Exitoso' THEN 1 ELSE 0 END) AS Exitosos,
    SUM(CASE WHEN Estado = 'Fallido' THEN 1 ELSE 0 END) AS Fallidos,
    ROUND(SUM(CASE WHEN Estado = 'Exitoso' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS Porcentaje_Exito,
    AVG(Duracion_Segundos) AS Duracion_Promedio
FROM Sincronizacion_Log
GROUP BY DATE(Fecha_Hora), Operacion
ORDER BY Fecha DESC, Operacion;
Conclusión
La integración con SuperTienda permite:

Centralizar la gestión de productos entre ambos sistemas
Consolidar reportes de ventas para análisis de negocio
Optimizar la gestión de inventario evitando duplicidades
Mejorar la experiencia del cliente con información consistente
Automatizar procesos reduciendo errores humanos
La implementación propuesta usa una combinación de:

API REST para comunicación en tiempo real
Procedimientos almacenados para lógica de negocio
Triggers para sincronización automática
Tablas de cola y log para seguimiento
Mecanismos de resolución de conflictos
Esta arquitectura garantiza una integración robusta, escalable y mantenible.



