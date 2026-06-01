# 🛍️ Yanki E-Commerce ETL Pipeline

![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-blue?logo=postgresql)
![pandas](https://img.shields.io/badge/pandas-Data%20Engineering-green?logo=pandas)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

> An end-to-end ETL (Extract, Transform, Load) pipeline that ingests raw e-commerce order data, cleans and normalises it into a relational data model, and loads it into a PostgreSQL database.

---

## 📌 Project Overview

Yanki is a fictional global e-commerce company selling perfume and fragrance products. The raw transactional data arrives as a single flat CSV file — every order, customer, product, and payment detail in one table.

This project simulates a real-world data engineering task: take that messy flat file and build a clean, queryable relational database from it.

**The pipeline does three things:**
1. **Extract** — reads the raw CSV into a pandas DataFrame
2. **Transform** — cleans missing values, fixes data types, and normalises the flat table into 5 separate dimension and fact tables
3. **Load** — creates a PostgreSQL schema with proper primary and foreign keys, then loads all 5 tables into the database

---

## 🗃️ Data Model

The raw flat file (20 columns, 1,020 rows) is normalised into a **star schema** with 5 tables:

| Table | Primary Key | Description |
|-------|-------------|-------------|
| `customers` | `Customer_ID` (UUID) | Customer name, email, phone |
| `products` | `Product_ID` (UUID) | Product name, brand, category, price |
| `orders` | `Order_ID` (UUID) | Links customer + product, quantity, total, date |
| `shipping_address` | `shipping_ID` (SERIAL) | Delivery address per customer |
| `payment_methods` | — | Payment method and transaction status per order |

**Relationships:**
- `orders` → `customers` (Foreign Key)
- `orders` → `products` (Foreign Key)
- `shipping_address` → `customers` (Foreign Key)
- `payment_methods` → `orders` (Foreign Key)

The data model diagram is included in the repo (`datamodel(yanki_ecommerce)-Page-2.drawio.png`).

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|------|---------|
| **Python 3.12** | Core scripting language |
| **pandas** | Data extraction, cleaning, and transformation |
| **psycopg2** | PostgreSQL database connector |
| **PostgreSQL** | Target relational database |
| **Jupyter Notebook** | Development and documentation environment |

---

## 📁 Project Structure
yanki_ecommerce_casestudy/
│
├── dataset/
│   ├── rawdata/
│   │   └── yanki_ecommerce.csv        ← Raw source data (1,020 rows)
│   └── cleaneddata/
│       ├── customers.csv
│       ├── products.csv
│       ├── orders.csv
│       ├── shipping_address.csv
│       └── payment_method.csv         ← Normalised output tables
│
├── yanki_etl.ipynb(FINAL).ipynb       ← Main ETL notebook
├── datamodel(yanki_ecommerce).drawio  ← Data model diagram source
└── datamodel(yanki_ecommerce)-Page-2.drawio.png  ← Data model image
---

## 🔄 ETL Process

### Extract
- Source: `yanki_ecommerce.csv` — 1,020 rows × 20 columns
- Loaded into a pandas DataFrame using `pd.read_csv()`

### Transform
**Cleaning:**
- Identified 20 rows with missing `Order_ID` and `Customer_ID` — dropped using `dropna()`
- Converted `Order_Date` from string to `datetime64` using `pd.to_datetime()`
- Result: 1,000 clean, valid order records

**Normalisation — flat table → 5 relational tables:**
- Extracted unique customers → `customers` table
- Extracted unique products → `products` table
- Extracted order facts → `orders` table
- Extracted shipping addresses → `shipping_address` table (with generated `shipping_ID`)
- Extracted payment info → `payment_methods` table

### Load
- Connected to PostgreSQL using `psycopg2`
- Created `yanki` schema with `CREATE SCHEMA`
- Created all 5 tables with correct data types, primary keys, and foreign key constraints
- Loaded each cleaned CSV into its corresponding table using parameterised `INSERT` statements

---

## ⚙️ How to Run

### Prerequisites
- Python 3.x
- PostgreSQL installed and running locally
- A database named `yanki_ecommerce` created in PostgreSQL

### Install dependencies
```bash
pip install pandas psycopg2
```

### Update database credentials
In the notebook, update this block with your own PostgreSQL credentials:
```python
connection = psycopg2.connect(
    host='localhost',
    database='yanki_ecommerce',
    user='your_username',
    password='your_password',
    port=5432
)
```

### Run the notebook
Open `yanki_etl.ipynb(FINAL).ipynb` in Jupyter and run all cells top to bottom.

---

## 📊 Dataset Summary

| Field | Detail |
|-------|--------|
| Raw rows | 1,020 |
| Rows after cleaning | 1,000 |
| Columns | 20 |
| Date range | 2020 – 2023 |
| Categories | Perfume, Perfume Oil |
| Payment methods | Credit Card, Debit Card, PayPal |
| Transaction statuses | Completed, Pending, Failed |

---

## 👤 Author

**Oluwatosin Eleja**
Data Engineer

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin)](https://linkedin.com/)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black?logo=github)](https://github.com/Toludills)
