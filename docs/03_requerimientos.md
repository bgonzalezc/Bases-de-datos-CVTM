# Requerimientos Funcionales y No Funcionales

## Actores del Sistema
   Actor | Descripción | Responsabilidades |
 |-------|-------------|-------------------|
 | **Cliente** | Persona que lleva su mascota al centro o compra productos | Registrar mascotas, agendar citas, realizar compras |
 | **Veterinario** | Profesional médico que atiende las mascotas | Atender citas, crear fichas médicas, diagnosticar |
 | **Cajero** | Empleado que maneja las ventas | Registrar ventas, manejar caja, emitir facturas |
 | **Proveedor** | Empresa que suministra productos | Proveer productos al centro |
 | **Administrador** | Personal de gestión | Gestionar usuarios, reportes, configuración |

---

## Requerimientos Funcionales

### RF-01: Gestión de Clientes
- Registrar nuevos clientes con RUT, nombre, correo, teléfono
- Modificar información de clientes existentes
- Consultar información de clientes
- Eliminar clientes (con restricciones)

### RF-02: Gestión de Mascotas
- Registrar mascotas asociadas a clientes
- Modificar información de mascotas (nombre, especie, raza, fecha nacimiento, sexo)
- Consultar historial de responsables de una mascota
- Transferir propiedad de mascota entre clientes

### RF-03: Gestión de Veterinarios
- Registrar veterinarios con RUT, nombre, especialidad, teléfono
- Modificar información de veterinarios
- Consultar disponibilidad de veterinarios

### RF-04: Gestión de Citas
- Agendar nuevas citas para mascotas con veterinarios
- Modificar estado de citas (pendiente, confirmada, atendida, cancelada, ausente)
- Consultar agenda de citas por veterinario, mascota o fecha
- Cancelar citas

### RF-05: Gestión de Fichas Médicas
- Crear ficha médica asociada a una cita
- Registrar diagnóstico, tratamiento, observaciones
- Consultar historial médico de una mascota
- Buscar fichas por veterinario, fecha o diagnóstico

### RF-06: Gestión de Productos
- Registrar nuevos productos con nombre, precio, stock, fecha vencimiento
- Modificar información de productos
- Consultar inventario de productos
- Registrar movimientos de inventario (entradas y salidas)

### RF-07: Gestión de Proveedores
- Registrar proveedores con RUT, nombre, teléfono, correo, dirección
- Modificar información de proveedores
- Consultar productos suministrados por proveedor

### RF-08: Gestión de Prestaciones
- Registrar servicios médicos con nombre, descripción, precio, duración
- Modificar información de prestaciones
- Consultar catálogo de prestaciones

### RF-09: Gestión de Ventas
- Registrar ventas de productos y/o prestaciones
- Asociar venta a cliente (opcional)
- Registrar detalles de venta (productos y prestaciones)
- Consultar historial de ventas
- Generar reportes de ventas por período, cajero, cliente

### RF-10: Reportes de Gestión
- Reporte de citas por veterinario
- Reporte de ventas por período
- Reporte de productos más vendidos
- Reporte de ingresos por prestaciones
- Reporte de stock de productos
- Reporte de fichas médicas por diagnóstico

---

## Requerimientos No Funcionales

### RNF-01: Rendimiento
- Las consultas de reportes deben ejecutarse en menos de 2 segundos
- El sistema debe soportar hasta 100 transacciones concurrentes

### RNF-02: Disponibilidad
- El sistema debe estar disponible 24/7
- Tiempo máximo de inactividad: 1 hora por mes

### RNF-03: Seguridad
- Acceso controlado por roles y privilegios
- Principio de mínimo privilegio
- Datos sensibles (RUT, información médica) protegidos

### RNF-04: Integridad de Datos
- Todas las restricciones de integridad referencial deben cumplirse
- Las transacciones deben ser ACID
- No se permiten datos inconsistentes

### RNF-05: Escalabilidad
- El modelo debe permitir agregar nuevas entidades sin cambios estructurales mayores
- Debe soportar crecimiento de datos (clientes, mascotas, ventas)

### RNF-06: Usabilidad
- Interfaz intuitiva para usuarios no técnicos
- Mensajes de error claros y útiles
- Documentación completa

