SELECT *
FROM propertydatabase_staging2
WHERE property_type = 'apartment'
;

SELECT  COUNT(property_type) nr_of_properties, 
COUNT(DISTINCT property_type) AS nr_of_properties_types,
COUNT(DISTINCT Property_location) AS nr_of_locations
FROM propertydatabase_staging2;

-- Number of property types
SELECT property_type, COUNT(property_type) 
FROM propertydatabase_staging2
GROUP BY property_type;

-- Property type with the most locations
SELECT property_type, COUNT(DISTINCT property_location) AS locations
FROM propertydatabase_staging2
GROUP BY property_type
ORDER BY locations;

-- Number of properties per location
SELECT property_location, COUNT(property_location) AS properties
FROM propertydatabase_staging2
WHERE Property_type = 'house'
GROUP BY Property_location
ORDER BY properties DESC;

-- Max, min, range
SELECT MAX(parking_space) AS Max,
MIN(bathrooms) AS MIN,
(MAX(parking_space) - MIN(parking_space)) AS `range`
FROM propertydatabase_staging2
WHERE property_type = 'house';

-- Mode
SELECT bathrooms, COUNT(bathrooms) AS occurancies
FROM propertydatabase_staging2
WHERE property_type = 'house'
GROUP BY bathrooms
ORDER BY occurancies DESC
LIMIT 5;

WITH percentile_cte AS
(
SELECT bedrooms,
PERCENT_RANK() OVER(ORDER BY bedrooms) AS percentiles
FROM propertydatabase_staging2
WHERE Property_type = 'apartment'
ORDER BY bedrooms
)
SELECT ROUND(AVG(bedrooms),2) AS Mean,
MIN(CASE WHEN percentiles >= 0.5 THEN bedrooms END) AS Median,
ROUND(STDDEV_SAMP(bedrooms),2) AS standard_deviation
FROM percentile_cte;

SELECT ROUND((STDDEV_SAMP(bathrooms)/avg(bathrooms)) * 100, 2) AS measure_STDDEV
FROM propertydatabase_staging2
WHERE property_type = 'house';

WITH IQR_cte AS
(
SELECT `property_price_(per_month)`,
PERCENT_RANK() OVER(ORDER BY `property_price_(per_month)`) AS percentiles
FROM propertydatabase_staging2
WHERE property_type = 'apartment'
ORDER BY `property_price_(per_month)`
)
SELECT (MIN(CASE WHEN percentiles >= 0.75 THEN `property_price_(per_month)` END) - MIN(CASE WHEN percentiles >= 0.25 THEN `property_price_(per_month)` END)) AS interquartileRange
FROM IQR_cte;

WITH possible_outliers AS
(
SELECT `property_price_(per_month)`,
PERCENT_RANK() OVER(ORDER BY `property_price_(per_month)`) AS percentiles
FROM propertydatabase_staging2
WHERE property_type = 'apartment'
ORDER BY `property_price_(per_month)`
)
SELECT `property_price_(per_month)`
FROM possible_outliers
WHERE 
	`property_price_(per_month)` < 
	(SELECT MIN(CASE WHEN percentiles >= 0.25 THEN `property_price_(per_month)` END) - (1.5)*(5080)
    FROM possible_outliers)
    OR
    `property_price_(per_month)` > 
    (SELECT MIN(CASE WHEN percentiles >= 0.75 THEN `property_price_(per_month)` END) + (1.5)*(5080)
    FROM possible_outliers);
  
WITH cte AS
(
SELECT `property_price_(per_month)`,
PERCENT_RANK() OVER(ORDER BY `property_price_(per_month)`) AS percentiles
FROM propertydatabase_staging2
ORDER BY `property_price_(per_month)`
)
SELECT MIN(CASE WHEN percentiles >= 0.25 THEN `property_price_(per_month)` END) - (1.5)*(1)
FROM cte;
  
SELECT SUM(POWER(bedrooms - AVG(bedrooms), 4))/
		COUNT(*)*POWER(STDDEV_SAMP(bedrooms), 4) AS Kurtosis
FROM propertydatabase_staging2
WHERE property_type = 'apartment'
GROUP BY bedrooms;


SELECT 'Average apartment monthly price' AS meaure_name,
ROUND(AVG(`property_price_(per_month)`), 2) AS measure_value
FROM propertydatabase_staging2
WHERE property_type = 'apartment'

