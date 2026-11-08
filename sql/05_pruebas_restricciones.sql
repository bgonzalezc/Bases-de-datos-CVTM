-- CVTM | Parte C: datos de prueba y pruebas de restricciones | MySQL 8.0
-- Ejecutar sentencia por sentencia: las pruebas P1 a P23 deben fallar y,
-- si se ejecutan como script completo, el primer error detiene la ejecucion.
-- Requiere la base creada con la Parte A y la Parte B, recien recreada.
USE veterinaria_db;

INSERT INTO Cliente VALUES
 ('11111111-1','Juan Pérez','juan@correo.cl','911111111'),
 ('22222222-2','María López','maria@correo.cl','922222222'),
 ('33333333-3','Carlos Soto','carlos@correo.cl','933333333');

INSERT INTO Veterinario VALUES
 ('15111111-1','Ana Rojas','Medicina general','955555551'),
 ('15222222-2','Luis Mena','Dermatología','955555552');

INSERT INTO Cajero VALUES
 ('16111111-1','Pedro Díaz','Mañana'),
 ('16222222-2','Sofía Vera','Tarde');

INSERT INTO Proveedor VALUES
 ('76111111-1','Distribuidora PetFood','227111111','ventas@petfood.cl','Av. Matta 100, Santiago'),
 ('76222222-2','VetFarma','227222222','contacto@vetfarma.cl','Calle Sur 200, Santiago');

INSERT INTO Mascota (Nombre,Especie,Raza,Fecha_Nacimiento,Sexo,Rut_Cliente) VALUES
 ('Firulais','Canino','Poodle','2021-03-10','M','11111111-1'),
 ('Michi','Felino','Siamés','2022-06-15','H','22222222-2'),
 ('Rocky','Canino','Labrador','2020-01-20','M','11111111-1');

INSERT INTO Prestacion (Nombre_Prestacion,Descripcion,Precio,Duracion_Min) VALUES
 ('Vacuna antirrábica','Vacunación anual',15000,30),
 ('Consulta general','Control de rutina',20000,20);

INSERT INTO Producto (Nombre_Producto,Precio_Unitario,Stock,Fecha_Vencimiento,Rut_Proveedor) VALUES
 ('Alimento premium 3kg',14000,50,'2027-05-01','76111111-1'),
 ('Antiparasitario',8000,30,'2027-02-01','76222222-2'),
 ('Collar antipulgas',5000,20,NULL,NULL);

INSERT INTO Cita (Fecha_Hora,Estado,ID_Mascota,Rut_Veterinario) VALUES
 ('2026-10-20 10:00:00','atendida',1,'15111111-1'),
 ('2026-10-20 11:00:00','confirmada',2,'15222222-2'),
 ('2026-10-21 09:00:00','pendiente',3,'15111111-1');

INSERT INTO Venta (Fecha_Pago,Monto_Venta,Forma_Pago,Rut_Cliente,Rut_Cajero) VALUES
 ('2026-10-20',28000,'Tarjeta','11111111-1','16111111-1'),
 ('2026-10-20',15000,'Efectivo','33333333-3','16222222-2'),
 ('2026-10-21',8000,'Efectivo',NULL,'16111111-1');

INSERT INTO Ficha_Medica (Diagnostico,Tratamiento,Observaciones,Fecha_Registro,N_Cita,Rut_Veterinario) VALUES
 ('Otitis leve','Gotas óticas por 7 días','Control en 1 semana','2026-10-20',1,'15111111-1'),
 ('Control sano',NULL,NULL,'2026-10-20',2,'15222222-2');

INSERT INTO Inventario (ID_Producto,Tipo_Movimiento,Cantidad,Fecha_Movimiento,Rut_Proveedor) VALUES
 (1,'entrada',100,'2026-10-01 09:00:00','76111111-1'),
 (1,'salida',2,'2026-10-20 10:30:00',NULL),
 (2,'entrada',40,'2026-10-02 09:00:00','76222222-2');

