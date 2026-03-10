use portfolio;
SET SQL_SAFE_UPDATES = 0;
-- ----------------------------------------------------------------
-- Limpieza de un dataset simulando una empresa de retail & ventas
-- ----------------------------------------------------------------

-- -------------------------------
-- Creación e importación de tablas
-- -------------------------------

-- Customers (01_customers.csv)
-- ----------------------------------
USE portfolio;
CREATE TABLE customers 
(
customer_id VARCHAR(6) PRIMARY KEY,
company_name VARCHAR(30),
industry VARCHAR(30),
city VARCHAR(30),
state VARCHAR(10),
country VARCHAR(3),
contract_tier VARCHAR(20),
contract_start_date DATE
);

SET GLOBAL local_infile =1;
LOAD DATA LOCAL INFILE 'C:/Users/alan_/OneDrive/Escritorio/Proyecto II/01_customers.csv'
INTO TABLE customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
SHOW VARIABLES LIKE 'local_infile';

SELECT * FROM customers;

-- drivers (02_drivers.csv)
-- --------------------------------------
CREATE TABLE drivers
(
driver_id VARCHAR(6) PRIMARY KEY,
full_name VARCHAR(30),
vehicle_type VARCHAR(20),
hub_city VARCHAR(20),
hub_state VARCHAR(10),
hire_date DATE,
status VARCHAR(15)
);

LOAD DATA LOCAL INFILE 'C:/Users/alan_/OneDrive/Escritorio/Proyecto II/02_drivers.csv'
INTO TABLE drivers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT * FROM drivers;

-- shipments (Tabla sucia) (03_shipments_dirty.csv)
-- Se creará una tabla STAGGING, con todas las columnas como texto para facilitar importación.
-- Posterior a la limpieza se normalizarán los campos para el análisis de métricas
-- ---------------------------
CREATE TABLE shipments_dirty
(
shipment_id TEXT,
customer_id TEXT,
driver_id TEXT,
origin_city TEXT,
origin_state TEXT,
destination_city TEXT,
destination_state TEXT,
created_at TEXT,
pickup_datetime TEXT,
delivered_datetime TEXT,
status TEXT,
distance_km TEXT,
weight_kg TEXT,
volume_m3 TEXT,
base_cost_mxn TEXT,
fuel_surcharge_mxn TEXT,
total_cost_mxn TEXT,
on_time_flag TEXT,
damage_flag TEXT,
tracking_events_count TEXT,
notes TEXT
);



LOAD DATA LOCAL INFILE 'C:/Users/alan_/OneDrive/Escritorio/Proyecto II/03_shipments_dirty.csv'
INTO TABLE shipments_dirty
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
SELECT * FROM shipments_dirty;

-- Creación de tabla limpia para preservación de dataset original

CREATE TABLE shipments_limp AS SELECT * FROM shipments_dirty;
SELECT * FROM shipments_limp;


-- --------------------------------------------------------------------
-- Limpieza de fechas (created_at, pickup_datetime, delivered_datetime)
-- --------------------------------------------------------------------
ALTER TABLE shipments_limp
ADD COLUMN created_at_dt DATETIME NULL,
ADD COLUMN pickup_datetime_dt DATETIME NULL,
ADD COLUMN delivered_datetime_dt DATETIME NULL;

-- -------------------------------------
-- created_at = 18,248 filas afectadas
-- -------------------------------------

