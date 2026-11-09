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
