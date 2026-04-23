CREATE TABLE credit_card_transactions (
    id            SERIAL PRIMARY KEY,
    time_seconds  FLOAT,
    v1  FLOAT, v2  FLOAT, v3  FLOAT, v4  FLOAT,
    v5  FLOAT, v6  FLOAT, v7  FLOAT, v8  FLOAT,
    v9  FLOAT, v10 FLOAT, v11 FLOAT, v12 FLOAT,
    v13 FLOAT, v14 FLOAT, v15 FLOAT, v16 FLOAT,
    v17 FLOAT, v18 FLOAT, v19 FLOAT, v20 FLOAT,
    v21 FLOAT, v22 FLOAT, v23 FLOAT, v24 FLOAT,
    v25 FLOAT, v26 FLOAT, v27 FLOAT, v28 FLOAT,
    amount        FLOAT,
    class         INTEGER
);

COPY credit_card_transactions (
    time_seconds,
    v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,
    v11,v12,v13,v14,v15,v16,v17,v18,v19,v20,
    v21,v22,v23,v24,v25,v26,v27,v28,
    amount, class
)
FROM 'C:\fraud_data\creditcard.csv'
DELIMITER ','
CSV HEADER;

SELECT COUNT(*) FROM credit_card_transactions;

SELECT * FROM credit_card_transactions LIMIT 10;

SELECT 
    class,
    COUNT(*) AS total_transactions
FROM credit_card_transactions
GROUP BY class;

SELECT 
    ROUND(
        (COUNT(*) FILTER (WHERE class = 1) * 100.0) / COUNT(*), 4
    ) AS fraud_percentage
FROM credit_card_transactions;

SELECT 
    class,
    ROUND(AVG(amount)::NUMERIC, 2) AS avg_amount,
    ROUND(MAX(amount)::NUMERIC, 2) AS max_amount,
    ROUND(MIN(amount)::NUMERIC, 2) AS min_amount
FROM credit_card_transactions
GROUP BY class;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(amount) AS amount_filled,
    COUNT(class) AS class_filled,
    COUNT(time_seconds) AS time_filled
FROM credit_card_transactions;

ALTER TABLE credit_card_transactions 
ADD COLUMN hour_of_day INTEGER;

UPDATE credit_card_transactions
SET hour_of_day = FLOOR((time_seconds / 3600.0) - FLOOR(time_seconds / 86400.0) * 24)::INTEGER;

SELECT time_seconds, hour_of_day 
FROM credit_card_transactions 
LIMIT 10;