---

## Casos de Uso Extendidos (14 casos)

### Casos de Uso de Cliente

#### CU-01: Registrar Cliente
- **Actor principal**: Cajero/Administrador
- **Precondición**: El cliente no existe en el sistema
- **Flujo principal**:
  1. El actor solicita registrar un nuevo cliente
  2. El sistema muestra formulario de registro
  3. El actor ingresa RUT, nombre, correo, teléfono
  4. El sistema valida que el RUT no exista
  5. El sistema guarda el cliente
  6. El sistema confirma el registro
- **Flujo alternativo**: Si el RUT ya existe, el sistema muestra error y vuelve al paso 2
- **Postcondición**: Nuevo cliente registrado en el sistema
- **Término normal**: Cliente registrado exitosamente
- **Término alternativo**: Operación cancelada por el usuario

#### CU-02: Modificar Cliente
- **Actor principal**: Cajero/Administrador
- **Precondición**: El cliente existe en el sistema
- **Flujo principal**:
  1. El actor solicita modificar un cliente
  2. El sistema busca el cliente por RUT
  3. El actor modifica los datos (nombre, correo, teléfono)
  4. El sistema valida los datos
  5. El sistema actualiza el cliente
  6. El sistema confirma la modificación
- **Flujo alternativo**: Si el cliente no existe, el sistema muestra error
- **Postcondición**: Datos del cliente actualizados
- **Término normal**: Cliente modificado exitosamente
- **Término alternativo**: Operación cancelada

#### CU-03: Consultar Cliente
- **Actor principal**: Cualquier usuario autorizado
- **Precondición**: El cliente existe en el sistema
- **Flujo principal**:
  1. El actor ingresa criterios de búsqueda (RUT, nombre)
  2. El sistema busca clientes que coincidan
  3. El sistema muestra lista de clientes
  4. El actor selecciona un cliente
  5. El sistema muestra detalles del cliente
- **Postcondición**: Información del cliente mostrada

### Casos de Uso de Mascota

#### CU-04: Registrar Mascota
- **Actor principal**: Cajero/Administrador
- **Precondición**: El cliente dueño existe en el sistema
- **Flujo principal**:
  1. El actor solicita registrar una nueva mascota
  2. El sistema muestra formulario de registro
  3. El actor ingresa nombre, especie, raza, fecha nacimiento, sexo, RUT cliente
  4. El sistema valida que el cliente exista
  5. El sistema valida que el sexo sea M o H
  6. El sistema guarda la mascota
  7. El sistema registra el historial de responsable (fecha inicio = hoy)
  8. El sistema confirma el registro
- **Flujo alternativo**: Si el cliente no existe o el sexo no es válido, error
- **Postcondición**: Nueva mascota registrada con historial de responsable

#### CU-05: Transferir Mascota
- **Actor principal**: Administrador
- **Precondición**: La mascota existe y ambos clientes existen
- **Flujo principal**:
  1. El actor solicita transferir una mascota a otro cliente
  2. El sistema busca la mascota
  3. El actor selecciona el nuevo cliente
  4. El sistema cierra el registro actual en Historial_Responsable (set Fecha_Fin = hoy)
  5. El sistema crea nuevo registro en Historial_Responsable (Fecha_Inicio = hoy, Fecha_Fin = NULL)
  6. El sistema actualiza el Rut_Cliente de la mascota
  7. El sistema confirma la transferencia
- **Flujo alternativo**: Si la mascota o el cliente no existe, error
- **Postcondición**: Mascota transferida a nuevo cliente, historial actualizado

#### CU-06: Consultar Historial de Responsables
- **Actor principal**: Veterinario/Administrador
- **Precondición**: La mascota existe
- **Flujo principal**:
  1. El actor selecciona una mascota
  2. El sistema consulta Historial_Responsable
  3. El sistema muestra lista de responsables con fechas
- **Postcondición**: Historial mostrado

### Casos de Uso de Citas

