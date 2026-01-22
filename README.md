# UK Housing Market Analysis
## Objective
A time-series analysis of UK median house prices to assess the impact of major economic events on housing costs over the last four decades, alongside a county-level comparison of median house prices in 2022 to identify high cost-of-living areas.
## Dataset
UK Housing (Cleaned) dataset sourced from Kaggle
**Note:** Records for 2023 were excluded from the analysis due to insufficient record counts compared with prior years, which could distort trend interpretation.
## Methodology
- Imported large-scale dataset into MySQL using Python (Pandas + SQLAlchemy) due to record size limitations of the standard import wizard
- Calculated median house prices to avoid skewed averages caused by outliers (e.g. small number of high-end properties)
- Calculated median house prices by county for the most recent complete year in the dataset (2022)
- Excluded counties with 30 or fewer records due to insufficient sample sizes
- Visualised results using line chart and heatmap in Tableau
## Key Findings
- Rapid house price growth between 2000 and 2007 indicates a period of accelerated housing inflation
- Median house prices ranged from £164k to £175k for four years following the 2008 financial crash
- A record median price of approximately £240k was observed in 2021, likely driven by a combination of COVID-19-related hybrid/remote working, the stamp duty holiday, and historically low interest rates
- The counties with the highest median house prices in 2022 were Windsor and Maidenhead, West Berkshire, Buckinghamshire, Greater London, and Hertfordshire
## Files
- `uk_median_house_prices.sql` – SQL query used for analysis
- `uk_median_house_prices.png` – Visualisation of results
## Output
![UK Housing Market](uk_median_house_prices.png)
