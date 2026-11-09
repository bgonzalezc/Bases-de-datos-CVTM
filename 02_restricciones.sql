-- CVTM | Parte B: restricciones y claves | MySQL 8.0
-- Ejecutar DESPUÉS del CREATE TABLE de las 14 tablas de la Parte A.
-- Las PK y NOT NULL existentes se conservan: no se vuelven a declarar.
-- Validar previamente que los datos existentes cumplan las restricciones.
USE veterinaria_db;

ALTER TABLE `Mascota`
    ADD CONSTRAINT `fk_mascota_cliente`
    FOREIGN KEY (`Rut_Cliente`)
    REFERENCES `Cliente` (`Rut_Cliente`)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `Producto`
    ADD CONSTRAINT `fk_producto_proveedor`
    FOREIGN KEY (`Rut_Proveedor`)
    REFERENCES `Proveedor` (`Rut_Proveedor`)
    ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE `Cita`
    ADD CONSTRAINT `fk_cita_mascota`
    FOREIGN KEY (`ID_Mascota`)
    REFERENCES `Mascota` (`ID_Mascota`)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `Cita`
    ADD CONSTRAINT `fk_cita_veterinario`
    FOREIGN KEY (`Rut_Veterinario`)
    REFERENCES `Veterinario` (`Rut_Veterinario`)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `Venta`
    ADD CONSTRAINT `fk_venta_cliente`
    FOREIGN KEY (`Rut_Cliente`)
    REFERENCES `Cliente` (`Rut_Cliente`)
    ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE `Venta`
    ADD CONSTRAINT `fk_venta_cajero`
    FOREIGN KEY (`Rut_Cajero`)
    REFERENCES `Cajero` (`Rut_Cajero`)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `Ficha_Medica`
    ADD CONSTRAINT `fk_ficha_cita`
    FOREIGN KEY (`N_Cita`)
    REFERENCES `Cita` (`N_Cita`)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `Ficha_Medica`
    ADD CONSTRAINT `fk_ficha_veterinario`
    FOREIGN KEY (`Rut_Veterinario`)
    REFERENCES `Veterinario` (`Rut_Veterinario`)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `Inventario`
    ADD CONSTRAINT `fk_inventario_producto`
    FOREIGN KEY (`ID_Producto`)
    REFERENCES `Producto` (`ID_Producto`)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `Inventario`
    ADD CONSTRAINT `fk_inventario_proveedor`
    FOREIGN KEY (`Rut_Proveedor`)
    REFERENCES `Proveedor` (`Rut_Proveedor`)
    ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE `Detalle_Venta`
    ADD CONSTRAINT `fk_detventa_venta`
    FOREIGN KEY (`ID_Venta`)
    REFERENCES `Venta` (`ID_Venta`)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `Detalle_Venta`
    ADD CONSTRAINT `fk_detventa_producto`
    FOREIGN KEY (`ID_Producto`)
    REFERENCES `Producto` (`ID_Producto`)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `Detalle_Prestacion`
    ADD CONSTRAINT `fk_detprest_venta`
    FOREIGN KEY (`ID_Venta`)
    REFERENCES `Venta` (`ID_Venta`)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `Detalle_Prestacion`
    ADD CONSTRAINT `fk_detprest_prestacion`
    FOREIGN KEY (`ID_Prestacion`)
    REFERENCES `Prestacion` (`ID_Prestacion`)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- Historial de responsables de la mascota.
ALTER TABLE `Historial_Responsable`
    ADD CONSTRAINT `fk_hist_mascota`
    FOREIGN KEY (`ID_Mascota`)
    REFERENCES `Mascota` (`ID_Mascota`)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE `Historial_Responsable`
    ADD CONSTRAINT `fk_hist_cliente`
    FOREIGN KEY (`Rut_Cliente`)
    REFERENCES `Cliente` (`Rut_Cliente`)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- Relación 1:0..1 entre Cita y Ficha_Medica.
ALTER TABLE `Ficha_Medica`
    ADD CONSTRAINT `uq_ficha_cita`
    UNIQUE (`N_Cita`);

-- Un veterinario no puede tener dos citas activas en el mismo horario.
-- Bloque_Activo es NULL si la cita está cancelada o ausente (libera el bloque).
ALTER TABLE `Cita`
    ADD CONSTRAINT `uq_cita_vet_bloque`
    UNIQUE (`Rut_Veterinario`, `Bloque_Activo`);

ALTER TABLE `Mascota`
    ADD CONSTRAINT `chk_mascota_sexo`
    CHECK (Sexo IS NULL OR Sexo IN ('M','H'));

ALTER TABLE `Prestacion`
    ADD CONSTRAINT `chk_prestacion_precio`
    CHECK (Precio >= 0);

ALTER TABLE `Prestacion`
    ADD CONSTRAINT `chk_prestacion_duracion`
    CHECK (Duracion_Min IS NULL OR Duracion_Min > 0);

ALTER TABLE `Producto`
    ADD CONSTRAINT `chk_producto_precio`
    CHECK (Precio_Unitario >= 0);

ALTER TABLE `Producto`
    ADD CONSTRAINT `chk_producto_stock`
    CHECK (Stock >= 0);

ALTER TABLE `Cita`
    ADD CONSTRAINT `chk_cita_estado`
    CHECK (Estado IN ('pendiente','confirmada','atendida','cancelada','ausente'));

ALTER TABLE `Venta`
    ADD CONSTRAINT `chk_venta_monto`
    CHECK (Monto_Venta >= 0);

ALTER TABLE `Inventario`
    ADD CONSTRAINT `chk_inventario_tipo`
    CHECK (Tipo_Movimiento IN ('entrada','salida'));

ALTER TABLE `Inventario`
    ADD CONSTRAINT `chk_inventario_cantidad`
    CHECK (Cantidad > 0);

ALTER TABLE `Detalle_Venta`
    ADD CONSTRAINT `chk_detventa_cantidad`
    CHECK (Cantidad > 0);

ALTER TABLE `Detalle_Venta`
    ADD CONSTRAINT `chk_detventa_subtotal`
    CHECK (Subtotal >= 0);

ALTER TABLE `Detalle_Prestacion`
    ADD CONSTRAINT `chk_detprest_cantidad`
    CHECK (Cantidad > 0);

ALTER TABLE `Detalle_Prestacion`
    ADD CONSTRAINT `chk_detprest_precio`
    CHECK (Precio_Aplicado >= 0);

ALTER TABLE `Detalle_Prestacion`
    ADD CONSTRAINT `chk_detprest_subtotal`
    CHECK (Subtotal >= 0);

ALTER TABLE `Historial_Responsable`
    ADD CONSTRAINT `chk_hist_fechas`
    CHECK (Fecha_Fin IS NULL OR Fecha_Fin >= Fecha_Inicio);

-- DEFAULT propuestos: aplicables sin modificar la nulidad existente.
ALTER TABLE `Cita`
    ALTER COLUMN `Estado` SET DEFAULT 'pendiente';

ALTER TABLE `Producto`
    ALTER COLUMN `Stock` SET DEFAULT 0;
