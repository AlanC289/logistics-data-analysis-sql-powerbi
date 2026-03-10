# logistics-data-analysis-sql-powerbi
Proyecto de limpieza, transformación y análisis de un dataset logístico utilizando SQL y Power BI, incluyendo corrección de calidad de datos, consultas analíticas y un dashboard interactivo.


# Análisis de Datos Logísticos con SQL y Power BI

## Descripción del Proyecto

Este proyecto simula el análisis de datos de una empresa logística utilizando SQL para la limpieza y análisis de datos, y Power BI para la visualización de resultados.

El objetivo fue transformar un conjunto de datos con inconsistencias en información útil para la toma de decisiones operativas, evaluando desempeño de entregas, ingresos y rutas de riesgo.

El proyecto incluye:

- Limpieza y estandarización de datos en SQL
- Corrección de inconsistencias en formatos y valores
- Consultas analíticas para obtener métricas de negocio
- Visualización de resultados mediante un dashboard en Power BI

---

# Estructura del Dataset

El dataset está compuesto por tres tablas que representan diferentes entidades del sistema logístico:

### Tabla: `shipments`
Contiene la información de cada envío realizado.

Columnas principales:

- shipment_id
- pickup_datetime
- delivery_datetime
- distance_km
- shipping_cost
- revenue
- route
- on_time_flag
- driver_id
- customer_id

Esta tabla fue sometida a un proceso de limpieza para asegurar la consistencia de los datos.

---

### Tabla: `drivers`
Contiene la información de los conductores encargados de los envíos.

Columnas principales:

- driver_id
- driver_name
- city
- status

Esta tabla permite analizar el desempeño de los conductores y relacionarlos con los envíos.

---

### Tabla: `customers`
Contiene la información de los clientes que solicitan los envíos.

Columnas principales:

- customer_id
- customer_name
- city
- segment

Esta tabla permite analizar patrones de envíos por tipo de cliente o ubicación.

---

# Proceso de Limpieza de Datos

Se realizó un proceso de limpieza sobre la tabla `shipments` para mejorar la calidad del dataset antes del análisis.

Entre las tareas realizadas se incluyen:

- Estandarización de múltiples formatos de fecha
- Corrección de valores numéricos inconsistentes
- Manejo de valores nulos
- Normalización de variables clave
- Validación de campos utilizados para cálculos

Se utilizaron sentencias SQL como:

- `UPDATE`
- `CASE`
- conversiones de tipo de datos
- validaciones condicionales

El objetivo fue asegurar que los datos fueran confiables para el análisis posterior.

---

# Consultas de Análisis

Se desarrollaron varias consultas SQL para analizar el desempeño de la operación logística.

Algunos de los análisis realizados incluyen:

### 1. Porcentaje de entregas a tiempo
Cálculo del porcentaje de envíos entregados dentro del tiempo esperado.

### 2. Análisis de ingresos
Evaluación del ingreso total generado por los envíos.

### 3. Rutas con mayor riesgo operativo
Identificación de rutas que presentan mayor impacto negativo en los ingresos debido a retrasos.

### 4. Volumen de envíos
Análisis del número total de envíos realizados.

### 5. Comparación entre costos y ganancias
Evaluación de la rentabilidad de los envíos.

### 6. Análisis operativo general
Evaluación de indicadores clave de desempeño logístico.

---

# Dashboard en Power BI

Se desarrolló un dashboard interactivo para visualizar las métricas clave del análisis.

El dashboard permite analizar:

- Ingresos totales
- Volumen de envíos
- Porcentaje de entregas a tiempo
- Rutas con mayor impacto operativo



# Archivos del Proyecto

El repositorio contiene los siguientes recursos:
-Dataset:
  - 01_customers.csv
  - 02_drivers.csv
  - 03_shipments_dirty.csv (tabla a limpiar)
-Análisis Retail & Ventas.ppbix
-Script limpieza end-to-end.sql
-Script_analisis.sql
   
