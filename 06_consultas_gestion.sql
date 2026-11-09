-- CVTM | Consultas de Gestión (10 consultas principales) | MySQL 8.0
-- Estas consultas implementan los reportes de gestión según casos de uso
-- Requiere: 01_crear_tablas.sql, 02_restricciones.sql, 03_datos_prueba.sql

USE veterinaria_db;

-- ============================================================================
-- CONSULTA 1: Citas por veterinario con detalles de mascota y cliente
-- Caso de uso: CU-07 (Agendar Cita), CU-08 (Atender Cita)
-- Descripción: Lista todas las citas con información completa
-- ============================================================================
SELECT
    c.N_Cita,
    c.Fecha_Hora,
    c.Estado,
    m.ID_Mascota,
    m.Nombre AS Mascota,
    cl.Nombre AS Cliente,
    cl.Rut_Cliente,
    cl.Telefono AS Telefono_Cliente,
    v.Nombre AS Veterinario,
    v.Especialidad,
    v.Telefono AS Telefono_Veterinario
FROM Cita c
JOIN Mascota m ON c.ID_Mascota = m.ID_Mascota
JOIN Cliente cl ON m.Rut_Cliente = cl.Rut_Cliente
JOIN Veterinario v ON c.Rut_Veterinario = v.Rut_Veterinario
ORDER BY c.Fecha_Hora, v.Nombre;

-- ============================================================================
-- CONSULTA 2: Fichas médicas completas con historial clínico
-- Caso de uso: CU-09 (Crear Ficha Médica)
-- Descripción: Reportes de fichas médicas para seguimiento clínico
-- ============================================================================
SELECT
    f.ID_Ficha,
    f.Fecha_Registro,
    f.Diagnostico,
    f.Tratamiento,
    f.Observaciones,
    c.N_Cita,
    c.Fecha_Hora AS Fecha_Cita,
    m.ID_Mascota,
    m.Nombre AS Mascota,
    m.Especie,
    m.Raza,
    m.Sexo,
    m.Fecha_Nacimiento,
    cl.Nombre AS Cliente,
    cl.Rut_Cliente,
    v.Nombre AS Veterinario,
    v.Especialidad,
    -- Calcular edad aproximada de la mascota
    TIMESTAMPDIFF(MONTH, m.Fecha_Nacimiento, f.Fecha_Registro) AS Edad_Meses
FROM Ficha_Medica f
JOIN Cita c ON f.N_Cita = c.N_Cita
JOIN Mascota m ON c.ID_Mascota = m.ID_Mascota
JOIN Cliente cl ON m.Rut_Cliente = cl.Rut_Cliente
JOIN Veterinario v ON f.Rut_Veterinario = v.Rut_Veterinario
ORDER BY f.Fecha_Registro DESC, m.Nombre;

-- ============================================================================
-- CONSULTA 3: Ventas detalladas con productos y prestaciones
-- Caso de uso: CU-11 (Realizar Venta)
-- Descripción: Reporte completo de ventas con todos los detalles
-- ============================================================================
SELECT
    v.ID_Venta,
    v.Fecha_Pago,
    v.Monto_Venta,
    v.Forma_Pago,
    cl.Nombre AS Cliente,
    cl.Rut_Cliente,
    cj.Nombre AS Cajero,
    cj.Turno,
    -- Detalles de productos
    (SELECT GROUP_CONCAT(
        CONCAT(p.Nombre_Producto, ' (', dv.Cantidad, ' x $', dv.Subtotal, ')')
        SEPARATOR ', '
    )
    FROM Detalle_Venta dv
    JOIN Producto p ON dv.ID_Producto = p.ID_Producto
    WHERE dv.ID_Venta = v.ID_Venta) AS Productos,
    -- Detalles de prestaciones
    (SELECT GROUP_CONCAT(
        CONCAT(pr.Nombre_Prestacion, ' (', dp.Cantidad, ' x $', dp.Subtotal, ')')
        SEPARATOR ', '
    )
    FROM Detalle_Prestacion dp
    JOIN Prestacion pr ON dp.ID_Prestacion = pr.ID_Prestacion
    WHERE dp.ID_Venta = v.ID_Venta) AS Prestaciones,
    -- Totales
    (SELECT SUM(Subtotal) FROM Detalle_Venta WHERE ID_Venta = v.ID_Venta) AS Total_Productos,
    (SELECT SUM(Subtotal) FROM Detalle_Prestacion WHERE ID_Venta = v.ID_Venta) AS Total_Prestaciones
FROM Venta v
LEFT JOIN Cliente cl ON v.Rut_Cliente = cl.Rut_Cliente
JOIN Cajero cj ON v.Rut_Cajero = cj.Rut_Cajero
ORDER BY v.Fecha_Pago DESC, v.ID_Venta;