INSERT INTO Detalle_Venta VALUES (1,1,2,28000),(3,2,1,8000);
INSERT INTO Detalle_Prestacion VALUES (2,1,1,15000,15000);

-- Venta auxiliar para las pruebas de Detalle_*
INSERT INTO Venta (ID_Venta,Fecha_Pago,Monto_Venta,Forma_Pago,Rut_Cajero)
VALUES (100,'2026-10-22',5000,'Efectivo','16111111-1');

-- verificar los datos
SELECT 'Cliente' AS Tabla, COUNT(*) AS Filas FROM Cliente
UNION ALL SELECT 'Veterinario', COUNT(*) FROM Veterinario
UNION ALL SELECT 'Cajero', COUNT(*) FROM Cajero
UNION ALL SELECT 'Proveedor', COUNT(*) FROM Proveedor
UNION ALL SELECT 'Mascota', COUNT(*) FROM Mascota
UNION ALL SELECT 'Prestacion', COUNT(*) FROM Prestacion
UNION ALL SELECT 'Producto', COUNT(*) FROM Producto
UNION ALL SELECT 'Cita', COUNT(*) FROM Cita
UNION ALL SELECT 'Venta', COUNT(*) FROM Venta
UNION ALL SELECT 'Ficha_Medica', COUNT(*) FROM Ficha_Medica
UNION ALL SELECT 'Inventario', COUNT(*) FROM Inventario
UNION ALL SELECT 'Detalle_Venta', COUNT(*) FROM Detalle_Venta
UNION ALL SELECT 'Detalle_Prestacion', COUNT(*) FROM Detalle_Prestacion;

SELECT c.Nombre AS Dueno, m.Nombre AS Mascota, ci.Fecha_Hora, ci.Estado,
       v.Nombre AS Veterinario, f.Diagnostico
FROM Cliente c
JOIN Mascota m ON m.Rut_Cliente = c.Rut_Cliente
JOIN Cita ci ON ci.ID_Mascota = m.ID_Mascota
JOIN Veterinario v ON v.Rut_Veterinario = ci.Rut_Veterinario
LEFT JOIN Ficha_Medica f ON f.N_Cita = ci.N_Cita;

-- Paso 3: Pruebas que deben fallar
-- FK al insertar (esperado: ERROR 1452)
-- P1
INSERT INTO Mascota (Nombre,Especie,Raza,Sexo,Rut_Cliente) VALUES ('Fantasma','Canino','Mestizo','M','99999999-9');
-- P2
INSERT INTO Cita (Fecha_Hora,Estado,ID_Mascota,Rut_Veterinario) VALUES ('2026-10-25 10:00:00','pendiente',999,'15111111-1');
-- P3
INSERT INTO Detalle_Venta VALUES (1,999,1,5000);

-- RESTRICT al borrar (esperado: ERROR 1451)
-- P4 (esperado: ERROR 1451)
DELETE FROM Cliente WHERE Rut_Cliente = '15.420.311-8';
-- P5 (esperado: ERROR 1451)
DELETE FROM Veterinario WHERE Rut_Veterinario = '14.890.123-4';
-- P6
DELETE FROM Producto WHERE ID_Producto = 1;

-- UNIQUE (esperado: ERROR 1062)
-- P7
INSERT INTO Ficha_Medica (Diagnostico,Fecha_Registro,N_Cita,Rut_Veterinario) VALUES ('Segunda ficha','2026-10-10',1,'14.890.123-4');

