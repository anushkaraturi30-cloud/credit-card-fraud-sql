-- =============================================
-- Project : Credit Card Fraud Detection
-- Author  : [Anushka Raturi]
-- Database: PostgreSQL
-- Dataset : Kaggle ULB Credit Card Fraud
-- =============================================

-- Step 1: Create Database
CREATE DATABASE fraud_analysis;

-- Step 2: Create Main Table
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

-- Step 3: Load Data from CSV
-- Update the file path below to match your computer
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

-- Step 4: Add Hour of Day Column
ALTER TABLE credit_card_transactions
ADD COLUMN hour_of_day INTEGER;

-- Step 5: Fill Hour of Day Column
UPDATE credit_card_transactions
SET hour_of_day = FLOOR(
    (time_seconds / 3600.0) -
    FLOOR(time_seconds / 86400.0) * 24
)::INTEGER;

-- Step 6: Verify Data Loaded Correctly
SELECT COUNT(*) FROM credit_card_transactions;
-- Expected: 284807
