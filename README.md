Airline Operations Analytics

A business-oriented airline operations analytics project built with PostgreSQL and Power BI. The project analyses aircraft utilization, flight operations, maintenance activity, operational events, and data quality to demonstrate how structured operational data can support decision-making in an airline environment.

Tools: PostgreSQL · SQL · Power BI · GitHub · Claude AI

## SQL Analysis

The project is organized into focused PostgreSQL analysis modules, with each SQL file addressing a specific area of airline operations.

### 01. Data Exploration
Initial exploration of the operational datasets, including fleet composition, flight coverage, and overall data volume.

### 02. Data Quality
Checks for missing references, inconsistent aircraft information, invalid values, and potential data-quality issues across operational datasets.

### 03. Aircraft Utilization
Analysis of aircraft flight activity, scheduled flight hours, fleet utilization, aircraft-type performance, and utilization rankings.

### 04. Flight Performance
Analysis of flight delays, cancellations, delay rates, delay reasons, aircraft-level performance, and operational punctuality.

### 05. Airport & Route Analysis
Analysis of airport activity, route performance, passenger volumes, and airport-level operational delays.

### 06. Maintenance Analysis
Analysis of maintenance workload, technician hours, aircraft downtime, maintenance priorities, maintenance categories, and the relationship between maintenance activity and aircraft utilization.

### 07. Operational Events
Analysis of operational event frequency, severity, resolution time, aircraft-level event patterns, and flights affected by multiple operational events.

### 08. Advanced Business Analysis
Cross-table and advanced analytical queries combining aircraft, flight, maintenance, and operational-event data. This section includes CTEs, window functions, ranking, time-series analysis, fleet comparisons, and aircraft-level operational performance analysis.

## SQL Techniques

The project applies PostgreSQL features including:

- SELECT, WHERE, ORDER BY and DISTINCT
- Aggregations and GROUP BY
- CASE expressions
- INNER JOIN and LEFT JOIN
- Common Table Expressions (CTEs)
- Subqueries
- Window functions
- RANK() and DENSE_RANK()
- LAG()
- FILTER clauses
- Date and time analysis
- Cross-table analytical queries
- Data-quality validation

Key Analytical Areas
Aircraft utilization and operational performance
Flight punctuality and delays
Airport and route performance
Maintenance workload and aircraft downtime
Operational events and disruption patterns
Data quality and consistency
Cross-table operational analysis
Business Objective

This project simulates an airline Technical Operations analytics environment, where data from aircraft, flights, airports, maintenance, and operational events is combined to identify operational patterns, improve data quality, and support continuous improvement.

Business Questions

The analysis addresses the following questions:

Which aircraft have the highest utilization?
Which aircraft spend the most time unavailable due to maintenance?
Which airports experience the highest levels of operational disruption?
Which aircraft types have the highest maintenance workload?
Are maintenance events associated with reduced aircraft utilization?
Which routes have the highest delay rates?
Which aircraft have unusually high numbers of operational events?
Which maintenance categories consume the most work-order hours?
Which aircraft show deteriorating operational performance over time?
Can data-quality inconsistencies be identified across operational datasets?

airline_operations_analytics/
│
├── README.md
│
├── data/
│   ├── aircraft.csv
│   ├── aircraft_types.csv
│   ├── airports.csv
│   ├── flights.csv
│   ├── maintenance_work_orders.csv
│   └── operational_events.csv
│
└── sql/
    ├── 01_data_exploration.sql
    ├── 02_data_quality.sql
    ├── 03_aircraft_utilization.sql
    ├── 04_flight_performance.sql
    ├── 05_airport_route_analysis.sql
    ├── 06_maintenance_analysis.sql
    ├── 07_operational_events.sql
    └── 08_advanced_business_analysis.sql
