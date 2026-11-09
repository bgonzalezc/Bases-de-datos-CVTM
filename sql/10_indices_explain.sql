-- CVTM | Índices y Optimización con EXPLAIN | MySQL 8.0
-- Análisis y optimización de consultas usando índices y EXPLAIN

USE veterinaria_db;

-- ============================================================================
-- SECCIÓN 1: ÍNDICES EXISTENTES
-- ============================================================================

-- Ver todos los índices de la base de datos
SHOW INDEX FROM veterinaria_db;

-- Ver índices por tabla
SHOW INDEX FROM Cliente;
SHOW INDEX FROM Mascota;
SHOW INDEX FROM Cita;
SHOW INDEX FROM Venta;
SHOW INDEX FROM Ficha_Medica;
SHOW INDEX FROM Producto;
SHOW INDEX FROM Detalle_Venta;
SHOW INDEX FROM Detalle_Prestacion;

-- ============================================================================
-- SECCIÓN 2: CREACIÓN DE ÍNDICES ADICIONALES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Índice 1: Índice compuesto para búsquedas frecuentes de citas
-- Buscar citas por veterinario y fecha
-- ----------------------------------------------------------------------------
CREATE INDEX idx_cita_veterinario_fecha ON Cita (Rut_Veterinario, Fecha_Hora);

-- Verificar el índice
SHOW INDEX FROM Cita;

-- ----------------------------------------------------------------------------
-- Índice 2: Índice para búsquedas de productos por nombre
-- ----------------------------------------------------------------------------
CREATE INDEX idx_producto_nombre ON Producto (Nombre_Producto);

-- ----------------------------------------------------------------------------
-- Índice 3: Índice compuesto para búsquedas de ventas por cliente y fecha
-- ----------------------------------------------------------------------------
CREATE INDEX idx_venta_cliente_fecha ON Venta (Rut_Cliente, Fecha_Pago);

-- ----------------------------------------------------------------------------
-- Índice 4: Índice para búsquedas de fichas médicas por diagnóstico
-- ----------------------------------------------------------------------------
CREATE INDEX idx_ficha_diagnostico ON Ficha_Medica (Diagnostico);

-- ----------------------------------------------------------------------------
-- Índice 5: Índice para búsquedas de historial de responsables
-- ----------------------------------------------------------------------------
CREATE INDEX idx_historial_mascota ON Historial_Responsable (ID_Mascota);
CREATE INDEX idx_historial_cliente ON Historial_Responsable (Rut_Cliente);

-- ----------------------------------------------------------------------------
-- Índice 6: Índice para búsquedas de inventario por producto y fecha
-- ----------------------------------------------------------------------------
CREATE INDEX idx_inventario_producto_fecha ON Inventario (ID_Producto, Fecha_Movimiento);

-- ----------------------------------------------------------------------------
-- Índice 7: Índice para búsquedas de detalle de venta por producto
-- ----------------------------------------------------------------------------
CREATE INDEX idx_detalleventa_producto ON Detalle_Venta (ID_Producto);

-- ----------------------------------------------------------------------------
-- Índice 8: Índice para búsquedas de detalle de prestación por prestación
-- ----------------------------------------------------------------------------
CREATE INDEX idx_detalleprestacion_prestacion ON Detalle_Prestacion (ID_Prestacion);

-- ============================================================================
-- SECCIÓN 3: ANÁLISIS CON EXPLAIN
-- ============================================================================

-- ----------------------------------------------------------------------------
-- EXPLAIN 1: Consulta simple sin índices
-- ----------------------------------------------------------------------------
EXPLAIN
SELECT * FROM Mascota WHERE Nombre = 'Max';

-- Observación: Sin índice en Nombre, MySQL hace un "ALL" (full table scan)

-- ----------------------------------------------------------------------------
-- EXPLAIN 2: Consulta con índice
-- ----------------------------------------------------------------------------
-- Primero creamos un índice para esta consulta
CREATE INDEX idx_mascota_nombre ON Mascota (Nombre);

