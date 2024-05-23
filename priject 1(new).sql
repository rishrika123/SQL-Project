create database car_showroom;
use car_showroom;
select * from audi;
select * from bmw;
select * from cclass;
select * from hyndai;
select * from merc;

-- Create a CombinedCarData all car data from different brands into a single view.--

CREATE VIEW CombinedCarData AS
SELECT 'audi' AS brand, model_ID, year, price, mileage, tax, mpg, engineSize, transmission_ID, fuel_ID
FROM audi
UNION ALL
SELECT 'bmw' AS brand, model_ID, year, price, mileage, tax, mpg, engineSize, transmission_ID, fuel_ID
FROM bmw
UNION ALL
SELECT 'cclass' AS brand, model_ID, year, price, mileage, NULL AS tax, NULL AS mpg, engineSize, transmission_ID, fuel_ID
FROM cclass
UNION ALL
SELECT 'hyndai' AS brand, model_ID, year, price, mileage, tax, mpg, engineSize, transmission_ID, fuel_ID
FROM hyndai
UNION ALL
SELECT 'merc' AS brand, model_ID, year, price, mileage, tax, mpg, engineSize, transmission_ID, fuel_ID
FROM merc;

select * from CombinedCarData;

-- 1. Categorize the cars on the basis of their price(Create as many buckets as you want as per your understanding of data) and analyze the:
SELECT
    CASE 
        WHEN price < 10000 THEN 'Low'
        WHEN price BETWEEN 10000 AND 20000 THEN 'Mid-Low'
        WHEN price BETWEEN 20000 AND 30000 THEN 'Mid'
        WHEN price BETWEEN 30000 AND 40000 THEN 'Mid-High'
        ELSE 'High'
    END AS price_category,
    year,
    COUNT(*) AS car_count,
    AVG(price) AS avg_price
FROM CombinedCarData
GROUP BY price_category, year
ORDER BY year, price_category;


-- (a) price changes across the years and identifies the categories which have seen a significant jump in their price--
-- Now that we have a combined dataset, we can calculate the average price for each model by year.--
CREATE VIEW AvgPriceByYear AS
SELECT brand, model_ID, year, AVG(price) AS avg_price
FROM CombinedCarData
GROUP BY brand, model_ID, year;
select * from AvgPriceByYear;

-- To identify models with significant price jumps, we need to compare the average prices year-over-year.--

WITH PriceChanges AS (
    SELECT a.brand, a.model_ID, a.year, a.avg_price AS current_price, b.avg_price AS previous_price,
           (a.avg_price - b.avg_price) / b.avg_price * 100 AS price_change_percentage
    FROM AvgPriceByYear a
    JOIN AvgPriceByYear b ON a.brand = b.brand AND a.model_ID = b.model_ID AND a.year = b.year + 1
)
SELECT brand, model_ID, year, current_price, previous_price, price_change_percentage
FROM PriceChanges
WHERE price_change_percentage > 10 -- Adjust the percentage as per the definition of "significant"
ORDER BY price_change_percentage DESC;


-- Relationship between fuel efficiency and price
SELECT
    AVG(mpg) AS avg_mpg,
    AVG(price) AS avg_price
FROM CombinedCarData
GROUP BY fuel_ID;

-- Relationship between fuel type and sales
SELECT
    fuel_ID,
    COUNT(*) AS car_count
FROM CombinedCarData
GROUP BY fuel_ID
ORDER BY car_count DESC;

-- Ranking models
SELECT
    brand,
    model_ID,
    COUNT(*) AS total_sales,
    AVG(price) AS avg_price,
    AVG(mileage) AS avg_mileage,
    AVG(engineSize) AS avg_engine_size
FROM CombinedCarData
GROUP BY brand, model_ID
ORDER BY total_sales DESC
LIMIT 10;







