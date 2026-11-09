-- CVTM | Transacciones ACID | MySQL 8.0
-- Ejemplos de transacciones que demuestran las propiedades ACID
-- y manejo de concurrencia

USE veterinaria_db;

-- ============================================================================
-- SECCIÓN 1: PROPIEDADES ACID
-- ============================================================================

-- ACID = Atomicidad, Consistencia, Aislamiento, Durabilidad

-- ----------------------------------------------------------------------------
-- TRANSACCIÓN 1: Atomicidad - Todo o nada
-- Ejemplo: Registrar una venta completa con sus detalles
-- Si algo falla, toda la transacción se revierte
-- ----------------------------------------------------------------------------
-- Iniciar transacción
START TRANSACTION;

-- Insertar la venta
INSERT INTO Venta (Fecha_Pago, Monto_Venta, Forma_Pago, Rut_Cliente, Rut_Cajero)
VALUES ('2026-11-15', 150000.00, 'Tarjeta Débito', '15.420.311-8', '19.876.543-1');

-- Obtener el ID de la venta recién insertada
SET @id_venta = LAST_INSERT_ID();

-- Insertar detalles de productos
INSERT INTO Detalle_Venta (ID_Venta, ID_Producto, Cantidad, Subtotal)
VALUES (@id_venta, 1, 2, 64000.00); -- 2 x Antiparasitario Bravecto

INSERT INTO Detalle_Venta (ID_Venta, ID_Producto, Cantidad, Subtotal)
VALUES (@id_venta, 2, 1, 48990.00); -- 1 x Alimento Premium

-- Insertar detalles de prestaciones
INSERT INTO Detalle_Prestacion (ID_Venta, ID_Prestacion, Cantidad, Precio_Aplicado, Subtotal)
VALUES (@id_venta, 1, 1, 20000.00, 20000.00); -- 1 x Consulta Médica General

INSERT INTO Detalle_Prestacion (ID_Venta, ID_Prestacion, Cantidad, Precio_Aplicado, Subtotal)
VALUES (@id_venta, 2, 1, 18000.00, 18000.00); -- 1 x Vacunación Séxtuple

-- Verificar que el monto coincide
-- Si no coincide, podemos hacer ROLLBACK
-- En este caso, asumimos que es correcto

-- Confirmar la transacción
COMMIT;

-- Si algo hubiera fallado, haríamos:
-- ROLLBACK;

-- Verificar la venta
SELECT * FROM Venta WHERE ID_Venta = @id_venta;
SELECT * FROM Detalle_Venta WHERE ID_Venta = @id_venta;
SELECT * FROM Detalle_Prestacion WHERE ID_Venta = @id_venta;

-- ----------------------------------------------------------------------------
-- TRANSACCIÓN 2: Consistencia - Las restricciones se mantienen
-- Ejemplo: Transferir una mascota entre clientes
-- ----------------------------------------------------------------------------
START TRANSACTION;

-- Verificar que el cliente nuevo existe
SELECT Rut_Cliente FROM Cliente WHERE Rut_Cliente = '18.734.902-5';

-- Si existe, proceder con la transferencia
-- Cerrar el registro actual de responsable
UPDATE Historial_Responsable
SET Fecha_Fin = CURDATE()
WHERE ID_Mascota = 1 AND Fecha_Fin IS NULL;

-- Crear nuevo registro de responsable
INSERT INTO Historial_Responsable (ID_Mascota, Rut_Cliente, Fecha_Inicio)
VALUES (1, '18.734.902-5', CURDATE());

-- Actualizar el dueño de la mascota
UPDATE Mascota
SET Rut_Cliente = '18.734.902-5'
WHERE ID_Mascota = 1;

-- Verificar que la restricción de fechas se mantiene
-- (Fecha_Fin >= Fecha_Inicio)

COMMIT;

-- Verificar la transferencia
SELECT * FROM Mascota WHERE ID_Mascota = 1;
SELECT * FROM Historial_Responsable WHERE ID_Mascota = 1 ORDER BY Fecha_Inicio;

-- ----------------------------------------------------------------------------
-- TRANSACCIÓN 3: Aislamiento - Manejo de transacciones concurrentes
-- Ejemplo: Dos cajeros intentando vender el mismo producto con stock limitado
-- ----------------------------------------------------------------------------
-- Sesión 1 (Cajero 1):
START TRANSACTION;

