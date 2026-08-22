-- Q01. Which aircraft have the highest operational utilization?
-- Utilization is represented by scheduled flight hours and
-- number of operated flights.
SELECT
    f.aircraft_id,
    a.aircraft_type,
    COUNT(*) FILTER (WHERE f.cancelled = FALSE) AS operated_flights,
    ROUND(
        SUM(f.scheduled_duration_min)
        FILTER (WHERE f.cancelled = FALSE) / 60.0,
        2
    ) AS scheduled_flight_hours,
    ROUND(
        AVG(f.scheduled_duration_min)
        FILTER (WHERE f.cancelled = FALSE),
        2
    ) AS avg_flight_duration_min
FROM flights f
JOIN aircraft a
    ON f.aircraft_id = a.aircraft_id
GROUP BY
    f.aircraft_id,
    a.aircraft_type
ORDER BY scheduled_flight_hours DESC;


-- Q02. Rank aircraft by scheduled flight hours.
WITH aircraft_utilization AS (
    SELECT
        aircraft_id,
        SUM(scheduled_duration_min)
            FILTER (WHERE cancelled = FALSE) / 60.0
            AS scheduled_flight_hours
    FROM flights
    GROUP BY aircraft_id
)
SELECT
    aircraft_id,
    ROUND(scheduled_flight_hours, 2) AS scheduled_flight_hours,
    RANK() OVER (
        ORDER BY scheduled_flight_hours DESC
    ) AS utilization_rank
FROM aircraft_utilization
ORDER BY utilization_rank;


-- Q03. Which aircraft types generate the most flight activity?
SELECT
    f.aircraft_type,
    COUNT(*) FILTER (WHERE f.cancelled = FALSE) AS operated_flights,
    ROUND(
        SUM(f.scheduled_duration_min)
        FILTER (WHERE f.cancelled = FALSE) / 60.0,
        2
    ) AS scheduled_flight_hours,
    SUM(f.passengers)
        FILTER (WHERE f.cancelled = FALSE) AS total_passengers
FROM flights f
GROUP BY f.aircraft_type
ORDER BY scheduled_flight_hours DESC;
