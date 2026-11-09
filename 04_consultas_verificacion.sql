-- CVTM | Consultas de verificación (requieren 03_datos_prueba.sql) | MySQL 8.0
USE veterinaria_db;

-- Citas con su mascota, su dueño y el veterinario a cargo
SELECT ci.N_Cita, ci.Fecha_Hora, ci.Estado, m.Nombre AS Mascota,
       c.Nombre AS Dueno, v.Nombre AS Veterinario
FROM Cita ci
JOIN Mascota m ON m.ID_Mascota = ci.ID_Mascota
JOIN Cliente c ON c.Rut_Cliente = m.Rut_Cliente
JOIN Veterinario v ON v.Rut_Veterinario = ci.Rut_Veterinario
ORDER BY ci.Fecha_Hora;

-- Fichas médicas con la mascota atendida y el veterinario que firma
SELECT f.ID_Ficha, m.Nombre AS Mascota, f.Diagnostico,
       v.Nombre AS Veterinario, f.Fecha_Registro
FROM Ficha_Medica f
JOIN Cita ci ON ci.N_Cita = f.N_Cita
JOIN Mascota m ON m.ID_Mascota = ci.ID_Mascota
JOIN Veterinario v ON v.Rut_Veterinario = f.Rut_Veterinario;

-- Ventas con su cliente y los totales de productos y prestaciones
SELECT v.ID_Venta, v.Fecha_Pago, c.Nombre AS Cliente, v.Monto_Venta,
       (SELECT SUM(Subtotal) FROM Detalle_Venta dv
        WHERE dv.ID_Venta = v.ID_Venta) AS Total_Productos,
       (SELECT SUM(Subtotal) FROM Detalle_Prestacion dp
        WHERE dp.ID_Venta = v.ID_Venta) AS Total_Prestaciones
FROM Venta v
LEFT JOIN Cliente c ON c.Rut_Cliente = v.Rut_Cliente;