-- Verificar stock del producto 1
SELECT ID_Producto, Nombre_Producto, Stock FROM Producto WHERE ID_Producto = 1;

-- Asumir que hay 25 unidades, vendemos 2
-- Simular una pausa (en la realidad, otra sesión podría ejecutarse aquí)
-- UPDATE Producto SET Stock = Stock - 2 WHERE ID_Producto = 1;

-- Sesión 2 (Cajero 2) - Ejecutar en otra conexión:
-- START TRANSACTION;
-- SELECT ID_Producto, Nombre_Producto, Stock FROM Producto WHERE ID_Producto = 1;
-- -- Verá 25 unidades (si el nivel de aislamiento es READ UNCOMMITTED)
-- -- o 25 unidades (si es READ COMMITTED y la sesión 1 no ha hecho COMMIT)
-- UPDATE Producto SET Stock = Stock - 3 WHERE ID_Producto = 1;
-- COMMIT;

-- Continuar Sesión 1:
-- Si la Sesión 2 ya actualizó, el stock podría ser 22
-- Pero con el nivel de aislamiento adecuado, veremos el valor original
UPDATE Producto SET Stock = Stock - 2 WHERE ID_Producto = 1;

COMMIT;

-- Verificar el stock final
SELECT ID_Producto, Nombre_Producto, Stock FROM Producto WHERE ID_Producto = 1;

-- ----------------------------------------------------------------------------
-- TRANSACCIÓN 4: Durabilidad - Los cambios persisten
-- Ejemplo: Registrar una cita y su ficha médica
-- ----------------------------------------------------------------------------
START TRANSACTION;

-- Insertar una nueva cita
INSERT INTO Cita (Fecha_Hora, Estado, ID_Mascota, Rut_Veterinario)
VALUES ('2026-11-20 14:00:00', 'confirmada', 2, '14.890.123-4');

SET @n_cita = LAST_INSERT_ID();

-- Crear la ficha médica
INSERT INTO Ficha_Medica (Diagnostico, Tratamiento, Observaciones, Fecha_Registro, N_Cita, Rut_Veterinario)
VALUES ('Control de rutina', 'Vacunación anual', 'Paciente en buen estado', '2026-11-20', @n_cita, '14.890.123-4');

COMMIT;

-- Verificar que los datos persisten
SELECT * FROM Cita WHERE N_Cita = @n_cita;
SELECT * FROM Ficha_Medica WHERE N_Cita = @n_cita;

-- ============================================================================
-- SECCIÓN 2: PUNTOS DE GUARDA (SAVEPOINT)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TRANSACCIÓN 5: Uso de SAVEPOINT para rollback parcial
-- ----------------------------------------------------------------------------
START TRANSACTION;

-- Insertar una venta
INSERT INTO Venta (Fecha_Pago, Monto_Venta, Forma_Pago, Rut_Cajero)
VALUES ('2026-11-16', 50000.00, 'Efectivo', '19.876.543-1');

SET @id_venta_save = LAST_INSERT_ID();

-- Crear un punto de guarda
SAVEPOINT despues_venta;

-- Insertar detalle de producto
INSERT INTO Detalle_Venta (ID_Venta, ID_Producto, Cantidad, Subtotal)
VALUES (@id_venta_save, 1, 1, 32000.00);

-- Crear otro punto de guarda
SAVEPOINT despues_detalle_producto;

-- Intentar insertar otro detalle (esto podría fallar por restricciones)
-- Por ejemplo, si el producto no existe:
-- INSERT INTO Detalle_Venta (ID_Venta, ID_Producto, Cantidad, Subtotal)
-- VALUES (@id_venta_save, 999, 1, 10000.00); -- Esto fallaría

-- Si falla, podemos hacer rollback al punto de guarda
-- ROLLBACK TO SAVEPOINT despues_detalle_producto;

-- O al primer punto de guarda
-- ROLLBACK TO SAVEPOINT despues_venta;

-- Si todo va bien, confirmar
COMMIT;

-- Verificar
SELECT * FROM Venta WHERE ID_Venta = @id_venta_save;
SELECT * FROM Detalle_Venta WHERE ID_Venta = @id_venta_save;

-- ----------------------------------------------------------------------------
-- TRANSACCIÓN 6: Múltiples SAVEPOINT
-- ----------------------------------------------------------------------------
START TRANSACTION;