UPDATE shipments_limp
SET created_at_dt = 
CASE
-- vaçio / null
WHEN created_at IS NULL OR created_at= '' THEN NULL
-- Formato YYYY-MM-DD HH:MM:SS (2024-02-02 14:42:14)
WHEN created_at REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
THEN str_to_date(created_at,'%Y-%m-%d %H:%i:%s')
-- YYYY/MM/DD HH:MM 
WHEN created_at REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}$'
THEN str_to_date(created_at, '%Y/%m/%d %H:%i')
-- Formato DD/MM/YYYY HH:MM
WHEN created_at REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}$'
THEN str_to_date(created_at, '%d/%m/%Y %H:%i')
-- Formato DD-MM-YYYY HH:MM:SS
WHEN created_at REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
THEN str_to_date(created_at, '%d-%m-%Y %H:%i:%s')
-- Formato YYYY-MM-DD
WHEN created_at REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
THEN str_to_date(created_at,'%Y-%m-%d')
ELSE NULL
END;

      -- Apicar resultados 
UPDATE shipments_limp SET created_at = created_at_dt;

-- -------------------------------------
-- pickup_datetime = 18,222 Filas afectadas
-- ----------------------------------

UPDATE shipments_limp
SET pickup_datetime_dt = 
CASE
-- vaçio / null
WHEN pickup_datetime IS NULL OR pickup_datetime= '' THEN NULL
-- Formato YYYY-MM-DD HH:MM:SS (2024-02-02 14:42:14)
WHEN pickup_datetime REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
THEN str_to_date(pickup_datetime,'%Y-%m-%d %H:%i:%s')
-- YYYY/MM/DD HH:MM 
WHEN pickup_datetime REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}$'
THEN str_to_date(pickup_datetime, '%Y/%m/%d %H:%i')
-- Formato DD/MM/YYYY HH:MM
WHEN pickup_datetime REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}$'
THEN str_to_date(pickup_datetime, '%d/%m/%Y %H:%i')
-- Formato DD-MM-YYYY HH:MM:SS
WHEN pickup_datetime REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
THEN str_to_date(pickup_datetime, '%d-%m-%Y %H:%i:%s')
-- Formato YYYY-MM-DD
WHEN pickup_datetime REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
THEN str_to_date(pickup_datetime,'%Y-%m-%d')
ELSE NULL
END;
-- APLICAR RESULTADOS
UPDATE shipments_limp SET pickup_datetime = pickup_datetime_dt;


-- -------------------------------------
-- delivered_datetime = 17,777 Filas afectadas
-- --------------------------------------

SELECT DISTINCT(delivered_datetime) FROM shipments_limp;
UPDATE shipments_limp
SET delivered_datetime_dt = 
CASE
-- vaçio / null
WHEN delivered_datetime IS NULL OR delivered_datetime= '' THEN NULL
-- FORMATO YYYY-MM-DD HH:MM:SS.MS
WHEN delivered_datetime REGEXP
'^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\\.[0-9]{1,6}$'
THEN STR_TO_DATE(LEFT(delivered_datetime,19), '%Y-%m-%d %H:%i:%s')
-- Formato YYYY-MM-DD HH:MM:SS (2024-02-02 14:42:14)
WHEN delivered_datetime REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
THEN str_to_date(delivered_datetime,'%Y-%m-%d %H:%i:%s')
-- YYYY/MM/DD HH:MM 
WHEN delivered_datetime REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}$'
THEN str_to_date(delivered_datetime, '%Y/%m/%d %H:%i')
-- Formato DD/MM/YYYY HH:MM
WHEN delivered_datetime REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}$'
THEN str_to_date(delivered_datetime, '%d/%m/%Y %H:%i')
-- Formato DD-MM-YYYY HH:MM:SS
WHEN delivered_datetime REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
THEN str_to_date(delivered_datetime, '%d-%m-%Y %H:%i:%s')
-- Formato YYYY-MM-DD
WHEN delivered_datetime REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
THEN str_to_date(delivered_datetime,'%Y-%m-%d')
ELSE NULL
END;

-- APLICAR CAMBIOS
UPDATE shipments_limp SET delivered_datetime = delivered_datetime_dt;

-- ELIMINAR COLUMNAS AUXILIARES
ALTER TABLE shipments_limp
DROP COLUMN created_at_dt,
DROP COLUMN pickup_datetime_dt,
DROP COLUMN delivered_datetime_dt;

