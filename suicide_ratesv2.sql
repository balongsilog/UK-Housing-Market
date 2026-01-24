/*1.) Sanity check: dataset population totals (2015) 
Query: Total population for Republic of Korea and Japan in 2015 (North Korea not present in dataset)
Output: Total population
*/
-- Dataset 48 million, External estimate ~50M (2015)
SELECT SUM(population) AS total_population_2015
FROM suicide_rates_raw
WHERE country = 'Republic of Korea' AND `year` = 2015;
-- Dataset 120 million, External estimate ~127M (2015)
SELECT SUM(population) AS total_population_2015
FROM suicide_rates_raw
WHERE country = 'Japan' AND `year` = 2015;
    
/* 2.) Record count by year.
Query: Return the total record count for each year
Output: Year, record_count
*/

SELECT 
	`year`, 
    COUNT(*) AS record_count
    -- Will be excluding 2016 in analysis as insufficient count
    -- record count range from 1985(576c) to 2015(1032c)
FROM suicide_rates_raw
GROUP BY `year`
ORDER BY 
	`year`;

/*3.) What is the population-weighted global suicide crude rate from 1985 to 2015
By doing population weighted crude rate, we ensure subgroups with larger population have proportionally greater influence on the global crude rate
Query: Multiply subgroup crude rates by subgroup populations to obtain population-weighted contributions, then divide by total population
to obtain the global crude rate.
Output: Year, populationweighted_crude
*/

SELECT 
	`year`, 
	ROUND(SUM(suicides_100k_pop * population) / SUM(population),1) AS populationweighted_crude 
		-- SUM(rate * population) / SUM(population)
FROM suicide_rates_raw
WHERE `year` < 2016
	AND suicides_100k_pop IS NOT NULL			
    AND population IS NOT NULL 					
    AND population > 0							
GROUP BY `year`
ORDER BY `year`;

/*4.) What is the global suicide crude rate from 1985 to 2015 by age group
-- The population-weighted suicide crude rate experienced by the global population within each age group and by year.
Query: same as query 3 with the addition of GROUP BY age and CASE WHEN for ordering
Output: Year, age, population weighted_crude
*/

SELECT 
	`year`, 
	age, 
    ROUND(SUM(suicides_100k_pop * population) / SUM(population),1) AS populationweighted_crude
FROM suicide_rates_raw
WHERE suicides_100k_pop IS NOT NULL
	AND population IS NOT NULL
	AND population > 0
	AND `year` < 2016
GROUP BY 
	`year`, 
    age
ORDER BY 
	`year`, 
    CASE WHEN age LIKE '%+%' 
            THEN CAST(REPLACE(age, '+ years','') AS UNSIGNED) 
            -- REPLACE(age, '+ years', '') turns '75+ years' to '75'
            -- CAST('75' AS UNSIGNED) turns '75' to numeric so last age group in order
        ELSE CAST(SUBSTRING_INDEX(age, '-', 1) AS UNSIGNED)
			-- (SUBSTRING_INDEX(age, '-', 1) takes everything before the first hyphen (delimiter)
    END;


/* Reminder:
suicides_100k_pop is a subgroup crude rate per 100,000 people:

suicides_100k_pop = (E / P) * 100000

Where:
E = number of suicides in the subgroup
P = subgroup population

Subgroups are defined by: country, year, sex, age.
*/

