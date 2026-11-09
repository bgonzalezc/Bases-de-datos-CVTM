# Álgebra Relacional - CVTM

## Introducción

El álgebra relacional es un lenguaje formal para manipular relaciones (tablas) en bases de datos relacionales. Este documento presenta consultas en notación de álgebra relacional que corresponden a los procesos definidos en los requerimientos funcionales del sistema CVTM.

## Operaciones de Álgebra Relacional Utilizadas

- **Selección (σ)**: Filtrar filas que cumplen una condición
- **Proyección (π)**: Seleccionar columnas específicas
- **Unión (∪)**: Combinar resultados de dos consultas
- **Diferencia (-)**: Restar resultados
- **Producto cartesiano (×)**: Combinar todas las filas de dos relaciones
- **Join (⋈)**: Combinar filas relacionadas
- **Renombrar (ρ)**: Cambiar el nombre de una relación o atributo
- **Agrupación (γ)**: Agrupar filas por uno o más atributos

## Consultas de Álgebra Relacional por Proceso

### Proceso RF-01: Gestión de Clientes

#### 1. Listar todos los clientes con sus mascotas
π Nombre_Cliente, Rut_Cliente, Nombre_Mascota, ID_Mascota (
Cliente ⋈ (Rut_Cliente=Rut_Cliente) Mascota
)

**Explicación:**
- Join entre Cliente y Mascota usando Rut_Cliente
- Proyección de los atributos relevantes

#### 2. Encontrar clientes sin mascotas
π Nombre, Rut_Cliente (Cliente) -
π Nombre, Rut_Cliente (
Cliente ⋈ (Rut_Cliente=Rut_Cliente) Mascota
)

**Explicación:**
- Diferencia entre todos los clientes y los clientes que tienen mascotas

---

### Proceso RF-02: Gestión de Mascotas

#### 3. Listar todas las mascotas con su dueño
π ID_Mascota, Nombre_Mascota, Especie, Raza, Nombre_Cliente (
Mascota ⋈ (Rut_Cliente=Rut_Cliente) Cliente
)

#### 4. Encontrar mascotas que nunca han tenido una cita
π ID_Mascota, Nombre (Mascota) -
π ID_Mascota, Nombre (
Mascota ⋈ (ID_Mascota=ID_Mascota) Cita
)

#### 5. Obtener el historial completo de responsables de una mascota
π ID_Mascota, Nombre_Mascota, Nombre_Cliente, Fecha_Inicio, Fecha_Fin (
(Mascota ⋈ (ID_Mascota=ID_Mascota) Historial_Responsable)
⋈ (Rut_Cliente=Rut_Cliente) Cliente
)

---

### Proceso RF-03: Gestión de Veterinarios

#### 6. Listar veterinarios con su especialidad y número de citas atendidas
γ[Rut_Veterinario, Nombre, Especialidad, COUNT(*) AS Citas_Atendidas] (
σ Estado='atendida' (Cita) ⋈ (Rut_Veterinario=Rut_Veterinario) Veterinario
)

**Explicación:**
- Selección de citas con estado 'atendida'
- Join con Veterinario
- Agrupación por veterinario con conteo de citas

#### 7. Encontrar veterinarios que no tienen citas agendadas
π Nombre, Especialidad (Veterinario) -
π Nombre, Especialidad (
Veterinario ⋈ (Rut_Veterinario=Rut_Veterinario) Cita
)

---
### Proceso RF-04: Gestión de Citas

#### 8. Listar todas las citas con información de mascota, cliente y veterinario
π N_Cita, Fecha_Hora, Estado, Nombre_Mascota, Nombre_Cliente, Nombre_Veterinario (
((Cita ⋈ (ID_Mascota=ID_Mascota) Mascota)
⋈ (Rut_Cliente=Rut_Cliente) Cliente)
⋈ (Rut_Veterinario=Rut_Veterinario) Veterinario
)

#### 9. Encontrar citas del día de hoy
σ Fecha_Hora = TODAY() (
π N_Cita, Fecha_Hora, Estado, ID_Mascota, Rut_Veterinario (Cita)
)

**Nota**: TODAY() es una función que representa la fecha actual.

#### 10. Listar citas por veterinario ordenadas por fecha
τ Fecha_Hora (
π N_Cita, Fecha_Hora, Estado, Nombre_Veterinario (
Cita ⋈ (Rut_Veterinario=Rut_Veterinario) Veterinario
)
)

**Explicación:** τ es el operador de ordenamiento (sort).

---
### Proceso RF-05: Gestión de Fichas Médicas

