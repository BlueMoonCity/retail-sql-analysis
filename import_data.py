import pandas as pd
from sqlalchemy import create_engine
from urllib.parse import quote_plus

# 1. Load CSV with UTF-8 support
df = pd.read_csv('online_retail_real_world.csv', encoding='utf-8-sig')

# 2. Database connection credentials
USER = 'root'
PASSWORD = '@Phoebus2024'
HOST = 'localhost'
PORT = '3306'
DATABASE = 'retail_db'

# Safe password encoding to prevent URI parsing errors
safe_password = quote_plus(PASSWORD)

# 3. Create database connection engine
engine = create_engine(f'mysql+pymysql://{USER}:{safe_password}@{HOST}:{PORT}/{DATABASE}?charset=utf8mb4')

# 4. Push dataframe to MySQL table 'online_retail_raw'
df.to_sql('online_retail_raw', con=engine, if_exists='replace', index=False)

print(f"Successfully loaded {len(df)} rows into 'online_retail_raw' in MySQL!")