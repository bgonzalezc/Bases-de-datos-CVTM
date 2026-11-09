-- ============================================================================
-- CVTM | RESPALDOS, RECUPERACIÓN Y MIGRACIONES | MySQL 8.0
-- Archivo SQL: ejecutar en MySQL Workbench después de seleccionar la conexión.
--
-- IMPORTANTE:
-- Este archivo contiene únicamente instrucciones SQL.
-- Los comandos mysqldump, mysql, gzip, cron y Bash se ejecutan en la terminal,
-- no dentro de MySQL Workbench. Los ejemplos están documentados como comentarios.
-- ============================================================================

USE veterinaria_db;

-- ============================================================================
-- SECCIÓN 1: POLÍTICAS DE RESPALDO
-- ============================================================================

-- Política recomendada:
-- 1. Respaldo completo semanal.
-- 2. Respaldo diario de los datos que cambian frecuentemente.
-- 3. Binary logs habilitados para recuperación a un punto en el tiempo.
-- 4. Conservar respaldos durante al menos 90 días.
-- 5. Mantener una copia local y otra externa.
-- 6. Probar periódicamente la restauración.
--
-- Nota: exportar filas recientes con mysqldump --where no constituye por sí
-- solo un respaldo incremental completo. Para recuperación incremental real
-- se utilizan los binary logs de MySQL.

-- ============================================================================
-- SECCIÓN 2: RESPALDO COMPLETO
-- ============================================================================

-- Ejecutar en la terminal del sistema operativo, no en Workbench:
--
-- mysqldump -u root -p --single-transaction --routines --triggers --events \
--   --quick --set-gtid-purged=OFF veterinaria_db > respaldo_cvtm.sql
--
-- Respaldo comprimido:
--
-- mysqldump -u root -p --single-transaction --routines --triggers --events \
--   --quick --set-gtid-purged=OFF veterinaria_db | gzip > respaldo_cvtm.sql.gz
--
-- Respaldo de todas las bases:
--
-- mysqldump -u root -p --all-databases --routines --triggers --events \
--   > respaldo_completo.sql
--
-- Respaldo de estructura sin datos:
--
-- mysqldump -u root -p --no-data veterinaria_db > respaldo_esquema.sql
--
-- Respaldo de datos sin estructura:
--
-- mysqldump -u root -p --no-create-info veterinaria_db > respaldo_datos.sql

-- ============================================================================
-- SECCIÓN 3: CONFIGURACIÓN DE BINARY LOGS
-- ============================================================================

-- La habilitación se realiza en el archivo de configuración de MySQL
-- (por ejemplo, my.cnf o my.ini), dentro de [mysqld].
--
-- [mysqld]
-- server-id=1
-- log_bin=mysql-bin
-- binlog_format=ROW
-- binlog_expire_logs_seconds=2592000
--
-- Después de modificar la configuración, reiniciar el servicio MySQL.
--
-- Consultar el estado de los binary logs:

SHOW BINARY LOGS;

-- En versiones de MySQL 8.0 que lo admitan:
SHOW MASTER STATUS;

-- Crear un nuevo archivo de binary log:
FLUSH BINARY LOGS;

-- IMPORTANTE:
-- No elimines manualmente binary logs que puedan ser necesarios para recuperar
-- la base de datos. La retención debe configurarse y supervisarse.

-- ============================================================================
-- SECCIÓN 4: RESPALDOS SELECTIVOS
-- ============================================================================

-- Los siguientes comandos se ejecutan en la terminal.
-- Se recomienda exportar cada tabla por separado cuando el filtro WHERE
-- utiliza una columna que no existe en las demás tablas.
--
-- Ejemplo: ventas del último día:
--
-- mysqldump -u root -p --single-transaction veterinaria_db Venta \
--   --where="Fecha_Pago >= NOW() - INTERVAL 1 DAY" > respaldo_ventas.sql
--
-- Ejemplo: citas del último día:
--
-- mysqldump -u root -p --single-transaction veterinaria_db Cita \
--   --where="Fecha_Hora >= NOW() - INTERVAL 1 DAY" > respaldo_citas.sql
--
-- No aplicar el filtro Fecha_Pago a Detalle_Venta ni a Detalle_Prestacion,
-- salvo que esas tablas tengan realmente esa columna. Para respaldar detalles
-- relacionados se debe utilizar la clave foránea correspondiente y comprobar
-- el esquema real de la base de datos.

