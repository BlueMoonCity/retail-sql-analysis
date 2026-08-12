# Ensure the database exists and uses UTF-8
CREATE DATABASE IF NOT EXISTS retail_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE retail_db;

-- 2. Create the target table structure
DROP TABLE IF EXISTS online_retail_raw;

CREATE TABLE online_retail_raw (
    OrderID VARCHAR(50),
    CustomerID INT,
    ProductName VARCHAR(255),
    Brand VARCHAR(255),
    Raw_Weight VARCHAR(100),
    Country TEXT,
    OrderDate VARCHAR(50),
    UnitPrice DECIMAL(10,2)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 3. Load file directly bypassing Python wizard
-- Replace the file path with your actual full file path
LOAD DATA LOCAL INFILE '/Users/nicoleedwardsharris/Desktop/kraggle/online_retail_real_world.csv'
INTO TABLE online_retail_raw
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

select *
from online_retail_raw;
SELECT COUNT(*) FROM online_retail_cleaned;


#Staging Table 
CREATE TABLE online_retail_cleaned AS
SELECT * FROM online_retail_raw;

#Setting blanks to null
UPDATE online_retail_cleaned
SET 
    ProductName = NULLIF(TRIM(ProductName), ''),
    Brand       = NULLIF(TRIM(Brand), ''),
    Raw_Weight  = NULLIF(TRIM(Raw_Weight), ''),
    Country     = NULLIF(TRIM(Country), ''),
    OrderDate   = NULLIF(TRIM(OrderDate), '');


#deleteting uneessary rows where product name/unit price is blank
DELETE FROM online_retail_cleaned
WHERE ProductName IS NULL OR UnitPrice IS NULL;

select*
from online_retail_cleaned;


#change null brands to unknown 
UPDATE online_retail_cleaned
SET Brand = 'Unknown'
WHERE Brand IS NULL;

# editing date to correct type
ALTER TABLE online_retail_cleaned 
MODIFY COLUMN OrderDate DATE;




# standardizing the weight into one format of grams

#create standarized grams collum
ALTER TABLE online_retail_cleaned 
ADD COLUMN Normalized_Weight_g DECIMAL(10,2);



# convert weights to grams 
UPDATE online_retail_cleaned
SET Normalized_Weight_g = CASE 
    
    --  Multipacks like '3 x 30g'
    WHEN Raw_Weight REGEXP '^[0-9]+\\s*x\\s*[0-9]+' THEN 
        CAST(REGEXP_SUBSTR(Raw_Weight, '^[0-9]+') AS UNSIGNED) * 
        CAST(REGEXP_SUBSTR(REPLACE(SUBSTRING_INDEX(Raw_Weight, 'x', -1), ',', '.'), '[0-9]+(\\.[0-9]+)?') AS DECIMAL(10,2))

    --  Kilograms 
    WHEN Raw_Weight LIKE '%kg%' THEN 
        CAST(REGEXP_SUBSTR(REPLACE(Raw_Weight, ',', '.'), '[0-9]+(\\.[0-9]+)?') AS DECIMAL(10,2)) * 1000

    --  Ounces 
    WHEN Raw_Weight LIKE '%oz%' OR Raw_Weight LIKE '%OZ%' THEN 
        CAST(REGEXP_SUBSTR(REPLACE(Raw_Weight, ',', '.'), '[0-9]+(\\.[0-9]+)?') AS DECIMAL(10,2)) * 28.35

    --  Standard Grams 
    ELSE 
        CAST(REGEXP_SUBSTR(REPLACE(Raw_Weight, ',', '.'), '[0-9]+(\\.[0-9]+)?') AS DECIMAL(10,2))
END
WHERE Raw_Weight IS NOT NULL 
  AND REGEXP_LIKE(Raw_Weight, '[0-9]');


# cleaning counrty names and stadardzing 

# getting rid of en and blank spaces at begining of country name
UPDATE online_retail_cleaned
SET Country = REGEXP_REPLACE(Country, 'en:', '');

#making non english country names into one english counrtry name
UPDATE online_retail_cleaned
SET Country = REPLACE(Country, 'España', 'Spain'),
    Country = REPLACE(Country, 'Francia', 'France'),
    Country = REPLACE(Country, 'Maroc', 'Morocco'),
    Country = REPLACE(Country, 'Bélgica', 'Belgium'),
    Country = REPLACE(Country, 'Alemania', 'Germany');

select*
from online_retail_cleaned;

# take first brand name to make it easier to read
UPDATE online_retail_cleaned
SET Brand = TRIM(SUBSTRING_INDEX(Brand, ',', 1))
WHERE Brand LIKE '%,%';


# setting all brands to a consitant format of upper case to lower case
UPDATE online_retail_cleaned
SET Brand = CONCAT(UPPER(SUBSTRING(Brand, 1, 1)), LOWER(SUBSTRING(Brand, 2)))
WHERE Brand != 'Unknown';


















# Data analsis maybe if I get to it

#total orders, uniques customers, and total revenue 

SELECT 
    COUNT(DISTINCT OrderID) AS Total_Orders,
    COUNT(DISTINCT CustomerID) AS Unique_Customers,
    ROUND(SUM(UnitPrice), 2) AS Total_Revenue
FROM online_retail_cleaned;



# sales and orders by month 
SELECT 
    DATE_FORMAT(OrderDate, '%Y-%m') AS Sales_Month,
    COUNT(OrderID) AS Total_Orders,
    ROUND(SUM(UnitPrice), 2) AS Monthly_Revenue
FROM online_retail_cleaned
GROUP BY Sales_Month
ORDER BY Sales_Month ASC;


#Top selling brands

SELECT 
    Brand,
    COUNT(OrderID) AS Total_Purchases,
    ROUND(SUM(UnitPrice), 2) AS Brand_Revenue
FROM online_retail_cleaned
WHERE Brand != 'Unknown'
GROUP BY Brand
ORDER BY Total_Purchases DESC
LIMIT 5;



#min, max, and avg price of products
SELECT 
    ROUND(MIN(UnitPrice), 2) AS Min_Price,
    ROUND(MAX(UnitPrice), 2) AS Max_Price,
    ROUND(AVG(UnitPrice), 2) AS Avg_Price
FROM online_retail_cleaned;


# orders by country    Us vs france for this one

SELECT 
    SUM(CASE WHEN Country LIKE '%United States%' THEN 1 ELSE 0 END) AS US_Orders,
    SUM(CASE WHEN Country LIKE '%France%' THEN 1 ELSE 0 END) AS France_Orders
FROM online_retail_cleaned;




# price per 100 grams 

SELECT 
    ProductName,
    Brand,
    UnitPrice,
    Normalized_Weight_g,
    ROUND((UnitPrice / Normalized_Weight_g) * 100, 2) AS Price_Per_100g
FROM online_retail_cleaned
WHERE Normalized_Weight_g > 0
ORDER BY Price_Per_100g DESC
LIMIT 10;

# order totals and revenue by day of the week

SELECT 
    DAYNAME(OrderDate) AS Day_Of_Week,
    COUNT(OrderID) AS Total_Orders,
    ROUND(SUM(UnitPrice), 2) AS Total_Revenue,
    ROUND(AVG(UnitPrice), 2) AS Average_Order_Value
FROM online_retail_cleaned
GROUP BY Day_Of_Week, DAYOFWEEK(OrderDate)
ORDER BY DAYOFWEEK(OrderDate) ASC;