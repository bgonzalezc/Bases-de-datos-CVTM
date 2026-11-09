# Diagrama de Casos de Uso - CVTM

## Descripción

El diagrama de casos de uso describe las interacciones entre los actores y el sistema CVTM. Incluye todos los procesos identificados en los requerimientos funcionales.

## Actores

1. **Cliente**: Persona que lleva su mascota al centro o compra productos
2. **Veterinario**: Profesional que atiende las mascotas
3. **Cajero**: Empleado que maneja las ventas
4. **Proveedor**: Empresa que suministra productos
5. **Administrador**: Personal de gestión

## Casos de Uso por Actor

### Actor: Cliente
- Consultar información de sus mascotas
- Agendar citas para sus mascotas
- Consultar historial médico de sus mascotas
- Realizar compras de productos

### Actor: Veterinario
- Consultar agenda de citas
- Atender citas
- Crear fichas médicas
- Consultar historial médico de mascotas

### Actor: Cajero
- Registrar clientes
- Registrar mascotas
- Agendar citas
- Realizar ventas
- Consultar información de productos

### Actor: Proveedor
- Proveer productos (interacción indirecta a través del administrador)

### Actor: Administrador
- Gestionar usuarios (veterinarios, cajeros)
- Gestionar proveedores
- Gestionar productos
- Registrar movimientos de inventario
- Generar reportes
- Transferir mascotas entre clientes

## Diagrama UML

El diagrama completo en notación UML está disponible en:
- `diagrama_casos_uso.drawio` - Formato editable
- `diagrama_casos_uso.png` - Imagen exportada

## Relaciones entre Casos de Uso

### Inclusión (<<include>>)
- **Atender Cita** incluye **Consultar Agenda** (el veterinario debe ver su agenda para atender)
- **Realizar Venta** incluye **Consultar Stock** (el cajero debe verificar disponibilidad)
- **Crear Ficha Médica** incluye **Consultar Cita** (el veterinario debe ver los detalles de la cita)

### Extensión (<<extend>>)
- **Agendar Cita** puede extenderse a **Crear Ficha Médica** (si se agendó para un control específico)
- **Atender Cita** se extiende con **Crear Ficha Médica** (opcional después de atender)

### Generalización
- **Gestionar Usuarios** generaliza a **Registrar Veterinario**, **Registrar Cajero**, **Modificar Usuario**
- **Gestionar Productos** generaliza a **Registrar Producto**, **Modificar Producto**, **Eliminar Producto**

## Detalle de Casos de Uso

Para el detalle completo de cada caso de uso (precondiciones, flujos, postcondiciones), consultar:
- [03_requerimientos.md](../03_requerimientos.md) - Sección "Casos de Uso Extendidos"
