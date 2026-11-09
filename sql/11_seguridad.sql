-- CVTM | Seguridad: Roles, Privilegios y Mínimo Privilegio | MySQL 8.0
-- Implementación de seguridad según el principio de mínimo privilegio

-- ============================================================================
-- SECCIÓN 1: CREACIÓN DE USUARIOS
-- ============================================================================

-- Nota: En MySQL 8.0, los roles son objetos de primera clase
-- Pero primero necesitamos crear los usuarios

-- ----------------------------------------------------------------------------
-- Crear usuarios para cada rol del sistema CVTM
-- ----------------------------------------------------------------------------

-- 1. Usuario Administrador (acceso completo)
CREATE USER IF NOT EXISTS 'admin_cvtm'@'localhost' IDENTIFIED BY 'AdminCVTM2024!';

-- 2. Usuario Veterinario (acceso a información médica)
CREATE USER IF NOT EXISTS 'vet_cvtm'@'localhost' IDENTIFIED BY 'VetCVTM2024!';

-- 3. Usuario Cajero (acceso a ventas)
CREATE USER IF NOT EXISTS 'cajero_cvtm'@'localhost' IDENTIFIED BY 'CajeroCVTM2024!';

-- 4. Usuario Recepcionista (acceso a citas y clientes)
CREATE USER IF NOT EXISTS 'recepcion_cvtm'@'localhost' IDENTIFIED BY 'RecepcionCVTM2024!';

-- 5. Usuario Inventario (acceso a productos y proveedores)
CREATE USER IF NOT EXISTS 'inventario_cvtm'@'localhost' IDENTIFIED BY 'InventarioCVTM2024!';

-- 6. Usuario Reportes (solo lectura para reportes)
CREATE USER IF NOT EXISTS 'reportes_cvtm'@'localhost' IDENTIFIED BY 'ReportesCVTM2024!';

-- 7. Usuario SuperTienda (para integración con SuperTienda)
CREATE USER IF NOT EXISTS 'supertienda_cvtm'@'%' IDENTIFIED BY 'SuperTienda2024!';

-- ============================================================================
-- SECCIÓN 2: CREACIÓN DE ROLES
-- ============================================================================

-- MySQL 8.0 soporta roles nativamente

-- ----------------------------------------------------------------------------
-- Rol: Administrador (todos los privilegios)
-- ----------------------------------------------------------------------------
CREATE ROLE IF NOT EXISTS 'rol_admin';

-- ----------------------------------------------------------------------------
-- Rol: Veterinario (acceso a información médica)
-- ----------------------------------------------------------------------------
CREATE ROLE IF NOT EXISTS 'rol_veterinario';

-- ----------------------------------------------------------------------------
-- Rol: Cajero (acceso a ventas)
-- ----------------------------------------------------------------------------
CREATE ROLE IF NOT EXISTS 'rol_cajero';

-- ----------------------------------------------------------------------------
-- Rol: Recepcionista (acceso a citas y clientes)
-- ----------------------------------------------------------------------------
CREATE ROLE IF NOT EXISTS 'rol_recepcionista';

-- ----------------------------------------------------------------------------
-- Rol: Inventario (acceso a productos y proveedores)
-- ----------------------------------------------------------------------------
CREATE ROLE IF NOT EXISTS 'rol_inventario';

-- ----------------------------------------------------------------------------
-- Rol: Reportes (solo lectura)
-- ----------------------------------------------------------------------------
CREATE ROLE IF NOT EXISTS 'rol_reportes';

-- ----------------------------------------------------------------------------
-- Rol: SuperTienda (acceso limitado para integración)
-- ----------------------------------------------------------------------------
CREATE ROLE IF NOT EXISTS 'rol_supertienda';

-- ============================================================================
-- SECCIÓN 3: ASIGNACIÓN DE PRIVILEGIOS A ROLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Privilegios para rol_admin (todos los privilegios)
-- ----------------------------------------------------------------------------
GRANT ALL PRIVILEGES ON veterinaria_db.* TO 'rol_admin';