#### 11. Listar todas las fichas médicas con información de la mascota y el veterinario
π ID_Ficha, Diagnostico, Fecha_Registro, Nombre_Mascota, Nombre_Veterinario (
((Ficha_Medica ⋈ (N_Cita=N_Cita) Cita)
⋈ (ID_Mascota=ID_Mascota) Mascota)
⋈ (Rut_Veterinario=Rut_Veterinario) Veterinario
)

#### 12. Encontrar fichas médicas por diagnóstico
σ Diagnostico = 'Dermatitis' (
π ID_Ficha, Diagnostico, Tratamiento, Fecha_Registro, N_Cita (
Ficha_Medica
)
)

#### 13. Listar el historial médico completo de una mascota
π ID_Ficha, Diagnostico, Tratamiento, Fecha_Registro, Nombre_Veterinario (
((Ficha_Medica ⋈ (N_Cita=N_Cita) Cita)
⋈ (Rut_Veterinario=Rut_Veterinario) Veterinario)
⋈ (ID_Mascota=ID_Mascota) (σ ID_Mascota = MASCOTA_ID (Mascota))
)

**Explicación**: MASCOTA_ID es un parámetro que identifica la mascota específica.

---
### Proceso RF-06: Gestión de Productos

#### 14. Listar productos con stock bajo (menos de 10 unidades)
σ Stock < 10 (
π ID_Producto, Nombre_Producto, Stock, Precio_Unitario (Producto)
)

#### 15. Encontrar productos por proveedor
π Nombre_Producto, Precio_Unitario, Stock, Nombre_Proveedor (
Producto ⋈ (Rut_Proveedor=Rut_Proveedor) Proveedor
)

#### 16. Listar productos vencidos o por vencer (en los próximos 30 días)
σ Fecha_Vencimiento ≤ TODAY() + 30 (
π ID_Producto, Nombre_Producto, Fecha_Vencimiento, Stock (Producto)
)

---
### Proceso RF-07: Gestión de Proveedores

#### 17. Listar proveedores con sus productos
π Nombre_Proveedor, Telefono, Nombre_Producto, Precio_Unitario, Stock (
Proveedor ⋈ (Rut_Proveedor=Rut_Proveedor) Producto
)

#### 18. Encontrar proveedores que no han suministrado productos
π Nombre_Proveedor, Telefono (Proveedor) -
π Nombre_Proveedor, Telefono (
Proveedor ⋈ (Rut_Proveedor=Rut_Proveedor) Producto
)

---
### Proceso RF-08: Gestión de Prestaciones

#### 19. Listar todas las prestaciones ordenadas por precio
τ Precio DESC (
π ID_Prestacion, Nombre_Prestacion, Precio, Duracion_Min (Prestacion)
)

#### 20. Encontrar prestaciones por duración
σ Duracion_Min > 30 (
π Nombre_Prestacion, Descripcion, Duracion_Min (Prestacion)
)

---
### Proceso RF-09: Gestión de Ventas

#### 21. Listar ventas con detalles de productos y prestaciones
-- Ventas con productos
π ID_Venta, Fecha_Pago, Monto_Venta, Nombre_Producto, Cantidad, Subtotal (
(Venta ⋈ (ID_Venta=ID_Venta) Detalle_Venta)
⋈ (ID_Producto=ID_Producto) Producto
)
∪
-- Ventas con prestaciones
π ID_Venta, Fecha_Pago, Monto_Venta, Nombre_Prestacion, Cantidad, Subtotal (
(Venta ⋈ (ID_Venta=ID_Venta) Detalle_Prestacion)
⋈ (ID_Prestacion=ID_Prestacion) Prestacion
)

**Explicación**: Unión de ventas con productos y ventas con prestaciones.

#### 22. Encontrar ventas por cajero
π Nombre_Cajero, COUNT() AS Total_Ventas, SUM(Monto_Venta) AS Monto_Total (
γ[Rut_Cajero, Nombre, COUNT() AS Total_Ventas, SUM(Monto_Venta) AS Monto_Total] (
Venta ⋈ (Rut_Cajero=Rut_Cajero) Cajero
)
)

#### 23. Listar ventas por cliente (ordenadas por monto descendente)
τ Monto_Total DESC (
π Nombre_Cliente, COUNT() AS Total_Compras, SUM(Monto_Venta) AS Monto_Total (
γ[Rut_Cliente, Nombre, COUNT() AS Total_Compras, SUM(Monto_Venta) AS Monto_Total] (
Venta ⋈ (Rut_Cliente=Rut_Cliente) Cliente
)
)
)

