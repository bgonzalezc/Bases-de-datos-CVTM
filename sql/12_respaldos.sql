-- CVTM | Respaldos, Recuperación y Migraciones | MySQL 8.0
-- Procedimientos para respaldo, recuperación y migración de datos

-- ============================================================================
-- SECCIÓN 1: POLÍTICAS DE RESPALDO
-- ============================================================================

-- Políticas recomendadas para el sistema CVTM:
-- 1. Respaldo completo semanal
-- 2. Respaldo incremental diario
-- 3. Respaldo de transacciones (binary log) cada hora
-- 4. Conservar respaldos por al menos 3 meses
-- 5. Almacenar respaldos en múltiples ubicaciones (local + cloud)
-- 6. Probar la recuperación periódicamente

-- ============================================================================
-- SECCIÓN 2: RESPALDO COMPLETO (FULL BACKUP)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Respaldo completo usando mysqldump (desde línea de comandos)
-- ----------------------------------------------------------------------------
-- Comando básico:
-- mysqldump -u [usuario] -p[contraseña] veterinaria_db > respaldo_cvtm_$(date +%Y%m%d_%H%M%S).sql

-- Comando recomendado (con compresión):
-- mysqldump -u root -p --single-transaction --routines --triggers --events
--   --add-drop-table --add-drop-trigger --add-drop-database
--   --skip-comments --quick --lock-tables=false
--   veterinaria_db | gzip > respaldo_cvtm_$(date +%Y%m%d_%H%M%S).sql.gz

-- Explicación de opciones:
-- --single-transaction: Crea una transacción para garantizar consistencia
-- --routines: Incluye procedimientos y funciones almacenados
-- --triggers: Incluye triggers
-- --events: Incluye eventos programados
-- --add-drop-table: Añade DROP TABLE antes de cada CREATE TABLE
-- --add-drop-trigger: Añade DROP TRIGGER antes de cada CREATE TRIGGER
-- --add-drop-database: Añade DROP DATABASE antes de CREATE DATABASE
-- --skip-comments: Omite comentarios para reducir tamaño
-- --quick: Recupera filas en lotes para reducir memoria
-- --lock-tables=false: No bloquea tablas (con --single-transaction)

-- ----------------------------------------------------------------------------
-- Respaldo completo de todas las bases de datos
-- ----------------------------------------------------------------------------
-- mysqldump -u root -p --all-databases > respaldo_completo_$(date +%Y%m%d_%H%M%S).sql

-- ----------------------------------------------------------------------------
-- Respaldo completo con información de usuarios y privilegios
-- ----------------------------------------------------------------------------
-- mysqldump -u root -p --single-transaction --routines --triggers
--   --events mysql user > respaldo_usuarios_$(date +%Y%m%d_%H%M%S).sql

-- ============================================================================
-- SECCIÓN 3: RESPALDO INCREMENTAL
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Respaldo incremental usando binary logs
-- ----------------------------------------------------------------------------
-- Primero, habilitar binary logging en my.cnf:
-- [mysqld]
-- log-bin = /var/log/mysql/mysql-bin.log
-- binlog_format = ROW
-- server-id = 1
-- expire_logs_days = 30

-- Ver el binary log actual:
SHOW MASTER STATUS;

-- Hacer flush de logs para crear un nuevo archivo:
FLUSH BINARY LOGS;

-- Ver todos los binary logs:
SHOW BINARY LOGS;

-- Respaldo de binary logs:
-- cp /var/log/mysql/mysql-bin.* /backup/binlogs/

-- Para restaurar desde un respaldo incremental:
-- mysqlbinlog /backup/binlogs/mysql-bin.000123 | mysql -u root -p

-- ----------------------------------------------------------------------------
-- Respaldo incremental usando mysqldump con --where
-- ----------------------------------------------------------------------------
-- Respaldo de ventas recientes (últimos 7 días)
-- mysqldump -u root -p veterinaria_db Venta Detalle_Venta Detalle_Prestacion
--   --where="Fecha_Pago >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)" > respaldo_ventas_recentes.sql

