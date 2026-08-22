-- Q01. What is the overall cancellation and delay performance?
SELECT
    COUNT(*) AS total_flights,
    COUNT(*) FILTER (WHERE cancelled = TRUE) AS cancelled_flights,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE cancelled = TRUE)
        / NULLIF(COUNT(*), 0),
        2
    ) AS cancellation_rate_pct,
    ROUND(
        AVG(departure_delay_min)
        FILTER (WHERE cancelled = FALSE),
        2
    ) AS avg_departure_delay_min
FROM flights;


-- Q02. Which routes have the highest delay rates?
SELECT
    origin,
    destination,
    COUNT(*) FILTER (WHERE cancelled = FALSE) AS operated_flights,
    COUNT(*) FILTER (
        WHERE cancelled = FALSE
          AND departure_delay_min > 0
    ) AS delayed_flights,
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
    ) AS delay_rate_pct,
    ROUND(
        AVG(departure_delay_min)
        FILTER (WHERE cancelled = FALSE),
        2
    ) AS avg_delay_min
FROM flights
GROUP BY origin, destination
HAVING COUNT(*) FILTER (WHERE cancelled = FALSE) > 0
ORDER BY delay_rate_pct DESC;


-- Q03. Which airports have the highest operational delay levels?
WITH airport_departures AS (
    SELECT
        origin AS airport_code,
        COUNT(*) FILTER (WHERE cancelled = FALSE) AS departures,
        AVG(departure_delay_min)
            FILTER (WHERE cancelled = FALSE)
            AS avg_delay_min
    FROM flights
    GROUP BY origin
)
SELECT
    ad.airport_code,
    ap.city,
    ap.country,
    ad.departures,
    ROUND(ad.avg_delay_min, 2) AS avg_departure_delay_min
FROM airport_departures ad
LEFT JOIN airports ap
    ON ad.airport_code = ap.airport_code
ORDER BY avg_departure_delay_min DESC;


-- Q04. What are the main reasons for flight delays?
SELECT
    delay_reason,
    COUNT(*) AS delayed_flights,
    ROUND(AVG(departure_delay_min), 2) AS avg_delay_min,
    MAX(departure_delay_min) AS max_delay_min
FROM flights
WHERE cancelled = FALSE
  AND departure_delay_min > 0
  AND delay_reason IS NOT NULL
GROUP BY delay_reason
ORDER BY delayed_flights DESC;


-- Q05. Which aircraft have the highest average departure delay?
SELECT
    f.aircraft_id,
    a.aircraft_type,
    COUNT(*) FILTER (WHERE f.cancelled = FALSE) AS operated_flights,
    ROUND(
        AVG(f.departure_delay_min)
        FILTER (WHERE f.cancelled = FALSE),
        2
    ) AS avg_delay_min
FROM flights f
JOIN aircraft a
    ON f.aircraft_id = a.aircraft_id
GROUP BY
    f.aircraft_id,
    a.aircraft_type
HAVING COUNT(*) FILTER (WHERE f.cancelled = FALSE) > 0
ORDER BY avg_delay_min DESC;
