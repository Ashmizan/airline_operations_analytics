-- Q01. Which event types occur most frequently?
SELECT
    event_type,
    COUNT(*) AS event_count,
    ROUND(AVG(resolved_hours), 2) AS avg_resolution_hours
FROM operational_events
GROUP BY event_type
ORDER BY event_count DESC;


-- Q02. Which event types have the highest operational impact?
SELECT
    event_type,
    severity,
    COUNT(*) AS event_count,
    ROUND(AVG(resolved_hours), 2) AS avg_resolution_hours,
    ROUND(SUM(resolved_hours), 2) AS total_resolution_hours
FROM operational_events
GROUP BY event_type, severity
ORDER BY total_resolution_hours DESC;


-- Q03. Which aircraft are associated with the highest number
-- of operational events?
SELECT
    f.aircraft_id,
    a.aircraft_type,
    COUNT(oe.event_id) AS operational_events,
    ROUND(AVG(oe.resolved_hours), 2) AS avg_resolution_hours
FROM operational_events oe
JOIN flights f
    ON oe.flight_id = f.flight_id
JOIN aircraft a
    ON f.aircraft_id = a.aircraft_id
GROUP BY
    f.aircraft_id,
    a.aircraft_type
ORDER BY operational_events DESC;


-- Q04. Which flights experienced the most operational events?
SELECT
    oe.flight_id,
    COUNT(*) AS event_count,
    COUNT(*) FILTER (
        WHERE oe.severity = 'High'
    ) AS high_severity_events,
    ROUND(SUM(oe.resolved_hours), 2) AS total_resolution_hours
FROM operational_events oe
GROUP BY oe.flight_id
ORDER BY event_count DESC;
