-- Q01. Identify aircraft with high utilization AND high
-- maintenance downtime.
WITH aircraft_metrics AS (
    SELECT
        a.aircraft_id,
        a.aircraft_type,
        COALESCE(f.flight_hours, 0) AS flight_hours,
        COALESCE(m.downtime_hours, 0) AS downtime_hours
    FROM aircraft a
    LEFT JOIN (
        SELECT
            aircraft_id,
            SUM(scheduled_duration_min)
                FILTER (WHERE cancelled = FALSE) / 60.0
                AS flight_hours
        FROM flights
        GROUP BY aircraft_id
    ) f
        ON a.aircraft_id = f.aircraft_id
    LEFT JOIN (
        SELECT
            aircraft_id,
            SUM(downtime_hours) AS downtime_hours
        FROM maintenance_work_orders
        GROUP BY aircraft_id
    ) m
        ON a.aircraft_id = m.aircraft_id
)
SELECT
    aircraft_id,
    aircraft_type,
    ROUND(flight_hours, 2) AS flight_hours,
    ROUND(downtime_hours, 2) AS downtime_hours,
    CASE
        WHEN flight_hours >= (
            SELECT AVG(flight_hours) FROM aircraft_metrics
        )
        AND downtime_hours >= (
            SELECT AVG(downtime_hours) FROM aircraft_metrics
        )
        THEN 'High utilization / high maintenance'
        ELSE 'Other'
    END AS operational_profile
FROM aircraft_metrics
ORDER BY flight_hours DESC;


-- Q02. Which aircraft have unusually high numbers of
-- operational events compared with the fleet average?
WITH aircraft_events AS (
    SELECT
        f.aircraft_id,
        COUNT(oe.event_id) AS event_count
    FROM flights f
    LEFT JOIN operational_events oe
        ON f.flight_id = oe.flight_id
    GROUP BY f.aircraft_id
),
fleet_average AS (
    SELECT AVG(event_count) AS avg_event_count
    FROM aircraft_events
)
SELECT
    ae.aircraft_id,
    ae.event_count,
    ROUND(fa.avg_event_count, 2) AS fleet_avg_events,
    ROUND(
        ae.event_count - fa.avg_event_count,
        2
    ) AS difference_from_fleet_avg
FROM aircraft_events ae
CROSS JOIN fleet_average fa
WHERE ae.event_count > fa.avg_event_count
ORDER BY ae.event_count DESC;

-- Q03. How does monthly flight performance change over time?
SELECT
    DATE_TRUNC('month', flight_date)::date AS month,
    COUNT(*) FILTER (WHERE cancelled = FALSE) AS operated_flights,
    COUNT(*) FILTER (
        WHERE cancelled = FALSE
          AND departure_delay_min > 0
    ) AS delayed_flights,
    ROUND(
        AVG(departure_delay_min)
        FILTER (WHERE cancelled = FALSE),
        2
    ) AS avg_delay_min,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE cancelled = FALSE
              AND departure_delay_min > 0
        )
        / NULLIF(
            COUNT(*) FILTER (WHERE cancelled = FALSE),
            0
        ),
        2
    ) AS delay_rate_pct
FROM flights
GROUP BY DATE_TRUNC('month', flight_date)
ORDER BY month;


-- Q04. Which aircraft show worsening average delay performance
-- from one month to the next?
WITH monthly_aircraft_performance AS (
    SELECT
        aircraft_id,
        DATE_TRUNC('month', flight_date)::date AS month,
        AVG(departure_delay_min)
            FILTER (WHERE cancelled = FALSE)
            AS avg_delay_min
    FROM flights
    GROUP BY
        aircraft_id,
        DATE_TRUNC('month', flight_date)
),
with_previous_month AS (
    SELECT
        aircraft_id,
        month,
        avg_delay_min,
        LAG(avg_delay_min) OVER (
            PARTITION BY aircraft_id
            ORDER BY month
        ) AS previous_avg_delay_min
    FROM monthly_aircraft_performance
)
SELECT
    aircraft_id,
    month,
    ROUND(avg_delay_min, 2) AS avg_delay_min,
    ROUND(previous_avg_delay_min, 2) AS previous_avg_delay_min,
    ROUND(
        avg_delay_min - previous_avg_delay_min,
        2
    ) AS change_in_delay_min
FROM with_previous_month
WHERE previous_avg_delay_min IS NOT NULL
  AND avg_delay_min > previous_avg_delay_min
ORDER BY change_in_delay_min DESC;


-- Q05. Rank aircraft within each aircraft type by flight hours.
WITH aircraft_hours AS (
    SELECT
        aircraft_id,
        aircraft_type,
        SUM(scheduled_duration_min)
            FILTER (WHERE cancelled = FALSE) / 60.0
            AS flight_hours
    FROM flights
    GROUP BY aircraft_id, aircraft_type
)
SELECT
    aircraft_id,
    aircraft_type,
    ROUND(flight_hours, 2) AS flight_hours,
    DENSE_RANK() OVER (
        PARTITION BY aircraft_type
        ORDER BY flight_hours DESC
    ) AS type_rank
FROM aircraft_hours
ORDER BY aircraft_type, type_rank;

-- Q06. Create a single aircraft-level analytical view of:
-- utilization, maintenance, and operational events.
WITH utilization AS (
    SELECT
        aircraft_id,
        COUNT(*) FILTER (WHERE cancelled = FALSE) AS operated_flights,
        SUM(scheduled_duration_min)
            FILTER (WHERE cancelled = FALSE) / 60.0
            AS flight_hours,
        AVG(departure_delay_min)
            FILTER (WHERE cancelled = FALSE)
            AS avg_delay_min
    FROM flights
    GROUP BY aircraft_id
),
maintenance AS (
    SELECT
        aircraft_id,
        COUNT(*) AS work_orders,
        SUM(technician_hours) AS technician_hours,
        SUM(downtime_hours) AS downtime_hours
    FROM maintenance_work_orders
    GROUP BY aircraft_id
),
events AS (
    SELECT
        f.aircraft_id,
        COUNT(oe.event_id) AS event_count,
        SUM(oe.resolved_hours) AS event_resolution_hours
    FROM flights f
    LEFT JOIN operational_events oe
        ON f.flight_id = oe.flight_id
    GROUP BY f.aircraft_id
)
SELECT
    a.aircraft_id,
    a.aircraft_type,
    a.status,
    COALESCE(u.operated_flights, 0) AS operated_flights,
    ROUND(COALESCE(u.flight_hours, 0), 2) AS flight_hours,
    ROUND(COALESCE(u.avg_delay_min, 0), 2) AS avg_delay_min,
    COALESCE(m.work_orders, 0) AS work_orders,
    ROUND(COALESCE(m.technician_hours, 0), 2) AS technician_hours,
    ROUND(COALESCE(m.downtime_hours, 0), 2) AS downtime_hours,
    COALESCE(e.event_count, 0) AS operational_events,
    ROUND(COALESCE(e.event_resolution_hours, 0), 2)
        AS event_resolution_hours
FROM aircraft a
LEFT JOIN utilization u
    ON a.aircraft_id = u.aircraft_id
LEFT JOIN maintenance m
    ON a.aircraft_id = m.aircraft_id
LEFT JOIN events e
    ON a.aircraft_id = e.aircraft_id
ORDER BY flight_hours DESC;
