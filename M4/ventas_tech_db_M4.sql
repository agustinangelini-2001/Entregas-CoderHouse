-- ============================================================
-- PROYECTO: RetailPro / Ventas_Tech_DB
-- MÓDULO 4: Pre-entrega - Consultas SQL de Negocio
-- ARCHIVO: m4_consultas_negocio.sql
-- ============================================================

-- ------------------------------------------------------------
-- CONSULTA 1: Resumen ejecutivo mensual
-- Objetivo: Total facturado, cantidad de pedidos y ticket promedio por mes.
-- ------------------------------------------------------------
SELECT 
    EXTRACT(MONTH FROM fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY EXTRACT(MONTH FROM fecha_venta)
ORDER BY mes;


-- ------------------------------------------------------------
-- CONSULTA 2: Ranking de productos
-- Objetivo: Top 5 de id_producto por total facturado y unidades vendidas.
-- ------------------------------------------------------------
SELECT 
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC
LIMIT 5;


-- ------------------------------------------------------------
-- CONSULTA 3: Clientes activos / recurrentes
-- Objetivo: Clientes con más de un pedido, su total gastado y compras realizadas.
-- ------------------------------------------------------------
SELECT 
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY cantidad_pedidos DESC, total_gastado DESC;


-- ------------------------------------------------------------
-- CONSULTA 4: Performance de ventas vs. Promedio
-- Objetivo: Comparativa del total facturado mensual contra el promedio general usando CASE WHEN.
-- Explicación por pasos:
--   1. 'ventas_mensuales': Calcula el total facturado por cada mes.
--   2. 'promedio_general': Obtiene el promedio global a partir del total de los meses.
--   3. Consulta final: Compara el total de cada mes contra el promedio usando CASE WHEN.
-- ------------------------------------------------------------
WITH ventas_mensuales AS (
    -- Paso 1: Obtener facturación por mes
    SELECT 
        EXTRACT(MONTH FROM fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY EXTRACT(MONTH FROM fecha_venta)
),
promedio_general AS (
    -- Paso 2: Calcular el promedio mensual general
    SELECT AVG(total_facturado) AS promedio_mensual
    FROM ventas_mensuales
)
-- Paso 3: Comparar la venta de cada mes contra el promedio general
SELECT 
    vm.mes,
    vm.total_facturado,
    CASE 
        WHEN vm.total_facturado >= pg.promedio_mensual THEN 'Por encima'
        ELSE 'Por debajo'
    END AS desempeno_vs_promedio
FROM ventas_mensuales vm
CROSS JOIN promedio_general pg
ORDER BY vm.mes;


-- ============================================================
-- BLOQUE DE CIERRE: Hallazgos Clave de Negocio (Rúbrica: 10%)
-- ============================================================
--
-- HALLAZGO 1 (Concentración de Facturación):
-- El producto id_producto 1 (Laptop Pro 15) es el principal generador de ingresos del negocio, 
-- alcanzando $3,600 USD sobre un total facturado de $5,314 USD. Esto representa el 67.7% de la 
-- facturación total de la empresa en el periodo analizado.
--
-- HALLAZGO 2 (Fidelización de Clientes):
-- El 100% de la base activa de clientes (los 5 clientes registrados) son recurrentes, habiendo 
-- realizado exactamente 2 pedidos cada uno en marzo de 2024. El cliente id_cliente 1 lidera 
-- el gasto total con $2,640 USD en compras.
--
-- HALLAZGO 3 (Métrica de Ticket Promedio y Volumen):
-- La operación registró un total de 10 transacciones con un ticket promedio de $531.40 USD por pedido. 
-- El producto id_producto 2 (Mouse Inalámbrico) destaca como el líder en volumen físico de ventas 
-- con 13 unidades comercializadas.
--
