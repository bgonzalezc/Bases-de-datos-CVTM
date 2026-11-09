# CVTM — Seguridad: Roles, Privilegios y Mínimo PrivilegioMotor: MySQL 8.0**

CREATE USER IF NOT EXISTS 'admin_cvtm'@'localhost'
IDENTIFIED BY 'AdminCVTM2024!';

CREATE USER IF NOT EXISTS 'vet_cvtm'@'localhost'
IDENTIFIED BY 'VetCVTM2024!';

CREATE USER IF NOT EXISTS 'cajero_cvtm'@'localhost'
IDENTIFIED BY 'CajeroCVTM2024!';

CREATE USER IF NOT EXISTS 'recepcion_cvtm'@'localhost'
IDENTIFIED BY 'RecepcionCVTM2024!';

CREATE USER IF NOT EXISTS 'inventario_cvtm'@'localhost'
IDENTIFIED BY 'InventarioCVTM2024!';

CREATE USER IF NOT EXISTS 'reportes_cvtm'@'localhost'
IDENTIFIED BY 'ReportesCVTM2024!';

CREATE USER IF NOT EXISTS 'supertienda_cvtm'@'%'
IDENTIFIED BY 'SuperTienda2024!';


-- ============================================================================
-- SECCIÓN 2: CREACIÓN DE ROLES
-- ============================================================================

CREATE ROLE IF NOT EXISTS 'rol_admin';
CREATE ROLE IF NOT EXISTS 'rol_veterinario';
CREATE ROLE IF NOT EXISTS 'rol_cajero';
CREATE ROLE IF NOT EXISTS 'rol_recepcionista';
CREATE ROLE IF NOT EXISTS 'rol_inventario';
CREATE ROLE IF NOT EXISTS 'rol_reportes';
CREATE ROLE IF NOT EXISTS 'rol_supertienda';


-- ============================================================================
-- SECCIÓN 3: ASIGNACIÓN DE PRIVILEGIOS A ROLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 3.1 ROL ADMINISTRADOR
-- ----------------------------------------------------------------------------

GRANT ALL PRIVILEGES ON veterinaria_db.*
TO 'rol_admin';

GRANT CREATE USER, PROCESS, RELOAD
ON *.* TO 'rol_admin';


-- ----------------------------------------------------------------------------
-- 3.2 ROL VETERINARIO
-- ----------------------------------------------------------------------------

GRANT SELECT, INSERT, UPDATE
ON veterinaria_db.Ficha_Medica
TO 'rol_veterinario';

GRANT SELECT, UPDATE
ON veterinaria_db.Cita
TO 'rol_veterinario';

GRANT SELECT ON veterinaria_db.Mascota
TO 'rol_veterinario';

GRANT SELECT ON veterinaria_db.Cliente
TO 'rol_veterinario';

GRANT SELECT ON veterinaria_db.Veterinario
TO 'rol_veterinario';

GRANT SELECT ON veterinaria_db.Prestacion
TO 'rol_veterinario';

GRANT SELECT ON veterinaria_db.vw_citas_completas
TO 'rol_veterinario';

GRANT SELECT ON veterinaria_db.vw_fichas_medicas_completas
TO 'rol_veterinario';


-- ----------------------------------------------------------------------------
-- 3.3 ROL CAJERO
-- ----------------------------------------------------------------------------

GRANT SELECT, INSERT, UPDATE
ON veterinaria_db.Venta
TO 'rol_cajero';

GRANT SELECT, INSERT, UPDATE
ON veterinaria_db.Detalle_Venta
TO 'rol_cajero';

GRANT SELECT, INSERT, UPDATE
ON veterinaria_db.Detalle_Prestacion
TO 'rol_cajero';

GRANT SELECT ON veterinaria_db.Producto
TO 'rol_cajero';

GRANT SELECT ON veterinaria_db.Prestacion
TO 'rol_cajero';

GRANT SELECT ON veterinaria_db.Cliente
TO 'rol_cajero';

GRANT SELECT ON veterinaria_db.Cajero
TO 'rol_cajero';

GRANT SELECT ON veterinaria_db.vw_ventas_detalladas
TO 'rol_cajero';

GRANT SELECT ON veterinaria_db.vw_inventario_valorado
TO 'rol_cajero';


-- ----------------------------------------------------------------------------
-- 3.4 ROL RECEPCIONISTA
-- ----------------------------------------------------------------------------

GRANT SELECT, INSERT, UPDATE, DELETE
ON veterinaria_db.Cita
TO 'rol_recepcionista';

GRANT SELECT, INSERT, UPDATE
ON veterinaria_db.Cliente
TO 'rol_recepcionista';

