# Apartment-analysis-project

### Project Overview 
In this analysis project, we try to uncover which apartment feature, bedrooms, bathrooms, and parking spaces have the most influence on the apartment's monthly price. We used metrics such as correlation, R-squared, and the slope of the regression equation to understand which feature had the strongest relationship with price.
### Data Sources
Due to the property website's prohibition on data scraping, I may not include the link.
### Tools
- Python Pandas for Web scraping & linear regression analysis
- MySQL for data cleaning, Exploratory Data Analysis, & Statistics
- Tableau for dasboarding
- Microsoft Word for insights reporting
### Data Cleaning
1. Removing records with missing, mixed or ambiguous fields
2. Converting strings to integer data type
3. Trimmimg string values
### Exploratory Data Analysis
1. Calculating range, mean, mode and median for measure
2. Studied the distribution of each measure using the mean, mode, median method and a histogram
3. Studied the correlation of measures to see how they relate with each other
4. Calculated the interquartile range and Kurtosis to look for statistical outliers

### Data Analysis
> This query is used to get the slope of the regression equation in order to quantify by how much each additional bedroom, bathroom or parking space drives prices up.
```sql
SELECT ROUND(SUM((parking_space - 1.57) * (`property_price_(per_month)` - 10797.42)) /
		SUM(POW(parking_space - 1.57, 2)), 2) AS slope
FROM propertydatabase_staging2
WHERE property_type = 'apartment';
```
> This query evaluates the Pearson correlation/Linear relationship between number of bedrooms, bathrooms, or parking spaces and apartment monthly prices.
```sql
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
```
This Python script calculated the Multiple Linear Regression of bedrooms, bathrooms, and parking spaces against monthly prices in order to get their combined influence.
```python
import pandas as pd
import statsmodels.formula.api as smf

df = pd.read_csv('../Database/propertyDatabase_MLR.csv')
print(df.head())
print(df.shape)

print(df['price'].describe())
print(df['price'].dtype)

model = smf.ols('price ~ bedrooms + bathrooms + parking_space', data=df).fit()
print(model.summary())
```

### Findings 
-  There is a very strong positive correlation (0.7) between the number of
bedrooms and monthly rental prices; this means that price tends to
increase with the number of bedrooms. Further analyses indicated that
each additional bedroom drives apartment prices up by R1 351.93.
Additionally, we evaluated an R-squared score of 49%, which tells us
that almost half of the variability in monthly rental prices can be
explained by the number of bedrooms.
- There is a very strong positive correlation (0.83) between the number
of bathrooms and monthly rental prices; this means that price tends to
increase with the number of bathrooms. Further analyses indicated
that each additional bathroom drives apartment prices up by R2
786.51. Additionally, we evaluated an R-squared score of 69%, which
tells us that more than half of the variability in monthly rental prices
can be explained by the number of bathrooms.
- There is a moderately strong positive correlation (0.44) between the
number of parking spaces and monthly rental prices; this means that
price tends to increase with the number of parking spaces but not at a
consistent pace. Further analyses indicated that each additional
parking space drives apartment prices up by only R662.98.
Additionally, we evaluated an R-squared score of 19%, which tells us
that less than one fifth of the variability in monthly rental prices can be
explained by the number of parking spaces.
- The multiple linear regression, when including bedrooms, bathrooms, and parking space, is only 9.6%, meaning that only about 9.6% of apartment price variation can be explained by all three features. Other features such as room size and location may play a larger role in the price difference between listings.

### Limitations
The project's aim was to compare the influence of the number of bedrooms, bathrooms, and parking spaces on apartment prices, not to uncover which factor drives apartment prices in the market. In order to do so, we would need to include other components such as room size, apartment ratings, and location, which this database doesn't currently have.

### Recommendation

If you have decided on the location of your apartment and as a real estate agent want to maximise your earnings, then looking into the number of bathrooms and bedrooms your apartment provides may be crucial to how you structure your monthly rates.

### References
- 'Indeed Jobs Web Scraping Save to CSV' by John Watson Rooney
- 'R-squared, Clearly Explained' by StatQuest with Josh Starmer