SELECT * FROM shipments_limp;

-- -------------
-- Status = 15,267 Filas Afectadas en total
-- -------------

UPDATE shipments_limp SET status = UPPER(status); -- 11347 Filas Afectadas
UPDATE shipments_limp SET status =
CASE 
    WHEN status IN ('DELIVERED', 'ENTREGADO', 'DELIVERED ') THEN 'ENTREGADO'
    WHEN status IN ('CANCELED', 'CANCELLED', 'CNCL', 'CANCELADO') THEN 'CANCELADO'
    WHEN status IN ('DEVUELTO', 'RETURNED', 'RET', 'DEVOLUCIÓN') THEN 'DEVUELTO'
 ELSE status
 END;
 SELECT DISTINCT(status) FROM shipments_limp;
 
 
 -- ----------------------------
-- Números
-- ----------------------------
-- --------------------------------------
-- distance_km = 17622 Filas Afectadas
-- -------------------------------------
ALTER TABLE shipments_limp
ADD COLUMN distance_km_num DECIMAL(10,2) NULL;

UPDATE shipments_limp
SET distance_km_num = 
CASE
	WHEN distance_km IS NULL OR TRIM(distance_km)='' THEN null
    ELSE CAST(
    TRIM(
		REPLACE(
			REPLACE(
				REPLACE(
					REPLACE(UPPER(distance_km), 'MXN', ''), '$', ''), 'KM', ''), ' ', ''))
                    AS DECIMAL(10,2)
                    )
END;
SELECT distance_km, distance_km_num FROM shipments_limp WHERE distance_km < 0;

-- NOTA: los valores negativos en esta y las demás columnas numéricas; weight_kg, volume_m3, base_cost_mxn
-- fuel_surchage_mxn, total_cost_mxn, los valores negativos se transformará a NULL para evitar análisis sesgados

-- Negativos a NULL = 163 Filas Afectadas
UPDATE shipments_limp
SET distance_km_num = NULL
WHERE distance_km_num < 0;

-- Aplicando los cambios
UPDATE shipments_limp SET distance_km = distance_km_num;


-- ---------------------------------------
-- volume_m3 = 16096 Filas Afectadas
-- -----------------------------
ALTER TABLE shipments_limp
ADD COLUMN volume_m3_num DECIMAL(6,2);

UPDATE shipments_limp
SET volume_m3_num = 
CASE
	WHEN volume_m3 IS NULL OR TRIM(volume_m3)='' THEN null
    ELSE CAST(
    TRIM(
		REPLACE(
			REPLACE(
				REPLACE(
					REPLACE(UPPER(volume_m3), 'MXN', ''), '$', ''), 'M3', ''), ' ', ''))
                    AS DECIMAL(6,2)
                    )
END;


-- APLICAR CAMBIOS
UPDATE shipments_limp SET volume_m3 =volume_m3_num;

-- ---------------------------
-- Formato numérico ---------
-- --------------------------
-- weight_kg = 17627 Filas Afectadas
-- --------------------------