-- ============================================================================
-- SECCIÓN 5: RECUPERACIÓN DE DATOS
-- ============================================================================

-- Restaurar un respaldo SQL desde la terminal:
--
-- mysql -u root -p veterinaria_db < respaldo_cvtm.sql
--
-- Restaurar un respaldo comprimido:
--
-- gunzip -c respaldo_cvtm.sql.gz | mysql -u root -p veterinaria_db
--
-- Restaurar una tabla específica:
--
-- mysql -u root -p veterinaria_db < respaldo_ventas.sql
--
-- Para recuperar en una base temporal, primero crearla:
CREATE DATABASE IF NOT EXISTS test_recovery;

-- La restauración del archivo debe realizarse desde la terminal:
-- mysql -u root -p test_recovery < respaldo_cvtm.sql
--
-- Después de restaurar, verificar desde Workbench:
-- USE test_recovery;
-- SHOW TABLES;
-- SELECT COUNT(*) FROM Cliente;
-- SELECT COUNT(*) FROM Mascota;
--
-- Eliminar la base de prueba solamente cuando ya no sea necesaria:
-- DROP DATABASE test_recovery;

-- ============================================================================
-- SECCIÓN 6: RECUPERACIÓN A UN PUNTO EN EL TIEMPO (PITR)
-- ============================================================================

-- Requisitos:
-- 1. Tener un respaldo completo anterior al incidente.
-- 2. Tener disponibles todos los binary logs posteriores a ese respaldo.
-- 3. Restaurar primero el respaldo completo.
-- 4. Aplicar los binary logs hasta el instante deseado.
--
-- Ejemplo de aplicación de binary logs desde la terminal:
--
-- mysqlbinlog --start-datetime="2026-11-15 10:00:00" \
--              --stop-datetime="2026-11-15 14:30:00" \
--              /ruta/mysql-bin.000123 | mysql -u root -p veterinaria_db
--
-- Los nombres de archivo, fechas y rutas son ejemplos: deben reemplazarse
-- por los valores reales del servidor.

-- ============================================================================
-- SECCIÓN 7: MIGRACIONES
-- ============================================================================

-- Migración a otro servidor MySQL:
-- 1. En el servidor de origen, generar el respaldo:
--
-- mysqldump -u root -p --single-transaction --routines --triggers --events \
--   --master-data=2 veterinaria_db > migracion_cvtm.sql
--
-- 2. Copiar el archivo al servidor destino:
--
-- scp migracion_cvtm.sql usuario@servidor_destino:/tmp/
--
-- 3. En el servidor destino, crear la base:
--
-- CREATE DATABASE veterinaria_db;
--
-- 4. Restaurar desde la terminal del servidor destino:
--
-- mysql -u root -p veterinaria_db < /tmp/migracion_cvtm.sql
--
-- 5. Verificar:
--
-- SHOW TABLES FROM veterinaria_db;

-- Migraciones a MariaDB, PostgreSQL o SQL Server requieren revisar y adaptar
-- tipos de datos, funciones, procedimientos, triggers y sintaxis. No se debe
-- asumir compatibilidad total entre motores.

-- ============================================================================
-- SECCIÓN 8: VERIFICACIÓN DE RESPALDOS
-- ============================================================================

-- Revisar las tablas de la base:
SHOW TABLES FROM veterinaria_db;

-- Revisar el motor de almacenamiento (InnoDB permite --single-transaction):
SELECT TABLE_NAME, ENGINE
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'veterinaria_db'
ORDER BY TABLE_NAME;

-- Revisar el tamaño aproximado de las tablas:
SELECT
    TABLE_NAME,
    ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS Tamano_MB
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'veterinaria_db'
ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC;

-- La integridad real del respaldo se comprueba restaurándolo en una base
-- de pruebas y verificando sus tablas, registros, restricciones y rutinas.

-- ============================================================================
-- SECCIÓN 9: COMPRESIÓN Y ENCRIPTACIÓN
-- ============================================================================

-- Estos comandos se ejecutan en la terminal.
--
-- Compresión:
-- mysqldump -u root -p veterinaria_db | gzip > respaldo.sql.gz
--
-- Encriptación con GPG:
-- mysqldump -u root -p veterinaria_db | gzip | \
--   gpg --encrypt --recipient correo@ejemplo.com > respaldo.sql.gz.gpg
--
-- Desencriptación y restauración:
-- gpg --decrypt respaldo.sql.gz.gpg | gunzip | \
--   mysql -u root -p veterinaria_db
--
-- Protege las claves de cifrado y conserva una copia segura de ellas.
-- No almacenes contraseñas directamente en scripts compartidos.