GRANT SELECT, INSERT, UPDATE
ON veterinaria_db.Mascota
TO 'rol_recepcionista';

GRANT SELECT, INSERT, UPDATE
ON veterinaria_db.Historial_Responsable
TO 'rol_recepcionista';

GRANT SELECT ON veterinaria_db.Veterinario
TO 'rol_recepcionista';

GRANT SELECT ON veterinaria_db.vw_citas_completas
TO 'rol_recepcionista';


-- ----------------------------------------------------------------------------
-- 3.5 ROL INVENTARIO
-- ----------------------------------------------------------------------------

GRANT SELECT, INSERT, UPDATE, DELETE
ON veterinaria_db.Producto
TO 'rol_inventario';

GRANT SELECT, INSERT, UPDATE, DELETE
ON veterinaria_db.Proveedor
TO 'rol_inventario';

GRANT SELECT, INSERT, UPDATE, DELETE
ON veterinaria_db.Inventario
TO 'rol_inventario';

GRANT SELECT ON veterinaria_db.Venta
TO 'rol_inventario';

GRANT SELECT ON veterinaria_db.Detalle_Venta
TO 'rol_inventario';

GRANT SELECT ON veterinaria_db.vw_inventario_valorado
TO 'rol_inventario';


-- ----------------------------------------------------------------------------
-- 3.6 ROL REPORTES
-- ----------------------------------------------------------------------------

GRANT SELECT ON veterinaria_db.*
TO 'rol_reportes';

GRANT SELECT ON veterinaria_db.vw_citas_completas
TO 'rol_reportes';

GRANT SELECT ON veterinaria_db.vw_ventas_detalladas
TO 'rol_reportes';

GRANT SELECT ON veterinaria_db.vw_fichas_medicas_completas
TO 'rol_reportes';

GRANT SELECT ON veterinaria_db.vw_inventario_valorado
TO 'rol_reportes';

GRANT SELECT ON veterinaria_db.vw_historial_responsables
TO 'rol_reportes';


-- ----------------------------------------------------------------------------
-- 3.7 ROL SUPERTIENDA
-- ----------------------------------------------------------------------------

GRANT SELECT ON veterinaria_db.Producto
TO 'rol_supertienda';

GRANT SELECT ON veterinaria_db.Proveedor
TO 'rol_supertienda';

GRANT SELECT ON veterinaria_db.Venta
TO 'rol_supertienda';

GRANT SELECT ON veterinaria_db.Detalle_Venta
TO 'rol_supertienda';


-- ============================================================================
-- SECCIÓN 4: ASIGNACIÓN DE ROLES A USUARIOS
-- ============================================================================

GRANT 'rol_admin' TO 'admin_cvtm'@'localhost';

GRANT 'rol_veterinario' TO 'vet_cvtm'@'localhost';

GRANT 'rol_cajero' TO 'cajero_cvtm'@'localhost';

GRANT 'rol_recepcionista' TO 'recepcion_cvtm'@'localhost';

GRANT 'rol_inventario' TO 'inventario_cvtm'@'localhost';

GRANT 'rol_reportes' TO 'reportes_cvtm'@'localhost';

GRANT 'rol_supertienda' TO 'supertienda_cvtm'@'%';


-- ============================================================================
-- SECCIÓN 5: CONFIGURACIÓN DE ROLES PREDETERMINADOS
-- ============================================================================

SET DEFAULT ROLE 'rol_admin'
TO 'admin_cvtm'@'localhost';

SET DEFAULT ROLE 'rol_veterinario'
TO 'vet_cvtm'@'localhost';

SET DEFAULT ROLE 'rol_cajero'
TO 'cajero_cvtm'@'localhost';

SET DEFAULT ROLE 'rol_recepcionista'
TO 'recepcion_cvtm'@'localhost';

SET DEFAULT ROLE 'rol_inventario'
TO 'inventario_cvtm'@'localhost';

SET DEFAULT ROLE 'rol_reportes'
TO 'reportes_cvtm'@'localhost';

SET DEFAULT ROLE 'rol_supertienda'
TO 'supertienda_cvtm'@'%';


-- ============================================================================
-- SECCIÓN 6: PRIVILEGIOS DIRECTOS
-- ============================================================================

-- Permitir que el veterinario actualice su información personal.

GRANT UPDATE ON veterinaria_db.Veterinario
TO 'vet_cvtm'@'localhost';

-- Permitir que el cajero actualice su información personal.

GRANT UPDATE ON veterinaria_db.Cajero
TO 'cajero_cvtm'@'localhost';