-- También conceder privilegios administrativos
GRANT CREATE USER, PROCESS, RELOAD ON *.* TO 'rol_admin';

-- ----------------------------------------------------------------------------
-- Privilegios para rol_veterinario
-- ----------------------------------------------------------------------------
-- Acceso de lectura y escritura a tablas médicas
GRANT SELECT, INSERT, UPDATE ON veterinaria_db.Ficha_Medica TO 'rol_veterinario';
GRANT SELECT, UPDATE ON veterinaria_db.Cita TO 'rol_veterinario';

-- Acceso de lectura a tablas relacionadas
GRANT SELECT ON veterinaria_db.Mascota TO 'rol_veterinario';
GRANT SELECT ON veterinaria_db.Cliente TO 'rol_veterinario';
GRANT SELECT ON veterinaria_db.Veterinario TO 'rol_veterinario';
GRANT SELECT ON veterinaria_db.Prestacion TO 'rol_veterinario';

-- Acceso de lectura a vistas
GRANT SELECT ON veterinaria_db.vw_citas_completas TO 'rol_veterinario';
GRANT SELECT ON veterinaria_db.vw_fichas_medicas_completas TO 'rol_veterinario';

-- ----------------------------------------------------------------------------
-- Privilegios para rol_cajero
-- ----------------------------------------------------------------------------
-- Acceso completo a ventas
GRANT SELECT, INSERT, UPDATE ON veterinaria_db.Venta TO 'rol_cajero';
GRANT SELECT, INSERT, UPDATE ON veterinaria_db.Detalle_Venta TO 'rol_cajero';
GRANT SELECT, INSERT, UPDATE ON veterinaria_db.Detalle_Prestacion TO 'rol_cajero';

-- Acceso de lectura a productos y prestaciones
GRANT SELECT ON veterinaria_db.Producto TO 'rol_cajero';
GRANT SELECT ON veterinaria_db.Prestacion TO 'rol_cajero';

-- Acceso de lectura a clientes
GRANT SELECT ON veterinaria_db.Cliente TO 'rol_cajero';

-- Acceso de lectura a cajeros
GRANT SELECT ON veterinaria_db.Cajero TO 'rol_cajero';

-- Acceso de lectura a vistas
GRANT SELECT ON veterinaria_db.vw_ventas_detalladas TO 'rol_cajero';
GRANT SELECT ON veterinaria_db.vw_inventario_valorado TO 'rol_cajero';

-- ----------------------------------------------------------------------------
-- Privilegios para rol_recepcionista
-- ----------------------------------------------------------------------------
-- Acceso completo a citas
GRANT SELECT, INSERT, UPDATE, DELETE ON veterinaria_db.Cita TO 'rol_recepcionista';

-- Acceso completo a clientes y mascotas
GRANT SELECT, INSERT, UPDATE ON veterinaria_db.Cliente TO 'rol_recepcionista';
GRANT SELECT, INSERT, UPDATE ON veterinaria_db.Mascota TO 'rol_recepcionista';

-- Acceso al historial de responsables
GRANT SELECT, INSERT, UPDATE ON veterinaria_db.Historial_Responsable TO 'rol_recepcionista';

-- Acceso de lectura a veterinarios
GRANT SELECT ON veterinaria_db.Veterinario TO 'rol_recepcionista';

-- Acceso de lectura a vistas
GRANT SELECT ON veterinaria_db.vw_citas_completas TO 'rol_recepcionista';

-- ----------------------------------------------------------------------------
-- Privilegios para rol_inventario
-- ----------------------------------------------------------------------------
-- Acceso completo a productos y proveedores
GRANT SELECT, INSERT, UPDATE, DELETE ON veterinaria_db.Producto TO 'rol_inventario';
GRANT SELECT, INSERT, UPDATE, DELETE ON veterinaria_db.Proveedor TO 'rol_inventario';

-- Acceso completo a inventario
GRANT SELECT, INSERT, UPDATE, DELETE ON veterinaria_db.Inventario TO 'rol_inventario';