-- Respaldo de citas recientes (últimos 30 días)
-- mysqldump -u root -p veterinaria_db Cita Ficha_Medica
--   --where="Fecha_Hora >= DATE_SUB(NOW(), INTERVAL 30 DAY)" > respaldo_citas_recentes.sql

-- ============================================================================
-- SECCIÓN 4: RESPALDO DE ESQUEMAS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Respaldo solo del esquema (sin datos)
-- ----------------------------------------------------------------------------
-- mysqldump -u root -p --no-data veterinaria_db > respaldo_esquema_cvtm_$(date +%Y%m%d).sql

-- ----------------------------------------------------------------------------
-- Respaldo de datos sin esquema
-- ----------------------------------------------------------------------------
-- mysqldump -u root -p --no-create-info veterinaria_db > respaldo_datos_cvtm_$(date +%Y%m%d).sql

-- ============================================================================
-- SECCIÓN 5: RECUPERACIÓN DE DATOS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Recuperación de respaldo completo
-- ----------------------------------------------------------------------------
-- Desde archivo SQL:
-- mysql -u root -p veterinaria_db < respaldo_cvtm_20261115_143022.sql

-- Desde archivo comprimido:
-- gunzip < respaldo_cvtm_20261115_143022.sql.gz | mysql -u root -p veterinaria_db

-- ----------------------------------------------------------------------------
-- Recuperación selectiva de tablas
-- ----------------------------------------------------------------------------
-- Extraer solo algunas tablas del respaldo:
-- grep -E '^(CREATE TABLE|INSERT INTO) (Cliente|Mascota|Cita)' respaldo_cvtm.sql > respaldo_parcial.sql
-- mysql -u root -p veterinaria_db < respaldo_parcial.sql

-- O usando mysqldump:
-- mysqldump -u root -p veterinaria_db Cliente Mascota Cita > respaldo_parcial.sql

-- ----------------------------------------------------------------------------
-- Recuperación a un punto en el tiempo (Point-In-Time Recovery)
-- ----------------------------------------------------------------------------
-- 1. Restaurar el respaldo completo más reciente
-- mysql -u root -p veterinaria_db < respaldo_cvtm_completo.sql

-- 2. Aplicar los binary logs hasta el punto deseado
-- mysqlbinlog --start-datetime="2026-11-15 10:00:00"
--             --stop-datetime="2026-11-15 14:30:00"
--             /backup/binlogs/mysql-bin.000123 | mysql -u root -p

-- ----------------------------------------------------------------------------
-- Recuperación de datos eliminados accidentalmente
-- ----------------------------------------------------------------------------
-- Si se eliminaron datos y tenemos un respaldo reciente:
-- 1. Crear una base de datos temporal
-- CREATE DATABASE temp_recovery;

-- 2. Restaurar el respaldo en la base temporal
-- mysql -u root -p temp_recovery < respaldo_cvtm.sql

-- 3. Extraer los datos eliminados
-- SELECT * FROM temp_recovery.Cliente WHERE Rut_Cliente NOT IN
--   (SELECT Rut_Cliente FROM veterinaria_db.Cliente);

-- 4. Insertar los datos de vuelta
-- INSERT INTO veterinaria_db.Cliente
-- SELECT * FROM temp_recovery.Cliente WHERE Rut_Cliente NOT IN
--   (SELECT Rut_Cliente FROM veterinaria_db.Cliente);

-- 5. Eliminar la base temporal
-- DROP DATABASE temp_recovery;

