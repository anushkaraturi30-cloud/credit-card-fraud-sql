# 💳 Credit Card Fraud Detection
## Advanced SQL Analysis & Risk Scoring System

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue)
![Dataset](https://img.shields.io/badge/Dataset-284%2C807%20Rows-green)
![Level](https://img.shields.io/badge/Level-Advanced-red)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

---

## 📌 Project Overview

This project analyzes **284,807 real-world credit card transactions** to identify fraud patterns, build an automated risk scoring system, and create a live fraud alert function using **Advanced SQL techniques** in PostgreSQL.

The goal is to simulate what a real **Data Analyst at a bank** would do — investigate fraud, find patterns, and build tools to help the business respond faster.

---

## 🎯 Business Problems Solved

- How much fraud is happening and what is the total financial impact?
- At what time of day does fraud peak?
- Which transaction amounts are most suspicious?
- Can we automatically score and flag risky transactions in real time?
- How do we optimize query performance on large datasets?

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| **PostgreSQL** | Main database |
| **DBeaver** | SQL editor & database management |
| **Kaggle Dataset** | Real world credit card transaction data |
| **Advanced SQL** | CTEs, Window Functions, Stored Procedures, Indexes |

---

## 🧠 Advanced SQL Concepts Used

| Concept | File |
|---|---|
| Data Exploration & EDA | `queries/01_data_exploration.sql` |
| CTEs & Window Functions | `queries/02_fraud_analysis.sql` |
| Views & Materialized Views | `queries/03_views.sql` |
| Stored Procedures & Functions | `queries/04_stored_procedures.sql` |
| Indexes & Query Optimization | `queries/05_indexes_optimization.sql` |
| Risk Scoring Dashboard | `queries/06_risk_dashboard.sql` |

---

## 📁 Project Structure

```
credit-card-fraud-sql/
│
├── 📄 README.md
├── 📁 schema/
│   └── 📄 schema.sql
├── 📁 queries/
│   ├── 📄 01_data_exploration.sql
│   ├── 📄 02_fraud_analysis.sql
│   ├── 📄 03_views.sql
│   ├── 📄 04_stored_procedures.sql
│   ├── 📄 05_indexes_optimization.sql
│   └── 📄 06_risk_dashboard.sql
├── 📁 insights/
│   └── 📄 key_findings.md
└── 📁 screenshots/
    └── 📄 *.png
```

---

## 💡 Project Highlights

### 1️⃣ Fraud Pattern Analysis
- Identified fraud rate across 284,807 transactions
- Analyzed fraud by hour of day, amount range and time period
- Compared average fraud amount vs legitimate transactions

### 2️⃣ Automated Risk Scoring System
- Built a Z-Score based risk scoring model using CTEs
- Categorizes every transaction as CRITICAL, HIGH, MEDIUM or LOW risk
- Uses standard deviation to detect statistically unusual transactions

### 3️⃣ Live Fraud Alert Function
Built a real time fraud detection function using Stored Procedures:
```sql
SELECT fraud_alert(2500.00, 2);
-- Returns: 🚨 CRITICAL ALERT: Extremely suspicious!
```
Takes any transaction amount and hour → instantly returns risk level

### 4️⃣ Performance Optimization
- Created 4 indexes on key columns (class, hour, amount)
- Reduced query execution time by up to 10x on 284,807 rows
- Used EXPLAIN ANALYZE to prove performance improvements

### 5️⃣ Analytical Views & Dashboard
- 3 reusable Views for fraud summary, hourly patterns and high risk transactions
- 1 Materialized View for fast amount range analysis
- 4 Executive Dashboard queries combining all techniques

---

## 📊 Dataset Information

- **Source:** [Credit Card Fraud Detection — Kaggle (ULB)](https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud)
- **Size:** 284,807 transactions
- **Features:** Time, Amount, Class (Fraud/Legitimate), V1-V28 (PCA features)
- **Fraud Cases:** 492 out of 284,807 transactions

---

## 🚀 How to Run This Project

### Step 1 — Setup Database
```sql
-- Run schema.sql to create the table
-- Load creditcard.csv using COPY command
```

### Step 2 — Run Queries in Order
```
01_data_exploration.sql  → Explore the data
02_fraud_analysis.sql    → Core analysis
03_views.sql             → Create views
04_stored_procedures.sql → Create functions
05_indexes_optimization  → Add indexes
06_risk_dashboard.sql    → Final dashboard
```

### Step 3 — Test the Alert System
```sql
SELECT fraud_alert(10.50, 14);   -- Low risk
SELECT fraud_alert(2500.00, 2);  -- High risk
SELECT fraud_alert(15000.00, 3); -- Critical
```

---

## 👤 Author

**[Anushka Raturi]**
Aspiring Data Analyst
📧 [raturianushka61@gmail.com]


---

## ⭐ If you found this project helpful, please give it a star!
