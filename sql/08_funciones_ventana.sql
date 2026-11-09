-- CVTM | SQL Avanzado: Funciones de Ventana | MySQL 8.0
-- Ejemplos de consultas con funciones de ventana para rankings y acumulados

USE veterinaria_db;

-- ============================================================================
-- SECCIÓN 1: FUNCIONES DE VENTANA BÁSICAS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- FW 1: ROW_NUMBER() - Numerar filas
-- ----------------------------------------------------------------------------
-- Numerar todas las citas por orden de fecha
SELECT
    ROW_NUMBER() OVER (ORDER BY c.Fecha_Hora) AS Numero_Fila,
    c.N_Cita,
    c.Fecha_Hora,
    c.Estado,
    m.Nombre AS Mascota,
    v.Nombre AS Veterinario
FROM Cita c
JOIN Mascota m ON c.ID_Mascota = m.ID_Mascota
JOIN Veterinario v ON c.Rut_Veterinario = v.Rut_Veterinario
ORDER BY c.Fecha_Hora;

-- ----------------------------------------------------------------------------
-- FW 2: RANK() - Ranking con empates
-- ----------------------------------------------------------------------------
-- Ranking de productos por cantidad vendida (con empates)
SELECT
    p.ID_Producto,
    p.Nombre_Producto,
    SUM(dv.Cantidad) AS Cantidad_Vendida,
    RANK() OVER (ORDER BY SUM(dv.Cantidad) DESC) AS Ranking
FROM Detalle_Venta dv
JOIN Producto p ON dv.ID_Producto = p.ID_Producto
GROUP BY p.ID_Producto, p.Nombre_Producto
ORDER BY Ranking;

-- ----------------------------------------------------------------------------
-- FW 3: DENSE_RANK() - Ranking sin saltos
-- ----------------------------------------------------------------------------
-- Ranking de veterinarios por número de citas (sin saltos en el ranking)
SELECT
    v.Rut_Veterinario,
    v.Nombre AS Veterinario,
    COUNT(c.N_Cita) AS Numero_Citas,
    DENSE_RANK() OVER (ORDER BY COUNT(c.N_Cita) DESC) AS Ranking_Denso
FROM Veterinario v
LEFT JOIN Cita c ON v.Rut_Veterinario = c.Rut_Veterinario
GROUP BY v.Rut_Veterinario, v.Nombre
ORDER BY Ranking_Denso;

-- ----------------------------------------------------------------------------
-- FW 4: NTILE() - Dividir en grupos
-- ----------------------------------------------------------------------------
-- Dividir clientes en 4 grupos por monto total gastado
SELECT
    cl.Rut_Cliente,
    cl.Nombre AS Cliente,
    COALESCE(SUM(v.Monto_Venta), 0) AS Monto_Total,
    NTILE(4) OVER (ORDER BY COALESCE(SUM(v.Monto_Venta), 0) DESC) AS Grupo
FROM Cliente cl
LEFT JOIN Venta v ON cl.Rut_Cliente = v.Rut_Cliente
GROUP BY cl.Rut_Cliente, cl.Nombre
ORDER BY Grupo, Monto_Total DESC;

-- ============================================================================
-- SECCIÓN 2: FUNCIONES DE VENTANA CON PARTITION BY
-- ============================================================================

-- ----------------------------------------------------------------------------
-- FW 5: ROW_NUMBER() con PARTITION BY - Numerar citas por veterinario
-- ----------------------------------------------------------------------------
SELECT
    v.Nombre AS Veterinario,
    c.N_Cita,
    c.Fecha_Hora,
    c.Estado,
    m.Nombre AS Mascota,
    ROW_NUMBER() OVER (PARTITION BY v.Rut_Veterinario ORDER BY c.Fecha_Hora) AS Numero_Cita_Veterinario
FROM Cita c
JOIN Veterinario v ON c.Rut_Veterinario = v.Rut_Veterinario
JOIN Mascota m ON c.ID_Mascota = m.ID_Mascota
ORDER BY v.Nombre, c.Fecha_Hora;

-- ----------------------------------------------------------------------------
-- FW 6: RANK() con PARTITION BY - Ranking de ventas por cajero
-- ----------------------------------------------------------------------------
SELECT
    cj.Nombre AS Cajero,
    v.ID_Venta,
    v.Fecha_Pago,
    v.Monto_Venta,
    RANK() OVER (PARTITION BY cj.Rut_Cajero ORDER BY v.Monto_Venta DESC) AS Ranking_Venta_Cajero
FROM Venta v
JOIN Cajero cj ON v.Rut_Cajero = cj.Rut_Cajero
ORDER BY cj.Nombre, Ranking_Venta_Cajero;