-- ============================================================================
-- SECCIÓN 6: AUTOMATIZACIÓN DE RESPALDOS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Script Bash para respaldos automáticos
-- ----------------------------------------------------------------------------
-- Crear archivo: /usr/local/bin/backup_cvtm.sh
"""
#!/bin/bash

# Configuración
USER="root"
PASS="tu_contraseña"
DB="veterinaria_db"
BACKUP_DIR="/backup/cvtm"
DATE=$(date +%Y%m%d_%H%M%S)

# Crear directorio de respaldo
mkdir -p $BACKUP_DIR

# Respaldo completo semanal (domingos)
if [ $(date +%u) -eq 7 ]; then
    echo "Iniciando respaldo completo..."
    mysqldump -u $USER -p$PASS --single-transaction --routines --triggers --events \
        --add-drop-table --add-drop-trigger --skip-comments --quick \
        $DB | gzip > $BACKUP_DIR/respaldo_completo_${DATE}.sql.gz
    echo "Respaldo completo finalizado: $BACKUP_DIR/respaldo_completo_${DATE}.sql.gz"
fi

# Respaldo incremental diario
echo "Iniciando respaldo incremental..."
mysqldump -u $USER -p$PASS --single-transaction --routines --triggers \
    --where="Fecha_Pago >= DATE_SUB(CURDATE(), INTERVAL 1 DAY)" \
    $DB Venta Detalle_Venta Detalle_Prestacion | gzip > $BACKUP_DIR/respaldo_ventas_${DATE}.sql.gz

mysqldump -u $USER -p$PASS --single-transaction --routines --triggers \
    --where="Fecha_Hora >= DATE_SUB(NOW(), INTERVAL 1 DAY)" \
    $DB Cita Ficha_Medica | gzip > $BACKUP_DIR/respaldo_citas_${DATE}.sql.gz

echo "Respaldo incremental finalizado"

# Respaldo de binary logs
cp /var/log/mysql/mysql-bin.* $BACKUP_DIR/binlogs/

# Eliminar respaldos antiguos (más de 90 días)
find $BACKUP_DIR -name "respaldo_*.sql.gz" -mtime +90 -delete

# Verificar espacio en disco
echo "Espacio en disco:"
df -h $BACKUP_DIR
"""

-- Hacer el script ejecutable:
-- chmod +x /usr/local/bin/backup_cvtm.sh

-- Programar en cron (ejecutar diariamente a las 2 AM):
-- 0 2 * * * /usr/local/bin/backup_cvtm.sh

-- ============================================================================
-- SECCIÓN 7: MIGRACIONES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Migración a otro servidor MySQL
-- ----------------------------------------------------------------------------
-- 1. Hacer respaldo completo en el servidor origen:
-- mysqldump -u root -p --single-transaction --routines --triggers --events
--   --master-data=2 veterinaria_db > migracion_cvtm.sql

-- 2. Copiar el archivo al servidor destino:
-- scp migracion_cvtm.sql usuario@servidor_destino:/tmp/

-- 3. Crear la base de datos en el servidor destino:
-- mysql -u root -p -e "CREATE DATABASE veterinaria_db;"

-- 4. Restaurar el respaldo en el servidor destino:
-- mysql -u root -p veterinaria_db < /tmp/migracion_cvtm.sql

-- 5. Verificar la migración:
-- mysql -u root -p -e "SHOW TABLES FROM veterinaria_db;"

-- ----------------------------------------------------------------------------
-- Migración a MariaDB
-- ----------------------------------------------------------------------------
-- El proceso es similar a MySQL, ya que MariaDB es compatible
-- Sin embargo, puede ser necesario ajustar algunas sintaxis:
-- 1. Reemplazar ENGINE=InnoDB por ENGINE=InnoDB (generalmente compatible)
-- 2. Revisar triggers y procedimientos almacenados
-- 3. Verificar funciones específicas de MySQL

-- ----------------------------------------------------------------------------
-- Migración a PostgreSQL
-- ----------------------------------------------------------------------------
-- Para migrar a PostgreSQL, se puede usar herramientas como:
-- 1. pgloader: https://github.com/dimitri/pgloader
-- 2. MySQL Workbench (exportar a CSV e importar en PostgreSQL)
-- 3. Scripts personalizados

