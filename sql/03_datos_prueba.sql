-- CVTM | Datos de prueba base (3 filas por tabla, 42 en total) | MySQL 8.0
-- Ejecutar después de 01 y 02, sobre una base recién creada.

USE veterinaria_db;
INSERT INTO Cliente (Rut_Cliente, Nombre, Correo_Electronico, Telefono) VALUES 
('15.420.311-8', 'Carlos Mendoza Silva', 'carlos.mendoza@email.com', '+56911223344'), 
('18.734.902-5', 'Valentina Silva Castro', 'valentina.silva@email.com', '+56922334455'), 
('12.658.120-K', 'Andrés Morales Ríos', 'andres.morales@email.com', '+56933445566');
INSERT INTO Veterinario (Rut_Veterinario, Nombre, Especialidad, Telefono) VALUES 
('14.890.123-4', 'Dra. Camila Rojas Fuentes', 'Medicina General y Felina', '+56944556677'), 
('16.234.567-8', 'Dr. Felipe Navarro Toro', 'Cirugía y Traumatología', '+56955667788'), 
('13.987.654-2', 'Dra. Beatriz Soto Lagos', 'Dermatología Veterinaria', '+56966778899');
INSERT INTO Cajero (Rut_Cajero, Nombre, Turno) VALUES 
('19.876.543-1', 'Gonzalo Pérez Vera', 'Mañana'), 
('20.123.456-7', 'Daniela Araya Pinto', 'Tarde'), 
('17.654.321-9', 'Rodrigo Castro Mena', 'Noche');
INSERT INTO Proveedor (Rut_Proveedor, Nombre_Proveedor, Telefono, Correo_Electronico, Direccion) VALUES 
('76.123.456-0', 'Distribuidora FarmaVet SpA', '+5622334455', 'contacto@farmavet.cl', 'Av. Industrial 1230, Santiago'), 
('77.987.654-1', 'Nutrición Animal Pro Ltda.', '+5622889900', 'ventas@nutricionpro.cl', 'Calle Los Alerces 450, Providencia'), 
('76.555.444-K', 'Insumos Clínicos BioVet', '+5622776655', 'pedidos@biovet.cl', 'Av. Santa Rosa 890, San Miguel');
INSERT INTO Prestacion (ID_Prestacion, Nombre_Prestacion, Descripcion, Precio, Duracion_Min) VALUES 
(1, 'Consulta Médica General', 'Evaluación clínica completa y control de signos vitales', 20000.00, 30), 
(2, 'Vacunación Séxtuple Canina', 'Aplicación de dosis séxtuple y registro en carnet sanitario', 18000.00, 15), 
(3, 'Profilaxis Dental Canina', 'Limpieza y destartraje dental con ultrasonido', 45000.00, 60);
INSERT INTO Mascota (ID_Mascota, Nombre, Especie, Raza, Fecha_Nacimiento, Sexo, Rut_Cliente) VALUES 
(1, 'Max', 'Canino', 'Golden Retriever', '2021-04-15', 'M', '15.420.311-8'), 
(2, 'Luna', 'Felino', 'Siamés', '2022-08-10', 'H', '18.734.902-5'), 
(3, 'Rocky', 'Canino', 'Bulldog Francés', '2020-11-05', 'M', '12.658.120-K');
INSERT INTO Producto (ID_Producto, Nombre_Producto, Precio_Unitario, Stock, Fecha_Vencimiento, Rut_Proveedor) VALUES 
(1, 'Antiparasitario Bravecto 20-40kg', 32000.00, 25, '2026-11-30', '76.123.456-0'), 
(2, 'Alimento Premium Adulto 15kg', 48990.00, 40, '2027-03-15', '77.987.654-1'), 
(3, 'Shampoo Antialérgico Clorhexidina 250ml', 12500.00, 15, '2026-08-20', '76.555.444-K');
INSERT INTO Cita (N_Cita, Fecha_Hora, Estado, ID_Mascota, Rut_Veterinario) VALUES 
(1, '2026-10-10 10:00:00', 'atendida', 1, '14.890.123-4'), 
(2, '2026-10-10 11:30:00', 'atendida', 2, '14.890.123-4'), 
(3, '2026-10-11 16:00:00', 'confirmada', 3, '16.234.567-8');
INSERT INTO Inventario (ID_Movimiento, ID_Producto, Tipo_Movimiento, Cantidad, Fecha_Movimiento, Rut_Proveedor) VALUES 
(1, 1, 'entrada', 30, '2026-10-01 09:30:00', '76.123.456-0'), 
(2, 2, 'entrada', 50, '2026-10-02 11:00:00', '77.987.654-1'), 
(3, 1, 'salida', 1, '2026-10-10 10:45:00', NULL);
INSERT INTO Ficha_Medica (ID_Ficha, Diagnostico, Tratamiento, Observaciones, Fecha_Registro, N_Cita, Rut_Veterinario) VALUES 
(1, 'Dermatitis alérgica por pulgas', 'Administración de antiparasitario externo y baño medicinal', 'Paciente con prurito moderado en zona dorsal', '2026-10-10', 1, '14.890.123-4'), 
(2, 'Control sano y calendario de inmunización', 'Administración de vacuna y desparasitación interna', 'Paciente felino en peso y condición óptima', '2026-10-10', 2, '14.890.123-4'), 
(3, 'Gingivitis y sarro moderado', 'Se programa profilaxis dental preventiva', 'Recomendar alimento específico dental', '2026-10-11', 3, '16.234.567-8');
INSERT INTO Venta (ID_Venta, Fecha_Pago, Monto_Venta, Forma_Pago, Rut_Cliente, Rut_Cajero) VALUES 
(1, '2026-10-10', 52000.00, 'Tarjeta Débito', '15.420.311-8', '19.876.543-1'), 
(2, '2026-10-10', 30500.00, 'Efectivo', '18.734.902-5', '19.876.543-1'), 
(3, '2026-10-11', 93990.00, 'Transferencia', '12.658.120-K', '20.123.456-7');
INSERT INTO Detalle_Venta (ID_Venta, ID_Producto, Cantidad, Subtotal) VALUES 
(1, 1, 1, 32000.00), 
(2, 3, 1, 12500.00), 
(3, 2, 1, 48990.00);
INSERT INTO Detalle_Prestacion (ID_Venta, ID_Prestacion, Cantidad, Precio_Aplicado, Subtotal) VALUES 
(1, 1, 1, 20000.00, 20000.00), 
(2, 2, 1, 18000.00, 18000.00), 
(3, 3, 1, 45000.00, 45000.00);

-- Historial de responsables: 3 registros de prueba.
INSERT INTO Historial_Responsable
(ID_Historial, ID_Mascota, Rut_Cliente, Fecha_Inicio, Fecha_Fin)
VALUES
(1, 1, '15.420.311-8', '2021-04-15', NULL),
(2, 2, '18.734.902-5', '2022-08-10', NULL),
(3, 3, '12.658.120-K', '2020-11-05', NULL);