ALTER TABLE shipments_limp ADD COLUMN weight_kg_num DECIMAL(8,2);
UPDATE shipments_limp
SET weight_kg_num =
CASE
  WHEN weight_kg IS NULL OR TRIM(weight_kg) = '' THEN NULL
  ELSE CAST(
    CASE
      WHEN REGEXP_REPLACE(UPPER(TRIM(weight_kg)), '[^0-9,\\.-]', '') LIKE '%,%.%' THEN
        CASE
          WHEN LOCATE(',', REGEXP_REPLACE(UPPER(TRIM(weight_kg)), '[^0-9,\\.-]', '')) >
               LOCATE('.', REGEXP_REPLACE(UPPER(TRIM(weight_kg)), '[^0-9,\\.-]', ''))
            THEN REPLACE(
                   REPLACE(REGEXP_REPLACE(UPPER(TRIM(weight_kg)), '[^0-9,\\.-]', ''), '.', ''),
                   ',', '.'
                 )
          ELSE REPLACE(
                 REGEXP_REPLACE(UPPER(TRIM(weight_kg)), '[^0-9,\\.-]', ''),
                 ',', ''
               )
        END
      WHEN REGEXP_REPLACE(UPPER(TRIM(weight_kg)), '[^0-9,\\.-]', '') LIKE '%,%' THEN
        REPLACE(REGEXP_REPLACE(UPPER(TRIM(weight_kg)), '[^0-9,\\.-]', ''), ',', '.')
      ELSE REGEXP_REPLACE(UPPER(TRIM(weight_kg)), '[^0-9\\.-]', '')
    END
  AS DECIMAL(8,2))
END;


UPDATE shipments_limp SET weight_kg_num = NULL WHERE weight_kg_num < 0;
UPDATE shipments_limp SET weight_kg = weight_kg_num;

-- ---------------------
-- base_cost_mx = 18977 Filas Afectadas
-- ------------------------
ALTER TABLE shipments_limp ADD COLUMN base_cost_mxn_num DECIMAL(12,2);
UPDATE shipments_limp
SET base_cost_mxn_num =
CASE
  WHEN base_cost_mxn IS NULL OR TRIM(base_cost_mxn) = '' THEN NULL
  ELSE CAST(
    CASE
      /* 1) EUROPEO: 18.653,50  ó 3.547,12  
      */
      WHEN TRIM(REPLACE(REPLACE(REPLACE(UPPER(base_cost_mxn),'MXN',''),'$',''),' ','')) 
           REGEXP '^[0-9]{1,3}(\\.[0-9]{3})+,[0-9]{1,2}$'
        THEN REPLACE(
               REPLACE(
                 TRIM(REPLACE(REPLACE(REPLACE(UPPER(base_cost_mxn),'MXN',''),'$',''),' ','')),
                 '.', ''     -- quita miles con punto
               ),
               ',', '.'      -- coma decimal -> punto
             )

      /*  US: 18,647.45   */
      WHEN TRIM(REPLACE(REPLACE(REPLACE(UPPER(base_cost_mxn),'MXN',''),'$',''),' ','')) 
           REGEXP '^[0-9]{1,3}(,[0-9]{3})+\\.[0-9]{1,2}$'
        THEN REPLACE(
               TRIM(REPLACE(REPLACE(REPLACE(UPPER(base_cost_mxn),'MXN',''),'$',''),' ','')),
               ',', ''       -- quita miles con coma
             )

      /* 3) Solo coma decimal: 5898,65 */
      WHEN TRIM(REPLACE(REPLACE(REPLACE(UPPER(base_cost_mxn),'MXN',''),'$',''),' ','')) 
           REGEXP '^[0-9]+,[0-9]{1,2}$'
        THEN REPLACE(
               TRIM(REPLACE(REPLACE(REPLACE(UPPER(base_cost_mxn),'MXN',''),'$',''),' ','')),
               ',', '.'
             )

      /* 4) Solo punto decimal o entero: 16396.12 o 7895 */
      ELSE TRIM(REPLACE(REPLACE(REPLACE(UPPER(base_cost_mxn),'MXN',''),'$',''),' ','')) 
    END
  AS DECIMAL(12,2))
END;

-- Aplicar cambios
UPDATE shipments_limp SET base_cost_mxn = base_cost_mxn_num;


-- ------------
-- fuel_surcharge_mxn = 17,660 Filas Afectadas
-- -----------------

ALTER TABLE shipments_limp ADD COLUMN fuel_surcharge_mxn_num DECIMAL(10,2);