-- ============================================================================
-- SECCIÓN 7: VERIFICACIÓN DE PRIVILEGIOS
-- ============================================================================

-- Consultar usuarios existentes.

SELECT User, Host
FROM mysql.user
ORDER BY User;

-- Consultar roles existentes.

SELECT User AS Role_Name, Host
FROM mysql.user
WHERE User LIKE 'rol_%';

-- Verificar privilegios de los roles.

SHOW GRANTS FOR 'rol_admin';

SHOW GRANTS FOR 'rol_veterinario';

SHOW GRANTS FOR 'rol_cajero';

SHOW GRANTS FOR 'rol_recepcionista';

SHOW GRANTS FOR 'rol_inventario';

SHOW GRANTS FOR 'rol_reportes';

SHOW GRANTS FOR 'rol_supertienda';

-- Verificar privilegios de los usuarios.

SHOW GRANTS FOR 'admin_cvtm'@'localhost';

SHOW GRANTS FOR 'vet_cvtm'@'localhost';

SHOW GRANTS FOR 'cajero_cvtm'@'localhost';

SHOW GRANTS FOR 'recepcion_cvtm'@'localhost';

SHOW GRANTS FOR 'inventario_cvtm'@'localhost';

SHOW GRANTS FOR 'reportes_cvtm'@'localhost';

SHOW GRANTS FOR 'supertienda_cvtm'@'%';

-- Consultar roles asignados al veterinario.

SELECT *
FROM mysql.role_edges
WHERE FROM_USER = 'vet_cvtm'
AND FROM_HOST = 'localhost';


-- ============================================================================
-- SECCIÓN 8: PRUEBAS DE SEGURIDAD
-- ============================================================================

-- Las siguientes pruebas deben realizarse conectándose
-- individualmente con cada usuario.

-- 1. ADMINISTRADOR
-- mysql -u admin_cvtm -p

-- SHOW TABLES;
-- SELECT * FROM Cliente;
-- INSERT INTO Cliente VALUES (...);

-- Resultado esperado: acceso permitido.

-- 2. VETERINARIO
-- mysql -u vet_cvtm -p

-- SELECT * FROM Ficha_Medica;
-- SELECT * FROM Venta;

-- Resultado esperado:
-- Ficha_Medica: permitido.
-- Venta: denegado.

-- 3. CAJERO
-- mysql -u cajero_cvtm -p

-- SELECT * FROM Venta;
-- SELECT * FROM Cita;

-- Resultado esperado:
-- Venta: permitido.
-- Cita: denegado.

-- 4. RECEPCIONISTA
-- mysql -u recepcion_cvtm -p

-- SELECT * FROM Cita;
-- SELECT * FROM Cliente;
-- SELECT * FROM Ficha_Medica;

-- Resultado esperado:
-- Cita: permitido.
-- Cliente: permitido.
-- Ficha_Medica: denegado.

-- 5. INVENTARIO
-- mysql -u inventario_cvtm -p

-- SELECT * FROM Producto;
-- SELECT * FROM Inventario;
-- SELECT * FROM Venta;
-- INSERT INTO Venta VALUES (...);

-- Resultado esperado:
-- Producto: permitido.
-- Inventario: permitido.
-- Venta (lectura): permitido.
-- Venta (escritura): denegado.

-- 6. REPORTES
-- mysql -u reportes_cvtm -p

-- SELECT * FROM Cliente;
-- INSERT INTO Cliente VALUES (...);

-- Resultado esperado:
-- SELECT: permitido.
-- INSERT: denegado.

-- 7. SUPERTIENDA
-- mysql -u supertienda_cvtm -p -h [servidor]

-- SELECT * FROM Producto;
-- SELECT * FROM Cliente;

-- Resultado esperado:
-- Producto: permitido.
-- Cliente: denegado.


-- ============================================================================
-- SECCIÓN 9: PRINCIPIO DE MÍNIMO PRIVILEGIO
-- ============================================================================

-- Cada usuario debe disponer únicamente de los privilegios
-- necesarios para realizar sus funciones.

-- Administrador: administración de la base de datos.
-- Veterinario: información médica.
-- Cajero: operaciones de venta.
-- Recepcionista: citas, clientes y mascotas.
-- Inventario: productos, proveedores e inventario.
-- Reportes: consultas de solo lectura.
-- SuperTienda: acceso limitado para integración.

-- Beneficios:
-- 1. Evita accesos innecesarios.
-- 2. Reduce el impacto de errores humanos.
-- 3. Limita el daño ante accesos no autorizados.
-- 4. Mejora el control y la administración de la información.


-- ============================================================================
-- SECCIÓN 10: GESTIÓN DE CONTRASEÑAS
-- ============================================================================

