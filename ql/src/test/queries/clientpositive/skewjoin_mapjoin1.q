set hive.mapred.mode=nonstrict;
set hive.optimize.skewjoin.compiletime = true;
set hive.auto.convert.join=true;

CREATE TABLE T1(key STRING, val STRING)
SKEWED BY (key) ON ((2)) STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH '../../data/files/T1.txt' INTO TABLE T1;

CREATE TABLE T2(key STRING, val STRING)
SKEWED BY (key) ON ((3)) STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH '../../data/files/T2.txt' INTO TABLE T2;

-- copy from skewjoinopt1
-- test compile time skew join and auto map join
-- a simple join query with skew on both the tables on the join key
-- adding an order by at the end to make the results deterministic

EXPLAIN
SELECT a.*, b.* FROM T1 a JOIN T2 b ON a.key = b.key;

SELECT a.*, b.* FROM T1 a JOIN T2 b ON a.key = b.key
ORDER BY a.key, b.key, a.val, b.val;

-- test outer joins also

EXPLAIN
SELECT a.*, b.* FROM T1 a RIGHT OUTER JOIN T2 b ON a.key = b.key;

SELECT a.*, b.* FROM T1 a RIGHT OUTER JOIN T2 b ON a.key = b.key
ORDER BY a.key, b.key, a.val, b.val;

-- an aggregation at the end should not change anything

EXPLAIN
SELECT count(1) FROM T1 a JOIN T2 b ON a.key = b.key;

SELECT count(1) FROM T1 a JOIN T2 b ON a.key = b.key;

EXPLAIN
SELECT count(1) FROM T1 a RIGHT OUTER JOIN T2 b ON a.key = b.key;

SELECT count(1) FROM T1 a RIGHT OUTER JOIN T2 b ON a.key = b.key;
