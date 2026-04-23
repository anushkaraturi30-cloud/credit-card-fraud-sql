-- =============================================
-- Project: Credit Card Fraud Detection
-- Author: Anushka Raturi
-- Database: PostgreSQL
-- Dataset: Kaggle ULB Credit Card Fraud
-- =============================================

-- Step 1: Create the main table
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

-- Step 2: Add hour of day column
ALTER TABLE credit_card_transactions
ADD COLUMN hour_of_day INTEGER;

-- Step 3: Fill hour of day column
UPDATE credit_card_transactions
SET hour_of_day = FLOOR(
    (time_seconds / 3600.0) -
    FLOOR(time_seconds / 86400.0) * 24
)::INTEGER;