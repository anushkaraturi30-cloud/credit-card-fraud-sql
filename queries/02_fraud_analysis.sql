-- Q1: Overall Fraud Summary
SELECT
    COUNT(*)                                          AS total_transactions,
    SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END)       AS total_fraud,
    SUM(CASE WHEN class = 0 THEN 1 ELSE 0 END)       AS total_legitimate,
    ROUND(
        SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 4
    )                                                 AS fraud_rate_percent
FROM credit_card_transactions;

-- Q2: Financial Impact
SELECT
    ROUND(SUM(CASE WHEN class = 1 THEN amount ELSE 0 END)::NUMERIC, 2) AS total_fraud_amount,
    ROUND(SUM(CASE WHEN class = 0 THEN amount ELSE 0 END)::NUMERIC, 2) AS total_legitimate_amount,
    ROUND(AVG(CASE WHEN class = 1 THEN amount END)::NUMERIC, 2)        AS avg_fraud_amount,
    ROUND(AVG(CASE WHEN class = 0 THEN amount END)::NUMERIC, 2)        AS avg_legitimate_amount
FROM credit_card_transactions;

-- Q3: Fraud by Amount Range
SELECT
    CASE
        WHEN amount < 10    THEN '0-10 (Very Small)'
        WHEN amount < 100   THEN '10-100 (Small)'
        WHEN amount < 500   THEN '100-500 (Medium)'
        WHEN amount < 1000  THEN '500-1000 (Large)'
        ELSE '1000+ (Very Large)'
    END                         AS amount_range,
    COUNT(*)                    AS total_transactions,
    SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END) AS fraud_count,
    ROUND(
        SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    )                           AS fraud_rate_percent
FROM credit_card_transactions
GROUP BY 1
ORDER BY fraud_rate_percent DESC;

-- Q4: Fraud by Hour of Day
SELECT
    hour_of_day,
    COUNT(*)                                            AS total_transactions,
    SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END)         AS fraud_count,
    ROUND(
        SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    )                                                   AS fraud_rate_percent
FROM credit_card_transactions
GROUP BY hour_of_day
ORDER BY fraud_rate_percent DESC;

-- Q5: Top 10 Highest Value Fraud Transactions
SELECT
    id,
    time_seconds,
    hour_of_day,
    amount,
    class
FROM credit_card_transactions
WHERE class = 1
ORDER BY amount DESC
LIMIT 10;

-- Q6: Peak Fraud Hours
SELECT
    hour_of_day,
    SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END) AS fraud_count
FROM credit_card_transactions
GROUP BY hour_of_day
HAVING SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END) > 20
ORDER BY fraud_count DESC;

-- Q7: Running Total of Fraud (Window Function)
SELECT
    id,
    time_seconds,
    amount,
    class,
    SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END)
        OVER (ORDER BY time_seconds)              AS running_fraud_count,
    SUM(CASE WHEN class = 1 THEN amount ELSE 0 END)
        OVER (ORDER BY time_seconds)              AS running_fraud_amount
FROM credit_card_transactions
ORDER BY time_seconds
LIMIT 100;

-- Q8: Flag High Risk Transactions (CTE)
WITH avg_amounts AS (
    SELECT
        AVG(amount)                    AS overall_avg,
        AVG(amount) * 3                AS suspicious_threshold
    FROM credit_card_transactions
    WHERE class = 0
),
flagged_transactions AS (
    SELECT
        t.id,
        t.amount,
        t.hour_of_day,
        t.class,
        a.suspicious_threshold,
        CASE
            WHEN t.amount > a.suspicious_threshold THEN 'HIGH RISK 🚨'
            WHEN t.amount > a.suspicious_threshold / 2 THEN 'MEDIUM RISK ⚠️'
            ELSE 'LOW RISK ✅'
        END AS risk_level
    FROM credit_card_transactions t
    CROSS JOIN avg_amounts a
)
SELECT
    risk_level,
    COUNT(*)                                        AS total_transactions,
    SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END)     AS actual_fraud_count,
    ROUND(
        SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    )                                               AS fraud_rate_percent
FROM flagged_transactions
GROUP BY risk_level
ORDER BY fraud_rate_percent DESC;

-- Q9: Percentile Analysis
SELECT
    class,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount) AS percentile_25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY amount) AS percentile_50,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount) AS percentile_75,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY amount) AS percentile_90,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY amount) AS percentile_99
FROM credit_card_transactions
GROUP BY class;

-- Q10: Risk Scoring System
WITH stats AS (
    SELECT
        AVG(amount)    AS avg_amt,
        STDDEV(amount) AS std_amt
    FROM credit_card_transactions
),
scored AS (
    SELECT
        t.id,
        t.amount,
        t.hour_of_day,
        t.class,
        ROUND(
            ((t.amount - s.avg_amt) / NULLIF(s.std_amt, 0))::NUMERIC, 2
        ) AS amount_zscore,
        RANK() OVER (ORDER BY t.amount DESC) AS amount_rank
    FROM credit_card_transactions t
    CROSS JOIN stats s
)
SELECT
    id,
    amount,
    hour_of_day,
    class,
    amount_zscore,
    amount_rank,
    CASE
        WHEN amount_zscore > 3 THEN 'EXTREME RISK 🚨'
        WHEN amount_zscore > 2 THEN 'HIGH RISK ⚠️'
        WHEN amount_zscore > 1 THEN 'MEDIUM RISK 🟡'
        ELSE 'NORMAL ✅'
    END AS risk_category
FROM scored
ORDER BY amount_zscore DESC
LIMIT 50;
