# Reglas de Negocio Detalladas

## Reglas de Integridad

### R1: Unicidad de RUT
- Todos los actores (Cliente, Veterinario, Cajero, Proveedor) tienen RUT único
- El RUT es el identificador principal y no puede repetirse

### R2: Mascota - Cliente
- Una mascota debe pertenecer a un cliente existente (FK obligatoria)
- El historial de responsables permite rastrear todos los dueños de una mascota
- Al eliminar un cliente, las mascotas asociadas no pueden eliminarse (RESTRICT)

### R3: Cita - Veterinario
- Una cita debe ser con un veterinario existente
- Un veterinario no puede tener dos citas activas en el mismo horario
- Se implementa con una columna generada `Bloque_Activo` que es NULL para citas canceladas/ausentes
- La combinación (Rut_Veterinario, Bloque_Activo) debe ser única

### R4: Cita - Ficha Médica
- Una cita puede generar como máximo una ficha médica (relación 1:0..1)
- La ficha médica debe referenciar una cita existente
- No es obligatorio que toda cita tenga ficha médica

### R5: Venta - Detalles
- Una venta puede tener múltiples productos (Detalle_Venta)
- Una venta puede tener múltiples prestaciones (Detalle_Prestacion)
- El subtotal de cada detalle debe ser positivo
- La cantidad en detalles debe ser positiva

### R6: Inventario
- Los movimientos de inventario pueden ser de tipo 'entrada' o 'salida'
- La cantidad en movimientos debe ser positiva
- Las entradas pueden tener un proveedor asociado
- Las salidas no tienen proveedor (NULL)

### R7: Stock
- El stock de un producto no puede ser negativo
- El stock inicial es 0 por defecto
- Los movimientos de inventario deberían afectar el stock (actualmente no está automatizado)

### R8: Precios
- Todos los precios (productos, prestaciones, subtotales) deben ser no negativos
- El monto de una venta debe ser no negativo

### R9: Fechas
- La fecha de fin en Historial_Responsable debe ser >= fecha de inicio
- Las fechas de citas, ventas, fichas médicas deben ser coherentes temporalmente

## Reglas de Proceso

### P1: Agendar Cita
- **Precondición**: Existe cliente, mascota y veterinario
- **Proceso**: Verificar disponibilidad del veterinario en el horario
- **Postcondición**: Cita creada con estado 'pendiente' por defecto
- **Flujo alternativo**: Si el veterinario no está disponible, error
- **Término normal**: Cita agendada exitosamente
- **Término alternativo**: Operación cancelada por el usuario

### P2: Atender Cita
- **Precondición**: Cita existe y está en estado 'confirmada' o 'pendiente'
- **Proceso**: Cambiar estado a 'atendida', opcionalmente crear ficha médica
- **Postcondición**: Cita marcada como atendida
- **Flujo alternativo**: Si la cita no existe o no es del veterinario, error
- **Término normal**: Cita atendida
- **Término alternativo**: Operación cancelada

### P3: Crear Ficha Médica
- **Precondición**: Cita existe, está atendida y no tiene ficha médica
- **Proceso**: Registrar diagnóstico, tratamiento y observaciones
- **Postcondición**: Ficha médica creada y asociada a la cita
- **Flujo alternativo**: Si la cita ya tiene ficha, error
- **Término normal**: Ficha médica creada
- **Término alternativo**: Operación cancelada

### P4: Realizar Venta
- **Precondición**: Existen productos/prestaciones disponibles
- **Proceso**: Registrar venta con detalles, actualizar stock (manual)
- **Postcondición**: Venta registrada, detalles creados
- **Flujo alternativo**: Si no hay stock suficiente, error
- **Término normal**: Venta registrada
- **Término alternativo**: Operación cancelada

### P5: Mover Inventario
- **Precondición**: El producto existe
- **Proceso**: Registrar movimiento con tipo, cantidad, fecha
- **Postcondición**: Movimiento registrado
- **Flujo alternativo**: Si el producto no existe o la cantidad no es positiva, error
- **Término normal**: Movimiento registrado
- **Término alternativo**: Operación cancelada

### P6: Cambiar Dueño de Mascota
- **Precondición**: Existen cliente actual y nuevo cliente
- **Proceso**: Cerrar registro actual en Historial_Responsable (set Fecha_Fin = hoy), crear nuevo registro
- **Postcondición**: Historial actualizado, mascota asociada a nuevo cliente
- **Flujo alternativo**: Si la mascota o el cliente no existen, error
- **Término normal**: Mascota transferida
- **Término alternativo**: Operación cancelada

## Restricciones de Negocio No Implementadas

Las siguientes reglas requieren triggers o lógica adicional:

1. **Stock automático**: El stock de Producto no se actualiza automáticamente con movimientos de Inventario
2. **Subtotal calculado**: No se verifica que Subtotal = Cantidad × Precio en Detalle_Venta y Detalle_Prestacion
3. **Ficha médica - Veterinario**: No se verifica que la ficha sea firmada por el mismo veterinario de la cita
4. **Colisión horaria**: Solo se detecta cuando citas comienzan a la misma hora exacta, no ante traslapes por duración
5. **Venta - Cita**: No hay relación directa entre ventas y citas
