-- CVTM | SQL Avanzado: CTE y Vistas | MySQL 8.0
-- Ejemplos de consultas avanzadas usando Common Table Expressions (CTE) y vistas

USE veterinaria_db;

-- ============================================================================
-- SECCIÓN 1: COMMON TABLE EXPRESSIONS (CTE)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- CTE 1: CTE Simple - Citas del día actual
-- ----------------------------------------------------------------------------
WITH Citas_Hoy AS (
    SELECT
        N_Cita,
        Fecha_Hora,
        Estado,
        ID_Mascota,
        Rut_Veterinario
    FROM Cita
    WHERE DATE(Fecha_Hora) = CURDATE()
)
SELECT
    c.N_Cita,
    c.Fecha_Hora,
    c.Estado,
    m.Nombre AS Mascota,
    v.Nombre AS Veterinario
FROM Citas_Hoy c
JOIN Mascota m ON c.ID_Mascota = m.ID_Mascota
JOIN Veterinario v ON c.Rut_Veterinario = v.Rut_Veterinario
ORDER BY c.Fecha_Hora;

-- ----------------------------------------------------------------------------
-- CTE 2: CTE Múltiple - Ventas y sus detalles
-- ----------------------------------------------------------------------------
WITH
-- CTE para ventas recientes
Ventas_Recientes AS (
    SELECT
        ID_Venta,
        Fecha_Pago,
        Monto_Venta,
        Rut_Cliente,
        Rut_Cajero
    FROM Venta
    WHERE Fecha_Pago >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
),
-- CTE para detalles de productos
Detalles_Productos AS (
    SELECT
        ID_Venta,
        SUM(Subtotal) AS Total_Productos
    FROM Detalle_Venta
    GROUP BY ID_Venta
),
-- CTE para detalles de prestaciones
Detalles_Prestaciones AS (
    SELECT
        ID_Venta,
        SUM(Subtotal) AS Total_Prestaciones
    FROM Detalle_Prestacion
    GROUP BY ID_Venta
)
SELECT
    vr.ID_Venta,
    vr.Fecha_Pago,
    vr.Monto_Venta,
    cl.Nombre AS Cliente,
    cj.Nombre AS Cajero,
    COALESCE(dp.Total_Productos, 0) AS Total_Productos,
    COALESCE(dpr.Total_Prestaciones, 0) AS Total_Prestaciones,
    (COALESCE(dp.Total_Productos, 0) + COALESCE(dpr.Total_Prestaciones, 0)) AS Total_Calculado,
    -- Verificar si el monto coincide
    CASE
        WHEN vr.Monto_Venta = (COALESCE(dp.Total_Productos, 0) + COALESCE(dpr.Total_Prestaciones, 0))
        THEN '✓ Coincide'
        ELSE '✗ Diferencia'
    END AS Verificacion
FROM Ventas_Recientes vr
LEFT JOIN Detalles_Productos dp ON vr.ID_Venta = dp.ID_Venta
LEFT JOIN Detalles_Prestaciones dpr ON vr.ID_Venta = dpr.ID_Venta
LEFT JOIN Cliente cl ON vr.Rut_Cliente = cl.Rut_Cliente
LEFT JOIN Cajero cj ON vr.Rut_Cajero = cj.Rut_Cajero
ORDER BY vr.Fecha_Pago DESC;

-- ----------------------------------------------------------------------------
-- CTE 3: CTE Recursiva - Jerarquía de clientes por número de mascotas
-- ----------------------------------------------------------------------------
-- Nota: MySQL 8.0 soporta CTE recursivas
-- Este ejemplo muestra clientes agrupados por rango de mascotas
WITH RECURSIVE
-- Ancla: clientes con 1 mascota
Clientes_Rango AS (
    SELECT
        cl.Rut_Cliente,
        cl.Nombre,
        COUNT(m.ID_Mascota) AS Num_Mascotas,
        1 AS Nivel
    FROM Cliente cl
    JOIN Mascota m ON cl.Rut_Cliente = m.Rut_Cliente
    GROUP BY cl.Rut_Cliente, cl.Nombre
    HAVING COUNT(m.ID_Mascota) = 1

    UNION ALL

    -- Parte recursiva: clientes con más mascotas
    SELECT
        cl.Rut_Cliente,
        cl.Nombre,
        COUNT(m.ID_Mascota) AS Num_Mascotas,
        CASE
            WHEN COUNT(m.ID_Mascota) <= 3 THEN 2
            WHEN COUNT(m.ID_Mascota) <= 5 THEN 3
            ELSE 4
        END AS Nivel
    FROM Cliente cl
    JOIN Mascota m ON cl.Rut_Cliente = m.Rut_Cliente
    GROUP BY cl.Rut_Cliente, cl.Nombre
    HAVING COUNT(m.ID_Mascota) > 1
)
SELECT
    Nivel,
    CASE Nivel
        WHEN 1 THEN '1 mascota'
        WHEN 2 THEN '2-3 mascotas'
        WHEN 3 THEN '4-5 mascotas'
        WHEN 4 THEN 'Más de 5 mascotas'
    END AS Categoria,
    COUNT(*) AS Numero_Clientes,
    GROUP_CONCAT(Nombre ORDER BY Nombre SEPARATOR ', ') AS Clientes