-- Ejemplo con pgloader:
-- pgloader mysql://user:password@mysql-server/veterinaria_db postgresql://user:password@pg-server/veterinaria_db

-- ----------------------------------------------------------------------------
-- Migración a SQL Server
-- ----------------------------------------------------------------------------
-- Usar herramientas como:
-- 1. SQL Server Migration Assistant (SSMA) for MySQL
-- 2. Exportar a CSV e importar en SQL Server
-- 3. Usar ODBC para conexión directa

-- ============================================================================
-- SECCIÓN 8: VERIFICACIÓN DE RESPALDOS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Verificar integridad del respaldo
-- ----------------------------------------------------------------------------
-- 1. Verificar que el archivo SQL es válido:
-- head -n 20 respaldo_cvtm.sql
-- tail -n 20 respaldo_cvtm.sql

-- 2. Verificar que el archivo no está corrupto:
-- mysql -u root -p --check respaldo_cvtm.sql

-- 3. Probar la restauración en un entorno de prueba:
-- CREATE DATABASE test_restore;
-- mysql -u root -p test_restore < respaldo_cvtm.sql
-- SELECT COUNT(*) FROM test_restore.Cliente;
-- SELECT COUNT(*) FROM test_restore.Mascota;
-- DROP DATABASE test_restore;

-- ----------------------------------------------------------------------------
-- Verificar tamaño del respaldo
-- ----------------------------------------------------------------------------
-- ls -lh respaldo_cvtm.sql
-- du -sh /backup/cvtm/

-- ----------------------------------------------------------------------------
-- Verificar fecha del respaldo
-- ----------------------------------------------------------------------------
-- stat respaldo_cvtm.sql
-- ls -lt /backup/cvtm/

-- ============================================================================
-- SECCIÓN 9: COMPRESIÓN Y ENCRIPTACIÓN
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Compresión de respaldos
-- ----------------------------------------------------------------------------
-- Usando gzip (Linux/Mac):
-- mysqldump ... | gzip > respaldo.sql.gz

-- Usando 7z (Windows/Linux):
-- mysqldump ... | 7z a -si respaldo.7z

-- Usando pigz (compresión paralela):
-- mysqldump ... | pigz -9 > respaldo.sql.gz

-- ----------------------------------------------------------------------------
-- Encriptación de respaldos
-- ----------------------------------------------------------------------------
-- Usando GPG:
-- mysqldump ... | gzip | gpg --encrypt --recipient nombre@email.com > respaldo.sql.gz.gpg

-- Usando OpenSSL:
-- mysqldump ... | gzip | openssl enc -aes-256-cbc -salt -out respaldo.sql.gz.enc

-- Desencriptar:
-- gpg --decrypt respaldo.sql.gz.gpg | gunzip | mysql -u root -p veterinaria_db
-- openssl enc -d -aes-256-cbc -in respaldo.sql.gz.enc | gunzip | mysql -u root -p veterinaria_db

-- ----------------------------------------------------------------------------
-- Respaldo en la nube
-- ----------------------------------------------------------------------------
-- Usando AWS S3:
-- aws s3 cp respaldo_cvtm.sql.gz s3://mi-bucket/respaldos/cvtm/

-- Usando Google Cloud Storage:
-- gsutil cp respaldo_cvtm.sql.gz gs://mi-bucket/respaldos/cvtm/

-- Usando Azure Blob Storage:
-- az storage blob upload --account-name miaccount --container respaldos --file respaldo_cvtm.sql.gz --name cvtm/respaldo_$(date +%Y%m%d).sql.gz

