-- Index 1: Speed up fraud/legitimate filtering
CREATE INDEX idx_class 
ON credit_card_transactions(class);

-- Index 2: Speed up hour of day filtering
CREATE INDEX idx_hour_of_day 
ON credit_card_transactions(hour_of_day);

-- Index 3: Speed up amount range queries
CREATE INDEX idx_amount 
ON credit_card_transactions(amount);

-- Index 4: Combined index for fraud + hour searches
CREATE INDEX idx_class_hour 
ON credit_card_transactions(class, hour_of_day);

-- See query execution plan
EXPLAIN ANALYZE
SELECT * 
FROM credit_card_transactions 
WHERE class = 1 
AND hour_of_day = 2;

-- See all indexes on our table
SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'credit_card_transactions';

-- 05_indexes_optimization.sql
-- SLOW VERSION (no optimization)
-- Scans every row to calculate
SELECT COUNT(*) 
FROM credit_card_transactions 
WHERE amount > 100 
AND class = 1;

-- FAST VERSION (uses our indexes + efficient filtering)
SELECT COUNT(*) 
FROM credit_card_transactions 
WHERE class = 1        -- indexed column first!
AND amount > 100;      -- then filter amount

-- EXPLAIN to prove it is faster
EXPLAIN ANALYZE
SELECT COUNT(*) 
FROM credit_card_transactions 
WHERE class = 1 
AND amount > 100;