-- CHECK (esperado en todos: ERROR 3819)
-- P8  chk_mascota_sexo
INSERT INTO Mascota (Nombre,Sexo,Rut_Cliente) VALUES ('Test','X','15.420.311-8');
-- P9  chk_prestacion_precio
INSERT INTO Prestacion (Nombre_Prestacion,Precio) VALUES ('Test',-1);
-- P10 chk_prestacion_duracion
INSERT INTO Prestacion (Nombre_Prestacion,Precio,Duracion_Min) VALUES ('Test',1000,0);
-- P11 chk_producto_precio
INSERT INTO Producto (Nombre_Producto,Precio_Unitario,Stock) VALUES ('Test',-1,5);
-- P12 chk_producto_stock
INSERT INTO Producto (Nombre_Producto,Precio_Unitario,Stock) VALUES ('Test',1000,-1);
-- P13 chk_cita_estado
INSERT INTO Cita (Fecha_Hora,Estado,ID_Mascota,Rut_Veterinario) VALUES ('2026-10-25 10:00:00','anulada',1,'14.890.123-4');
-- P14 chk_venta_monto
INSERT INTO Venta (Fecha_Pago,Monto_Venta,Rut_Cajero) VALUES ('2026-10-22',-1,'16111111-1');
-- P15 chk_inventario_tipo
INSERT INTO Inventario (ID_Producto,Tipo_Movimiento,Cantidad,Fecha_Movimiento) VALUES (1,'devolucion',5,'2026-10-22 10:00:00');
-- P16 chk_inventario_cantidad
INSERT INTO Inventario (ID_Producto,Tipo_Movimiento,Cantidad,Fecha_Movimiento) VALUES (1,'entrada',0,'2026-10-22 10:00:00');
-- P17 chk_detventa_cantidad
INSERT INTO Detalle_Venta VALUES (100,3,0,0);
-- P18 chk_detventa_subtotal
INSERT INTO Detalle_Venta VALUES (100,3,1,-1);
-- P19 chk_detprest_cantidad
INSERT INTO Detalle_Prestacion VALUES (100,2,0,20000,0);
-- P20 chk_detprest_precio
INSERT INTO Detalle_Prestacion VALUES (100,2,1,-1,0);
-- P21 chk_detprest_subtotal
INSERT INTO Detalle_Prestacion VALUES (100,2,1,20000,-1);

-- NOT NULL
-- P22 (esperado: ERROR 1048)
INSERT INTO Mascota (Nombre,Rut_Cliente) VALUES (NULL,'15.420.311-8');
-- P23 (esperado: ERROR 1364)
INSERT INTO Mascota (Especie,Rut_Cliente) VALUES ('Canino','15.420.311-8');

-- paso 4:
INSERT INTO Cita (Fecha_Hora,ID_Mascota,Rut_Veterinario) VALUES ('2026-10-26 15:00:00',2,'16.234.567-8');
INSERT INTO Producto (Nombre_Producto,Precio_Unitario) VALUES ('Juguete de goma',3000);
SELECT N_Cita, Estado FROM Cita ORDER BY N_Cita DESC LIMIT 1;
SELECT ID_Producto, Nombre_Producto, Stock FROM Producto ORDER BY ID_Producto DESC LIMIT 1;

-- Paso 5: Limitaciones 
-- Subtotal incorrecto aceptado L1
INSERT INTO Detalle_Venta VALUES (100,3,2,1);

-- L2 Ficha firmada por un veterinario distinto al de la cita (la cita 100 es del Dr. Navarro)
INSERT INTO Ficha_Medica (Diagnostico,Fecha_Registro,N_Cita,Rut_Veterinario)
VALUES ('Ficha de otro vet','2026-10-12',100,'14.890.123-4');

-- Salida de inventario que no descuenta el Stock
INSERT INTO Inventario (ID_Producto,Tipo_Movimiento,Cantidad,Fecha_Movimiento)
VALUES (3,'salida',5,'2026-10-22 12:00:00');
SELECT Stock FROM Producto WHERE ID_Producto = 3;

-- P24 (antes era la limitación "dos citas a la misma hora") (esperado: ERROR 1062, key 'Cita.uq_cita_vet_bloque')
INSERT INTO Cita (Fecha_Hora,Estado,ID_Mascota,Rut_Veterinario)
VALUES ('2026-10-10 10:00:00','pendiente',3,'14.890.123-4');