FROM Clientes_Rango
GROUP BY Nivel
ORDER BY Nivel;

-- ----------------------------------------------------------------------------
-- CTE 4: CTE para análisis de stock - Productos que necesitan reposición
-- ----------------------------------------------------------------------------
WITH
-- Productos con stock bajo
Productos_Bajo_Stock AS (
    SELECT
        ID_Producto,
        Nombre_Producto,
        Stock,
        Precio_Unitario,
        CASE
            WHEN Stock = 0 THEN 'Urgente'
            WHEN Stock < 5 THEN 'Reponer pronto'
            ELSE 'OK'
        END AS Prioridad
    FROM Producto
    WHERE Stock < 10
),
-- Ventas de los últimos 30 días
Ventas_Recientes_Productos AS (
    SELECT
        ID_Producto,
        SUM(Cantidad) AS Cantidad_Vendida
    FROM Detalle_Venta dv
    JOIN Venta v ON dv.ID_Venta = v.ID_Venta
    WHERE v.Fecha_Pago >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY ID_Producto
)
SELECT
    pbs.Nombre_Producto,
    pbs.Stock,
    pbs.Prioridad,
    COALESCE(vrp.Cantidad_Vendida, 0) AS Vendidos_30d,
    -- Días estimados hasta agotarse (asumiendo tasa constante)
    CASE
        WHEN COALESCE(vrp.Cantidad_Vendida, 0) > 0
        THEN CEIL(pbs.Stock / vrp.Cantidad_Vendida * 30)
        ELSE NULL
    END AS Dias_Hasta_Agotarse
FROM Productos_Bajo_Stock pbs
LEFT JOIN Ventas_Recientes_Productos vrp ON pbs.ID_Producto = vrp.ID_Producto
ORDER BY pbs.Stock ASC, vrp.Cantidad_Vendida DESC;

-- ============================================================================
-- SECCIÓN 2: VISTAS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Vista 1: Vista de citas con información completa
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_citas_completas AS
SELECT
    c.N_Cita,
    c.Fecha_Hora,
    c.Estado,
    c.Bloque_Activo,
    m.ID_Mascota,
    m.Nombre AS Mascota,
    m.Especie,
    m.Raza,
    m.Sexo,
    m.Fecha_Nacimiento,
    cl.Rut_Cliente,
    cl.Nombre AS Cliente,
    cl.Telefono AS Telefono_Cliente,
    cl.Correo_Electronico AS Email_Cliente,
    v.Rut_Veterinario,
    v.Nombre AS Veterinario,
    v.Especialidad,
    v.Telefono AS Telefono_Veterinario
FROM Cita c
JOIN Mascota m ON c.ID_Mascota = m.ID_Mascota
JOIN Cliente cl ON m.Rut_Cliente = cl.Rut_Cliente
JOIN Veterinario v ON c.Rut_Veterinario = v.Rut_Veterinario;

-- Consultar la vista
SELECT * FROM vw_citas_completas
WHERE DATE(Fecha_Hora) = CURDATE()
ORDER BY Fecha_Hora;

-- ----------------------------------------------------------------------------
-- Vista 2: Vista de ventas con detalles
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_ventas_detalladas AS
SELECT
    v.ID_Venta,
    v.Fecha_Pago,
    v.Monto_Venta,
    v.Forma_Pago,
    v.Rut_Cliente,
    cl.Nombre AS Nombre_Cliente,
    v.Rut_Cajero,
    cj.Nombre AS Nombre_Cajero,
    cj.Turno,
    -- Totales de productos
    (SELECT SUM(Subtotal) FROM Detalle_Venta WHERE ID_Venta = v.ID_Venta) AS Total_Productos,
    -- Totales de prestaciones
    (SELECT SUM(Subtotal) FROM Detalle_Prestacion WHERE ID_Venta = v.ID_Venta) AS Total_Prestaciones,
    -- Número de items
    (SELECT COUNT(*) FROM Detalle_Venta WHERE ID_Venta = v.ID_Venta) +
    (SELECT COUNT(*) FROM Detalle_Prestacion WHERE ID_Venta = v.ID_Venta) AS Total_Items
