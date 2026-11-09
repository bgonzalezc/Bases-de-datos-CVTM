# Normalización a 3FN - CVTM

## Introducción

La normalización es el proceso de organizar los datos en una base de datos para minimizar la redundancia y las dependencias. Este documento describe cómo el modelo CVTM cumple con la **Tercera Forma Normal (3FN)**.

## Formas Normales

### Primera Forma Normal (1FN)
- Cada tabla tiene una clave primaria
- Todos los atributos son atómicos (no hay grupos repetitivos)
- No hay atributos multivaluados

**Cumplimiento**: Todas las tablas del modelo CVTM cumplen con 1FN.

### Segunda Forma Normal (2FN)
- Cumple con 1FN
- Todos los atributos no clave dependen completamente de la clave primaria (no hay dependencias parciales)

**Cumplimiento**: Todas las tablas cumplen con 2FN. Las tablas con claves compuestas (Detalle_Venta, Detalle_Prestacion) tienen todos sus atributos dependiendo de la clave completa.

### Tercera Forma Normal (3FN)
- Cumple con 2FN
- No hay dependencias transitivas (los atributos no clave no dependen de otros atributos no clave)

**Cumplimiento**: Todas las tablas cumplen con 3FN.

## Análisis de Normalización por Tabla

### 1. Cliente
Clave primaria: Rut_Cliente
Atributos: Nombre, Correo_Electronico, Telefono

- ✅ **1FN**: Todos los atributos son atómicos
- ✅ **2FN**: No hay dependencias parciales (solo una PK)
- ✅ **3FN**: No hay dependencias transitivas
  - Nombre depende de Rut_Cliente
  - Correo_Electronico depende de Rut_Cliente
  - Telefono depende de Rut_Cliente

### 2. Veterinario
Clave primaria: Rut_Veterinario
Atributos: Nombre, Especialidad, Telefono

- ✅ **1FN**: Todos los atributos son atómicos
- ✅ **2FN**: No hay dependencias parciales
- ✅ **3FN**: No hay dependencias transitivas
  - Todos los atributos dependen directamente de Rut_Veterinario

### 3. Cajero
Clave primaria: Rut_Cajero
Atributos: Nombre, Turno

- ✅ **1FN**: Todos los atributos son atómicos
- ✅ **2FN**: No hay dependencias parciales
- ✅ **3FN**: No hay dependencias transitivas

### 4. Proveedor
Clave primaria: Rut_Proveedor
Atributos: Nombre_Proveedor, Telefono, Correo_Electronico, Direccion

- ✅ **1FN**: Todos los atributos son atómicos
- ✅ **2FN**: No hay dependencias parciales
- ✅ **3FN**: No hay dependencias transitivas

### 5. Mascota
Clave primaria: ID_Mascota
Clave foránea: Rut_Cliente
Atributos: Nombre, Especie, Raza, Fecha_Nacimiento, Sexo

- ✅ **1FN**: Todos los atributos son atómicos
- ✅ **2FN**: No hay dependencias parciales
- ✅ **3FN**: No hay dependencias transitivas
  - Todos los atributos dependen directamente de ID_Mascota
  - Rut_Cliente es FK y depende de ID_Mascota

### 6. Historial_Responsable
Clave primaria: ID_Historial
Claves foráneas: ID_Mascota, Rut_Cliente
Atributos: Fecha_Inicio, Fecha_Fin

- ✅ **1FN**: Todos los atributos son atómicos
- ✅ **2FN**: No hay dependencias parciales
- ✅ **3FN**: No hay dependencias transitivas

### 7. Prestacion
Clave primaria: ID_Prestacion
Atributos: Nombre_Prestacion, Descripcion, Precio, Duracion_Min

- ✅ **1FN**: Todos los atributos son atómicos
- ✅ **2FN**: No hay dependencias parciales
- ✅ **3FN**: No hay dependencias transitivas

### 8. Producto
Clave primaria: ID_Producto
Clave foránea: Rut_Proveedor
Atributos: Nombre_Producto, Precio_Unitario, Stock, Fecha_Vencimiento

- ✅ **1FN**: Todos los atributos son atómicos
- ✅ **2FN**: No hay dependencias parciales
- ✅ **3FN**: No hay dependencias transitivas
  - Todos los atributos dependen directamente de ID_Producto
  - Rut_Proveedor es FK y depende de ID_Producto