-- P25 una cita cancelada libera el bloque
-- (a) OK
INSERT INTO Cita (Fecha_Hora,Estado,ID_Mascota,Rut_Veterinario)
VALUES ('2026-10-27 10:00:00','pendiente',3,'14.890.123-4');
-- (b) ERROR 1062: el bloque está ocupado
INSERT INTO Cita (Fecha_Hora,Estado,ID_Mascota,Rut_Veterinario)
VALUES ('2026-10-27 10:00:00','pendiente',2,'14.890.123-4');
-- (c) cancelar la cita de (a)
UPDATE Cita SET Estado='cancelada'
WHERE Rut_Veterinario='14.890.123-4' AND Fecha_Hora='2026-10-27 10:00:00';
-- (d) ahora se acepta
INSERT INTO Cita (Fecha_Hora,Estado,ID_Mascota,Rut_Veterinario)
VALUES ('2026-10-27 10:00:00','pendiente',2,'14.890.123-4');
SELECT N_Cita, Estado, Bloque_Activo FROM Cita
WHERE Rut_Veterinario='14.890.123-4' AND Fecha_Hora='2026-10-27 10:00:00';

-- P26 (esperado: ERROR 1452)
INSERT INTO Historial_Responsable (ID_Mascota,Rut_Cliente,Fecha_Inicio) VALUES (999,'15.420.311-8','2026-01-01');
-- P27 (esperado: ERROR 1452)
INSERT INTO Historial_Responsable (ID_Mascota,Rut_Cliente,Fecha_Inicio) VALUES (1,'99.999.999-9','2026-01-01');
-- P28 (esperado: ERROR 3819, chk_hist_fechas)
INSERT INTO Historial_Responsable (ID_Mascota,Rut_Cliente,Fecha_Inicio,Fecha_Fin) VALUES (1,'15.420.311-8','2026-05-01','2026-04-01');
-- P29 borde positivo, Fecha_Fin = Fecha_Inicio (debe aceptarse)
INSERT INTO Historial_Responsable (ID_Mascota,Rut_Cliente,Fecha_Inicio,Fecha_Fin) VALUES (2,'15.420.311-8','2022-06-15','2022-06-15');
SELECT * FROM Historial_Responsable;

-- Paso 6 
-- Paso 6.1 ON UPDATE CASCADE
SELECT Nombre, Rut_Cliente FROM Mascota;
SELECT ID_Venta, Rut_Cliente FROM Venta;
SELECT ID_Historial, ID_Mascota, Rut_Cliente FROM Historial_Responsable;
UPDATE Cliente SET Rut_Cliente = '15.420.311-9' WHERE Rut_Cliente = '15.420.311-8';
SELECT Nombre, Rut_Cliente FROM Mascota;
SELECT ID_Venta, Rut_Cliente FROM Venta;
SELECT ID_Historial, ID_Mascota, Rut_Cliente FROM Historial_Responsable;
-- 6.2 ON DELETE SET NULL (cliente)
-- El SELECT siguiente muestra el resultado del 6.1 y el estado 'antes' del 6.2
SELECT ID_Venta, Rut_Cliente FROM Venta;
DELETE FROM Cliente WHERE Rut_Cliente = '11.111.111-1';
SELECT ID_Venta, Rut_Cliente FROM Venta;
-- 6.3 ON DELETE SET NULL (proveedor)
SELECT ID_Producto, Nombre_Producto, Rut_Proveedor FROM Producto;
SELECT ID_Movimiento, ID_Producto, Tipo_Movimiento, Rut_Proveedor FROM Inventario;
DELETE FROM Proveedor WHERE Rut_Proveedor = '76.123.456-0';
SELECT ID_Producto, Nombre_Producto, Rut_Proveedor FROM Producto;
SELECT ID_Movimiento, ID_Producto, Tipo_Movimiento, Rut_Proveedor FROM Inventario;


