# Diagrama de Clases - CVTM

## Descripción

El diagrama de clases representa la estructura estática del sistema CVTM, mostrando las entidades (clases), sus atributos y las relaciones entre ellas.

## Clases Principales

### Clase: Cliente
- **Atributos**: Rut_Cliente (PK), Nombre, Correo_Electronico, Telefono
- **Descripción**: Persona que es dueña de mascotas y/o compra productos

### Clase: Veterinario
- **Atributos**: Rut_Veterinario (PK), Nombre, Especialidad, Telefono
- **Descripción**: Profesional médico que atiende las mascotas

### Clase: Cajero
- **Atributos**: Rut_Cajero (PK), Nombre, Turno
- **Descripción**: Empleado que maneja las ventas

### Clase: Proveedor
- **Atributos**: Rut_Proveedor (PK), Nombre_Proveedor, Telefono, Correo_Electronico, Direccion
- **Descripción**: Empresa que suministra productos al centro

### Clase: Mascota
- **Atributos**: ID_Mascota (PK), Nombre, Especie, Raza, Fecha_Nacimiento, Sexo
- **Descripción**: Animal que recibe atención veterinaria

### Clase: Historial_Responsable
- **Atributos**: ID_Historial (PK), ID_Mascota (FK), Rut_Cliente (FK), Fecha_Inicio, Fecha_Fin
- **Descripción**: Registra los cambios de dueño de una mascota

### Clase: Prestacion
- **Atributos**: ID_Prestacion (PK), Nombre_Prestacion, Descripcion, Precio, Duracion_Min
- **Descripción**: Servicio médico ofrecido por el centro

### Clase: Producto
- **Atributos**: ID_Producto (PK), Nombre_Producto, Precio_Unitario, Stock, Fecha_Vencimiento, Rut_Proveedor (FK)
- **Descripción**: Artículo comercializado en la tienda

### Clase: Cita
- **Atributos**: N_Cita (PK), Fecha_Hora, Estado, ID_Mascota (FK), Rut_Veterinario (FK), Bloque_Activo (generada)
- **Descripción**: Agendamiento de atención veterinaria

### Clase: Venta
- **Atributos**: ID_Venta (PK), Fecha_Pago, Monto_Venta, Forma_Pago, Rut_Cliente (FK), Rut_Cajero (FK)
- **Descripción**: Transacción de venta de productos y/o servicios

### Clase: Ficha_Medica
- **Atributos**: ID_Ficha (PK), Diagnostico, Tratamiento, Observaciones, Fecha_Registro, N_Cita (FK), Rut_Veterinario (FK)
- **Descripción**: Registro clínico de una atención

### Clase: Inventario
- **Atributos**: ID_Movimiento (PK), ID_Producto (FK), Tipo_Movimiento, Cantidad, Fecha_Movimiento, Rut_Proveedor (FK)
- **Descripción**: Movimiento de stock de productos

### Clase: Detalle_Venta
- **Atributos**: ID_Venta (PK,FK), ID_Producto (PK,FK), Cantidad, Subtotal
- **Descripción**: Productos incluidos en una venta

### Clase: Detalle_Prestacion
- **Atributos**: ID_Venta (PK,FK), ID_Prestacion (PK,FK), Cantidad, Precio_Aplicado, Subtotal
- **Descripción**: Servicios incluidos en una venta

## Relaciones entre Clases

### Relaciones de Asociación

1. **Cliente - Mascota**: Un cliente puede tener muchas mascotas (1:N)
   - Cardinalidad: 1 Cliente → N Mascotas

2. **Cliente - Historial_Responsable**: Un cliente puede ser responsable de muchas mascotas (1:N)
   - Cardinalidad: 1 Cliente → N Historial_Responsable

3. **Mascota - Historial_Responsable**: Una mascota puede tener un historial de responsables (1:N)
   - Cardinalidad: 1 Mascota → N Historial_Responsable

4. **Mascota - Cita**: Una mascota puede tener muchas citas (1:N)
   - Cardinalidad: 1 Mascota → N Citas

5. **Veterinario - Cita**: Un veterinario puede tener muchas citas (1:N)
   - Cardinalidad: 1 Veterinario → N Citas

6. **Cita - Ficha_Medica**: Una cita puede generar una ficha médica (1:0..1)
   - Cardinalidad: 1 Cita → 0..1 Ficha_Medica

7. **Veterinario - Ficha_Medica**: Un veterinario puede firmar muchas fichas (1:N)
   - Cardinalidad: 1 Veterinario → N Fichas_Médicas

8. **Cajero - Venta**: Un cajero puede realizar muchas ventas (1:N)
   - Cardinalidad: 1 Cajero → N Ventas

9. **Cliente - Venta**: Un cliente puede realizar muchas ventas (1:N)
   - Cardinalidad: 1 Cliente → N Ventas

10. **Venta - Detalle_Venta**: Una venta puede incluir muchos productos (1:N)
    - Cardinalidad: 1 Venta → N Detalle_Venta

11. **Venta - Detalle_Prestacion**: Una venta puede incluir muchas prestaciones (1:N)
    - Cardinalidad: 1 Venta → N Detalle_Prestacion

12. **Producto - Detalle_Venta**: Un producto puede estar en muchas ventas (1:N)
    - Cardinalidad: 1 Producto → N Detalle_Venta

13. **Prestacion - Detalle_Prestacion**: Una prestación puede estar en muchas ventas (1:N)
    - Cardinalidad: 1 Prestacion → N Detalle_Prestacion

14. **Proveedor - Producto**: Un proveedor puede suministrar muchos productos (1:N)
    - Cardinalidad: 1 Proveedor → N Productos

15. **Producto - Inventario**: Un producto puede tener muchos movimientos de inventario (1:N)
    - Cardinalidad: 1 Producto → N Inventario

16. **Proveedor - Inventario**: Un proveedor puede estar asociado a muchos movimientos de entrada (1:N)
    - Cardinalidad: 1 Proveedor → N Inventario

## Diagrama UML

El diagrama completo en notación UML está disponible en:
- `diagrama_clases.drawio` - Formato editable
- `diagrama_clases.png` - Imagen exportada

## Cardinalidades Resumidas
   Relación | Cardinalidad | Descripción |
 |----------|--------------|-------------|
 | Cliente - Mascota | 1:N | Un cliente tiene muchas mascotas |
 | Mascota - Historial_Responsable | 1:N | Una mascota tiene un historial |
 | Cliente - Historial_Responsable | 1:N | Un cliente es responsable de muchas mascotas |
 | Mascota - Cita | 1:N | Una mascota tiene muchas citas |
 | Veterinario - Cita | 1:N | Un veterinario atiende muchas citas |
 | Cita - Ficha_Medica | 1:0..1 | Una cita genera cero o una ficha |
 | Veterinario - Ficha_Medica | 1:N | Un veterinario firma muchas fichas |
 | Cajero - Venta | 1:N | Un cajero realiza muchas ventas |
 | Cliente - Venta | 1:N | Un cliente realiza muchas compras |
 | Venta - Detalle_Venta | 1:N | Una venta incluye muchos productos |
 | Producto - Detalle_Venta | 1:N | Un producto se vende en muchas ventas |
 | Venta - Detalle_Prestacion | 1:N | Una venta incluye muchos servicios |
 | Prestacion - Detalle_Prestacion | 1:N | Una prestación se vende en muchas ventas |
 | Proveedor - Producto | 1:N | Un proveedor suministra muchos productos |
 | Producto - Inventario | 1:N | Un producto tiene muchos movimientos |
 | Proveedor - Inventario | 1:N | Un proveedor provee muchos movimientos |
