-- Q01. How many records are in each operational table?
SELECT 'aircraft' AS table_name, COUNT(*) AS row_count
FROM aircraft
UNION ALL
SELECT 'aircraft_types', COUNT(*)
FROM aircraft_types
UNION ALL
SELECT 'airports', COUNT(*)
FROM airports
UNION ALL
SELECT 'flights', COUNT(*)
FROM flights
UNION ALL
SELECT 'maintenance_work_orders', COUNT(*)
FROM maintenance_work_orders
UNION ALL
SELECT 'operational_events', COUNT(*)
FROM operational_events;


-- Q02. What is the overall flight date range?
SELECT
    MIN(flight_date) AS first_flight_date,
    MAX(flight_date) AS last_flight_date,
    MAX(flight_date) - MIN(flight_date) + 1 AS days_covered
FROM flights;


-- Q03. What is the current aircraft fleet composition?
SELECT
    a.aircraft_type,
    at.model,
    at.category,
    COUNT(*) AS aircraft_count
FROM aircraft a
LEFT JOIN aircraft_types at
    ON a.aircraft_type = at.aircraft_type
GROUP BY
    a.aircraft_type,
    at.model,
    at.category
ORDER BY aircraft_count DESC;

