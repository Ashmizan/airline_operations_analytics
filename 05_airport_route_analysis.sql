-- Q01. Which airports handle the highest number of flights?
WITH airport_activity AS (
    SELECT origin AS airport_code FROM flights
    UNION ALL
    SELECT destination AS airport_code FROM flights
)
SELECT
    aa.airport_code,
    ap.city,
    ap.country,
    COUNT(*) AS flight_movements
FROM airport_activity aa
LEFT JOIN airports ap
    ON aa.airport_code = ap.airport_code
GROUP BY
    aa.airport_code,
    ap.city,
    ap.country
ORDER BY flight_movements DESC;


-- Q02. Which routes carry the most passengers?
SELECT
    origin,
    destination,
    COUNT(*) FILTER (WHERE cancelled = FALSE) AS operated_flights,
    SUM(passengers)
        FILTER (WHERE cancelled = FALSE) AS total_passengers,
    ROUND(
        AVG(passengers)
        FILTER (WHERE cancelled = FALSE),
        2
    ) AS avg_passengers_per_flight
FROM flights
GROUP BY origin, destination
ORDER BY total_passengers DESC;
