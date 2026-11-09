# Modelo Entidad-Relación - CVTM

## Descripción

El modelo Entidad-Relación (ER) representa la estructura lógica de la base de datos CVTM, identificando entidades, atributos y relaciones entre ellas.

## Entidades Fuertes

Las entidades fuertes son aquellas que pueden existir por sí mismas y tienen una clave primaria que las identifica de manera única.

### 1. Cliente
- **Clave primaria**: Rut_Cliente (VARCHAR(12))
- **Atributos**:
  - Nombre (VARCHAR(100)) - NOT NULL
  - Correo_Electronico (VARCHAR(100)) - NULL
  - Telefono (VARCHAR(15)) - NULL
- **Descripción**: Persona que es dueña de mascotas y/o compra productos

### 2. Veterinario
- **Clave primaria**: Rut_Veterinario (VARCHAR(12))
- **Atributos**:
  - Nombre (VARCHAR(100)) - NOT NULL
  - Especialidad (VARCHAR(60)) - NULL
  - Telefono (VARCHAR(15)) - NULL
- **Descripción**: Profesional médico que atiende las mascotas

### 3. Cajero
- **Clave primaria**: Rut_Cajero (VARCHAR(12))
- **Atributos**:
  - Nombre (VARCHAR(100)) - NOT NULL
  - Turno (VARCHAR(20)) - NULL
- **Descripción**: Empleado que maneja las ventas

### 4. Proveedor
- **Clave primaria**: Rut_Proveedor (VARCHAR(12))
- **Atributos**:
  - Nombre_Proveedor (VARCHAR(100)) - NOT NULL
  - Telefono (VARCHAR(15)) - NULL
  - Correo_Electronico (VARCHAR(100)) - NULL
  - Direccion (VARCHAR(150)) - NULL
- **Descripción**: Empresa que suministra productos al centro

### 5. Prestacion
- **Clave primaria**: ID_Prestacion (INT, AUTO_INCREMENT)
- **Atributos**:
  - Nombre_Prestacion (VARCHAR(100)) - NOT NULL
  - Descripcion (VARCHAR(255)) - NULL
  - Precio (DECIMAL(10,2)) - NOT NULL
  - Duracion_Min (INT) - NULL
- **Descripción**: Servicio médico ofrecido por el centro

## Entidades Débiles

Las entidades débiles son aquellas que dependen de otra entidad para su existencia.

### 1. Mascota
- **Clave primaria**: ID_Mascota (INT, AUTO_INCREMENT)
- **Clave foránea**: Rut_Cliente (VARCHAR(12)) - REFERENCES Cliente(Rut_Cliente)
- **Atributos**:
  - Nombre (VARCHAR(50)) - NOT NULL
  - Especie (VARCHAR(30)) - NULL
  - Raza (VARCHAR(50)) - NULL
  - Fecha_Nacimiento (DATE) - NULL
  - Sexo (CHAR(1)) - NULL
- **Descripción**: Animal que recibe atención veterinaria. Depende de un cliente.

### 2. Historial_Responsable
- **Clave primaria**: ID_Historial (INT, AUTO_INCREMENT)
- **Claves foráneas**: ID_Mascota (INT), Rut_Cliente (VARCHAR(12))
- **Atributos**:
  - Fecha_Inicio (DATE) - NOT NULL
  - Fecha_Fin (DATE) - NULL
- **Descripción**: Registra los cambios de dueño de una mascota. Depende de una mascota y un cliente.

### 3. Cita
- **Clave primaria**: N_Cita (INT, AUTO_INCREMENT)
- **Claves foráneas**: ID_Mascota (INT), Rut_Veterinario (VARCHAR(12))
- **Atributos**:
  - Fecha_Hora (DATETIME) - NOT NULL
  - Estado (VARCHAR(20)) - NOT NULL
  - Bloque_Activo (DATETIME) - GENERATED
- **Descripción**: Agendamiento de atención veterinaria. Depende de una mascota y un veterinario.

### 4. Venta
- **Clave primaria**: ID_Venta (INT, AUTO_INCREMENT)
- **Claves foráneas**: Rut_Cliente (VARCHAR(12)), Rut_Cajero (VARCHAR(12))
- **Atributos**:
  - Fecha_Pago (DATE) - NOT NULL
  - Monto_Venta (DECIMAL(10,2)) - NOT NULL
  - Forma_Pago (VARCHAR(20)) - NULL
- **Descripción**: Transacción de venta. Depende de un cajero, opcionalmente de un cliente.