-- ============================================================================
-- CONSULTA 4: Reporte de stock de productos por proveedor
-- Caso de uso: RF-06 (Gestión de Productos)
-- Descripción: Inventario actual con información de proveedores
-- ============================================================================
SELECT
    p.ID_Producto,
    p.Nombre_Producto,
    p.Precio_Unitario,
    p.Stock,
    p.Fecha_Vencimiento,
    pr.Nombre_Proveedor,
    pr.Telefono AS Telefono_Proveedor,
    pr.Correo_Electronico AS Email_Proveedor,
    -- Clasificación de stock
    CASE
        WHEN p.Stock = 0 THEN 'Agotado'
        WHEN p.Stock < 5 THEN 'Bajo'
        WHEN p.Stock < 20 THEN 'Normal'
        ELSE 'Alto'
    END AS Nivel_Stock,
    -- Valor del inventario
    (p.Precio_Unitario * p.Stock) AS Valor_Inventario
FROM Producto p
LEFT JOIN Proveedor pr ON p.Rut_Proveedor = pr.Rut_Proveedor
ORDER BY p.Stock ASC, p.Nombre_Producto;

-- ============================================================================
-- CONSULTA 5: Productos más vendidos (Top 10)
-- Caso de uso: RF-10 (Reportes de Gestión)
-- Descripción: Ranking de productos por cantidad vendida
-- ============================================================================
SELECT
    p.ID_Producto,
    p.Nombre_Producto,
    p.Precio_Unitario,
    SUM(dv.Cantidad) AS Cantidad_Vendida,
    COUNT(DISTINCT dv.ID_Venta) AS Numero_Ventas,
    SUM(dv.Subtotal) AS Ingresos_Totales,
    RANK() OVER (ORDER BY SUM(dv.Cantidad) DESC) AS Ranking_Cantidad,
    RANK() OVER (ORDER BY SUM(dv.Subtotal) DESC) AS Ranking_Ingresos
FROM Detalle_Venta dv
JOIN Producto p ON dv.ID_Producto = p.ID_Producto
GROUP BY p.ID_Producto, p.Nombre_Producto, p.Precio_Unitario
ORDER BY Cantidad_Vendida DESC
LIMIT 10;

-- ============================================================================
-- CONSULTA 6: Prestaciones más solicitadas (Top 10)
-- Caso de uso: RF-10 (Reportes de Gestión)
-- Descripción: Ranking de servicios por frecuencia
-- ============================================================================
SELECT
    pr.ID_Prestacion,
    pr.Nombre_Prestacion,
    pr.Precio,
    pr.Duracion_Min,
    SUM(dp.Cantidad) AS Veces_Realizada,
    COUNT(DISTINCT dp.ID_Venta) AS Numero_Ventas,
    SUM(dp.Subtotal) AS Ingresos_Totales,
    RANK() OVER (ORDER BY SUM(dp.Cantidad) DESC) AS Ranking_Frecuencia
FROM Detalle_Prestacion dp
JOIN Prestacion pr ON dp.ID_Prestacion = pr.ID_Prestacion
GROUP BY pr.ID_Prestacion, pr.Nombre_Prestacion, pr.Precio, pr.Duracion_Min
ORDER BY Veces_Realizada DESC
LIMIT 10;

-- ============================================================================
-- CONSULTA 7: Ingresos por veterinario (de citas y fichas)
-- Caso de uso: RF-10 (Reportes de Gestión)
-- Descripción: Reportes de productividad de veterinarios
-- ============================================================================
SELECT
    v.Rut_Veterinario,
    v.Nombre AS Veterinario,
    v.Especialidad,
    -- Citas atendidas
    COUNT(DISTINCT c.N_Cita) AS Citas_Atendidas,
    -- Fichas médicas creadas
    COUNT(DISTINCT f.ID_Ficha) AS Fichas_Creadas,
    -- Ingresos estimados (asumiendo que cada cita genera ingresos)
    COUNT(DISTINCT c.N_Cita) * 20000 AS Ingresos_Estimados_Citas
FROM Veterinario v
LEFT JOIN Cita c ON v.Rut_Veterinario = c.Rut_Veterinario AND c.Estado = 'atendida'
LEFT JOIN Ficha_Medica f ON v.Rut_Veterinario = f.Rut_Veterinario
GROUP BY v.Rut_Veterinario, v.Nombre, v.Especialidad
ORDER BY Citas_Atendidas DESC;

-- ============================================================================
-- CONSULTA 8: Movimientos de inventario recientes
-- Caso de uso: RF-06 (Gestión de Productos), CU-13 (Registrar Movimiento)
-- Descripción: Historial de movimientos de inventario
-- ============================================================================
SELECT
    i.ID_Movimiento,
    i.Fecha_Movimiento,
    i.Tipo_Movimiento,
    i.Cantidad,
    p.ID_Producto,
    p.Nombre_Producto,
    p.Stock AS Stock_Actual,
    pr.Nombre_Proveedor,
    -- Stock después del movimiento (estimado)
    CASE
        WHEN i.Tipo_Movimiento = 'entrada' THEN p.Stock - i.Cantidad
        WHEN i.Tipo_Movimiento = 'salida' THEN p.Stock + i.Cantidad
    END AS Stock_Despues_Movimiento
FROM Inventario i
JOIN Producto p ON i.ID_Producto = p.ID_Producto
LEFT JOIN Proveedor pr ON i.Rut_Proveedor = pr.Rut_Proveedor
ORDER BY i.Fecha_Movimiento DESC
LIMIT 20;

