# E-Commerce Retail Data Cleaning & Exploratory Data Analysis (MySQL)

## 📌 Executive Summary
This project demonstrates an end-to-end SQL and Python data engineering pipeline. A raw e-commerce dataset containing 3,000 transaction records with unstructured text, irregular units, character encoding issues, and messy weight formats was cleaned, standardized, and analyzed in MySQL.

---

## 🛠️ Tech Stack
* **Database Management:** MySQL 8.0 / MySQL Workbench
* **ETL Pipeline:** Python 3 (Pandas, SQLAlchemy, PyMySQL)
* **Language & Syntax:** SQL (CTEs, Window Functions, REGEXP, Case Statements)
* **Version Control:** Git & GitHub

---

## 📂 Repository Structureretail_sql_project/
├── online_retail_real_world.csv  # Raw dataset
├── import_data.py               # Automated Python ETL pipeline script
├── retail_analysis.sql          # Data cleaning and advanced EDA queries
└── README.md                    # Project documentation---

## 🔄 Data Pipeline & Key Transformations

### 1. Robust Python ETL (`import_data.py`)
* Resolved character encoding conflicts (`UTF-8-BOM` byte order marks and non-ASCII character parsing like `û` and `é`) by replacing GUI import wizards with a Python stream engine using `sqlalchemy` and `pandas`.

### 2. Data Cleaning & Sanitization (`retail_analysis.sql`)
* **Blank-to-NULL Normalization:** Standardized empty strings and trailing whitespace across all text columns to SQL `NULL` values using `TRIM()` and `NULLIF()`.
* **Multipack & Unit Normalization:** Utilized `REGEXP_SUBSTR` and `CASE` statements to extract and standardize weight dimensions from unstructured text formats:
  * **Kilograms (`kg`):** Converted to grams ($1\,\text{kg} = 1000\,\text{g}$).
  * **Ounces (`oz`):** Converted to grams ($1\,\text{oz} = 28.35\,\text{g}$).
  * **Multipacks (`3 x 30g`):** Parsed quantity multiplier and unit weight to compute true item weight ($3 \times 30\,\text{g} = 90\,\text{g}$).

---

## 📊 Key Data Insights & Business Value

1. **Revenue Share by Price Tier:** Premium items ($> \$15$) account for **64.7%** of overall revenue despite comprising only ~36% of sales volume.
2. **Customer Loyalty Metrics:** Repeat customers account for multi-order activity, with top spenders contributing disproportionately to store margin.
3. **Price Density Modeling:** Price-per-100g metrics isolated top high-margin items after weight extraction.

---

## 🚀 How to Reproduce This Project

1. **Clone the Repository:**
   ```bash
   git clone [https://github.com/YOUR_GITHUB_USERNAME/retail-sql-analysis.git](https://github.com/YOUR_GITHUB_USERNAME/retail-sql-analysis.git)
   cd retail-sql-analysis
pip3 install pandas sqlalchemy pymysql
python3 import_data.py

