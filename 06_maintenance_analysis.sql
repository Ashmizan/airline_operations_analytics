-- Q01. Which aircraft spend the most time unavailable due
-- to maintenance?
SELECT
    m.aircraft_id,
    a.aircraft_type,
    COUNT(*) AS work_orders,
    ROUND(SUM(m.downtime_hours), 2) AS total_downtime_hours,
    ROUND(AVG(m.downtime_hours), 2) AS avg_downtime_per_order
FROM maintenance_work_orders m
JOIN aircraft a
    ON m.aircraft_id = a.aircraft_id
GROUP BY
    m.aircraft_id,
    a.aircraft_type
ORDER BY total_downtime_hours DESC;


-- Q02. Which aircraft types have the highest maintenance workload?
SELECT
    a.aircraft_type,
    at.model,
    at.category,
    COUNT(m.work_order_id) AS work_orders,
    ROUND(SUM(m.technician_hours), 2) AS technician_hours,
    ROUND(SUM(m.downtime_hours), 2) AS downtime_hours
FROM maintenance_work_orders m
JOIN aircraft a
    ON m.aircraft_id = a.aircraft_id
LEFT JOIN aircraft_types at
    ON a.aircraft_type = at.aircraft_type
GROUP BY
    a.aircraft_type,
    at.model,
    at.category
ORDER BY technician_hours DESC;


-- Q03. Which maintenance categories consume the most
-- technician hours and cost?
SELECT
    maintenance_type,
    COUNT(*) AS work_orders,
    ROUND(SUM(technician_hours), 2) AS technician_hours,
    ROUND(SUM(parts_cost_eur), 2) AS parts_cost_eur,
    ROUND(SUM(downtime_hours), 2) AS downtime_hours
FROM maintenance_work_orders
GROUP BY maintenance_type
ORDER BY technician_hours DESC;


-- Q04. Which maintenance priorities create the greatest
-- operational downtime?
SELECT
    priority,
    COUNT(*) AS work_orders,
    ROUND(SUM(downtime_hours), 2) AS total_downtime_hours,
    ROUND(AVG(downtime_hours), 2) AS avg_downtime_hours
FROM maintenance_work_orders
GROUP BY priority
ORDER BY total_downtime_hours DESC;


-- Q05. What is the relationship between maintenance workload
-- and aircraft utilization?
WITH utilization AS (
    SELECT
        aircraft_id,
        SUM(scheduled_duration_min)
            FILTER (WHERE cancelled = FALSE) / 60.0
            AS flight_hours
    FROM flights
    GROUP BY aircraft_id
),
maintenance AS (
    SELECT
        aircraft_id,
        SUM(technician_hours) AS technician_hours,
        SUM(downtime_hours) AS downtime_hours,
        COUNT(*) AS work_orders
    FROM maintenance_work_orders
    GROUP BY aircraft_id
)
SELECT
    u.aircraft_id,
    ROUND(u.flight_hours, 2) AS flight_hours,
    ROUND(COALESCE(m.technician_hours, 0), 2) AS technician_hours,
    ROUND(COALESCE(m.downtime_hours, 0), 2) AS downtime_hours,
    COALESCE(m.work_orders, 0) AS work_orders
FROM utilization u
LEFT JOIN maintenance m
    ON u.aircraft_id = m.aircraft_id
ORDER BY downtime_hours DESC;

