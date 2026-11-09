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