EXPLAIN
SELECT * FROM Mascota WHERE Nombre = 'Max';

-- Observación: Con índice, MySQL usa "ref" y el índice idx_mascota_nombre

-- ----------------------------------------------------------------------------
-- EXPLAIN 3: Consulta de join sin índices
-- ----------------------------------------------------------------------------
EXPLAIN
SELECT c.N_Cita, m.Nombre AS Mascota, v.Nombre AS Veterinario
FROM Cita c
JOIN Mascota m ON c.ID_Mascota = m.ID_Mascota
JOIN Veterinario v ON c.Rut_Veterinario = v.Rut_Veterinario
WHERE c.Estado = 'atendida';

-- Observación: MySQL usa los índices primarios para los joins

-- ----------------------------------------------------------------------------
-- EXPLAIN 4: Consulta de join con WHERE en columna no indexada
-- ----------------------------------------------------------------------------
-- Primero eliminamos el índice de Estado si existe
DROP INDEX IF EXISTS idx_cita_estado ON Cita;

EXPLAIN
SELECT c.N_Cita, m.Nombre AS Mascota, v.Nombre AS Veterinario
FROM Cita c
JOIN Mascota m ON c.ID_Mascota = m.ID_Mascota
JOIN Veterinario v ON c.Rut_Veterinario = v.Rut_Veterinario
WHERE c.Estado = 'atendida';

-- Observación: Sin índice en Estado, MySQL hace un full scan en Cita

-- ----------------------------------------------------------------------------
-- EXPLAIN 5: Consulta con índice en columna WHERE
-- ----------------------------------------------------------------------------
CREATE INDEX idx_cita_estado ON Cita (Estado);

EXPLAIN
SELECT c.N_Cita, m.Nombre AS Mascota, v.Nombre AS Veterinario
FROM Cita c
JOIN Mascota m ON c.ID_Mascota = m.ID_Mascota
JOIN Veterinario v ON c.Rut_Veterinario = v.Rut_Veterinario
WHERE c.Estado = 'atendida';

-- Observación: Con índice en Estado, MySQL usa "ref" para el filtro

-- ----------------------------------------------------------------------------
-- EXPLAIN 6: Consulta con índice compuesto
-- ----------------------------------------------------------------------------
EXPLAIN
SELECT * FROM Cita
WHERE Rut_Veterinario = '14.890.123-4' AND Fecha_Hora >= '2026-10-01';

-- Observación: MySQL puede usar el índice compuesto idx_cita_veterinario_fecha
-- para filtrar por ambas condiciones

-- ----------------------------------------------------------------------------
-- EXPLAIN 7: Consulta con ORDER BY
-- ----------------------------------------------------------------------------
EXPLAIN
SELECT * FROM Venta
WHERE Rut_Cliente = '15.420.311-8'
ORDER BY Fecha_Pago DESC;

-- Observación: MySQL puede usar el índice idx_venta_cliente_fecha
-- para el filtro y el ordenamiento

-- ----------------------------------------------------------------------------
-- EXPLAIN 8: Consulta con GROUP BY
-- ----------------------------------------------------------------------------
EXPLAIN
SELECT Rut_Veterinario, COUNT(*) AS Numero_Citas
FROM Cita
GROUP BY Rut_Veterinario;

-- Observación: Sin índice en Rut_Veterinario, MySQL hace un full scan

-- ----------------------------------------------------------------------------
-- EXPLAIN 9: Consulta con subconsulta
-- ----------------------------------------------------------------------------
EXPLAIN
SELECT v.*,
    (SELECT COUNT(*) FROM Cita c WHERE c.Rut_Veterinario = v.Rut_Veterinario) AS Numero_Citas
FROM Veterinario v;

-- Observación: MySQL ejecuta la subconsulta para cada fila de Veterinario

