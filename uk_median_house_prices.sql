SELECT *
FROM uk_housing_cleaned;

SELECT
 COUNT(*) AS total_rows,					
 MIN(date_of_transfer) AS  min_date,
 MAX(date_of_transfer) AS max_date         -- dataset captures records of house purchased from 1995-01-01 to 2023-04-25
FROM uk_housing_cleaned;

-- NULL Checks
SELECT 
	SUM(price IS NULL) AS price_nulls,
    SUM(date_of_transfer IS NULL) AS date_nulls,
    SUM(`year` IS NULL) AS year_nulls,
    SUM(`month` IS NULL) AS month_nulls,
    SUM(county IS NULL) AS county_nulls
FROM uk_housing_cleaned;

-- what is the median house prices in UK over time?

WITH ranked AS
	(SELECT price, `year`,
    ROW_NUMBER() OVER (PARTITION BY `year` ORDER BY price) AS r, -- ROW_NUMBER() assigns rank, PARTITION BY `year` restarts rank number after year is done, ORDER BY price orders price from lowest to highest	
    COUNT(price) OVER (PARTITION BY `year`) AS c -- Count of price rows OVER the partitioned year (count total price rows for each year)
FROM uk_housing_cleaned
WHERE price IS NOT NULL),
	median AS 	-- table looks at middle position based on c (total row number)
    (SELECT `year`, price -- (c+1)/2 gives middle index. if number is odd then midpoint is easily pinpointed
    FROM ranked											
    WHERE r IN (FLOOR((c+1)/2), CEILING((c+1)/2)) -- IF c is even number FLOOR AND CEILING rounds up and down. so r will be in one of these values which is midpoint
    )
SELECT `year`, ROUND(AVG(price),0) AS median_price
FROM median   
GROUP BY `year`
ORDER BY `year`;


-- Median house prices by county on year 2022
-- Counties with fewer than 30 observations will be excluded due to insufficient sample size.

WITH county_counts AS (
	SELECT county,
    COUNT(*) AS record_count
	FROM uk_housing_cleaned
	WHERE year = 2022 AND price IS NOT NULL
	GROUP BY county
	HAVING COUNT(*) >= 30),					-- identifies counties with count equal/over 30
    
    ranked AS (
    SELECT h.county,
			h.price,
            ROW_NUMBER() OVER (PARTITION BY h.county ORDER BY h.price) AS r, -- assigns row number to order of price by county
            COUNT(*) OVER (PARTITION BY h.county) AS c  -- count of county rows
    FROM uk_housing_cleaned AS h			-- include main table to get prices as county counts doesnt have prices
    INNER JOIN county_counts AS cc 			-- Restricts the data set to only those valid counties with equal/over 30 rows
    ON h.county = cc.county
    WHERE h.`year` = 2022),
    
    median_price AS ( 
    SELECT county,
			price
	FROM ranked
    WHERE r IN ( FLOOR((c+1)/2), CEILING((c+1)/2))
    )
    
    SELECT county, 
			ROUND(AVG(price),0) AS median_price
	FROM median_price
    GROUP BY county
    ORDER BY median_price DESC;
    






    















    