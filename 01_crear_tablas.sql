-- CVTM | Parte A: creación de la base de datos y las 14 tablas | MySQL 8.0

CREATE DATABASE IF NOT EXISTS veterinaria_db;
USE veterinaria_db;

CREATE TABLE Cliente (
Rut_Cliente VARCHAR(12) NOT NULL,
Nombre VARCHAR(100) NOT NULL,
Correo_Electronico VARCHAR(100),
Telefono VARCHAR(15),
PRIMARY KEY (Rut_Cliente)
);

CREATE TABLE Veterinario (
Rut_Veterinario VARCHAR(12) NOT NULL,
Nombre VARCHAR(100) NOT NULL,
Especialidad VARCHAR(60),
Telefono VARCHAR(15),
PRIMARY KEY (Rut_Veterinario)
);

CREATE TABLE Cajero (
Rut_Cajero VARCHAR(12) NOT NULL,
Nombre VARCHAR(100) NOT NULL,
Turno VARCHAR(20),
PRIMARY KEY (Rut_Cajero)
);

CREATE TABLE Proveedor (
Rut_Proveedor VARCHAR(12) NOT NULL,
Nombre_Proveedor VARCHAR(100) NOT NULL,
Telefono VARCHAR(15),
Correo_Electronico VARCHAR(100),
Direccion VARCHAR(150),
PRIMARY KEY (Rut_Proveedor)
);

CREATE TABLE Mascota (
ID_Mascota INT NOT NULL AUTO_INCREMENT,
Nombre VARCHAR(50) NOT NULL,
Especie VARCHAR(30),
Raza VARCHAR(50),
Fecha_Nacimiento DATE,
Sexo CHAR(1),
Rut_Cliente VARCHAR(12) NOT NULL,
PRIMARY KEY (ID_Mascota)
);

CREATE TABLE Historial_Responsable (
ID_Historial INT NOT NULL AUTO_INCREMENT,
ID_Mascota INT NOT NULL,
Rut_Cliente VARCHAR(12) NOT NULL,
Fecha_Inicio DATE NOT NULL,
Fecha_Fin DATE,
PRIMARY KEY (ID_Historial)
);

CREATE TABLE Prestacion (
ID_Prestacion INT NOT NULL AUTO_INCREMENT,
Nombre_Prestacion VARCHAR(100) NOT NULL,
Descripcion VARCHAR(255),
Precio DECIMAL(10,2) NOT NULL,
Duracion_Min INT,
PRIMARY KEY (ID_Prestacion)
);

CREATE TABLE Producto (
ID_Producto INT NOT NULL AUTO_INCREMENT,
Nombre_Producto VARCHAR(100) NOT NULL,
Precio_Unitario DECIMAL(10,2) NOT NULL,
Stock INT NOT NULL,
Fecha_Vencimiento DATE,
Rut_Proveedor VARCHAR(12),
PRIMARY KEY (ID_Producto)
);

CREATE TABLE Cita (
N_Cita INT NOT NULL AUTO_INCREMENT,
Fecha_Hora DATETIME NOT NULL,
Estado VARCHAR(20) NOT NULL,
ID_Mascota INT NOT NULL,
Rut_Veterinario VARCHAR(12) NOT NULL,
Bloque_Activo DATETIME GENERATED ALWAYS AS
  (IF(Estado IN ('cancelada','ausente'), NULL, Fecha_Hora)) STORED,
PRIMARY KEY (N_Cita)
);

CREATE TABLE Venta (
ID_Venta INT NOT NULL AUTO_INCREMENT,
Fecha_Pago DATE NOT NULL,
Monto_Venta DECIMAL(10,2) NOT NULL,
Forma_Pago VARCHAR(20),
Rut_Cliente VARCHAR(12),
Rut_Cajero VARCHAR(12) NOT NULL,
PRIMARY KEY (ID_Venta)
);

CREATE TABLE Ficha_Medica (
ID_Ficha INT NOT NULL AUTO_INCREMENT,
Diagnostico VARCHAR(255) NOT NULL,
Tratamiento VARCHAR(255),
Observaciones VARCHAR(255),
Fecha_Registro DATE NOT NULL,
N_Cita INT NOT NULL,
Rut_Veterinario VARCHAR(12) NOT NULL,
PRIMARY KEY (ID_Ficha)
);

CREATE TABLE Inventario (
ID_Movimiento INT NOT NULL AUTO_INCREMENT,
ID_Producto INT NOT NULL,
Tipo_Movimiento VARCHAR(20) NOT NULL,
Cantidad INT NOT NULL,
Fecha_Movimiento DATETIME NOT NULL,
Rut_Proveedor VARCHAR(12),
PRIMARY KEY (ID_Movimiento)
);

CREATE TABLE Detalle_Venta (
ID_Venta INT NOT NULL,
ID_Producto INT NOT NULL,
Cantidad INT NOT NULL,
Subtotal DECIMAL(10,2) NOT NULL,
PRIMARY KEY (ID_Venta, ID_Producto)
);

CREATE TABLE Detalle_Prestacion (
ID_Venta INT NOT NULL,
ID_Prestacion INT NOT NULL,
Cantidad INT NOT NULL,
Precio_Aplicado DECIMAL(10,2) NOT NULL,
Subtotal DECIMAL(10,2) NOT NULL,
PRIMARY KEY (ID_Venta, ID_Prestacion)
);
