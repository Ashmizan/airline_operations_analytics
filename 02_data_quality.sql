-- Q01. Are there flights referencing aircraft that do not exist
-- in the aircraft table?
SELECT
    f.flight_id,
    f.aircraft_id
FROM flights f
LEFT JOIN aircraft a
    ON f.aircraft_id = a.aircraft_id
WHERE a.aircraft_id IS NULL;


-- Q02. Are there flights referencing aircraft types that do not
-- exist in the aircraft_types table?
SELECT DISTINCT
    f.aircraft_type
FROM flights f
LEFT JOIN aircraft_types at
    ON f.aircraft_type = at.aircraft_type
WHERE at.aircraft_type IS NULL;


-- Q03. Are any flight origin or destination airports missing
-- from the airports reference table?
SELECT
    f.flight_id,
    f.origin,
    f.destination
FROM flights f
LEFT JOIN airports origin_airport
    ON f.origin = origin_airport.airport_code
LEFT JOIN airports destination_airport
    ON f.destination = destination_airport.airport_code
WHERE origin_airport.airport_code IS NULL
   OR destination_airport.airport_code IS NULL;


-- Q04. Does the aircraft type recorded on a flight match the
-- aircraft's registered type?
SELECT
    f.flight_id,
    f.aircraft_id,
    a.aircraft_type AS registered_aircraft_type,
    f.aircraft_type AS flight_aircraft_type
FROM flights f
JOIN aircraft a
    ON f.aircraft_id = a.aircraft_id
WHERE a.aircraft_type <> f.aircraft_type;


-- Q05. Check for impossible or suspicious flight values.
SELECT
    flight_id,
    scheduled_duration_min,
    departure_delay_min,
    passengers
FROM flights
WHERE scheduled_duration_min < 0
   OR passengers < 0;


-- Q06. Check for suspicious maintenance values.
SELECT
    work_order_id,
    technician_hours,
    parts_cost_eur,
    downtime_hours
FROM maintenance_work_orders
WHERE technician_hours < 0
   OR parts_cost_eur < 0
   OR downtime_hours < 0;