-- ============================================================================
-- SECCIÓN 10: MONITOREO DE RESPALDOS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Registrar respaldos en una tabla de auditoría
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Backup_Log (
    ID_Backup INT AUTO_INCREMENT PRIMARY KEY,
    Fecha_Hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Tipo VARCHAR(20) NOT NULL, -- 'Completo', 'Incremental', 'Esquema', 'Datos'
    Tablas_Afectadas VARCHAR(255),
    Tamaño_Bytes BIGINT,
    Ubicacion VARCHAR(255) NOT NULL,
    Duracion_Segundos INT,
    Estado VARCHAR(20) NOT NULL, -- 'Exitoso', 'Fallido'
    Mensaje_Error VARCHAR(500)
);

-- Procedimiento para registrar un respaldo
DELIMITER //
CREATE PROCEDURE registrar_respaldo(
    IN p_tipo VARCHAR(20),
    IN p_tablas VARCHAR(255),
    IN p_tamaño BIGINT,
    IN p_ubicacion VARCHAR(255),
    IN p_duracion INT,
    IN p_estado VARCHAR(20),
    IN p_error VARCHAR(500)
)
BEGIN
    INSERT INTO Backup_Log (
        Fecha_Hora, Tipo, Tablas_Afectadas, Tamaño_Bytes,
        Ubicacion, Duracion_Segundos, Estado, Mensaje_Error
    ) VALUES (
        NOW(), p_tipo, p_tablas, p_tamaño, p_ubicacion,
        p_duracion, p_estado, p_error
    );
END //
DELIMITER ;

-- Ejemplo de uso:
-- CALL registrar_respaldo('Completo', 'Todas', 104857600, '/backup/cvtm/respaldo.sql.gz', 120, 'Exitoso', NULL);

-- Consulta para ver el historial de respaldos
SELECT
    ID_Backup,
    Fecha_Hora,
    Tipo,
    Tablas_Afectadas,
    CONCAT(ROUND(Tamaño_Bytes / 1024 / 1024, 2), ' MB') AS Tamaño,
    Ubicacion,
    Duracion_Segundos,
    Estado,
    Mensaje_Error
FROM Backup_Log
ORDER BY Fecha_Hora DESC
LIMIT 20;

-- ============================================================================
-- SECCIÓN 11: RECUPERACIÓN DE DESASTRES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Plan de recuperación de desastres
-- ----------------------------------------------------------------------------
-- 1. Identificar el tipo de falla:
--    - Fallo de hardware
--    - Error humano (eliminación accidental)
--    - Ataque de malware/ransomware
--    - Corrupción de datos

-- 2. Evaluar el impacto:
--    - ¿Cuántos datos se perdieron?
--    - ¿Cuánto tiempo de inactividad es aceptable?

-- 3. Seleccionar el método de recuperación:
--    - Restaurar desde respaldo completo
--    - Restaurar desde respaldo incremental
--    - Usar réplicas (si están configuradas)

-- 4. Ejecutar la recuperación:
--    - Restaurar en un entorno de prueba primero
--    - Verificar la integridad de los datos
--    - Restaurar en producción

-- 5. Comunicar:
--    - Notificar a los usuarios sobre el tiempo de inactividad
--    - Proporcionar estimaciones de recuperación

-- 6. Post-recuperación:
--    - Verificar que todas las aplicaciones funcionen correctamente
--    - Monitorear el rendimiento
--    - Documentar el incidente y las acciones tomadas

-- ----------------------------------------------------------------------------
-- Configuración de réplicas para alta disponibilidad
-- ----------------------------------------------------------------------------
-- En el servidor maestro (my.cnf):
-- [mysqld]
-- server-id = 1
-- log-bin = /var/log/mysql/mysql-bin.log
-- binlog_format = ROW
-- bind-address = 0.0.0.0

-- En el servidor esclavo (my.cnf):
-- [mysqld]
-- server-id = 2
-- relay-log = /var/log/mysql/mysql-relay-bin.log

-- Configurar la replicación:
-- En el maestro:
-- CREATE USER 'replica_user'@'%' IDENTIFIED BY 'Replica2024!';
-- GRANT REPLICATION SLAVE ON *.* TO 'replica_user'@'%';
-- FLUSH PRIVILEGES;
-- SHOW MASTER STATUS; -- Anotar File y Position

