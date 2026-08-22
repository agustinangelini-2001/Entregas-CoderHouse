
-- CONSULTA 1: Vista base del proyecto (INNER JOIN)
-- Propósito: Une las tablas de ventas, clientes, productos y categorias 
--            para ver todos los datos juntos en una sola consulta.
-- ------------------------------------------------------------
SELECT 
    v.fecha_venta AS fecha,
    c.nombre AS nombre_cliente,
    'Consumo Final' AS segmento,
    c.ciudad AS region,
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta,
    'Online' AS canal
FROM ventas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN productos p ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta;


-- CONSULTA 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: Muestra los clientes que no tienen ninguna compra registrada.
-- ------------------------------------------------------------
SELECT 
    c.nombre AS nombre_cliente,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;


-- CONSULTA 3: Productos sin ventas (LEFT JOIN)
-- Propósito: Muestra los productos del catálogo que nunca se vendieron.
-- ------------------------------------------------------------
SELECT 
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;


-- CONSULTA 4: Consolidado por canal (UNION ALL + GROUP BY)
-- Propósito: Junta las ventas online y presenciales con UNION ALL y 
--            suma el total vendido por cada canal.
-- ------------------------------------------------------------
SELECT 
    canal,
    COUNT(*) AS cantidad_ventas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM (
    -- Ventas del canal Online
    SELECT cantidad, precio_unitario, 'Online' AS canal
    FROM ventas
    WHERE cantidad <= 3

    UNION ALL

    -- Ventas del canal Presencial
    SELECT cantidad, precio_unitario, 'Presencial' AS canal
    FROM ventas
    WHERE cantidad > 3
) AS ventas_unificadas
GROUP BY canal;


-- ------------------------------------------------------------
-- HALLAZGO 1:
-- No hay clientes sin ventas. Todos los clientes de la base de datos hicieron al menos una compra.
--
-- HALLAZGO 2:
-- No hay productos sin ventas. Todos los productos del catálogo registran ventas.
--
-- HALLAZGO 3:
-- El canal Online tiene más cantidad de ventas, pero el canal Presencial genera más dinero por venta.
--
