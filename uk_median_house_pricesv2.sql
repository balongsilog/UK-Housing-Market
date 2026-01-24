/*1.) Data overview/checks 
Query: Display total rows, minimum and maximum date of transfer in the whole dataset
Output: Count of total rows, minimum date of transfer, maximum date of transfer
*/
SELECT
	COUNT(*) AS total_rows,					
	MIN(date_of_transfer) AS  min_date,
	MAX(date_of_transfer) AS max_date 
    -- dataset captures records of house purchased from 1995-01-01 to 2023-04-25
FROM uk_housing_cleaned;

/*2.) Data NULL checks
Query: Display any nulls for the key columns I will be using (price, date_of_transfer,`year`,`month`,county)
Output: price_nulls, date_nulls, year_nulls, month_nulls, county_nulls
*/

SELECT 
	SUM(price IS NULL) AS price_nulls,
    SUM(date_of_transfer IS NULL) AS date_nulls,
    SUM(`year` IS NULL) AS year_nulls,
    SUM(`month` IS NULL) AS month_nulls,
    SUM(county IS NULL) AS county_nulls
FROM uk_housing_cleaned;


/*3.) what is the median house prices in UK over time?
Query: 2x CTE to: 
	1.) rank prices by year 
    2.) identify midpoint price in each year.
Final query to retun the median house prices from 1995-2023
Output: year, median_price
*/

WITH ranked AS (
	SELECT 
		price, 
		`year`,
		-- ROW_NUMBER() assigns rank, PARTITION BY `year` restarts rank number after year is done, ORDER BY price orders price from lowest to highest	
        ROW_NUMBER() OVER (PARTITION BY `year` ORDER BY price) AS r, 
        -- Count of price rows OVER the partitioned year (count total price rows for each year)
		COUNT(price) OVER (PARTITION BY `year`) AS c 
	FROM uk_housing_cleaned
	WHERE price IS NOT NULL 
	AND `year` IS NOT NULL
),
	median_rows AS ( -- CTE table looks at middle position based on c (total row number)
	SELECT 
		`year`, 
		price 
	FROM ranked											
	WHERE r IN (FLOOR((c+1)/2), CEILING((c+1)/2))
    /*if c is even number FLOOR AND CEILING rounds up and down. so r will be in one of these values which is midpoint
    (c+1)/2 gives middle index. if number is odd then midpoint is easily pinpointed*/
)
SELECT 
	`year`, 
	ROUND(AVG(price),0) AS median_price
FROM median_rows   
GROUP BY `year`
ORDER BY `year`;

/*4.) Median house prices by county for year 2022, Counties with fewer than 30 observations will be excluded due to insufficient sample size.
Query: 3x CTE to:
	1.) identify counties with record counts of 30 or more 
    2.) rank prices in each county
    3.) identify midpoint price in each county
Final query to return the median house prices in each county for 2022
Output: county, median_price
*/

WITH county_counts AS ( -- CTE identifies counties with count equal/over 30
	SELECT 
		county,
		COUNT(*) AS record_count
	FROM uk_housing_cleaned
	WHERE year = 2022 
    AND price IS NOT NULL
	GROUP BY county
	HAVING COUNT(*) >= 30					
),	    
    ranked AS ( -- CTE to rank prices in each county
    SELECT 
		h.county,
		h.price,
		-- assigns row number to order of price by county
        ROW_NUMBER() OVER (PARTITION BY h.county ORDER BY h.price) AS r, 
		-- count of county rows
        COUNT(*) OVER (PARTITION BY h.county) AS c 
    -- include main table to get prices as county counts does NOT contain prices
    FROM uk_housing_cleaned AS h	
    INNER JOIN county_counts AS cc 			
		ON h.county = cc.county
	-- Restricts the dataset to only include counties with equal/over 30 rows
    WHERE h.`year` = 2022
	AND h.price IS NOT NULL
),
    median_price AS (-- CTE table looks at middle position based on c (total row number)
    SELECT 
		county,
		price
	FROM ranked
    WHERE r IN ( FLOOR((c+1)/2), CEILING((c+1)/2))
)
    
SELECT 
	county, 
	ROUND(AVG(price),0) AS median_price
FROM median_price
GROUP BY county
ORDER BY median_price DESC;
    



