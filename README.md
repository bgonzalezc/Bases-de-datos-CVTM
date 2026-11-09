# CVTM – Base de Datos: Centro Veterinario y Tienda de Mascotas
Implementación en **MySQL 8.0** de la base de datos `veterinaria_db` para un centro veterinario con tienda de mascotas (CVTM).
Proyecto del ramo **Bases de Datos**, Facultad de Ingeniería, Universidad San Sebastián, Bellavista, Chile.
## Integrantes
- Bastian Aguilar Araya
- Nicolas Cifuentes Westhoff
- Benjamín González
- Neil Osorio Morán
- Eydan Seguel Perez
## Qué incluye
- **14 tablas** para gestionar clientes, mascotas, responsables, veterinarios, citas, fichas médicas, prestaciones, productos, inventario y ventas.
- **16 claves foráneas** con reglas `ON UPDATE CASCADE` y `ON DELETE RESTRICT` / `SET NULL`, según corresponda.
- **15 restricciones CHECK** para validar los datos.
- **2 restricciones UNIQUE** para evitar duplicaciones específicas.
- Valores por defecto para `Cita.Estado` y `Producto.Stock`.
- Diccionario de datos con la descripción de cada tabla.
- Datos de prueba: **3 registros por tabla (42 en total)**.
- Consultas de verificación y 23 pruebas de restricciones (P1 a P23).
## Estructura del proyecto
```text
.
├── README.md
├── run_all.sh
├── docs/
│   └── diccionario_datos.md
└── sql/
    ├── 01_crear_tablas.sql
    ├── 02_restricciones.sql
    ├── 03_datos_prueba.sql
    ├── 04_consultas_verificacion.sql
    └── 05_pruebas_restricciones.sql

Descripción de los scripts

Archivo	Descripción
01_crear_tablas.sql	Crea la base de datos, las 14 tablas y sus claves primarias.
02_restricciones.sql	Agrega claves foráneas, restricciones UNIQUE, CHECK y valores DEFAULT.
03_datos_prueba.sql	Inserta 3 registros por tabla para probar el funcionamiento de la base de datos.
04_consultas_verificacion.sql	Ejecuta consultas JOIN para comprobar las relaciones entre tablas.
05_pruebas_restricciones.sql	Contiene 23 pruebas diseñadas para comprobar que las restricciones impidan operaciones inválidas.

Cómo ejecutar el proyecto

Requisitos

* MySQL 8.0.
* MySQL Workbench o cliente de consola mysql.
* Git (opcional, para clonar el repositorio).

Clonar el repositorio

git clone https://github.com/bgonzalezc/Bases-de-datos-CVTM.git
cd Bases-de-datos-CVTM

Ejecución automática

En Linux o macOS:

./run_all.sh root

El script run_all.sh ejecuta los archivos 01, 02 y 03 en orden. No ejecuta las consultas de verificación ni las pruebas de restricciones.

Ejecución manual

Los scripts deben ejecutarse en el siguiente orden:

Paso	Archivo	Resultado esperado
1	sql/01_crear_tablas.sql	Creación de las 14 tablas.
2	sql/02_restricciones.sql	Creación de claves foráneas y restricciones.
3	sql/03_datos_prueba.sql	Inserción de 42 registros de prueba.
4	sql/04_consultas_verificacion.sql	Visualización de relaciones mediante consultas JOIN.

Verificar las restricciones

Para consultar la cantidad de restricciones registradas en la base de datos:

SELECT CONSTRAINT_TYPE, COUNT(*)
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'veterinaria_db'
GROUP BY CONSTRAINT_TYPE;

Parte C: pruebas de restricciones

El archivo sql/05_pruebas_restricciones.sql contiene 23 pruebas (P1 a P23) destinadas a comprobar que las restricciones de integridad funcionen correctamente.

Importante: este archivo utiliza sus propios datos de prueba. Por lo tanto, no debe ejecutarse sobre la base de datos que ya contiene los registros del paso 3.

Para ejecutarlo:

* Recrear la base de datos.
* Ejecutar 01_crear_tablas.sql.
* Ejecutar 02_restricciones.sql.
* Ejecutar 05_pruebas_restricciones.sql sentencia por sentencia.

Las operaciones inválidas deben producir errores de MySQL. Entre los códigos esperados se encuentran:

* 1452: incumplimiento de clave foránea al insertar.
* 1451: incumplimiento de RESTRICT al eliminar.
* 1062: duplicación de un valor UNIQUE.
* 3819: incumplimiento de una restricción CHECK.
* 1048 y 1364: problemas relacionados con valores NOT NULL.

Reiniciar la base de datos

Para repetir una ejecución desde cero:

DROP DATABASE IF EXISTS veterinaria_db;

Después, volver a ejecutar los scripts desde el paso 1.

Limitaciones conocidas del modelo

* No se verifica automáticamente que Subtotal = Cantidad × Precio.
* El campo Producto.Stock no se actualiza automáticamente mediante los movimientos registrados en Inventario.
* La ficha médica no exige que el veterinario que la registra sea el mismo que atendió la cita.
* La validación de colisiones horarias solo detecta citas que comienzan exactamente a la misma hora; no considera traslapes según la duración.
* La restricción UNIQUE de N_Cita permite como máximo una ficha médica por cita, pero no obliga a que todas las citas tengan una ficha.

Estas funcionalidades podrían implementarse mediante triggers o restricciones adicionales y se consideran posibles mejoras futuras.

Documentación

El detalle de cada tabla, sus atributos, tipos de datos, claves, nulidad y descripción se encuentra en:

docs/diccionario_datos.md⁠￼