-- Paso 1: Crear venta
INSERT INTO Venta (Fecha_Pago, Monto_Venta, Forma_Pago, Rut_Cajero)
VALUES ('2026-11-17', 80000.00, 'Tarjeta Crédito', '20.123.456-7');
SET @id_venta_multi = LAST_INSERT_ID();
SAVEPOINT paso1;

-- Paso 2: Añadir producto
INSERT INTO Detalle_Venta (ID_Venta, ID_Producto, Cantidad, Subtotal)
VALUES (@id_venta_multi, 2, 1, 48990.00);
SAVEPOINT paso2;

-- Paso 3: Añadir prestación
INSERT INTO Detalle_Prestacion (ID_Venta, ID_Prestacion, Cantidad, Precio_Aplicado, Subtotal)
VALUES (@id_venta_multi, 1, 1, 20000.00, 20000.00);
SAVEPOINT paso3;

-- Paso 4: Añadir otro producto
INSERT INTO Detalle_Venta (ID_Venta, ID_Producto, Cantidad, Subtotal)
VALUES (@id_venta_multi, 3, 1, 12500.00);

-- Si algo falla en el paso 4, podemos retroceder al paso 3
-- ROLLBACK TO SAVEPOINT paso3;

-- O al paso 2
-- ROLLBACK TO SAVEPOINT paso2;

-- O al paso 1
-- ROLLBACK TO SAVEPOINT paso1;

-- Confirmar todo
COMMIT;