UNION ALL

SELECT 'Average number of bedrooms' AS measure_name,
ROUND(AVG(bedrooms), 2) AS measure_value
FROM propertydatabase_staging2
WHERE property_type = 'apartment';

SELECT property_location, property_type,
ROUND(AVG(`property_price_(per_month)`), 2) AS avg_monthly_price,
COUNT(*) AS nr_listings
FROM propertydatabase_staging2
WHERE property_type = 'apartment'
GROUP BY Property_location
ORDER BY avg_monthly_price DESC;
    
SELECT 
    bedrooms,
    bathrooms,
    parking_space,
    ROUND(AVG(`property_price_(per_month)`), 2) AS avg_price,
    COUNT(*) AS nr_listings
FROM propertydatabase_staging2
WHERE property_type = 'apartment'
GROUP BY bedrooms, bathrooms, parking_space
ORDER BY avg_price DESC;

SELECT Parking_space, COUNT(parking_space) nr, ROUND(AVG(`property_price_(per_month)`),2) AS avg_price
FROM propertydatabase_staging2
GROUP BY parking_space
ORDER BY Parking_space DESC;

-- Pearson Correlation
SELECT
	ROUND((SUM((parking_space - bd_mean) * (`property_price_(per_month)` - price_mean)))/
    (STDDEV(parking_space) * STDDEV(`property_price_(per_month)`) * (COUNT(*) - 1)), 2) AS correlation
FROM propertydatabase_staging2
CROSS JOIN (
	SELECT 
		AVG(parking_space) AS bd_mean,
        AVG(`property_price_(per_month)`) AS price_mean
	FROM propertydatabase_staging2) AS means
    WHERE property_type = 'apartment';

-- Spearman's rank correlation
WITH raw_ranking AS (
	SELECT 
		bedrooms,
		`property_price_(per_month)` AS price,
		RANK() OVER(ORDER BY bedrooms) AS rank_bedrooms_r,
		RANK() OVER(ORDER BY `property_price_(per_month)`) AS rank_price_r
	FROM propertydatabase_staging2
	WHERE property_type = 'apartment' 
    AND bedrooms IS NOT NULL
	AND `property_price_(per_month)` IS NOT NULL
), ranking_data AS (
	SELECT 
		bedrooms,
        price,
        ROUND(AVG(rank_bedrooms_r) OVER(PARTITION BY bedrooms)) AS bedroom_rank,
		ROUND(AVG(rank_price_r) OVER(PARTITION BY price)) AS price_rank
	FROM raw_ranking
), diff_rank AS (
	SELECT 
		POW(bedroom_rank - price_rank, 2) AS d_rank
	FROM ranking_data
)
SELECT ROUND(
	(COUNT(*) * SUM(bedroom_rank * price_rank) - SUM(bedroom_rank) - SUM(price_rank)) /
    SQRT(
		(COUNT(*) * SUM(POW(bedroom_rank, 2)) - POW(SUM(bedroom_rank),2)) *
        (COUNT(*) * SUM(POW(price_rank,2)) - POW(SUM(price_rank),2))
    ), 4) AS spearman_correlation
FROM ranking_data;


SELECT
	ROUND(AVG(parking_space),2) AS bathroom_avg,
	ROUND(AVG(`property_price_(per_month)`),2) AS price_avg
FROM propertydatabase_staging2
WHERE property_type = 'apartment';

SELECT ROUND(SUM((parking_space - 1.57) * (`property_price_(per_month)` - 10797.42)) /
		SUM(POW(parking_space - 1.57, 2)), 2) AS slope
FROM propertydatabase_staging2
WHERE property_type = 'apartment';

SELECT ROUND(AVG(`property_price_(per_month)`) - 662.98*(AVG(bathrooms)),2) AS y_intercept
FROM propertydatabase_staging2
WHERE property_type = 'apartment';

SELECT ROUND(AVG(`property_price_(per_month)`),2) price,
	ROUND(AVG(bedrooms),2) AS bedrooms
FROM propertydatabase_staging2;


SELECT 
	bedrooms,
    bathrooms,
    parking_space,
    `property_price_(per_month)` AS price
FROM propertydatabase_staging2
WHERE property_type = 'apartment';


SELECT 'ASDF' AS P,
	'fadsga' AS P;