FROM Venta v
LEFT JOIN Cliente cl ON v.Rut_Cliente = cl.Rut_Cliente
JOIN Cajero cj ON v.Rut_Cajero = cj.Rut_Cajero;

-- Consultar la vista
SELECT * FROM vw_ventas_detalladas
ORDER BY Fecha_Pago DESC
LIMIT 10;

-- ----------------------------------------------------------------------------
-- Vista 3: Vista de fichas médicas completas
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_fichas_medicas_completas AS
SELECT
    f.ID_Ficha,
    f.Diagnostico,
    f.Tratamiento,
    f.Observaciones,
    f.Fecha_Registro,
    c.N_Cita,
    c.Fecha_Hora AS Fecha_Cita,
    c.Estado AS Estado_Cita,
    m.ID_Mascota,
    m.Nombre AS Mascota,
    m.Especie,
    m.Raza,
    m.Sexo,
    m.Fecha_Nacimiento,
    cl.Rut_Cliente,
    cl.Nombre AS Cliente,
    cl.Telefono AS Telefono_Cliente,
    v.Rut_Veterinario,
    v.Nombre AS Veterinario,
    v.Especialidad,
    -- Edad de la mascota al momento de la ficha
    TIMESTAMPDIFF(MONTH, m.Fecha_Nacimiento, f.Fecha_Registro) AS Edad_Meses
FROM Ficha_Medica f
JOIN Cita c ON f.N_Cita = c.N_Cita
JOIN Mascota m ON c.ID_Mascota = m.ID_Mascota
JOIN Cliente cl ON m.Rut_Cliente = cl.Rut_Cliente
JOIN Veterinario v ON f.Rut_Veterinario = v.Rut_Veterinario;

-- Consultar la vista
SELECT * FROM vw_fichas_medicas_completas
ORDER BY Fecha_Registro DESC;

-- ----------------------------------------------------------------------------
-- Vista 4: Vista de inventario con valorización
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_inventario_valorado AS
SELECT
    p.ID_Producto,
    p.Nombre_Producto,
    p.Precio_Unitario,
    p.Stock,
    p.Fecha_Vencimiento,
    p.Rut_Proveedor,
    pr.Nombre_Proveedor,
    pr.Telefono AS Telefono_Proveedor,
    -- Valor del inventario
    (p.Precio_Unitario * p.Stock) AS Valor_Inventario,
    -- Clasificación
    CASE
        WHEN p.Stock = 0 THEN 'Agotado'
        WHEN p.Stock < 5 THEN 'Bajo'
        WHEN p.Stock < 20 THEN 'Normal'
        ELSE 'Alto'
    END AS Nivel_Stock,
    -- Días hasta vencimiento
    CASE
        WHEN p.Fecha_Vencimiento IS NOT NULL
        THEN DATEDIFF(p.Fecha_Vencimiento, CURDATE())
        ELSE NULL
    END AS Dias_Hasta_Vencimiento,
    -- Estado de vencimiento
    CASE
        WHEN p.Fecha_Vencimiento IS NULL THEN 'Sin vencimiento'
        WHEN p.Fecha_Vencimiento < CURDATE() THEN 'Vencido'
        WHEN p.Fecha_Vencimiento <= DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN 'Por vencer'
        ELSE 'Vigente'
    END AS Estado_Vencimiento
FROM Producto p
LEFT JOIN Proveedor pr ON p.Rut_Proveedor = pr.Rut_Proveedor;

-- Consultar la vista
SELECT * FROM vw_inventario_valorado
WHERE Estado_Vencimiento != 'Vigente' OR Nivel_Stock = 'Agotado'
ORDER BY Estado_Vencimiento, Nivel_Stock, Valor_Inventario DESC;

-- ----------------------------------------------------------------------------
-- Vista 5: Vista de historial de responsables
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_historial_responsables AS
SELECT
    m.ID_Mascota,
    m.Nombre AS Mascota,
    m.Especie,
    m.Raza,
    hr.ID_Historial,
    hr.Fecha_Inicio,
    hr.Fecha_Fin,
    cl.Rut_Cliente,
    cl.Nombre AS Responsable,
    cl.Telefono,
    cl.Correo_Electronico,
    -- Duración como responsable
    CASE
        WHEN hr.Fecha_Fin IS NULL THEN
            DATEDIFF(CURDATE(), hr.Fecha_Inicio)
        ELSE
            DATEDIFF(hr.Fecha_Fin, hr.Fecha_Inicio)
    END AS Dias_Responsable,
    -- ¿Es el responsable actual?
    CASE
        WHEN hr.Fecha_Fin IS NULL THEN 'Sí'
        ELSE 'No'
    END AS Es_Actual