-- ============================================================================
-- SECCIÓN 3: MANEJO DE ERRORES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TRANSACCIÓN 7: Manejo de errores con DECLARE HANDLER
-- ----------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE registrar_venta_con_errores(
    IN p_fecha_pago DATE,
    IN p_monto DECIMAL(10,2),
    IN p_forma_pago VARCHAR(20),
    IN p_rut_cliente VARCHAR(12),
    IN p_rut_cajero VARCHAR(12)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: La transacción ha sido revertida' AS Mensaje;
    END;

    DECLARE EXIT HANDLER FOR SQLWARNING
    BEGIN
        ROLLBACK;
        SELECT 'Advertencia: La transacción ha sido revertida' AS Mensaje;
    END;

    START TRANSACTION;

    -- Insertar venta
    INSERT INTO Venta (Fecha_Pago, Monto_Venta, Forma_Pago, Rut_Cliente, Rut_Cajero)
    VALUES (p_fecha_pago, p_monto, p_forma_pago, p_rut_cliente, p_rut_cajero);

    SET @id_venta_proc = LAST_INSERT_ID();

    -- Insertar detalle (esto podría fallar si el producto no existe)
    INSERT INTO Detalle_Venta (ID_Venta, ID_Producto, Cantidad, Subtotal)
    VALUES (@id_venta_proc, 1, 1, 32000.00);

    COMMIT;
    SELECT 'Transacción completada exitosamente' AS Mensaje;
END //

DELIMITER ;

-- Ejecutar el procedimiento
-- CALL registrar_venta_con_errores('2026-11-18', 50000.00, 'Efectivo', '15.420.311-8', '19.876.543-1');

-- ----------------------------------------------------------------------------
-- TRANSACCIÓN 8: Verificación de restricciones antes de COMMIT
-- ----------------------------------------------------------------------------
START TRANSACTION;

-- Intentar insertar una mascota con un cliente que no existe
-- Esto violaría la restricción de clave foránea
-- Primero verificamos
SELECT COUNT(*) FROM Cliente WHERE Rut_Cliente = '99.999.999-9';

-- Si el cliente no existe, no insertamos
-- En su lugar, podemos hacer:

-- Opción 1: Insertar el cliente primero
INSERT INTO Cliente (Rut_Cliente, Nombre, Correo_Electronico, Telefono)
VALUES ('99.999.999-9', 'Cliente Nuevo', 'nuevo@email.com', '+56987654321');

-- Luego insertar la mascota
INSERT INTO Mascota (Nombre, Especie, Raza, Fecha_Nacimiento, Sexo, Rut_Cliente)
VALUES ('Nueva Mascota', 'Canino', 'Labrador', '2023-01-01', 'M', '99.999.999-9');

-- Verificar que no hay violaciones
-- SELECT * FROM Mascota WHERE Rut_Cliente = '99.999.999-9';

COMMIT;

-- ============================================================================
-- SECCIÓN 4: NIVELES DE AISLAMIENTO
-- ============================================================================

-- MySQL soporta los siguientes niveles de aislamiento:
-- 1. READ UNCOMMITTED (lectura sucia permitida)
-- 2. READ COMMITTED (lectura sucia no permitida, lectura no repetible sí)
-- 3. REPEATABLE READ (lectura sucia y no repetible no permitidas, fantasma sí)
-- 4. SERIALIZABLE (todos los fenómenos anómalos evitados)

-- ----------------------------------------------------------------------------
-- Configurar nivel de aislamiento para la sesión
-- ----------------------------------------------------------------------------
-- READ UNCOMMITTED
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- En este nivel, una transacción puede leer cambios no confirmados de otras transacciones

-- READ COMMITTED (valor por defecto en MySQL)
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- En este nivel, una transacción solo puede leer datos confirmados

-- REPEATABLE READ (valor por defecto en InnoDB)
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- En este nivel, una transacción ve una instantánea consistente de los datos

-- SERIALIZABLE
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- En este nivel, todas las transacciones se ejecutan en serie

-- Verificar el nivel de aislamiento actual
SELECT @@SESSION.TRANSACTION_ISOLATION;

-- ----------------------------------------------------------------------------
-- Ejemplo: Lectura sucia (Dirty Read)
-- ----------------------------------------------------------------------------
-- Sesión 1:
START TRANSACTION;
UPDATE Producto SET Stock = Stock - 10 WHERE ID_Producto = 1;
-- No hacer COMMIT aún

-- Sesión 2 (con READ UNCOMMITTED):
-- SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- SELECT Stock FROM Producto WHERE ID_Producto = 1; -- Vería el valor no confirmado

-- Sesión 1:
ROLLBACK; -- Revertir la transacción

-- Sesión 2:
-- SELECT Stock FROM Producto WHERE ID_Producto = 1; -- Aún vería el valor no confirmado (lectura sucia)

-- ----------------------------------------------------------------------------
-- Ejemplo: Lectura no repetible (Non-Repeatable Read)
-- ----------------------------------------------------------------------------
-- Sesión 1 (con READ COMMITTED):
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT Stock FROM Producto WHERE ID_Producto = 1; -- Supongamos que devuelve 25
-- No confirmar aún

-- Sesión 2:
START TRANSACTION;
UPDATE Producto SET Stock = 10 WHERE ID_Producto = 1;
COMMIT;

-- Sesión 1:
SELECT Stock FROM Producto WHERE ID_Producto = 1; -- Devuelve 10 (lectura no repetible)
COMMIT;

-- ----------------------------------------------------------------------------
-- Ejemplo: Lectura fantasma (Phantom Read)
-- ----------------------------------------------------------------------------
-- Sesión 1 (con REPEATABLE READ):
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT COUNT(*) FROM Producto WHERE Stock < 20; -- Supongamos que devuelve 5

-- Sesión 2:
START TRANSACTION;
INSERT INTO Producto (Nombre_Producto, Precio_Unitario, Stock)
VALUES ('Nuevo Producto', 5000.00, 10);
COMMIT;

-- Sesión 1:
SELECT COUNT(*) FROM Producto WHERE Stock < 20; -- Podría devolver 6 (lectura fantasma)
COMMIT;

-- ============================================================================
-- SECCIÓN 5: MVCC (Multi-Version Concurrency Control)
-- ============================================================================

-- MVCC es el mecanismo que usa InnoDB para implementar los niveles de aislamiento
-- Cada fila tiene versiones múltiples que permiten a las transacciones ver una instantánea consistente

-- ----------------------------------------------------------------------------
-- Ejemplo: MVCC en acción
-- ----------------------------------------------------------------------------
-- Sesión 1:
START TRANSACTION;
SELECT * FROM Producto WHERE ID_Producto = 1; -- Versión V1

-- Sesión 2:
START TRANSACTION;
UPDATE Producto SET Stock = Stock - 5 WHERE ID_Producto = 1;
COMMIT; -- Crea una nueva versión V2

-- Sesión 1:
-- Aún ve la versión V1 debido a MVCC
SELECT * FROM Producto WHERE ID_Producto = 1;
COMMIT;

-- Sesión 3:
-- Ve la versión V2
SELECT * FROM Producto WHERE ID_Producto = 1;

-- ============================================================================
-- SECCIÓN 6: BLOQUEOS EXPLÍCITOS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Bloqueo de filas para lectura
-- ----------------------------------------------------------------------------
START TRANSACTION;
SELECT * FROM Producto WHERE ID_Producto = 1 FOR SHARE;
-- Esto bloquea la fila para que otras transacciones no puedan modificarla
-- hasta que esta transacción termine
COMMIT;

-- ----------------------------------------------------------------------------
-- Bloqueo de filas para actualización
-- ----------------------------------------------------------------------------
START TRANSACTION;
SELECT * FROM Producto WHERE ID_Producto = 1 FOR UPDATE;
-- Esto bloquea la fila para que otras transacciones no puedan leer ni modificar
-- hasta que esta transacción termine
UPDATE Producto SET Stock = Stock - 1 WHERE ID_Producto = 1;
COMMIT;

-- ----------------------------------------------------------------------------
-- Bloqueo de tablas
-- ----------------------------------------------------------------------------
START TRANSACTION;
LOCK TABLES Producto WRITE;
-- Ahora ninguna otra transacción puede leer ni escribir en Producto
UPDATE Producto SET Stock = Stock - 1 WHERE ID_Producto = 1;
UNLOCK TABLES;
COMMIT;

-- ============================================================================
-- SECCIÓN 7: TRANSACCIONES ANIDADAS (Simuladas con SAVEPOINT)
-- ============================================================================

-- MySQL no soporta transacciones anidadas verdaderas, pero podemos simularlas
-- con SAVEPOINT

START TRANSACTION;

-- Nivel 1
SAVEPOINT nivel1;

-- Operaciones del nivel 1
INSERT INTO Venta (Fecha_Pago, Monto_Venta, Forma_Pago, Rut_Cajero)
VALUES ('2026-11-19', 100000.00, 'Transferencia', '19.876.543-1');
SET @id_nivel1 = LAST_INSERT_ID();

-- Nivel 2
SAVEPOINT nivel2;

-- Operaciones del nivel 2
INSERT INTO Detalle_Venta (ID_Venta, ID_Producto, Cantidad, Subtotal)
VALUES (@id_nivel1, 1, 2, 64000.00);

-- Nivel 3
SAVEPOINT nivel3;

-- Operaciones del nivel 3
INSERT INTO Detalle_Prestacion (ID_Venta, ID_Prestacion, Cantidad, Precio_Aplicado, Subtotal)
VALUES (@id_nivel1, 1, 1, 20000.00, 20000.00);

-- Si algo falla en el nivel 3, retrocedemos al nivel 2
-- ROLLBACK TO SAVEPOINT nivel2;

-- Si algo falla en el nivel 2, retrocedemos al nivel 1
-- ROLLBACK TO SAVEPOINT nivel1;

-- Si todo va bien
COMMIT;

-- ============================================================================
-- SECCIÓN 8: TRANSACCIONES DISTRIBUIDAS (XA)
-- ============================================================================

-- MySQL soporta transacciones distribuidas usando el estándar XA
-- Esto permite coordinar transacciones entre múltiples bases de datos

-- ----------------------------------------------------------------------------
-- Ejemplo básico de transacción XA
-- ----------------------------------------------------------------------------
-- XA START 'transaccion1';
-- INSERT INTO Venta (...) VALUES (...);
-- XA END 'transaccion1';
-- XA PREPARE 'transaccion1';
-- XA COMMIT 'transaccion1';

-- Para más información sobre XA, consultar la documentación de MySQL

-- ============================================================================
-- RESUMEN
-- ============================================================================

-- Las transacciones ACID son fundamentales para garantizar:
-- 1. Atomicidad: Todo o nada
-- 2. Consistencia: Las restricciones siempre se cumplen
-- 3. Aislamiento: Las transacciones no se interfieren entre sí
-- 4. Durabilidad: Los cambios persisten incluso ante fallos

-- MySQL InnoDB implementa MVCC para lograr un buen rendimiento
-- con altos niveles de aislamiento

-- Los SAVEPOINT permiten un control más granular del rollback
-- Los niveles de aislamiento permiten equilibrar consistencia y concurrencia
-- Los bloqueos explícitos permiten un control más fino en situaciones críticas
