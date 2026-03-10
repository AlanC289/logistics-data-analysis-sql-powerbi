-- ---------------
-- Métricas-- 
-- ------------------

-- % de envíos entrgados a tiempo = 75% 
SELECT 
COUNT(CASE WHEN on_time_flag = 1 THEN 1 END)/
COUNT(*)  AS envios_a_tiempo
FROM shipments_limp;  

-- Ingresos en riesgo 
SELECT
SUM(total_cost_mxn) AS revenue_total,
SUM(
CASE
WHEN on_time_flag = 0
THEN total_cost_mxn
ELSE 0
END
) AS revenue_at_risk
FROM shipments_limp;


-- Promedio de horas tarde= 7.86 hrs
SELECT
AVG(TIMESTAMPDIFF(HOUR, pickup_datetime, delivered_datetime)) AS avg_hours
FROM shipments_limp
WHERE pickup_datetime IS NOT NULL
AND delivered_datetime IS NOT NULL;

-- tasa_daño 
SELECT COUNT(CASE WHEN damage_flag = 1 THEN 1 END)/
COUNT(*)  AS tasa_daño
FROM shipments_limp;



-- Pedidos cancelados o devueltos = 4.78
SELECT COUNT(CASE WHEN status IN('CANCELADO', 'DEVUELTO') THEN 1 END)/
COUNT(*)  AS tasa_cancelacion
FROM shipments_limp;

-- Porcentaje de ingresos en riesgo
SELECT
SUM(total_cost_mxn) AS revenue_total,
SUM(
CASE
WHEN on_time_flag = 0
THEN total_cost_mxn
ELSE 0
END
) AS revenue_at_risk
FROM shipments_limp;


-- Rutas con mayor costo en riesgo 
SELECT
origin_city,
destination_city,
COUNT(*) AS shipments,
SUM(total_cost_mxn) AS revenue,
SUM(
CASE
WHEN on_time_flag = 0
THEN total_cost_mxn
ELSE 0
END
) AS delayed_cost
FROM shipments_limp
GROUP BY origin_city,destination_city
ORDER BY delayed_cost DESC;