-- ----------------------------------------------------------------------------
-- FW 7: Acumulados con SUM() OVER - Ventas acumuladas por día
-- ----------------------------------------------------------------------------
SELECT
    v.Fecha_Pago,
    v.ID_Venta,
    v.Monto_Venta,
    SUM(v.Monto_Venta) OVER (ORDER BY v.Fecha_Pago) AS Ventas_Acumuladas,
    SUM(v.Monto_Venta) OVER (ORDER BY v.Fecha_Pago ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Ventas_Acumuladas_Explicito
FROM Venta v
ORDER BY v.Fecha_Pago;

-- ----------------------------------------------------------------------------
-- FW 8: Acumulados por categoría - Ventas acumuladas por cajero
-- ----------------------------------------------------------------------------
SELECT
    cj.Nombre AS Cajero,
    v.Fecha_Pago,
    v.Monto_Venta,
    SUM(v.Monto_Venta) OVER (
        PARTITION BY cj.Rut_Cajero
        ORDER BY v.Fecha_Pago
    ) AS Ventas_Acumuladas_Cajero
FROM Venta v
JOIN Cajero cj ON v.Rut_Cajero = cj.Rut_Cajero
ORDER BY cj.Nombre, v.Fecha_Pago;

-- ----------------------------------------------------------------------------
-- FW 9: Promedio móvil - Promedio de ventas de los últimos 3 días
-- ----------------------------------------------------------------------------
SELECT
    v1.Fecha_Pago,
    SUM(v1.Monto_Venta) AS Ventas_Dia,
    AVG(v2.Monto_Venta) OVER (
        ORDER BY v1.Fecha_Pago
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS Promedio_Movil_3d
FROM Venta v1
JOIN Venta v2 ON v2.Fecha_Pago BETWEEN DATE_SUB(v1.Fecha_Pago, INTERVAL 2 DAY) AND v1.Fecha_Pago
GROUP BY v1.Fecha_Pago
ORDER BY v1.Fecha_Pago;

-- ----------------------------------------------------------------------------
-- FW 10: Diferencia con el anterior - Crecimiento de ventas día a día
-- ----------------------------------------------------------------------------
WITH Ventas_Diarias AS (
    SELECT
        Fecha_Pago,
        SUM(Monto_Venta) AS Total_Dia
    FROM Venta
    GROUP BY Fecha_Pago
)
SELECT
    Fecha_Pago,
    Total_Dia,
    LAG(Total_Dia, 1) OVER (ORDER BY Fecha_Pago) AS Total_Dia_Anterior,
    Total_Dia - LAG(Total_Dia, 1) OVER (ORDER BY Fecha_Pago) AS Diferencia_Dia,
    CASE
        WHEN LAG(Total_Dia, 1) OVER (ORDER BY Fecha_Pago) = 0 THEN NULL
        ELSE ROUND(
            (Total_Dia - LAG(Total_Dia, 1) OVER (ORDER BY Fecha_Pago)) /
            LAG(Total_Dia, 1) OVER (ORDER BY Fecha_Pago) * 100, 2
        )
    END AS Crecimiento_Porcentual
FROM Ventas_Diarias
ORDER BY Fecha_Pago;

-- ============================================================================
-- SECCIÓN 3: FUNCIONES DE VENTANA AVANZADAS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- FW 11: FIRST_VALUE() y LAST_VALUE() - Primera y última venta por cajero
-- ----------------------------------------------------------------------------
SELECT DISTINCT
    cj.Nombre AS Cajero,
    FIRST_VALUE(v.Monto_Venta) OVER (
        PARTITION BY cj.Rut_Cajero
        ORDER BY v.Fecha_Pago, v.ID_Venta
    ) AS Primera_Venta,
    LAST_VALUE(v.Monto_Venta) OVER (
        PARTITION BY cj.Rut_Cajero
        ORDER BY v.Fecha_Pago, v.ID_Venta
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS Ultima_Venta,
    COUNT(v.ID_Venta) OVER (PARTITION BY cj.Rut_Cajero) AS Total_Ventas
FROM Venta v
JOIN Cajero cj ON v.Rut_Cajero = cj.Rut_Cajero
ORDER BY cj.Nombre;

-- ----------------------------------------------------------------------------
-- FW 12: LEAD() - Comparar con el siguiente registro
-- ----------------------------------------------------------------------------
-- Comparar ventas consecutivas
SELECT
    v.ID_Venta,
    v.Fecha_Pago,
    v.Monto_Venta,
    LEAD(v.Monto_Venta, 1) OVER (ORDER BY v.Fecha_Pago, v.ID_Venta) AS Siguiente_Venta,
    LEAD(v.Monto_Venta, 1) OVER (ORDER BY v.Fecha_Pago, v.ID_Venta) - v.Monto_Venta AS Diferencia_Siguiente
FROM Venta v
ORDER BY v.Fecha_Pago, v.ID_Venta;

-- ----------------------------------------------------------------------------
-- FW 13: Percentiles - Calcular percentiles de ventas
-- ----------------------------------------------------------------------------
SELECT
    v.ID_Venta,
    v.Monto_Venta,
    PERCENT_RANK() OVER (ORDER BY v.Monto_Venta) AS Percentil,
    CUME_DIST() OVER (ORDER BY v.Monto_Venta) AS Distribucion_Acumulada
FROM Venta v
ORDER BY Percentil;

-- ----------------------------------------------------------------------------
-- FW 14: Nth_VALUE() - Obtener el n-ésimo valor
-- ----------------------------------------------------------------------------
-- Obtener la segunda venta más grande por día
SELECT
    v.Fecha_Pago,
    v.Monto_Venta,
    NTH_VALUE(v.Monto_Venta, 2) OVER (
        PARTITION BY v.Fecha_Pago
        ORDER BY v.Monto_Venta DESC
    ) AS Segunda_Venta_Mas_Grande
FROM Venta v
ORDER BY v.Fecha_Pago, v.Monto_Venta DESC;

-- ============================================================================
-- SECCIÓN 4: CONSULTAS ANALÍTICAS CON FUNCIONES DE VENTANA
-- ============================================================================

-- ----------------------------------------------------------------------------
-- FW 15: Análisis ABC de productos (Clasificación por valor de ventas)
-- ----------------------------------------------------------------------------
WITH Ventas_Productos AS (
    SELECT
        p.ID_Producto,
        p.Nombre_Producto,
        SUM(dv.Subtotal) AS Total_Ventas
    FROM Detalle_Venta dv
    JOIN Producto p ON dv.ID_Producto = p.ID_Producto
    GROUP BY p.ID_Producto, p.Nombre_Producto
)
SELECT
    ID_Producto,
    Nombre_Producto,
    Total_Ventas,
    SUM(Total_Ventas) OVER () AS Total_General,
    ROUND(Total_Ventas / SUM(Total_Ventas) OVER () * 100, 2) AS Porcentaje_Ventas,
    SUM(Total_Ventas) OVER (ORDER BY Total_Ventas DESC) AS Acumulado,
    ROUND(SUM(Total_Ventas) OVER (ORDER BY Total_Ventas DESC) / SUM(Total_Ventas) OVER () * 100, 2) AS Porcentaje_Acumulado,
    CASE
        WHEN SUM(Total_Ventas) OVER (ORDER BY Total_Ventas DESC) / SUM(Total_Ventas) OVER () <= 0.8 THEN 'A'
        WHEN SUM(Total_Ventas) OVER (ORDER BY Total_Ventas DESC) / SUM(Total_Ventas) OVER () <= 0.9 THEN 'B'
        ELSE 'C'
    END AS Clasificacion_ABC
FROM Ventas_Productos
ORDER BY Total_Ventas DESC;

-- ----------------------------------------------------------------------------
-- FW 16: Análisis de citas por día de la semana
-- ----------------------------------------------------------------------------
SELECT
    DAYNAME(c.Fecha_Hora) AS Dia_Semana,
    DAYOFWEEK(c.Fecha_Hora) AS Numero_Dia,
    COUNT(*) AS Numero_Citas,
    SUM(CASE WHEN c.Estado = 'atendida' THEN 1 ELSE 0 END) AS Citas_Atendidas,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2) AS Porcentaje_Total,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS Ranking_Dia
FROM Cita c
GROUP BY DAYNAME(c.Fecha_Hora), DAYOFWEEK(c.Fecha_Hora)
ORDER BY Numero_Dia;

-- ----------------------------------------------------------------------------
-- FW 17: Análisis de edad de mascotas por diagnóstico
-- ----------------------------------------------------------------------------
SELECT
    f.Diagnostico,
    COUNT(*) AS Numero_Fichas,
    AVG(TIMESTAMPDIFF(MONTH, m.Fecha_Nacimiento, f.Fecha_Registro)) AS Edad_Promedio_Meses,
    MIN(TIMESTAMPDIFF(MONTH, m.Fecha_Nacimiento, f.Fecha_Registro)) AS Edad_Minima,
    MAX(TIMESTAMPDIFF(MONTH, m.Fecha_Nacimiento, f.Fecha_Registro)) AS Edad_Maxima,
    STDDEV(TIMESTAMPDIFF(MONTH, m.Fecha_Nacimiento, f.Fecha_Registro)) AS Desviacion_Estandar
FROM Ficha_Medica f
JOIN Cita c ON f.N_Cita = c.N_Cita
JOIN Mascota m ON c.ID_Mascota = m.ID_Mascota
GROUP BY f.Diagnostico
HAVING COUNT(*) >= 2
ORDER BY Numero_Fichas DESC;

-- ----------------------------------------------------------------------------
-- FW 18: Top 3 productos más vendidos por categoría de especie
-- ----------------------------------------------------------------------------
WITH Ventas_Por_Especie AS (
    SELECT
        m.Especie,
        p.ID_Producto,
        p.Nombre_Producto,
        SUM(dv.Cantidad) AS Cantidad_Vendida,
        RANK() OVER (PARTITION BY m.Especie ORDER BY SUM(dv.Cantidad) DESC) AS Ranking_Especie
    FROM Detalle_Venta dv
    JOIN Producto p ON dv.ID_Producto = p.ID_Producto
    JOIN Venta v ON dv.ID_Venta = v.ID_Venta
    JOIN Mascota m ON v.Rut_Cliente = m.Rut_Cliente
    WHERE m.Especie IS NOT NULL
    GROUP BY m.Especie, p.ID_Producto, p.Nombre_Producto
)
SELECT
    Especie,
    ID_Producto,
    Nombre_Producto,
    Cantidad_Vendida,
    Ranking_Especie
FROM Ventas_Por_Especie
WHERE Ranking_Especie <= 3
ORDER BY Especie, Ranking_Especie;

-- ----------------------------------------------------------------------------
-- FW 19: Análisis de retención de clientes (clientes que vuelven)
-- ----------------------------------------------------------------------------
WITH Clientes_Vistas AS (
    SELECT
        Rut_Cliente,
        Fecha_Pago,
        LAG(Fecha_Pago, 1) OVER (PARTITION BY Rut_Cliente ORDER BY Fecha_Pago) AS Visita_Anterior,
        DATEDIFF(Fecha_Pago, LAG(Fecha_Pago, 1) OVER (PARTITION BY Rut_Cliente ORDER BY Fecha_Pago)) AS Dias_Entre_Visitas
    FROM Venta
    WHERE Rut_Cliente IS NOT NULL
)
SELECT
    Rut_Cliente,
    COUNT(*) AS Numero_Visitas,
    AVG(Dias_Entre_Visitas) AS Promedio_Dias_Entre_Visitas,
    MIN(Dias_Entre_Visitas) AS Minimo_Dias,
    MAX(Dias_Entre_Visitas) AS Maximo_Dias,
    CASE
        WHEN AVG(Dias_Entre_Visitas) <= 30 THEN 'Alta Frecuencia'
        WHEN AVG(Dias_Entre_Visitas) <= 90 THEN 'Frecuencia Media'
        ELSE 'Baja Frecuencia'
    END AS Frecuencia
FROM Clientes_Vistas
WHERE Dias_Entre_Visitas IS NOT NULL
GROUP BY Rut_Cliente
HAVING COUNT(*) >= 2
ORDER BY Numero_Visitas DESC, Promedio_Dias_Entre_Visitas;

-- ----------------------------------------------------------------------------
-- FW 20: Análisis de estacionalidad de ventas por mes
-- ----------------------------------------------------------------------------
SELECT
    MONTH(v.Fecha_Pago) AS Mes,
    MONTHNAME(v.Fecha_Pago) AS Nombre_Mes,
    COUNT(*) AS Numero_Ventas,
    SUM(v.Monto_Venta) AS Total_Ventas,
    AVG(v.Monto_Venta) AS Promedio_Venta,
    -- Comparación con el mes anterior
    LAG(SUM(v.Monto_Venta), 1) OVER (ORDER BY MONTH(v.Fecha_Pago)) AS Mes_Anterior,
    SUM(v.Monto_Venta) - LAG(SUM(v.Monto_Venta), 1) OVER (ORDER BY MONTH(v.Fecha_Pago)) AS Diferencia_Mes,
    -- Porcentaje de cambio
    CASE
        WHEN LAG(SUM(v.Monto_Venta), 1) OVER (ORDER BY MONTH(v.Fecha_Pago)) = 0 THEN NULL
        ELSE ROUND(
            (SUM(v.Monto_Venta) - LAG(SUM(v.Monto_Venta), 1) OVER (ORDER BY MONTH(v.Fecha_Pago))) /
            LAG(SUM(v.Monto_Venta), 1) OVER (ORDER BY MONTH(v.Fecha_Pago)) * 100, 2
        )
    END AS Crecimiento_Porcentual
FROM Venta v
GROUP BY MONTH(v.Fecha_Pago), MONTHNAME(v.Fecha_Pago)
ORDER BY Mes;