-- Acceso de lectura a ventas (para verificar movimientos)
GRANT SELECT ON veterinaria_db.Venta TO 'rol_inventario';
GRANT SELECT ON veterinaria_db.Detalle_Venta TO 'rol_inventario';

-- Acceso de lectura a vistas
GRANT SELECT ON veterinaria_db.vw_inventario_valorado TO 'rol_inventario';

-- ----------------------------------------------------------------------------
-- Privilegios para rol_reportes
-- ----------------------------------------------------------------------------
-- Solo acceso de lectura a todas las tablas
GRANT SELECT ON veterinaria_db.* TO 'rol_reportes';

-- Acceso a vistas
GRANT SELECT ON veterinaria_db.vw_citas_completas TO 'rol_reportes';
GRANT SELECT ON veterinaria_db.vw_ventas_detalladas TO 'rol_reportes';
GRANT SELECT ON veterinaria_db.vw_fichas_medicas_completas TO 'rol_reportes';
GRANT SELECT ON veterinaria_db.vw_inventario_valorado TO 'rol_reportes';
GRANT SELECT ON veterinaria_db.vw_historial_responsables TO 'rol_reportes';

-- ----------------------------------------------------------------------------
-- Privilegios para rol_supertienda
-- ----------------------------------------------------------------------------
-- Solo acceso de lectura a productos (para integración)
GRANT SELECT ON veterinaria_db.Producto TO 'rol_supertienda';

-- Acceso de lectura a proveedores
GRANT SELECT ON veterinaria_db.Proveedor TO 'rol_supertienda';

-- Acceso de lectura a ventas (solo para sincronización)
GRANT SELECT ON veterinaria_db.Venta TO 'rol_supertienda';
GRANT SELECT ON veterinaria_db.Detalle_Venta TO 'rol_supertienda';

-- ============================================================================
-- SECCIÓN 4: ASIGNACIÓN DE ROLES A USUARIOS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Asignar rol_admin a admin_cvtm
-- ----------------------------------------------------------------------------
GRANT 'rol_admin' TO 'admin_cvtm'@'localhost';

-- ----------------------------------------------------------------------------
-- Asignar rol_veterinario a vet_cvtm
-- ----------------------------------------------------------------------------
GRANT 'rol_veterinario' TO 'vet_cvtm'@'localhost';

-- ----------------------------------------------------------------------------
-- Asignar rol_cajero a cajero_cvtm
-- ----------------------------------------------------------------------------
GRANT 'rol_cajero' TO 'cajero_cvtm'@'localhost';

-- ----------------------------------------------------------------------------
-- Asignar rol_recepcionista a recepcion_cvtm
-- ----------------------------------------------------------------------------
GRANT 'rol_recepcionista' TO 'recepcion_cvtm'@'localhost';

-- ----------------------------------------------------------------------------
-- Asignar rol_inventario a inventario_cvtm
-- ----------------------------------------------------------------------------
GRANT 'rol_inventario' TO 'inventario_cvtm'@'localhost';

-- ----------------------------------------------------------------------------
-- Asignar rol_reportes a reportes_cvtm
-- ----------------------------------------------------------------------------
GRANT 'rol_reportes' TO 'reportes_cvtm'@'localhost';

-- ----------------------------------------------------------------------------
-- Asignar rol_supertienda a supertienda_cvtm
-- ----------------------------------------------------------------------------
GRANT 'rol_supertienda' TO 'supertienda_cvtm'@'%';

-- ============================================================================
-- SECCIÓN 5: PRIVILEGIOS DIRECTOS (sin roles)
-- ============================================================================

-- Algunos privilegios específicos que no se asignaron mediante roles

-- Permitir que los veterinarios actualicen su propia información
GRANT UPDATE ON veterinaria_db.Veterinario TO 'vet_cvtm'@'localhost';

-- Permitir que los cajeros actualicen su propia información
GRANT UPDATE ON veterinaria_db.Cajero TO 'cajero_cvtm'@'localhost';

-- ============================================================================
-- SECCIÓN 6: VERIFICACIÓN DE PRIVILEGIOS
-- ============================================================================

