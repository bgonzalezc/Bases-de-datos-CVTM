-- Verificar si existe el índice y eliminarlo
SET @db = DATABASE();
SET @tbl = 'Cita';
SET @idx = 'idx_cita_veterinario_fecha';

-- Contar si existe
SELECT COUNT(*) INTO @exists
FROM information_schema.statistics
WHERE table_schema = @db
  AND table_name = @tbl
  AND index_name = @idx;

-- Si existe, eliminarlo
SET @sql = IF(@exists > 0,
    CONCAT('ALTER TABLE ', @tbl, ' DROP INDEX ', @idx),
    'SELECT "Índice no existe, se omitirá DROP" AS mensaje');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Crear el índice
CREATE INDEX idx_cita_veterinario_fecha ON Cita (Rut_Veterinario, Fecha_Hora);