#### CU-07: Agendar Cita
- **Actor principal**: Cajero
- **Precondición**: Existen cliente, mascota y veterinario
- **Flujo principal**:
  1. El actor solicita agendar una cita
  2. El sistema muestra formulario con campos: fecha/hora, mascota, veterinario
  3. El actor selecciona mascota y veterinario
  4. El sistema verifica disponibilidad del veterinario (no hay cita activa en ese horario)
  5. El actor confirma
  6. El sistema guarda la cita con estado 'pendiente'
  7. El sistema confirma el agendamiento
- **Flujo alternativo**: Si el veterinario no está disponible o la mascota/veterinario no existen, error
- **Postcondición**: Cita agendada

#### CU-08: Atender Cita
- **Actor principal**: Veterinario
- **Precondición**: La cita existe y está en estado pendiente o confirmada
- **Flujo principal**:
  1. El veterinario selecciona una cita de su agenda
  2. El sistema muestra detalles de la cita
  3. El veterinario marca como atendida
  4. El sistema actualiza estado a 'atendida'
  5. El sistema pregunta si desea crear ficha médica
  6. Si sí, va a CU-09
- **Flujo alternativo**: Si la cita no existe o no es del veterinario, error
- **Postcondición**: Cita marcada como atendida

#### CU-09: Crear Ficha Médica
- **Actor principal**: Veterinario
- **Precondición**: La cita existe, está atendida y no tiene ficha médica
- **Flujo principal**:
  1. El veterinario selecciona una cita atendida
  2. El sistema muestra formulario de ficha médica
  3. El veterinario ingresa diagnóstico, tratamiento, observaciones
  4. El sistema guarda la ficha con fecha actual
  5. El sistema asocia la ficha a la cita y al veterinario
  6. El sistema confirma la creación
- **Flujo alternativo**: Si la cita ya tiene ficha, error
- **Postcondición**: Ficha médica creada y asociada

#### CU-10: Cancelar Cita
- **Actor principal**: Cajero/Cliente
- **Precondición**: La cita existe
- **Flujo principal**:
  1. El actor selecciona una cita
  2. El sistema muestra detalles
  3. El actor confirma cancelación
  4. El sistema actualiza estado a 'cancelada'
  5. El sistema confirma
- **Postcondición**: Cita cancelada

### Casos de Uso de Ventas

#### CU-11: Realizar Venta
- **Actor principal**: Cajero
- **Precondición**: Existen productos/prestaciones disponibles
- **Flujo principal**:
  1. El cajero inicia una nueva venta
  2. El cajero selecciona cliente (opcional)
  3. El cajero agrega productos y/o prestaciones
  4. Para cada producto: seleccionar producto, cantidad, calcular subtotal
  5. Para cada prestación: seleccionar prestación, cantidad, precio aplicado, calcular subtotal
  6. El sistema calcula monto total
  7. El cajero selecciona forma de pago
  8. El sistema guarda la venta
  9. El sistema guarda los detalles
  10. El sistema confirma la venta
- **Flujo alternativo**: Si no hay stock suficiente o el producto/prestación no existe, error
- **Postcondición**: Venta registrada con sus detalles

#### CU-12: Consultar Venta
- **Actor principal**: Cajero/Administrador
- **Precondición**: La venta existe
- **Flujo principal**:
  1. El actor busca venta por ID o fecha
  2. El sistema muestra detalles de la venta
  3. El sistema muestra productos y prestaciones vendidas
- **Postcondición**: Información de venta mostrada

### Casos de Uso de Inventario

#### CU-13: Registrar Movimiento de Inventario
- **Actor principal**: Administrador
- **Precondición**: El producto existe
- **Flujo principal**:
  1. El actor selecciona registrar movimiento
  2. El sistema muestra formulario
  3. El actor selecciona producto, tipo (entrada/salida), cantidad, fecha
  4. Si es entrada, selecciona proveedor
  5. El sistema valida que cantidad > 0
  6. El sistema guarda el movimiento
  7. El sistema confirma
- **Flujo alternativo**: Si el producto no existe o la cantidad no es positiva, error
- **Postcondición**: Movimiento registrado

#### CU-14: Consultar Stock
- **Actor principal**: Cualquier usuario autorizado
- **Precondición**: -
- **Flujo principal**:
  1. El actor solicita consultar stock
  2. El sistema muestra lista de productos con stock actual
  3. El actor puede filtrar por producto o categoría
- **Postcondición**: Stock mostrado
