-- Function 1: Get Fraud Stats for Any Hour
CREATE OR REPLACE FUNCTION get_fraud_by_hour(input_hour INTEGER)
RETURNS TABLE (
    hour_of_day       INTEGER,
    total_transactions BIGINT,
    fraud_count       BIGINT,
    fraud_rate        NUMERIC,
    avg_fraud_amount  NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.hour_of_day,
        COUNT(*)                                          AS total_transactions,
        SUM(CASE WHEN t.class = 1 THEN 1 ELSE 0 END)    AS fraud_count,
        ROUND(
            SUM(CASE WHEN t.class = 1 THEN 1 ELSE 0 END)
            * 100.0 / COUNT(*), 2
        )                                                 AS fraud_rate,
        ROUND(AVG(CASE WHEN t.class = 1 
            THEN t.amount END)::NUMERIC, 2)               AS avg_fraud_amount
    FROM credit_card_transactions t
    WHERE t.hour_of_day = input_hour
    GROUP BY t.hour_of_day;
END;
$$;

SELECT * FROM get_fraud_by_hour(2);

-- Function 2: Get Transactions by Risk Level
CREATE OR REPLACE FUNCTION get_transactions_by_risk(risk_input TEXT)
RETURNS TABLE (
    id          INTEGER,
    amount      FLOAT,
    hour_of_day INTEGER,
    class       INTEGER,
    risk_score  NUMERIC,
    risk_level  TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        h.id,
        h.amount,
        h.hour_of_day,
        h.class,
        h.risk_score,
        h.risk_level
    FROM high_risk_transactions h
    WHERE h.risk_level = risk_input
    ORDER BY h.risk_score DESC;
END;
$$;

-- See all EXTREME risk transactions
SELECT * FROM get_transactions_by_risk('EXTREME 🚨');

-- See all HIGH risk transactions
SELECT * FROM get_transactions_by_risk('HIGH ⚠️');

-- Function 3: Real Time Fraud Alert System
CREATE OR REPLACE FUNCTION fraud_alert(
    input_amount    FLOAT,
    input_hour      INTEGER
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    avg_amt         FLOAT;
    std_amt         FLOAT;
    zscore          FLOAT;
    hour_fraud_rate FLOAT;
    alert_message   TEXT;
BEGIN
    -- Get average and standard deviation
    SELECT AVG(amount), STDDEV(amount)
    INTO avg_amt, std_amt
    FROM credit_card_transactions;

    -- Calculate Z-Score
    zscore := (input_amount - avg_amt) / NULLIF(std_amt, 0);

    -- Get fraud rate for that hour
    SELECT ROUND(
        SUM(CASE WHEN class = 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    )
    INTO hour_fraud_rate
    FROM credit_card_transactions
    WHERE hour_of_day = input_hour;

    -- Generate Alert
    IF zscore > 3 AND hour_fraud_rate > 0.5 THEN
        alert_message := '🚨 CRITICAL ALERT: Extremely suspicious! High amount + High risk hour!';
    ELSIF zscore > 3 THEN
        alert_message := '⚠️ HIGH ALERT: Very unusual amount detected!';
    ELSIF hour_fraud_rate > 0.5 THEN
        alert_message := '🟡 MEDIUM ALERT: High risk hour detected!';
    ELSE
        alert_message := '✅ LOW RISK: Transaction appears normal.';
    END IF;

    RETURN alert_message;
END;
$$;

-- Test 1: Small amount at normal hour
SELECT fraud_alert(10.50, 14);

-- Test 2: Large amount at risky hour
SELECT fraud_alert(2500.00, 2);

-- Test 3: Very large amount
SELECT fraud_alert(15000.00, 3);
