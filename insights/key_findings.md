# 🔍 Credit Card Fraud Detection — Key Business Findings

## Project Overview
Analyzed **284,807 real credit card transactions** to identify fraud patterns,
detect high risk hours, and build an automated risk scoring system using Advanced SQL in PostgreSQL.

---

## 📌 Finding 1 — Fraud Rate

- Total Transactions: **284,807**
- Total Fraud Cases: **492**
- Total Legitimate: **284,315**
- Fraud Rate: **0.1727%**
- ✅ Insight: Fraud is rare but financially devastating — only 0.17% of transactions
  are fraud but they result in over $60,000 in losses

---

## 📌 Finding 2 — Financial Impact

- Total Money Lost to Fraud: **$60,127.97**
- Average Fraud Transaction: **$122.21**
- Average Normal Transaction: **$88.29**
- ✅ Insight: Fraud transactions are on average **38% higher** than normal transactions
  — fraudsters tend to make larger purchases to maximize stolen value

---

## 📌 Finding 3 — Riskiest Amount Range

| Amount Range | Fraud Rate |
|---|---|
| Very Small (0-10) | 0.26% |
| Small (10-100) | 0.09% |
| Medium (100-500) | 0.20% |
| **Large (500-1000)** | **0.40% ← HIGHEST** |
| Very Large (1000+) | 0.29% |

- Highest fraud rate: **Large transactions ($500 - $1000) at 0.40%**
- ✅ Insight: The bank should automatically flag all transactions between
  $500-$1000 for additional verification — this range has double the average fraud rate

---

## 📌 Finding 4 — Peak Fraud Hours

| Rank | Hour | Fraud Rate |
|---|---|---|
| 🥇 1st | **2 AM** | **1.71%** |
| 🥈 2nd | 4 AM | 1.04% |
| 🥉 3rd | 3 AM | 0.49% |
| 4th | 5 AM | 0.37% |
| 5th | 7 AM | 0.32% |

- Fraud happens most at: **2 AM with a fraud rate of 1.71%**
- The top 4 riskiest hours are all between **2AM and 5AM**
- ✅ Insight: The bank should increase automated monitoring and add extra
  verification steps during late night hours (2AM - 5AM)
  when fraud rate is 10x higher than average

---

## 📌 Finding 5 — Extreme Risk Transactions

Top flagged transactions by our risk scoring system:

| Transaction ID | Amount | Hour | Risk Score |
|---|---|---|---|
| 274,772 | $25,691.16 | 10 PM | 102.36 |
| 58,466 | $19,656.53 | 1 PM | 78.24 |
| 151,297 | $18,910.00 | 2 AM | 75.25 |
| 46,842 | $12,910.93 | 11 AM | 51.27 |
| 54,019 | $11,898.09 | 12 PM | 47.22 |

- ✅ Insight: Our Z-Score based risk scoring system successfully
  identifies statistically unusual transactions automatically
  — analysts can prioritize these for immediate investigation

---

## 📌 Finding 6 — Live Fraud Alert System

Built a real time fraud detection function that evaluates
any transaction instantly:

```sql
SELECT fraud_alert(15000.00, 3);
-- Output: ⚠️ HIGH ALERT: Very unusual amount detected!
```

- ✅ Insight: This function can be integrated into any banking
  dashboard to flag suspicious transactions the moment they occur
  — reducing response time from hours to seconds

---

## 📌 Finding 7 — Business Recommendations

Based on the analysis here are the top 3 actions the bank should take:

**1. Increase Monitoring Between 2AM - 5AM**
Fraud rate is 10x higher during these hours. Automated alerts
and additional verification should be triggered for all transactions
in this window.

**2. Flag All Transactions Between $500 - $1000**
This amount range has the highest fraud rate at 0.40%.
The bank should require secondary authentication for these amounts.

**3. Deploy the Risk Scoring System**
The Z-Score based scoring system can automatically rank every
transaction by risk level — allowing analysts to focus only on
EXTREME and HIGH risk cases instead of reviewing everything manually.

---

## 🛠️ Tools Used

- **PostgreSQL** — Database management & advanced SQL
- **DBeaver** — SQL editor & query execution
- **Dataset** — Credit Card Fraud Detection (Kaggle - ULB)
- **284,807** real world transactions analyzed

---

## 💡 Skills Demonstrated

- Advanced SQL (CTEs, Window Functions, Percentile Analysis)
- Stored Procedures & Custom Functions
- Views & Materialized Views
- Index Creation & Query Optimization
- Data Cleaning & Exploratory Data Analysis (EDA)
- Business Insight Generation
- Fraud Risk Scoring using Z-Score methodology
- Executive Dashboard Design
