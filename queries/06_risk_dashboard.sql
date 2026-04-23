-- DASHBOARD: Executive Fraud Summary
WITH fraud_stats AS (
    SELECT
        COUNT(*)                                        AS total_transactions,
        SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END)     AS total_fraud,
        SUM(CASE WHEN class = 0 THEN 1 ELSE 0 END)     AS total_legitimate,
        ROUND(
            SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END)
            * 100.0 / COUNT(*), 4
        )                                               AS fraud_rate,
        ROUND(SUM(CASE WHEN class = 1 
            THEN amount ELSE 0 END)::NUMERIC, 2)        AS total_fraud_amount,
        ROUND(AVG(CASE WHEN class = 1 
            THEN amount END)::NUMERIC, 2)               AS avg_fraud_amount,
        ROUND(MAX(CASE WHEN class = 1 
            THEN amount END)::NUMERIC, 2)               AS max_fraud_amount
    FROM credit_card_transactions
)
SELECT
    total_transactions,
    total_fraud,
    total_legitimate,
    fraud_rate                                          AS fraud_rate_percent,
    total_fraud_amount,
    avg_fraud_amount,
    max_fraud_amount,
    CASE
        WHEN fraud_rate < 0.1   THEN '🟢 LOW RISK'
        WHEN fraud_rate < 0.5   THEN '🟡 MEDIUM RISK'
        ELSE                         '🔴 HIGH RISK'
    END                                                 AS overall_risk_level
FROM fraud_stats;


-- DASHBOARD: Top 5 Peak Fraud Hours
WITH hourly_stats AS (
    SELECT
        hour_of_day,
        COUNT(*)                                        AS total_transactions,
        SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END)     AS fraud_count,
        ROUND(
            SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END)
            * 100.0 / COUNT(*), 2
        )                                               AS fraud_rate,
        ROUND(AVG(CASE WHEN class = 1 
            THEN amount END)::NUMERIC, 2)               AS avg_fraud_amount
    FROM credit_card_transactions
    GROUP BY hour_of_day
),
ranked_hours AS (
    SELECT
        *,
        RANK() OVER (ORDER BY fraud_rate DESC)          AS risk_rank
    FROM hourly_stats
)
SELECT
    risk_rank,
    hour_of_day,
    CASE
        WHEN hour_of_day BETWEEN 0 AND 5   THEN '🌙 Late Night'
        WHEN hour_of_day BETWEEN 6 AND 11  THEN '🌅 Morning'
        WHEN hour_of_day BETWEEN 12 AND 17 THEN '☀️ Afternoon'
        ELSE                                    '🌆 Evening'
    END                                                 AS time_of_day,
    total_transactions,
    fraud_count,
    fraud_rate                                          AS fraud_rate_percent,
    avg_fraud_amount
FROM ranked_hours
WHERE risk_rank <= 5
ORDER BY risk_rank;

-- DASHBOARD: Complete Risk Report
WITH stats AS (
    SELECT
        AVG(amount)                                     AS avg_amt,
        STDDEV(amount)                                  AS std_amt,
        PERCENTILE_CONT(0.95) 
            WITHIN GROUP (ORDER BY amount)              AS percentile_95
    FROM credit_card_transactions
),
scored_transactions AS (
    SELECT
        t.id,
        t.amount,
        t.hour_of_day,
        t.class,
        ROUND(
            ((t.amount - s.avg_amt) / 
            NULLIF(s.std_amt, 0))::NUMERIC, 2
        )                                               AS zscore,
        CASE
            WHEN t.amount > s.percentile_95             THEN 1
            ELSE 0
        END                                             AS is_high_amount,
        CASE
            WHEN t.hour_of_day BETWEEN 0 AND 5          THEN 1
            ELSE 0
        END                                             AS is_risky_hour
    FROM credit_card_transactions t
    CROSS JOIN stats s
),
risk_scored AS (
    SELECT
        *,
        -- Combined risk score out of 10
        ROUND(
            (LEAST(ABS(zscore), 5) * 1.5) +
            (is_high_amount * 2) +
            (is_risky_hour * 1.5), 2
        )                                               AS risk_score,
        ROW_NUMBER() OVER (ORDER BY 
            ABS(zscore) DESC)                           AS row_num
    FROM scored_transactions
)
SELECT
    id,
    ROUND(amount::NUMERIC, 2)                           AS amount,
    hour_of_day,
    class,
    zscore,
    risk_score,
    CASE
        WHEN risk_score >= 8    THEN '🚨 CRITICAL'
        WHEN risk_score >= 6    THEN '⚠️ HIGH'
        WHEN risk_score >= 4    THEN '🟡 MEDIUM'
        ELSE                         '✅ LOW'
    END                                                 AS risk_category,
    CASE
        WHEN class = 1          THEN '❌ CONFIRMED FRAUD'
        ELSE                         '✅ LEGITIMATE'
    END                                                 AS transaction_status
FROM risk_scored
WHERE risk_score >= 6
ORDER BY risk_score DESC
LIMIT 20;

-- DASHBOARD: Fraud Accumulation Over Time
SELECT
    ROUND(time_seconds::NUMERIC / 3600, 0)              AS hour_number,
    COUNT(*)                                            AS transactions_this_hour,
    SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END)         AS fraud_this_hour,
    SUM(COUNT(*)) 
        OVER (ORDER BY 
            ROUND(time_seconds::NUMERIC / 3600, 0))     AS running_total_transactions,
    SUM(SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END)) 
        OVER (ORDER BY 
            ROUND(time_seconds::NUMERIC / 3600, 0))     AS running_fraud_total,
    ROUND(SUM(SUM(CASE WHEN class = 1 THEN amount 
        ELSE 0 END)) 
        OVER (ORDER BY 
            ROUND(time_seconds::NUMERIC / 3600, 0
        ))::NUMERIC, 2)                                 AS running_fraud_amount
FROM credit_card_transactions
GROUP BY ROUND(time_seconds::NUMERIC / 3600, 0)
ORDER BY hour_number
LIMIT 50;