-- ----------------------------------------------------------------------------
-- EXPLAIN 10: Consulta compleja con múltiples joins
-- ----------------------------------------------------------------------------
EXPLAIN
SELECT
    f.ID_Ficha,
    f.Diagnostico,
    m.Nombre AS Mascota,
    cl.Nombre AS Cliente,
    v.Nombre AS Veterinario,
    c.Fecha_Hora AS Fecha_Cita
FROM Ficha_Medica f
JOIN Cita c ON f.N_Cita = c.N_Cita
JOIN Mascota m ON c.ID_Mascota = m.ID_Mascota
JOIN Cliente cl ON m.Rut_Cliente = cl.Rut_Cliente
JOIN Veterinario v ON f.Rut_Veterinario = v.Rut_Veterinario
WHERE f.Diagnostico LIKE '%Dermatitis%';

-- ============================================================================
-- SECCIÓN 4: OPTIMIZACIÓN DE CONSULTAS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Optimización 1: Añadir índice para consulta frecuente
-- ----------------------------------------------------------------------------
-- Consulta original (lenta)
EXPLAIN
SELECT * FROM Producto WHERE Nombre_Producto LIKE 'Alimento%';

-- Crear índice para esta consulta
CREATE INDEX idx_producto_nombre_like ON Producto (Nombre_Producto(50));
-- Índice prefijo para búsquedas LIKE

EXPLAIN
SELECT * FROM Producto WHERE Nombre_Producto LIKE 'Alimento%';

-- ----------------------------------------------------------------------------
-- Optimización 2: Usar índice compuesto para JOIN + WHERE
-- ----------------------------------------------------------------------------
-- Consulta original
EXPLAIN
SELECT c.N_Cita, m.Nombre
FROM Cita c
JOIN Mascota m ON c.ID_Mascota = m.ID_Mascota
WHERE c.Estado = 'atendida' AND c.Rut_Veterinario = '14.890.123-4';

-- Crear índice compuesto
CREATE INDEX idx_cita_estado_veterinario ON Cita (Estado, Rut_Veterinario);

EXPLAIN
SELECT c.N_Cita, m.Nombre
FROM Cita c
JOIN Mascota m ON c.ID_Mascota = m.ID_Mascota
WHERE c.Estado = 'atendida' AND c.Rut_Veterinario = '14.890.123-4';

-- ----------------------------------------------------------------------------
-- Optimización 3: Evitar SELECT *
-- ----------------------------------------------------------------------------
-- Consulta original (recupera todos los campos)
EXPLAIN
SELECT * FROM Venta WHERE Fecha_Pago = '2026-10-10';

-- Consulta optimizada (solo campos necesarios)
EXPLAIN
SELECT ID_Venta, Monto_Venta, Forma_Pago FROM Venta WHERE Fecha_Pago = '2026-10-10';

-- ----------------------------------------------------------------------------
-- Optimización 4: Usar JOIN en lugar de subconsultas correlacionadas
-- ----------------------------------------------------------------------------
-- Consulta original (subconsulta correlacionada)
EXPLAIN
SELECT v.*,
    (SELECT COUNT(*) FROM Cita c WHERE c.Rut_Veterinario = v.Rut_Veterinario) AS Numero_Citas
FROM Veterinario v;

-- Consulta optimizada (JOIN)
EXPLAIN
SELECT v.*, COUNT(c.N_Cita) AS Numero_Citas
FROM Veterinario v
LEFT JOIN Cita c ON v.Rut_Veterinario = c.Rut_Veterinario
GROUP BY v.Rut_Veterinario, v.Nombre, v.Especialidad, v.Telefono;

-- ----------------------------------------------------------------------------
-- Optimización 5: Usar WHERE en lugar de HAVING cuando sea posible
-- ----------------------------------------------------------------------------
-- Consulta original (HAVING en GROUP BY)
EXPLAIN
SELECT Rut_Cliente, COUNT(*) AS Numero_Mascotas
FROM Mascota
GROUP BY Rut_Cliente
HAVING COUNT(*) > 1;

-- Consulta optimizada (WHERE antes de GROUP BY no aplica aquí)
-- Pero podemos usar un índice en Rut_Cliente
CREATE INDEX idx_mascota_cliente ON Mascota (Rut_Cliente);