---
### Proceso RF-10: Reportes de Gestión

#### 24. Reporte de citas por veterinario (conteos por estado)
γ[Nombre_Veterinario, Estado, COUNT(*) AS Total] (
(Cita ⋈ (Rut_Veterinario=Rut_Veterinario) Veterinario)
)

#### 25. Reporte de ventas por período
γ[Fecha_Pago, COUNT(*) AS Total_Ventas, SUM(Monto_Venta) AS Ingresos] (
σ Fecha_Pago ≥ FECHA_INICIO AND Fecha_Pago ≤ FECHA_FIN (Venta)
)

**Explicación**: FECHA_INICIO y FECHA_FIN son parámetros del reporte.

#### 26. Reporte de productos más vendidos
τ Cantidad_Total DESC (
π Nombre_Producto, SUM(Cantidad) AS Cantidad_Total (
γ[ID_Producto, SUM(Cantidad) AS Cantidad_Total] (
Detalle_Venta
) ⋈ (ID_Producto=ID_Producto) Producto
)
)

#### 27. Reporte de ingresos por prestaciones
τ Ingresos_Totales DESC (
π Nombre_Prestacion, SUM(Subtotal) AS Ingresos_Totales (
γ[ID_Prestacion, SUM(Subtotal) AS Ingresos_Totales] (
Detalle_Prestacion
) ⋈ (ID_Prestacion=ID_Prestacion) Prestacion
)
)

#### 28. Reporte de stock actual por producto
π Nombre_Producto, Stock, Precio_Unitario, Nombre_Proveedor (
Producto ⋈ (Rut_Proveedor=Rut_Proveedor) Proveedor
)

#### 29. Reporte de fichas médicas por diagnóstico
γ[Diagnostico, COUNT(*) AS Total, AVG(DATEDIFF(Fecha_Registro, Fecha_Nacimiento)) AS Edad_Promedio] (
(Ficha_Medica ⋈ (N_Cita=N_Cita) Cita)
⋈ (ID_Mascota=ID_Mascota) Mascota
)

**Explicación**: Calcula el número de fichas por diagnóstico y la edad promedio de las mascotas.

#### 30. Reporte de movimientos de inventario por producto
γ[Nombre_Producto, Tipo_Movimiento, SUM(Cantidad) AS Total_Cantidad] (
(Inventario ⋈ (ID_Producto=ID_Producto) Producto)
)

---
## Correspondencia con Reglas de Negocio

Las consultas de álgebra relacional implementan las siguientes reglas de negocio:

1. **R1 - Unicidad de RUT**: Las claves primarias garantizan la unicidad
2. **R2 - Mascota - Cliente**: El join entre Mascota y Cliente implementa esta relación
3. **R3 - Cita - Veterinario**: La restricción de unicidad en (Rut_Veterinario, Bloque_Activo) se implementa en la consulta 8
4. **R4 - Cita - Ficha Médica**: La relación 1:0..1 se refleja en las consultas de fichas médicas
5. **R5 - Venta - Detalles**: Las consultas 21, 22, 23 implementan esta relación
6. **R6 - Inventario**: Las consultas de inventario reflejan los tipos de movimiento
7. **R7 - Stock**: La consulta 14 identifica productos con stock bajo
8. **R8 - Precios**: Las consultas de productos y prestaciones garantizan precios no negativos
9. **R9 - Fechas**: Las consultas de historial de responsables respetan la restricción de fechas

## Notación Adicional

- **σ**: Selección (WHERE)
- **π**: Proyección (SELECT)
- **⋈**: Join natural (INNER JOIN)
- **×**: Producto cartesiano (CROSS JOIN)
- **∪**: Unión (UNION)
- **−**: Diferencia (EXCEPT/MINUS)
- **γ**: Agrupación (GROUP BY)
- **τ**: Ordenamiento (ORDER BY)
- **ρ**: Renombrar (AS)

## Conversión a SQL

Todas estas consultas de álgebra relacional pueden ser convertidas directamente a SQL. Ejemplo:

**Álgebra Relacional:**
π Nombre, Especialidad (Veterinario)

**SQL:**
```sql
SELECT Nombre, Especialidad FROM Veterinario;
Álgebra Relacional:

σ Stock < 10 (Producto)
SQL:

SELECT * FROM Producto WHERE Stock < 10;
Álgebra Relacional:

Cita ⋈ (ID_Mascota=ID_Mascota) Mascota
SQL:

SELECT * FROM Cita INNER JOIN Mascota ON Cita.ID_Mascota = Mascota.ID_Mascota;