-- ============================================================================
-- CONSULTA 9: Clientes frecuentes (Top 10 por número de citas y compras)
-- Caso de uso: RF-10 (Reportes de Gestión)
-- Descripción: Identificar clientes más activos
-- ============================================================================
SELECT
    cl.Rut_Cliente,
    cl.Nombre AS Cliente,
    cl.Telefono,
    cl.Correo_Electronico,
    -- Número de mascotas
    COUNT(DISTINCT m.ID_Mascota) AS Numero_Mascotas,
    -- Número de citas
    COUNT(DISTINCT c.N_Cita) AS Numero_Citas,
    -- Número de compras
    COUNT(DISTINCT v.ID_Venta) AS Numero_Compras,
    -- Monto total gastado
    COALESCE(SUM(v.Monto_Venta), 0) AS Monto_Total_Gastado,
    -- Fecha de última visita
    MAX(c.Fecha_Hora) AS Ultima_Cita,
    -- Fecha de última compra
    MAX(v.Fecha_Pago) AS Ultima_Compra
FROM Cliente cl
LEFT JOIN Mascota m ON cl.Rut_Cliente = m.Rut_Cliente
LEFT JOIN Cita c ON m.ID_Mascota = c.ID_Mascota
LEFT JOIN Venta v ON cl.Rut_Cliente = v.Rut_Cliente
GROUP BY cl.Rut_Cliente, cl.Nombre, cl.Telefono, cl.Correo_Electronico
ORDER BY Numero_Citas DESC, Monto_Total_Gastado DESC
LIMIT 10;

-- ============================================================================
-- CONSULTA 10: Reporte de salud - Mascotas con múltiples visitas
-- Caso de uso: RF-05 (Gestión de Fichas Médicas)
-- Descripción: Identificar mascotas con historial médico extenso
-- ============================================================================
SELECT
    m.ID_Mascota,
    m.Nombre AS Mascota,
    m.Especie,
    m.Raza,
    m.Sexo,
    m.Fecha_Nacimiento,
    TIMESTAMPDIFF(YEAR, m.Fecha_Nacimiento, CURDATE()) AS Edad_Años,
    cl.Nombre AS Dueño,
    cl.Rut_Cliente,
    cl.Telefono,
    -- Número de citas
    COUNT(DISTINCT c.N_Cita) AS Numero_Citas,
    -- Número de fichas médicas
    COUNT(DISTINCT f.ID_Ficha) AS Numero_Fichas,
    -- Última visita
    MAX(c.Fecha_Hora) AS Ultima_Visita,
    -- Diagnósticos recientes (últimos 3)
    (SELECT GROUP_CONCAT(
        CONCAT(f2.Diagnostico, ' (', f2.Fecha_Registro, ')')
        SEPARATOR ' | '
    )
    FROM Ficha_Medica f2
    JOIN Cita c2 ON f2.N_Cita = c2.N_Cita
    WHERE c2.ID_Mascota = m.ID_Mascota
    ORDER BY f2.Fecha_Registro DESC
    LIMIT 3) AS Diagnosticos_Recientes
FROM Mascota m
JOIN Cliente cl ON m.Rut_Cliente = cl.Rut_Cliente
LEFT JOIN Cita c ON m.ID_Mascota = c.ID_Mascota
LEFT JOIN Ficha_Medica f ON c.N_Cita = f.N_Cita
GROUP BY m.ID_Mascota, m.Nombre, m.Especie, m.Raza, m.Sexo,
         m.Fecha_Nacimiento, cl.Nombre, cl.Rut_Cliente, cl.Telefono
HAVING COUNT(DISTINCT f.ID_Ficha) >= 2 OR COUNT(DISTINCT c.N_Cita) >= 3
ORDER BY Numero_Fichas DESC, Numero_Citas DESC;

-- ============================================================================
-- CONSULTA BONUS: Historial completo de responsables de mascotas
-- Caso de uso: CU-06 (Consultar Historial de Responsables)
-- Descripción: Ver todos los cambios de dueño de mascotas
-- ============================================================================
SELECT
    m.ID_Mascota,
    m.Nombre AS Mascota,
    hr.Fecha_Inicio,
    hr.Fecha_Fin,
    cl.Nombre AS Responsable,
    cl.Rut_Cliente,
    cl.Telefono,
    -- Duración como responsable
    CASE
        WHEN hr.Fecha_Fin IS NULL THEN
            CONCAT(TIMESTAMPDIFF(DAY, hr.Fecha_Inicio, CURDATE()), ' días (Actual)')
        ELSE
            CONCAT(TIMESTAMPDIFF(DAY, hr.Fecha_Inicio, hr.Fecha_Fin), ' días')
    END AS Duracion
FROM Historial_Responsable hr
JOIN Mascota m ON hr.ID_Mascota = m.ID_Mascota
JOIN Cliente cl ON hr.Rut_Cliente = cl.Rut_Cliente
ORDER BY m.ID_Mascota, hr.Fecha_Inicio;