-- Ver todos los roles
SHOW ROLES;

-- Ver privilegios de un rol específico
SHOW GRANTS FOR 'rol_admin';
SHOW GRANTS FOR 'rol_veterinario';
SHOW GRANTS FOR 'rol_cajero';
SHOW GRANTS FOR 'rol_recepcionista';
SHOW GRANTS FOR 'rol_inventario';
SHOW GRANTS FOR 'rol_reportes';
SHOW GRANTS FOR 'rol_supertienda';

-- Ver privilegios de un usuario
SHOW GRANTS FOR 'admin_cvtm'@'localhost';
SHOW GRANTS FOR 'vet_cvtm'@'localhost';
SHOW GRANTS FOR 'cajero_cvtm'@'localhost';
SHOW GRANTS FOR 'recepcion_cvtm'@'localhost';
SHOW GRANTS FOR 'inventario_cvtm'@'localhost';
SHOW GRANTS FOR 'reportes_cvtm'@'localhost';
SHOW GRANTS FOR 'supertienda_cvtm'@'%';

-- Ver roles asignados a un usuario
SELECT * FROM mysql.role_edges WHERE USER = 'vet_cvtm' AND HOST = 'localhost';

-- ============================================================================
-- SECCIÓN 7: PRUEBAS DE SEGURIDAD
-- ============================================================================

-- Para probar la seguridad, conectarse como cada usuario y verificar:

-- 1. admin_cvtm: Debe poder hacer todo
-- mysql -u admin_cvtm -p
-- SHOW TABLES;
-- SELECT * FROM Cliente;
-- INSERT INTO Cliente VALUES (...);

-- 2. vet_cvtm: Solo debe poder acceder a información médica
-- mysql -u vet_cvtm -p
-- SELECT * FROM Ficha_Medica; -- ✓ Debe funcionar
-- SELECT * FROM Venta; -- ✗ Debe fallar (no tiene permiso)

-- 3. cajero_cvtm: Solo debe poder acceder a ventas
-- mysql -u cajero_cvtm -p
-- SELECT * FROM Venta; -- ✓ Debe funcionar
-- INSERT INTO Venta VALUES (...); -- ✓ Debe funcionar
-- SELECT * FROM Cita; -- ✗ Debe fallar

-- 4. recepcion_cvtm: Solo debe poder acceder a citas y clientes
-- mysql -u recepcion_cvtm -p
-- SELECT * FROM Cita; -- ✓ Debe funcionar
-- SELECT * FROM Cliente; -- ✓ Debe funcionar
-- SELECT * FROM Ficha_Medica; -- ✗ Debe fallar

-- 5. inventario_cvtm: Solo debe poder acceder a productos e inventario
-- mysql -u inventario_cvtm -p
-- SELECT * FROM Producto; -- ✓ Debe funcionar
-- SELECT * FROM Inventario; -- ✓ Debe funcionar
-- SELECT * FROM Venta; -- ✓ Debe funcionar (solo lectura)
-- INSERT INTO Venta VALUES (...); -- ✗ Debe fallar

-- 6. reportes_cvtm: Solo lectura en todas las tablas
-- mysql -u reportes_cvtm -p
-- SELECT * FROM Cliente; -- ✓ Debe funcionar
-- INSERT INTO Cliente VALUES (...); -- ✗ Debe fallar

-- 7. supertienda_cvtm: Solo acceso limitado
-- mysql -u supertienda_cvtm -p -h [servidor]
-- SELECT * FROM Producto; -- ✓ Debe funcionar
-- SELECT * FROM Cliente; -- ✗ Debe fallar

-- ============================================================================
-- SECCIÓN 8: PRINCIPIO DE MÍNIMO PRIVILEGIO
-- ============================================================================

-- El principio de mínimo privilegio establece que:
-- "Cada usuario debe tener solo los privilegios necesarios para realizar su trabajo"