-- Cambiar contraseña de un usuario.

ALTER USER 'vet_cvtm'@'localhost'
IDENTIFIED BY 'NuevaContraseña2026!';

-- Forzar cambio de contraseña en el próximo inicio de sesión.

ALTER USER 'vet_cvtm'@'localhost'
PASSWORD EXPIRE;

-- Bloquear un usuario.

ALTER USER 'vet_cvtm'@'localhost'
ACCOUNT LOCK;

-- Desbloquear un usuario.

ALTER USER 'vet_cvtm'@'localhost'
ACCOUNT UNLOCK;

-- Eliminar un usuario.

-- DROP USER IF EXISTS 'vet_cvtm'@'localhost';


-- ============================================================================
-- SECCIÓN 11: AUDITORÍA DE SEGURIDAD
-- ============================================================================

-- 11.1 Consultar conexiones registradas.

SELECT event_time, user_host, command_type, argument
FROM mysql.general_log
WHERE command_type = 'Connect'
ORDER BY event_time DESC
LIMIT 1000;

-- IMPORTANTE:
-- general_log registra conexiones y consultas.
-- No contiene una columna return_code.
-- Por lo tanto, no permite identificar directamente
-- cuáles intentos de conexión fueron fallidos.

-- 11.2 Consultar consultas ejecutadas por el veterinario.

SELECT event_time, user_host, command_type, argument
FROM mysql.general_log
WHERE user_host LIKE '%vet_cvtm%'
ORDER BY event_time DESC;

-- 11.3 Consultar la estructura del registro general.

DESCRIBE mysql.general_log;

-- 11.4 Consultar el estado del registro general.

SHOW VARIABLES LIKE 'general_log';

SHOW VARIABLES LIKE 'general_log_file';

-- 11.5 Habilitar el registro general.
-- Ejecutar únicamente si se desea habilitar la auditoría.

-- SET GLOBAL log_output = 'TABLE';
-- SET GLOBAL general_log = 'ON';

-- 11.6 Deshabilitar el registro general cuando no sea necesario.

-- SET GLOBAL general_log = 'OFF';

-- 11.7 Para investigar conexiones fallidas:
-- Consultar el MySQL Error Log del servidor.
-- Su ubicación depende de la configuración de MySQL.

-- SHOW VARIABLES LIKE 'log_error';

-- NOTA:
-- El registro general y el registro de errores son mecanismos
-- diferentes y deben utilizarse de forma complementaria.


-- ============================================================================
-- SECCIÓN 12: SEGURIDAD DE LA BASE DE DATOS
-- ============================================================================

-- Recomendaciones generales:

-- 1. Utilizar contraseñas fuertes.
-- 2. Evitar utilizar root en aplicaciones.
-- 3. Aplicar el principio de mínimo privilegio.
-- 4. Utilizar conexiones cifradas mediante SSL/TLS.
-- 5. Mantener MySQL actualizado.
-- 6. Realizar copias de seguridad periódicas.
-- 7. Monitorear intentos de acceso no autorizados.
-- 8. Utilizar firewalls para limitar conexiones.

-- Configuración recomendada en my.cnf o my.ini:

-- [mysqld]
-- require_secure_transport = ON


-- ============================================================================
-- SECCIÓN 13: REVOCACIÓN DE PRIVILEGIOS
-- ============================================================================

-- Revocar un privilegio específico.

REVOKE UPDATE ON veterinaria_db.Veterinario
FROM 'vet_cvtm'@'localhost';

-- Revocar todos los privilegios directos de un usuario.

REVOKE ALL PRIVILEGES, GRANT OPTION
FROM 'vet_cvtm'@'localhost';

-- Revocar un rol de un usuario.

REVOKE 'rol_veterinario'
FROM 'vet_cvtm'@'localhost';

-- Eliminar un rol.

-- DROP ROLE IF EXISTS 'rol_veterinario';


-- ============================================================================
-- RESUMEN FINAL
-- ============================================================================

-- La seguridad del sistema CVTM contempla:
--
-- 1. Creación de usuarios individuales.
-- 2. Creación y administración de roles.
-- 3. Asignación de privilegios específicos.
-- 4. Configuración de roles predeterminados.
-- 5. Verificación de permisos.
-- 6. Pruebas de acceso.
-- 7. Gestión de contraseñas.
-- 8. Auditoría de actividad.
-- 9. Revocación de privilegios.
--
-- Se aplica el principio de mínimo privilegio para garantizar
-- que cada usuario tenga únicamente los permisos necesarios
-- para desempeñar sus funciones dentro del sistema CVTM.

-- FIN DEL SCRIPT

