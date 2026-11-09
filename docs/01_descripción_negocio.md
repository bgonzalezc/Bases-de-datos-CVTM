# Descripción del Negocio: Centro Veterinario y Tienda de Mascotas (CVTM)

## Contexto

El Centro Veterinario y Tienda de Mascotas (CVTM) es un establecimiento que ofrece servicios médicos veterinarios y venta de productos para mascotas. El sistema de gestión de bases de datos debe soportar las operaciones diarias del centro, incluyendo la gestión de clientes, mascotas, citas médicas, fichas clínicas, inventario de productos, ventas y proveedores.

## Objetivo del Sistema

El sistema CVTM tiene como objetivo centralizar y automatizar la gestión de:
- Pacientes (mascotas) y sus dueños (clientes)
- Profesionales (veterinarios y cajeros)
- Proveedores de productos
- Agenda de citas médicas
- Historial clínico de las mascotas
- Inventario y movimientos de productos
- Proceso de ventas (productos y prestaciones)
- Historial de responsables de mascotas

## Alcance

El sistema abarca desde la atención veterinaria hasta la venta de productos, incluyendo:
1. Registro y gestión de clientes y sus mascotas
2. Gestión de citas médicas con veterinarios
3. Creación y seguimiento de fichas médicas
4. Control de inventario de productos
5. Proceso de ventas (productos y servicios)
6. Gestión de proveedores
7. Historial de transferencia de responsabilidad de mascotas entre clientes

## Reglas de Negocio

### Clientes y Mascotas
- Un cliente puede tener múltiples mascotas
- Una mascota pertenece a un solo cliente en un momento dado
- El historial de responsables permite registrar cambios de dueño de una mascota
- Cada mascota tiene un historial de responsables con fechas de inicio y fin

### Citas Médicas
- Una cita es agendada para una mascota específica con un veterinario
- Una cita puede estar en estados: pendiente, confirmada, atendida, cancelada, ausente
- Cada cita tiene una fecha y hora específica
- Un veterinario no puede tener dos citas activas (pendiente/confirmada/atendida) en el mismo horario
- Una cita puede generar como máximo una ficha médica

### Fichas Médicas
- Cada ficha médica está asociada a una cita específica
- La ficha médica debe ser firmada por un veterinario
- No es obligatorio que toda cita tenga una ficha médica
- Una ficha médica contiene: diagnóstico, tratamiento, observaciones y fecha de registro

### Productos y Proveedores
- Los productos son suministrados por proveedores
- Cada producto tiene un precio unitario, stock y fecha de vencimiento opcional
- El stock no puede ser negativo
- Los movimientos de inventario (entradas y salidas) afectan el stock

### Ventas
- Una venta puede incluir productos y/o prestaciones (servicios)
- Una venta es realizada por un cajero
- Una venta puede estar asociada a un cliente (opcional)
- El monto de la venta es la suma de los subtotales de productos y prestaciones

### Prestaciones
- Las prestaciones son servicios médicos con un precio y duración estimada
- El precio de una prestación no puede ser negativo
- La duración debe ser positiva si se especifica

### Historial de Responsables
- Permite registrar cuando una mascota cambia de dueño
- Cada registro tiene fecha de inicio y opcionalmente fecha de fin
- La fecha de fin debe ser mayor o igual a la fecha de inicio
- El responsable actual tiene fecha de fin NULL
