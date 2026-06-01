# 🛍️ Yanki E-Commerce ETL Pipeline & Analysis

![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-blue?logo=postgresql)
![pandas](https://img.shields.io/badge/pandas-Data%20Engineering-green?logo=pandas)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

> An end-to-end data engineering project: ETL pipeline that ingests raw e-commerce data, normalises it into a relational schema, loads it into PostgreSQL — then analyses the data to surface business insights.

---

## 📌 Project Overview

Yanki is a fictional global e-commerce company selling perfume and fragrance products. The raw transactional data arrives as a single flat CSV file — every order, customer, product, and payment detail crammed into one table.

This project does two things:

**1. ETL Pipeline** (`yanki_etl.ipynb(FINAL).ipynb`)
- **Extract** — reads 1,020 raw rows from a flat CSV
- **Transform** — cleans missing values, fixes data types, normalises into 5 relational tables
- **Load** — creates a PostgreSQL schema with primary/foreign keys and loads all tables

**2. Business Analysis** (`yanki_business_analysis.ipynb`)
- Connects to the cleaned data outputs
- Verifies pipeline integrity before analysing
- Answers 5 business questions with charts and written findings

---

## 🗃️ Data Model

The raw flat file is normalised into a **star schema**:

![Data Model](datamodel(yanki_ecommerce)-Page-2.drawio.png)

| Table | Primary Key | Description |
|-------|-------------|-------------|
| `customers` | `Customer_ID` (UUID) | Customer name, email, phone |
| `products` | `Product_ID` (UUID) | Product name, brand, category, price |
| `orders` | `Order_ID` (UUID) | Links customer + product, quantity, total, date |
| `shipping_address` | `shipping_ID` (SERIAL) | Delivery address per customer |
| `payment_methods` | — | Payment method and transaction status per order |

**Why normalise?**  
The raw file stores the customer's name and email on every single order row — if a customer places 10 orders, their name appears 10 times. Normalisation stores each customer once and references them by ID, making the database smaller, faster, and easier to maintain.

---

## 📊 Key Findings

| Metric | Value |
|--------|-------|
| Total Orders (cleaned) | 1,000 |
| Date Range | 2020 – 2023 |
| Product Categories | Perfume, Perfume Oil |
| Payment Methods | Credit Card, Debit Card, PayPal |
| Countries Served | 50+ |
| Pending Revenue at Risk | ~30% of gross orders |

**Top insights from analysis:**
- Perfume Oil generates a higher average order value than standard Perfume
- ~30% of transactions sit in `pending` status — a significant revenue risk requiring follow-up automation
- Revenue grew consistently year-over-year from 2020 to peak year
- One payment method dominates volume — checkout friction may be limiting alternatives

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|------|---------|
| **Python 3.12** | Core scripting |
| **pandas** | Data extraction, cleaning, transformation |
| **psycopg2** | PostgreSQL connector |
| **PostgreSQL** | Target relational database |
| **matplotlib / seaborn** | Business analysis charts |
| **Jupyter Notebook** | Development & documentation |

---

## 📁 Project Structure

```
yanki_ecommerce_casestudy/
│
├── yanki_etl.ipynb(FINAL).ipynb        ← ETL pipeline (extract, transform, load)
├── yanki_business_analysis.ipynb       ← Post-ETL business analysis
├── yanki_verification_and_analysis.sql ← SQL queries: verification + business analysis
│
├── dataset/
│   ├── rawdata/
│   │   └── yanki_ecommerce.csv         ← Raw source (1,020 rows × 20 cols)
│   └── cleaneddata/
│       ├── customers.csv
│       ├── products.csv
│       ├── orders.csv
│       ├── shipping_address.csv
│       └── payment_method.csv          ← 5 normalised output tables
│
└── datamodel(yanki_ecommerce)-Page-2.drawio.png  ← Schema diagram
```

---

## 🔄 ETL Process

### Extract
- **Source:** `yanki_ecommerce.csv` — 1,020 rows × 20 columns
- Loaded into pandas with `pd.read_csv()`

### Transform
**Cleaning:**
- Identified 20 rows with null `Order_ID` / `Customer_ID` — dropped
- Converted `Order_Date` from string to `datetime64`
- Result: **1,000 clean records**

**Normalisation:**
- `customers` — unique customers extracted with `drop_duplicates()`
- `products` — unique products with pricing
- `orders` — transactional fact table linking customer + product
- `shipping_address` — address per customer with auto-generated `shipping_ID`
- `payment_methods` — payment method and transaction status per order

### Load
- Connected to PostgreSQL via `psycopg2`
- Created `yanki` schema with `CREATE SCHEMA`
- Built 5 tables with correct types, `PRIMARY KEY`, and `FOREIGN KEY` constraints
- Loaded each CSV using parameterised `INSERT` statements (prevents SQL injection)

---

## ✅ Pipeline Verification

After loading, run `yanki_verification_and_analysis.sql` to confirm:

```sql
-- Row count check across all tables
SELECT 'customers' AS table_name, COUNT(*) FROM yanki.customers
UNION ALL
SELECT 'products',  COUNT(*) FROM yanki.products
UNION ALL
SELECT 'orders',    COUNT(*) FROM yanki.orders;

-- Referential integrity check
SELECT COUNT(*) AS orphaned_orders
FROM yanki.orders o
LEFT JOIN yanki.customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
-- Expected: 0
```

---

## ⚙️ How to Run

### Prerequisites
- Python 3.x installed
- PostgreSQL running locally
- A database named `yanki_ecommerce` created

### Install dependencies
```bash
pip install pandas psycopg2 matplotlib seaborn jupyter
```

### Update credentials
In the ETL notebook, update:
```python
connection = psycopg2.connect(
    host='localhost',
    database='yanki_ecommerce',
    user='your_username',     # ← update this
    password='your_password', # ← update this
    port=5432
)
```

### Run the ETL pipeline
Open `yanki_etl.ipynb(FINAL).ipynb` → Run All Cells

### Run verification & analysis
Open `yanki_business_analysis.ipynb` → Run All Cells  
Or execute `yanki_verification_and_analysis.sql` in your PostgreSQL client

---

## 👤 Author

**Oluwatosin Eleja** — Data Engineer

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin)](https://linkedin.com/)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black?logo=github)](https://github.com/Toludills)