### 9. Cita
Clave primaria: N_Cita
Claves foráneas: ID_Mascota, Rut_Veterinario
Atributos: Fecha_Hora, Estado, Bloque_Activo (generada)

- ✅ **1FN**: Todos los atributos son atómicos
- ✅ **2FN**: No hay dependencias parciales
- ✅ **3FN**: No hay dependencias transitivas
  - Bloque_Activo es una columna generada basada en Estado y Fecha_Hora

### 10. Venta
Clave primaria: ID_Venta
Claves foráneas: Rut_Cliente, Rut_Cajero
Atributos: Fecha_Pago, Monto_Venta, Forma_Pago

- ✅ **1FN**: Todos los atributos son atómicos
- ✅ **2FN**: No hay dependencias parciales
- ✅ **3FN**: No hay dependencias transitivas

### 11. Ficha_Medica
Clave primaria: ID_Ficha
Claves foráneas: N_Cita, Rut_Veterinario
Atributos: Diagnostico, Tratamiento, Observaciones, Fecha_Registro

- ✅ **1FN**: Todos los atributos son atómicos
- ✅ **2FN**: No hay dependencias parciales
- ✅ **3FN**: No hay dependencias transitivas

### 12. Inventario
Clave primaria: ID_Movimiento
Claves foráneas: ID_Producto, Rut_Proveedor
Atributos: Tipo_Movimiento, Cantidad, Fecha_Movimiento

- ✅ **1FN**: Todos los atributos son atómicos
- ✅ **2FN**: No hay dependencias parciales
- ✅ **3FN**: No hay dependencias transitivas

### 13. Detalle_Venta
Clave primaria compuesta: (ID_Venta, ID_Producto)
Claves foráneas: ID_Venta → Venta, ID_Producto → Producto
Atributos: Cantidad, Subtotal

- ✅ **1FN**: Todos los atributos son atómicos
- ✅ **2FN**: No hay dependencias parciales
  - Cantidad y Subtotal dependen de TODA la clave (ID_Venta + ID_Producto)
- ✅ **3FN**: No hay dependencias transitivas

### 14. Detalle_Prestacion
Clave primaria compuesta: (ID_Venta, ID_Prestacion)
Claves foráneas: ID_Venta → Venta, ID_Prestacion → Prestacion
Atributos: Cantidad, Precio_Aplicado, Subtotal

- ✅ **1FN**: Todos los atributos son atómicos
- ✅ **2FN**: No hay dependencias parciales
  - Todos los atributos dependen de TODA la clave
- ✅ **3FN**: No hay dependencias transitivas

## Verificación de Dependencias Transitivas

Se analizó cada tabla para identificar posibles dependencias transitivas:

1. **Cliente**: No hay dependencias transitivas. Todos los atributos dependen directamente de Rut_Cliente.

2. **Veterinario**: No hay dependencias transitivas.

3. **Producto**:
   - Precio_Unitario depende de ID_Producto (no de Rut_Proveedor)
   - Stock depende de ID_Producto
   - Fecha_Vencimiento depende de ID_Producto
   - No hay dependencia transitiva a través de Rut_Proveedor

4. **Cita**:
   - Bloque_Activo es una columna generada, no una dependencia transitiva

5. **Venta**:
   - Monto_Venta podría calcularse a partir de los detalles, pero se almacena como atributo
   - No hay dependencia transitiva

## Conclusión

El modelo relacional de CVTM cumple con la **Tercera Forma Normal (3FN)** en todas sus tablas. No existen:
- Atributos multivaluados (1FN)
- Dependencias parciales (2FN)
- Dependencias transitivas (3FN)

El diseño está optimizado para minimizar la redundancia y garantizar la integridad de los datos.

## Recomendaciones

Aunque el modelo cumple con 3FN, se recomienda considerar:

1. **Normalización adicional (BCNF)**: No es necesaria actualmente, ya que no hay dependencias funcionales que violen BCNF.

2. **Desnormalización controlada**: Para mejorar el rendimiento de consultas frecuentes, se podrían crear vistas materializadas o añadir algunos atributos redundantes (como el nombre del cliente en Venta), pero esto debe evaluarse según los requisitos de rendimiento.

3. **Triggers para integridad**: Implementar triggers para mantener la integridad referencial en casos complejos (como actualizar el stock automáticamente).