UPDATE shipments_limp
SET fuel_surcharge_mxn_num =
CASE
  WHEN fuel_surcharge_mxn IS NULL OR TRIM(fuel_surcharge_mxn) = '' THEN NULL
  ELSE CAST(
    CASE
      -- 1) EUROPEO con miles: 1.620,31  
      WHEN TRIM(REPLACE(REPLACE(REPLACE(UPPER(fuel_surcharge_mxn),'MXN',''),'$',''),' ','')) 
           REGEXP '^[0-9]{1,3}(\\.[0-9]{3})+,[0-9]{1,2}$'
        THEN REPLACE(
               REPLACE(
                 TRIM(REPLACE(REPLACE(REPLACE(UPPER(fuel_surcharge_mxn),'MXN',''),'$',''),' ','')),
                 '.', ''
               ),
               ',', '.'
             )

      -- 2) US con miles: 1,918.33  
      WHEN TRIM(REPLACE(REPLACE(REPLACE(UPPER(fuel_surcharge_mxn),'MXN',''),'$',''),' ','')) 
           REGEXP '^[0-9]{1,3}(,[0-9]{3})+\\.[0-9]{1,2}$'
        THEN REPLACE(
               TRIM(REPLACE(REPLACE(REPLACE(UPPER(fuel_surcharge_mxn),'MXN',''),'$',''),' ','')),
               ',', ''
             )

      -- 3) Solo coma decimal: 751,05  
      WHEN TRIM(REPLACE(REPLACE(REPLACE(UPPER(fuel_surcharge_mxn),'MXN',''),'$',''),' ','')) 
           REGEXP '^[0-9]+,[0-9]{1,2}$'
        THEN REPLACE(
               TRIM(REPLACE(REPLACE(REPLACE(UPPER(fuel_surcharge_mxn),'MXN',''),'$',''),' ','')),
               ',', '.'
             )

      -- 4) Solo punto decimal o entero: 1005.83 
      WHEN TRIM(REPLACE(REPLACE(REPLACE(UPPER(fuel_surcharge_mxn),'MXN',''),'$',''),' ','')) 
           REGEXP '^[0-9]+(\\.[0-9]{1,2})?$'
        THEN TRIM(REPLACE(REPLACE(REPLACE(UPPER(fuel_surcharge_mxn),'MXN',''),'$',''),' ',''))

      ELSE NULL
    END
  AS DECIMAL(10,2))
END;
SELECT fuel_surcharge_mxn, fuel_surcharge_mxn_num FROM shipments_limp;

-- Aplicación de cambios
UPDATE shipments_limp SET fuel_surcharge_mxn = fuel_surcharge_mxn_num;



-- --------------------------
-- total_cost_mxn = 17,550 Filas Afectadas
-- --------------------------
ALTER TABLE shipments_limp ADD COLUMN total_cost_mxn_num DECIMAL(12,2);

UPDATE shipments_limp
SET total_cost_mxn_num =
CASE
  WHEN total_cost_mxn IS NULL OR TRIM(total_cost_mxn) = '' THEN NULL
  ELSE CAST(
    CASE
      -- 1) EUROPEO con miles: 1.620,31  
      WHEN TRIM(REPLACE(REPLACE(REPLACE(UPPER(total_cost_mxn),'MXN',''),'$',''),' ','')) 
           REGEXP '^[0-9]{1,3}(\\.[0-9]{3})+,[0-9]{1,2}$'
        THEN REPLACE(
               REPLACE(
                 TRIM(REPLACE(REPLACE(REPLACE(UPPER(total_cost_mxn),'MXN',''),'$',''),' ','')),
                 '.', ''
               ),
               ',', '.'
             )

      -- 2) US con miles: 1,918.33  
      WHEN TRIM(REPLACE(REPLACE(REPLACE(UPPER(total_cost_mxn),'MXN',''),'$',''),' ','')) 
           REGEXP '^[0-9]{1,3}(,[0-9]{3})+\\.[0-9]{1,2}$'
        THEN REPLACE(
               TRIM(REPLACE(REPLACE(REPLACE(UPPER(total_cost_mxn),'MXN',''),'$',''),' ','')),
               ',', ''
             )

      -- 3) Solo coma decimal: 751,05  
      WHEN TRIM(REPLACE(REPLACE(REPLACE(UPPER(total_cost_mxn),'MXN',''),'$',''),' ','')) 
           REGEXP '^[0-9]+,[0-9]{1,2}$'
        THEN REPLACE(
               TRIM(REPLACE(REPLACE(REPLACE(UPPER(total_cost_mxn),'MXN',''),'$',''),' ','')),
               ',', '.'
             )

      -- 4) Solo punto decimal o entero: 1005.83 
      WHEN TRIM(REPLACE(REPLACE(REPLACE(UPPER(total_cost_mxn),'MXN',''),'$',''),' ','')) 
           REGEXP '^[0-9]+(\\.[0-9]{1,2})?$'
        THEN TRIM(REPLACE(REPLACE(REPLACE(UPPER(total_cost_mxn),'MXN',''),'$',''),' ',''))

      ELSE NULL
    END
  AS DECIMAL(10,2))
