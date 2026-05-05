SELECT *
FROM propertydatabase_staging2;

SELECT DISTINCT property_type
FROM propertydatabase_staging2
WHERE property_type like '%apartment%';

WITH the_table AS
(
SELECT property_location, COUNT(*) AS listings
FROM propertydatabase_staging2
WHERE property_type = 'apartment'
GROUP BY property_location
)
SELECT *
FROM the_table;

DELETE
FROM propertydatabase_staging2
WHERE property_location IN (
	SELECT Property_location
    FROM (
		SELECT property_location, COUNT(*) apartment_count
		FROM propertydatabase_staging2
		WHERE property_type = 'apartment'
		GROUP BY property_location
		HAVING COUNT(*) <= 20
		ORDER BY apartment_count ASC) AS sub_table)
AND property_type = 'apartment';

SELECT property_location, COUNT(*) apartment_count
FROM propertydatabase_staging2
WHERE property_type = 'apartment'
GROUP BY property_location
HAVING COUNT(*) <= 20
ORDER BY apartment_count ASC;

SELECT Property_location    
FROM propertydatabase_staging2
WHERE property_location = 'apartment'
GROUP BY Property_location
HAVING COUNT(*) <= 20;

SELECT Property_location
FROM propertydatabase_staging2
GROUP BY Property_location
HAVING COUNT(*) < 7;


UPDATE propertydatabase_staging2
SET `property_price_(per_month)` = "30000"
WHERE `property_price_(per_month)` LIKE '%perday%';

SELECT property_type
FROM propertydatabase_staging2
GROUP BY property_type;

SELECT *
FROM propertydatabase_staging2;

SELECT `property_price_(per_month)`
FROM propertydatabase_staging2
GROUP BY `property_price_(per_month)`
ORDER BY `property_price_(per_month)`;

UPDATE propertydatabase_staging2
SET floor_size = 0
WHERE Floor_size = ''
	OR floor_size <= 0;

SELECT property_location
FROM propertydatabase_staging2
GROUP BY property_location;

SELECT TRIM(property_location), property_location
FROM propertydatabase_staging2;

UPDATE propertydatabase_staging2
SET property_location = TRIM(property_location);

SELECT COUNT(DISTINCT property_type)
FROM propertydatabase_staging2;

SELECT
MAX(bedrooms) AS MAX,
MIN(bedrooms) MIN
FROM propertydatabase_staging2;

SELECT MAX(bathrooms),
MIN(bathrooms)
FROM propertydatabase_staging2;

SELECT MAX(parking_space),
MIN(parking_space)
FROM propertydatabase_staging2;

SELECT CAST(`Property_price_(per_month)` AS DECIMAL(10,2)) AS price
FROM propertydatabase_staging2
;

SELECT *
FROM propertydatabase_staging2
WHERE `property_price_(per_month)` LIKE '%perday%';

SELECT `property_price_(per_month)`, REPLACE(`property_price_(per_month)`, ' ', '')
FROM propertydatabase_staging2;

UPDATE propertydatabase_staging2
SET `property_price_(per_month)` = CAST(`property_price_(per_month)` AS UNSIGNED);

ALTER TABLE propertydatabase_staging2
MODIFY COLUMN `property_price_(per_month)` DOUBLE;

SELECT *
FROM propertydatabase_staging2
WHERE `property_price_(per_month)` <= 0;

SELECT TRIM(property_location), property_location
FROM propertydatabase_staging2;

UPDATE propertydatabase_staging2
SET property_location = TRIM(property_location)
;

SELECT *
FROM propertydatabase_staging2
WHERE property_type = 'apartment';


DELETE
FROM propertydatabase_staging2
WHERE parking_space >= 7;
