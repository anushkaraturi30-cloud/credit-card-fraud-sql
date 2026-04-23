--View 1 — Fraud Summary View

CREATE VIEW fraud_summary AS
SELECT
    COUNT(*)                                            AS total_transactions,
    SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END)         AS total_fraud,
    SUM(CASE WHEN class = 0 THEN 1 ELSE 0 END)         AS total_legitimate,
    ROUND(
        SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END) 
        * 100.0 / COUNT(*), 4
    )                                                   AS fraud_rate_percent,
    ROUND(SUM(CASE WHEN class = 1 THEN amount 
        ELSE 0 END)::NUMERIC, 2)                        AS total_fraud_amount
FROM credit_card_transactions;

SELECT * FROM fraud_summary;


--View 2 — Hourly Fraud Pattern View

CREATE VIEW hourly_fraud_patterns AS
SELECT
    hour_of_day,
    COUNT(*)                                            AS total_transactions,
    SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END)         AS fraud_count,
    ROUND(
        SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    )                                                   AS fraud_rate_percent,
    ROUND(AVG(CASE WHEN class = 1 
        THEN amount END)::NUMERIC, 2)                   AS avg_fraud_amount
FROM credit_card_transactions
GROUP BY hour_of_day;

SELECT * FROM hourly_fraud_patterns 
ORDER BY fraud_rate_percent DESC;

--View 3 — High Risk Transactions View

CREATE VIEW high_risk_transactions AS
WITH stats AS (
    SELECT
        AVG(amount)     AS avg_amt,
        STDDEV(amount)  AS std_amt
    FROM credit_card_transactions
)
SELECT
    t.id,
    t.amount,
    t.hour_of_day,
    t.class,
    ROUND(
        ((t.amount - s.avg_amt) / 
        NULLIF(s.std_amt, 0))::NUMERIC, 2
    )                                   AS risk_score,
    CASE
        WHEN ((t.amount - s.avg_amt) / 
            NULLIF(s.std_amt, 0)) > 3   THEN 'EXTREME 🚨'
        WHEN ((t.amount - s.avg_amt) / 
            NULLIF(s.std_amt, 0)) > 2   THEN 'HIGH ⚠️'
        WHEN ((t.amount - s.avg_amt) / 
            NULLIF(s.std_amt, 0)) > 1   THEN 'MEDIUM 🟡'
        ELSE                                 'NORMAL ✅'
    END                                 AS risk_level
FROM credit_card_transactions t
CROSS JOIN stats s;

SELECT * FROM high_risk_transactions 
WHERE risk_level = 'EXTREME 🚨'
ORDER BY risk_score DESC
LIMIT 10;


--Materialized View!

CREATE MATERIALIZED VIEW fraud_by_amount_range AS
SELECT
    CASE
        WHEN amount < 10    THEN '1. Very Small (0-10)'
        WHEN amount < 100   THEN '2. Small (10-100)'
        WHEN amount < 500   THEN '3. Medium (100-500)'
        WHEN amount < 1000  THEN '4. Large (500-1000)'
        ELSE                     '5. Very Large (1000+)'
    END                                             AS amount_range,
    COUNT(*)                                        AS total_transactions,
    SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END)     AS fraud_count,
    ROUND(
        SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    )                                               AS fraud_rate_percent,
    ROUND(SUM(CASE WHEN class = 1 
        THEN amount ELSE 0 END)::NUMERIC, 2)        AS total_fraud_amount
FROM credit_card_transactions
GROUP BY 1
ORDER BY 1;

SELECT * FROM fraud_by_amount_range;