# E-Commerce Retail Data Cleaning & Exploratory Data Analysis (MySQL)

# Summary
This project is a raw e-commerce dataset containing 3,000 transaction records with unstructured text, irregular units, character encoding issues, and messy weight formats was cleaned, standardized, and analyzed in MySQL.


#  Data Transformation

# 1. Python ETL (`import_data.py`)
* Resolved character encoding conflicts (`UTF-8-BOM` byte order marks and non-ASCII character parsing like `û` and `é`) by replacing GUI import wizards with a Python stream engine using `sqlalchemy` and `pandas`.

# 2. Data Cleaning & Standardization (`retail_analysis.sql`)
* *Blank to NULL Normalization:** Standardized empty strings and trailing whitespace across all text columns to SQL `NULL` values using `TRIM()` and `NULLIF()`.
  
  * **Kilograms (`kg`):** Converted to grams ($1\,\text{kg} = 1000\,\text{g}$).
  * **Ounces (`oz`):** Converted to grams ($1\,\text{oz} = 28.35\,\text{g}$).
  * **Multipacks (`3 x 30g`):**  quantity multiplier and unit weight to compute true item weight ($3 \times 30\,\text{g} = 90\,\text{g}$).

---

## Data Insights 

1. **Revenue Share by Price Tier:** Premium items ($> \$15$) account for 64.7% of overall revenue 
2. **Customer Loyalty Metrics:** Repeat customers account for multi order activity, with top spenders contributing disproportionately to store margin.
3. **Price Density Modeling:** Price per 100g metrics shows top high margin items after weight extraction.

---

##  How to Reuse This Project

1. Clone the Repository:
   ```bash
   git clone [https://github.com/YOUR_GITHUB_USERNAME/retail-sql-analysis.git](https://github.com/YOUR_GITHUB_USERNAME/retail-sql-analysis.git)
   cd retail-sql-analysis
pip3 install pandas sqlalchemy pymysql
python3 import_data.py