END;


-- Aplicar cambios
UPDATE shipments_limp SET total_cost_mxn= total_cost_mxn_num;


-- Eliminar columnas auxiliares
ALTER TABLE shipments_limp
DROP COLUMN distance_km_num,
DROP COLUMN volume_m3_num,
DROP COLUMN weight_kg_num,
DROP COLUMN base_cost_mxn_num,
DROP COLUMN fuel_surcharge_mxn_num,
DROP COLUMN total_cost_mxn_num;

-- ---------------------------
-- FLAGS 
-- ----------------------------
-- on_time_ flag = 17,641 Filas Afectadas
-- -----------------------------

SELECT DISTINCT(on_time_flag) FROM shipments_limp;



ALTER TABLE  shipments_limp ADD COLUMN on_time_flag_bool BOOL;

UPDATE shipments_limp 
SET on_time_flag_bool = 
CASE
	WHEN UPPER(TRIM(on_time_flag)) IN ('TRUE', 'Y', '1', 'SI') THEN 1
    WHEN UPPER(TRIM(on_time_flag)) IN ('FALSE', 'NO', 'N', '0') THEN 0
    ELSE NULL
END;

-- Aplicación de cambios
UPDATE shipments_limp SET on_time_flag = on_time_flag_bool;
ALTER TABLE shipments_limp DROP COLUMN on_time_flag_bool;

-- -------------------
-- damage_flag = 14640 Filas Afectadas
-- -------------------
 SELECT DISTINCT(damage_flag) From shipments_limp;
 
 UPDATE shipments_limp
 SET damage_flag =
 CASE
	WHEN UPPER(TRIM(damage_flag)) IN ('SI','1','TRUE','Y') THEN 1
    WHEN UPPER(TRIM(damage_flag)) IN ('NO','FALSE','N','0') THEN 0
    ELSE NULL
END;


-- --------------------------
-- tracking_events_count= 68 Filas Afectadas
-- --------------------------
-- Eliminar negativos 
UPDATE shipments_limp
SET tracking_events_count = NULL
WHERE tracking_events_count IS NULL
OR TRIM(tracking_events_count) = ''
OR TRIM(tracking_events_count) NOT REGEXP '^[0-9]+$';