EXPLAIN
SELECT Rut_Cliente, COUNT(*) AS Numero_Mascotas
FROM Mascota
GROUP BY Rut_Cliente
HAVING COUNT(*) > 1;

-- ----------------------------------------------------------------------------
-- Optimización 6: Limitar resultados con LIMIT
-- ----------------------------------------------------------------------------
-- Consulta original (recupera todos los registros)
EXPLAIN
SELECT * FROM Cita ORDER BY Fecha_Hora;

-- Consulta optimizada (solo los primeros 10)
EXPLAIN
SELECT * FROM Cita ORDER BY Fecha_Hora LIMIT 10;

-- ============================================================================
-- SECCIÓN 5: ANÁLISIS DE EXPLAIN
-- ============================================================================

-- La salida de EXPLAIN tiene las siguientes columnas:
--
-- id: Identificador de la consulta
-- select_type: Tipo de SELECT (SIMPLE, PRIMARY, SUBQUERY, DERIVED, etc.)
-- table: Tabla a la que se accede
-- partitions: Particiones (si aplica)
-- type: Tipo de join (ALL, index, range, ref, eq_ref, const, system, NULL)
-- possible_keys: Índices que podrían usarse
-- key: Índice usado realmente
-- key_len: Longitud del índice usado
-- ref: Columna o constante usada con el índice
-- rows: Número estimado de filas examinadas
-- filtered: Porcentaje de filas filtradas
-- Extra: Información adicional

-- Tipos de join (type) ordenados de peor a mejor:
-- 1. ALL: Full table scan (el peor)
-- 2. index: Full index scan
-- 3. range: Index range scan
-- 4. ref: Index lookup with non-unique key
-- 5. eq_ref: Index lookup with unique key
-- 6. const: Primary key lookup (el mejor)
-- 7. system: Tabla con solo una fila

-- ----------------------------------------------------------------------------
-- Ejemplo de análisis detallado
-- ----------------------------------------------------------------------------
-- Consulta a analizar
EXPLAIN FORMAT=JSON
SELECT
    f.ID_Ficha,
    f.Diagnostico,
    m.Nombre AS Mascota,
    cl.Nombre AS Cliente,
    v.Nombre AS Veterinario
FROM Ficha_Medica f
JOIN Cita c ON f.N_Cita = c.N_Cita
JOIN Mascota m ON c.ID_Mascota = m.ID_Mascota
JOIN Cliente cl ON m.Rut_Cliente = cl.Rut_Cliente
JOIN Veterinario v ON f.Rut_Veterinario = v.Rut_Veterinario
WHERE f.Diagnostico LIKE '%Dermatitis%'
ORDER BY f.Fecha_Registro DESC
LIMIT 10;

-- El formato JSON proporciona más detalles sobre la ejecución

-- ----------------------------------------------------------------------------
-- EXPLAIN con FORMAT=TREE (MySQL 8.0.16+)
-- ----------------------------------------------------------------------------
-- Proporciona una representación visual de la ejecución
EXPLAIN FORMAT=TREE
SELECT
    v.*,
    COUNT(c.N_Cita) AS Numero_Citas
FROM Veterinario v
LEFT JOIN Cita c ON v.Rut_Veterinario = c.Rut_Veterinario
GROUP BY v.Rut_Veterinario, v.Nombre, v.Especialidad, v.Telefono;

-- ============================================================================
-- SECCIÓN 6: ÍNDICES RECOMENDADOS
-- ============================================================================

-- Basado en el análisis de las consultas más frecuentes, se recomiendan:

-- 1. Índices para claves foráneas (ya existen por defecto en InnoDB)
-- 2. Índices para columnas usadas en WHERE
-- 3. Índices para columnas usadas en ORDER BY
-- 4. Índices para columnas usadas en GROUP BY
-- 5. Índices compuestos para consultas frecuentes

-- Índices recomendados adicionales:

-- Para consultas de citas por veterinario y fecha
CREATE INDEX IF NOT EXISTS idx_cita_fecha_veterinario ON Cita (Fecha_Hora, Rut_Veterinario);

-- Para consultas de ventas por fecha
CREATE INDEX IF NOT EXISTS idx_venta_fecha ON Venta (Fecha_Pago);

-- Para consultas de fichas médicas por fecha
CREATE INDEX IF NOT EXISTS idx_ficha_fecha ON Ficha_Medica (Fecha_Registro);

-- Para consultas de inventario por fecha
CREATE INDEX IF NOT EXISTS idx_inventario_fecha ON Inventario (Fecha_Movimiento);

-- Para búsquedas de clientes por nombre
CREATE INDEX IF NOT EXISTS idx_cliente_nombre ON Cliente (Nombre(50));

-- Para búsquedas de veterinarios por especialidad
CREATE INDEX IF NOT EXISTS idx_veterinario_especialidad ON Veterinario (Especialidad);

-- ============================================================================
-- SECCIÓN 7: MONITOREO DE RENDIMIENTO
-- ============================================================================

-- Ver estadísticas de uso de índices
SHOW STATUS LIKE 'Handler_read%';

-- Handler_read_key: Número de lecturas que usaron índices
-- Handler_read_rnd: Número de lecturas aleatorias (sin índice)
-- Handler_read_rnd_next: Número de lecturas secuenciales

-- Ver tablas con más lecturas
SELECT
    table_name,
    rows_read,
    rows_inserted,
    rows_updated,
    rows_deleted
FROM performance_schema.table_io_waits_summary_by_table
WHERE table_schema = 'veterinaria_db';

-- Ver índices no usados
SELECT
    TABLE_NAME,
    INDEX_NAME,
    INDEX_TYPE
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'veterinaria_db'
AND INDEX_NAME NOT IN (
    SELECT INDEX_NAME
    FROM performance_schema.events_waits_summary_by_index_usage
    WHERE OBJECT_SCHEMA = 'veterinaria_db'
);

-- ============================================================================
-- SECCIÓN 8: MANTENIMIENTO DE ÍNDICES
-- ============================================================================

-- Analizar tablas para actualizar estadísticas
ANALYZE TABLE Cliente, Mascota, Cita, Venta, Ficha_Medica, Producto;

-- Optimizar tablas (reorganizar datos e índices)
OPTIMIZE TABLE Cliente, Mascota, Cita, Venta, Ficha_Medica, Producto;

-- Ver el tamaño de los índices
SELECT
    table_name,
    ROUND(data_length / 1024 / 1024, 2) AS data_size_mb,
    ROUND(index_length / 1024 / 1024, 2) AS index_size_mb,
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS total_size_mb
FROM information_schema.tables
WHERE table_schema = 'veterinaria_db'
ORDER BY total_size_mb DESC;

-- Ver fragmentación de índices
SELECT
    TABLE_NAME,
    INDEX_NAME,
    ROUND(stat_value * (SELECT variable_value FROM performance_schema.global_status WHERE variable_name = 'Innodb_page_size') / 1024 / 1024, 2) AS fragmentation_mb
FROM sys.schema_unused_indexes
WHERE table_schema = 'veterinaria_db';

-- ============================================================================
-- RESUMEN
-- ============================================================================

-- Los índices son esenciales para el rendimiento de las consultas
-- EXPLAIN es la herramienta principal para analizar y optimizar consultas
-- MySQL usa índices de manera inteligente, pero es importante:
-- 1. Crear índices en columnas usadas en WHERE, JOIN, ORDER BY, GROUP BY
-- 2. Usar índices compuestos para consultas frecuentes
-- 3. Evitar índices redundantes
-- 4. Monitorear el uso de índices
-- 5. Mantener los índices actualizados

-- Los índices tienen un costo:
-- - Espacio en disco
-- - Tiempo de actualización (INSERT, UPDATE, DELETE)
-- Por lo tanto, solo se deben crear índices que realmente se usen