-- En el esclavo:
-- CHANGE MASTER TO
--   MASTER_HOST='maestro_ip',
--   MASTER_USER='replica_user',
--   MASTER_PASSWORD='Replica2024!',
--   MASTER_LOG_FILE='mysql-bin.000001',
--   MASTER_LOG_POS=1234;
-- START SLAVE;
-- SHOW SLAVE STATUS\G

-- ============================================================================
-- SECCIÓN 12: PRUEBAS DE RECUPERACIÓN
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Prueba 1: Recuperación de respaldo completo
-- ----------------------------------------------------------------------------
-- 1. Crear una base de datos de prueba:
-- CREATE DATABASE test_recovery;

-- 2. Restaurar el respaldo:
-- mysql -u root -p test_recovery < respaldo_cvtm.sql

-- 3. Verificar que todas las tablas existen:
-- SHOW TABLES FROM test_recovery;

-- 4. Verificar que los datos son correctos:
-- SELECT COUNT(*) FROM test_recovery.Cliente;
-- SELECT COUNT(*) FROM test_recovery.Mascota;
-- SELECT COUNT(*) FROM test_recovery.Venta;

-- 5. Verificar restricciones:
-- SELECT CONSTRAINT_TYPE, COUNT(*)
-- FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
-- WHERE TABLE_SCHEMA = 'test_recovery'
-- GROUP BY CONSTRAINT_TYPE;

-- 6. Limpiar:
-- DROP DATABASE test_recovery;

-- ----------------------------------------------------------------------------
-- Prueba 2: Recuperación de datos eliminados
-- ----------------------------------------------------------------------------
-- 1. Eliminar algunos datos de prueba:
-- DELETE FROM veterinaria_db.Cliente WHERE Rut_Cliente = '15.420.311-8';

-- 2. Restaurar desde respaldo:
-- mysql -u root -p veterinaria_db < respaldo_cvtm.sql

-- 3. Verificar que los datos están de vuelta:
-- SELECT * FROM veterinaria_db.Cliente WHERE Rut_Cliente = '15.420.311-8';

-- ----------------------------------------------------------------------------
-- Prueba 3: Recuperación a un punto en el tiempo
-- ----------------------------------------------------------------------------
-- 1. Simular un error a una hora específica:
-- INSERT INTO veterinaria_db.Venta (Fecha_Pago, Monto_Venta, Forma_Pago, Rut_Cajero)
-- VALUES ('2026-11-15 14:30:00', 100000, 'Error', '19.876.543-1');

-- 2. Restaurar hasta antes del error:
-- mysql -u root -p veterinaria_db < respaldo_cvtm_completo.sql
-- mysqlbinlog --stop-datetime="2026-11-15 14:29:59" /var/log/mysql/mysql-bin.000123 | mysql -u root -p veterinaria_db

-- 3. Verificar que el registro erróneo no existe:
-- SELECT * FROM veterinaria_db.Venta WHERE Forma_Pago = 'Error';

-- ============================================================================
-- RESUMEN
-- ============================================================================

-- Las políticas de respaldo y recuperación son fundamentales para:
-- 1. Proteger los datos contra pérdidas
-- 2. Minimizar el tiempo de inactividad
-- 3. Cumplir con requisitos legales y de auditoría
-- 4. Garantizar la continuidad del negocio

-- Recomendaciones finales:
-- 1. Automatizar los respaldos
-- 2. Probar regularmente la recuperación
-- 3. Almacenar respaldos en múltiples ubicaciones
-- 4. Documentar todos los procedimientos
-- 5. Capacitar al personal en procedimientos de recuperación
-- 6. Monitorear el espacio de almacenamiento
-- 7. Verificar la integridad de los respaldos
-- 8. Mantener un plan de recuperación de desastres actualizado