-- ============================================================================
-- SECCIÓN 10: MONITOREO DE RESPALDOS
-- ============================================================================

CREATE TABLE IF NOT EXISTS Backup_Log (
    ID_Backup INT AUTO_INCREMENT PRIMARY KEY,
    Fecha_Hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Tipo VARCHAR(20) NOT NULL,
    Tablas_Afectadas VARCHAR(255),
    Tamano_Bytes BIGINT,
    Ubicacion VARCHAR(255) NOT NULL,
    Duracion_Segundos INT,
    Estado VARCHAR(20) NOT NULL,
    Mensaje_Error VARCHAR(500)
) ENGINE=InnoDB;

DROP PROCEDURE IF EXISTS registrar_respaldo;

DELIMITER $$

CREATE PROCEDURE registrar_respaldo(
    IN p_tipo VARCHAR(20),
    IN p_tablas VARCHAR(255),
    IN p_tamano BIGINT,
    IN p_ubicacion VARCHAR(255),
    IN p_duracion INT,
    IN p_estado VARCHAR(20),
    IN p_error VARCHAR(500)
)
BEGIN
    INSERT INTO Backup_Log (
        Tipo,
        Tablas_Afectadas,
        Tamano_Bytes,
        Ubicacion,
        Duracion_Segundos,
        Estado,
        Mensaje_Error
    )
    VALUES (
        p_tipo,
        p_tablas,
        p_tamano,
        p_ubicacion,
        p_duracion,
        p_estado,
        p_error
    );
END$$

DELIMITER ;

-- Ejemplo de registro:
CALL registrar_respaldo(
    'Completo',
    'Todas',
    104857600,
    '/backup/cvtm/respaldo.sql.gz',
    120,
    'Exitoso',
    NULL
);

-- Consultar los últimos 20 respaldos:
SELECT
    ID_Backup,
    Fecha_Hora,
    Tipo,
    Tablas_Afectadas,
    CONCAT(ROUND(Tamano_Bytes / 1024 / 1024, 2), ' MB') AS Tamano,
    Ubicacion,
    Duracion_Segundos,
    Estado,
    Mensaje_Error
FROM Backup_Log
ORDER BY Fecha_Hora DESC
LIMIT 20;

-- ============================================================================
-- SECCIÓN 11: RECUPERACIÓN ANTE DESASTRES
-- ============================================================================

-- Procedimiento recomendado:
-- 1. Identificar la causa de la falla.
-- 2. Determinar el alcance de la pérdida de datos.
-- 3. Seleccionar el respaldo adecuado.
-- 4. Restaurar primero en un entorno de pruebas.
-- 5. Verificar tablas, registros, relaciones y rutinas.
-- 6. Restaurar en producción cuando la prueba sea satisfactoria.
-- 7. Documentar el incidente y las acciones realizadas.

-- ============================================================================
-- SECCIÓN 12: PRUEBAS DE RECUPERACIÓN
-- ============================================================================

-- Crear una base de datos de prueba:
CREATE DATABASE IF NOT EXISTS test_cvtm_restore;

-- Restaurar el respaldo en esa base desde la terminal:
-- mysql -u root -p test_cvtm_restore < respaldo_cvtm.sql
--
-- Después, ejecutar estas verificaciones:
-- USE test_cvtm_restore;
-- SHOW TABLES;
-- SELECT COUNT(*) FROM Cliente;
-- SELECT COUNT(*) FROM Mascota;
-- SELECT COUNT(*) FROM Venta;
--
-- Revisar las restricciones:
SELECT
    CONSTRAINT_TYPE,
    COUNT(*) AS Cantidad
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'test_cvtm_restore'
GROUP BY CONSTRAINT_TYPE;

-- Eliminar la base de pruebas solo después de terminar la validación:
-- DROP DATABASE test_cvtm_restore;

-- ============================================================================
-- RESUMEN
-- ============================================================================

-- Buenas prácticas:
-- 1. Automatizar respaldos completos y conservar binary logs.
-- 2. Proteger los archivos mediante permisos y cifrado.
-- 3. Mantener copias en ubicaciones distintas.
-- 4. Verificar periódicamente la restauración.
-- 5. Documentar y probar el plan de recuperación.
--
-- FIN DEL ARCHIVO SQL