-- ----------------------
-- Normalizar tipo de datos
-- ------------------------
ALTER TABLE shipments_limp
  MODIFY COLUMN shipment_id           VARCHAR(8) NULL,
  MODIFY COLUMN customer_id           VARCHAR(6)  NULL,
  MODIFY COLUMN driver_id             VARCHAR(6)  NULL,
  MODIFY COLUMN origin_city           VARCHAR(60) NULL,
  MODIFY COLUMN origin_state          VARCHAR(10) NULL,
  MODIFY COLUMN destination_city      VARCHAR(60) NULL,
  MODIFY COLUMN destination_state     VARCHAR(10) NULL,

  MODIFY COLUMN created_at            DATETIME NULL,
  MODIFY COLUMN pickup_datetime       DATETIME NULL,
  MODIFY COLUMN delivered_datetime    DATETIME NULL,

  MODIFY COLUMN status                VARCHAR(20) NULL,

  MODIFY COLUMN distance_km           DECIMAL(10,2) NULL,
  MODIFY COLUMN weight_kg             DECIMAL(8,2)  NULL,
  MODIFY COLUMN volume_m3             DECIMAL(6,2)  NULL,

  MODIFY COLUMN base_cost_mxn         DECIMAL(12,2) NULL,
  MODIFY COLUMN fuel_surcharge_mxn    DECIMAL(10,2) NULL,
  MODIFY COLUMN total_cost_mxn        DECIMAL(12,2) NULL,

  MODIFY COLUMN on_time_flag          BOOLEAN NULL,
  MODIFY COLUMN damage_flag           BOOLEAN NULL,

  MODIFY COLUMN tracking_events_count INT NULL,

  MODIFY COLUMN notes                 VARCHAR(255) NULL;
  
  SELECT * FROM shipments_limp;
  
DESCRIBE shipments_limp;
-- -----------------------------
-- Validaciones lógicas --------
-- ---------------------------
-- entrega antes de pickup = 762
SELECT COUNT(*) AS entregas_antes_pickup
FROM shipments_limp
WHERE delivered_datetime IS NOT NULL
  AND pickup_datetime IS NOT NULL
  AND delivered_datetime < pickup_datetime;
-- Se dejan en NULL para que no interfieran en el análisis de métricas de negocio
UPDATE shipments_limp
SET delivered_datetime = NULL
WHERE delivered_datetime IS NOT NULL
AND pickup_datetime IS NOT NULL
AND delivered_datetime < pickup_datetime;

-- Costo inconsistente = 5972 registros
  SELECT COUNT(*) AS costo_inconsistente_strict
FROM shipments_limp
WHERE total_cost_mxn IS NOT NULL
  AND base_cost_mxn IS NOT NULL
  AND fuel_surcharge_mxn IS NOT NULL
  AND ABS(total_cost_mxn - (base_cost_mxn + fuel_surcharge_mxn)) > 0.01;
 --  Se detectaron discrepancias entre total_cost_mxn y la suma de base_cost_mxn + fuel_surcharge_mxn.
 --  La mayoría correspondía a diferencias de redondeo de ±1 MXN.
 --  Se normalizó total_cost_mxn recalculándolo a partir de sus componentes cuando la diferencia era ≤1 MXN.
 --  Tras la corrección, la validación final confirmó 0 inconsistencias.
  
  UPDATE shipments_limp
SET total_cost_mxn = base_cost_mxn + fuel_surcharge_mxn
WHERE total_cost_mxn IS NOT NULL
AND base_cost_mxn IS NOT NULL
AND fuel_surcharge_mxn IS NOT NULL
AND ABS(total_cost_mxn - (base_cost_mxn + fuel_surcharge_mxn)) <= 1;
SELECT COUNT(*) AS costo_inconsistente
FROM shipments_limp
WHERE total_cost_mxn IS NOT NULL
AND base_cost_mxn IS NOT NULL
AND fuel_surcharge_mxn IS NOT NULL
AND ABS(total_cost_mxn - (base_cost_mxn + fuel_surcharge_mxn)) > 0.01;
  
 

 -- Customer_id sin catálogo = 0. Todos los customer_id existen en tabla customers 
SELECT COUNT(*) AS customer_id_sin_catalogo
FROM shipments_limp s
LEFT JOIN customers c ON s.customer_id = c.customer_id
WHERE s.customer_id IS NOT NULL AND c.customer_id IS NULL;