-- En nuestro diseño:
-- 1. admin_cvtm: Tiene todos los privilegios (necesario para administración)
-- 2. vet_cvtm: Solo tiene acceso a información médica (su área de trabajo)
-- 3. cajero_cvtm: Solo tiene acceso a ventas (su área de trabajo)
-- 4. recepcion_cvtm: Solo tiene acceso a citas y clientes (su área de trabajo)
-- 5. inventario_cvtm: Solo tiene acceso a productos e inventario (su área de trabajo)
-- 6. reportes_cvtm: Solo tiene acceso de lectura (para generar reportes)
-- 7. supertienda_cvtm: Solo tiene acceso limitado para integración

-- Esto garantiza que:
-- - Los usuarios no pueden acceder a información que no necesitan
-- - Los errores de los usuarios no pueden afectar otros componentes
-- - Las violaciones de seguridad tienen un impacto limitado

-- ============================================================================
-- SECCIÓN 9: GESTIÓN DE CONTRASEÑAS
-- ============================================================================

-- Cambiar contraseña de un usuario
ALTER USER 'vet_cvtm'@'localhost' IDENTIFIED BY 'NuevaContraseña2024!';

-- Forzar cambio de contraseña en el próximo inicio de sesión
ALTER USER 'vet_cvtm'@'localhost' PASSWORD EXPIRE;

-- Bloquear un usuario
ALTER USER 'vet_cvtm'@'localhost' ACCOUNT LOCK;

-- Desbloquear un usuario
ALTER USER 'vet_cvtm'@'localhost' ACCOUNT UNLOCK;

-- Eliminar un usuario
DROP USER IF EXISTS 'vet_cvtm'@'localhost';

-- ============================================================================
-- SECCIÓN 10: AUDITORÍA DE SEGURIDAD
-- ============================================================================

-- Ver intentos de conexión fallidos
SELECT * FROM mysql.general_log
WHERE command_type = 'Connect' AND return_code != 0;

-- Ver consultas ejecutadas por un usuario
SELECT * FROM mysql.general_log
WHERE user_host LIKE '%vet_cvtm%';

-- Habilitar logging de consultas (en my.cnf o my.ini)
-- [mysqld]
-- general_log = 1
-- general_log_file = /var/log/mysql/mysql-query.log

-- ============================================================================
-- SECCIÓN 11: SEGURIDAD DE LA BASE DE DATOS
-- ============================================================================

-- 1. Usar contraseñas fuertes
-- 2. No usar el usuario root para aplicaciones
-- 3. Limitar los privilegios según el principio de mínimo privilegio
-- 4. Usar conexiones cifradas (SSL)
-- 5. Mantener MySQL actualizado
-- 6. Realizar backups regulares
-- 7. Monitorear intentos de acceso no autorizados
-- 8. Usar firewalls para limitar el acceso

-- Configurar MySQL para usar SSL
-- En my.cnf:
-- [mysqld]
-- require_secure_transport = ON

-- ============================================================================
-- SECCIÓN 12: REVOCACIÓN DE PRIVILEGIOS
-- ============================================================================

-- Revocar un privilegio específico
REVOKE UPDATE ON veterinaria_db.Veterinario FROM 'vet_cvtm'@'localhost';

-- Revocar todos los privilegios de un usuario
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'vet_cvtm'@'localhost';

-- Revocar un rol de un usuario
REVOKE 'rol_veterinario' FROM 'vet_cvtm'@'localhost';

-- Eliminar un rol
DROP ROLE IF EXISTS 'rol_veterinario';

-- ============================================================================
-- RESUMEN
-- ============================================================================

-- La seguridad en MySQL se implementa mediante:
-- 1. Creación de usuarios con contraseñas seguras
-- 2. Asignación de privilegios según el principio de mínimo privilegio
-- 3. Uso de roles para organizar privilegios
-- 4. Verificación regular de privilegios
-- 5. Monitoreo de actividad sospechosa
-- 6. Gestión adecuada de contraseñas

-- En este archivo se ha implementado un esquema de seguridad completo
-- para el sistema CVTM, con roles y privilegios específicos para cada tipo de usuario.