### 5. Ficha_Medica
- **Clave primaria**: ID_Ficha (INT, AUTO_INCREMENT)
- **Claves foráneas**: N_Cita (INT), Rut_Veterinario (VARCHAR(12))
- **Atributos**:
  - Diagnostico (VARCHAR(255)) - NOT NULL
  - Tratamiento (VARCHAR(255)) - NULL
  - Observaciones (VARCHAR(255)) - NULL
  - Fecha_Registro (DATE) - NOT NULL
- **Descripción**: Registro clínico de una atención. Depende de una cita y un veterinario.

### 6. Producto
- **Clave primaria**: ID_Producto (INT, AUTO_INCREMENT)
- **Clave foránea**: Rut_Proveedor (VARCHAR(12))
- **Atributos**:
  - Nombre_Producto (VARCHAR(100)) - NOT NULL
  - Precio_Unitario (DECIMAL(10,2)) - NOT NULL
  - Stock (INT) - NOT NULL, DEFAULT 0
  - Fecha_Vencimiento (DATE) - NULL
- **Descripción**: Artículo comercializado en la tienda. Opcionalmente suministro por un proveedor.

### 7. Inventario
- **Clave primaria**: ID_Movimiento (INT, AUTO_INCREMENT)
- **Claves foráneas**: ID_Producto (INT), Rut_Proveedor (VARCHAR(12))
- **Atributos**:
  - Tipo_Movimiento (VARCHAR(20)) - NOT NULL
  - Cantidad (INT) - NOT NULL
  - Fecha_Movimiento (DATETIME) - NOT NULL
- **Descripción**: Movimiento de stock de productos. Depende de un producto.

### 8. Detalle_Venta
- **Clave primaria compuesta**: (ID_Venta, ID_Producto)
- **Claves foráneas**: ID_Venta → Venta, ID_Producto → Producto
- **Atributos**:
  - Cantidad (INT) - NOT NULL
  - Subtotal (DECIMAL(10,2)) - NOT NULL
- **Descripción**: Productos incluidos en una venta

### 9. Detalle_Prestacion
- **Clave primaria compuesta**: (ID_Venta, ID_Prestacion)
- **Claves foráneas**: ID_Venta → Venta, ID_Prestacion → Prestacion
- **Atributos**:
  - Cantidad (INT) - NOT NULL
  - Precio_Aplicado (DECIMAL(10,2)) - NOT NULL
  - Subtotal (DECIMAL(10,2)) - NOT NULL
- **Descripción**: Servicios incluidos en una venta

## Relaciones

### Relaciones 1:N (Uno a Muchos)

1. **Cliente → Mascota**: Un cliente puede tener muchas mascotas
2. **Cliente → Historial_Responsable**: Un cliente puede ser responsable de muchas mascotas
3. **Mascota → Historial_Responsable**: Una mascota puede tener un historial de responsables
4. **Mascota → Cita**: Una mascota puede tener muchas citas
5. **Veterinario → Cita**: Un veterinario puede tener muchas citas
6. **Cita → Ficha_Medica**: Una cita puede generar una ficha médica (0..1)
7. **Veterinario → Ficha_Medica**: Un veterinario puede firmar muchas fichas
8. **Cajero → Venta**: Un cajero puede realizar muchas ventas
9. **Cliente → Venta**: Un cliente puede realizar muchas ventas
10. **Venta → Detalle_Venta**: Una venta puede incluir muchos productos
11. **Venta → Detalle_Prestacion**: Una venta puede incluir muchas prestaciones
12. **Producto → Detalle_Venta**: Un producto puede estar en muchas ventas
13. **Prestacion → Detalle_Prestacion**: Una prestación puede estar en muchas ventas
14. **Proveedor → Producto**: Un proveedor puede suministrar muchos productos
15. **Producto → Inventario**: Un producto puede tener muchos movimientos
16. **Proveedor → Inventario**: Un proveedor puede estar asociado a muchos movimientos

### Relaciones M:N (Muchos a Muchos)

1. **Venta ↔ Producto**: Resuelta mediante la entidad **Detalle_Venta**
2. **Venta ↔ Prestacion**: Resuelta mediante la entidad **Detalle_Prestacion**

## Diagrama ER

El diagrama Entidad-Relación completo está disponible en:
- `modelo_er.drawio` - Formato editable
- `modelo_er.png` - Imagen exportada

## Notación

- **Entidades**: Rectángulos
- **Atributos**: Óvalos conectados a entidades
- **Claves primarias**: Atributos subrayados
- **Claves foráneas**: Atributos con flecha hacia la entidad referenciada
- **Relaciones**: Líneas que conectan entidades con rombos
- **Cardinalidad**: 1 (uno), N (muchos), 0..1 (cero o uno)