FROM Historial_Responsable hr
JOIN Mascota m ON hr.ID_Mascota = m.ID_Mascota
JOIN Cliente cl ON hr.Rut_Cliente = cl.Rut_Cliente;

-- Consultar la vista
SELECT * FROM vw_historial_responsables
ORDER BY ID_Mascota, Fecha_Inicio;

-- ============================================================================
-- SECCIÓN 3: VISTAS MATERIALIZADAS (Simuladas con tablas)
-- ============================================================================

-- MySQL no soporta vistas materializadas nativamente, pero podemos simularlas
-- con tablas que se actualizan periódicamente

-- Crear tabla para vista materializada de ventas diarias
CREATE TABLE IF NOT EXISTS mat_ventas_diarias (
    Fecha DATE PRIMARY KEY,
    Numero_Ventas INT,
    Monto_Total DECIMAL(12,2),
    Numero_Clientes INT,
    Numero_Productos INT,
    Numero_Prestaciones INT,
    Fecha_Actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para actualizar la vista materializada
DELIMITER //
CREATE PROCEDURE actualizar_ventas_diarias()
BEGIN
    -- Eliminar datos antiguos
    DELETE FROM mat_ventas_diarias
    WHERE Fecha >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

    -- Insertar datos actualizados
    INSERT INTO mat_ventas_diarias (Fecha, Numero_Ventas, Monto_Total, Numero_Clientes, Numero_Productos, Numero_Prestaciones)
    SELECT
        v.Fecha_Pago AS Fecha,
        COUNT(DISTINCT v.ID_Venta) AS Numero_Ventas,
        SUM(v.Monto_Venta) AS Monto_Total,
        COUNT(DISTINCT v.Rut_Cliente) AS Numero_Clientes,
        (SELECT COUNT(*) FROM Detalle_Venta dv JOIN Venta v2 ON dv.ID_Venta = v2.ID_Venta WHERE v2.Fecha_Pago = v.Fecha_Pago) AS Numero_Productos,
        (SELECT COUNT(*) FROM Detalle_Prestacion dp JOIN Venta v3 ON dp.ID_Venta = v3.ID_Venta WHERE v3.Fecha_Pago = v.Fecha_Pago) AS Numero_Prestaciones
    FROM Venta v
    WHERE v.Fecha_Pago >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY v.Fecha_Pago;
END //
DELIMITER ;

-- Ejecutar el procedimiento (comentado para evitar ejecución automática)
-- CALL actualizar_ventas_diarias();

-- Consultar la vista materializada
SELECT * FROM mat_ventas_diarias
ORDER BY Fecha DESC;

-- ----------------------------------------------------------------------------
-- Vista materializada de productos más vendidos
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mat_productos_mas_vendidos (
    ID_Producto INT PRIMARY KEY,
    Nombre_Producto VARCHAR(100),
    Cantidad_Vendida INT,
    Numero_Ventas INT,
    Ingresos_Totales DECIMAL(12,2),
    Ranking INT,
    Fecha_Actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ID_Producto) REFERENCES Producto(ID_Producto)
);

DELIMITER //
CREATE PROCEDURE actualizar_productos_mas_vendidos()
BEGIN
    -- Eliminar todos los datos
    TRUNCATE TABLE mat_productos_mas_vendidos;

    -- Insertar productos más vendidos
    INSERT INTO mat_productos_mas_vendidos
        (ID_Producto, Nombre_Producto, Cantidad_Vendida, Numero_Ventas, Ingresos_Totales, Ranking)
    SELECT
        p.ID_Producto,
        p.Nombre_Producto,
        SUM(dv.Cantidad) AS Cantidad_Vendida,
        COUNT(DISTINCT dv.ID_Venta) AS Numero_Ventas,
        SUM(dv.Subtotal) AS Ingresos_Totales,
        RANK() OVER (ORDER BY SUM(dv.Cantidad) DESC) AS Ranking
    FROM Detalle_Venta dv
    JOIN Producto p ON dv.ID_Producto = p.ID_Producto
    GROUP BY p.ID_Producto, p.Nombre_Producto
    ORDER BY Cantidad_Vendida DESC;
END //
DELIMITER ;

-- Consultar la vista materializada
SELECT * FROM mat_productos_mas_vendidos
ORDER BY Ranking
LIMIT 10;
