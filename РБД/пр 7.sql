ALTER TABLE user_logs
ADD COLUMN IF NOT EXISTS ip_address inet;

WITH
country_ids AS (
    SELECT array_agg(id ORDER BY id) AS ids
    FROM country
),
supplier_ids AS (
    SELECT array_agg(id ORDER BY id) AS ids
    FROM supplier
),
airline_ids AS (
    SELECT array_agg(id ORDER BY id) AS ids
    FROM airline
),
tour_operator_ids AS (
    SELECT array_agg(id ORDER BY id) AS ids
    FROM tour_operator
)
INSERT INTO service (
    name,
    service_type,
    country_id,
    departure_city,
    supplier_id,
    description,
    airline_id,
    tour_operator_id
)
SELECT
    'Тур №' || i,
    CASE
        WHEN i % 4 = 0 THEN 'flight'
        WHEN i % 4 = 1 THEN 'tour'
        WHEN i % 4 = 2 THEN 'hotel'
        ELSE 'insurance'
    END,
    country_ids.ids[(i % cardinality(country_ids.ids)) + 1],
    CASE
        WHEN i % 4 = 0 THEN 'Москва (MOW)'
        ELSE NULL
    END,
    supplier_ids.ids[(i % cardinality(supplier_ids.ids)) + 1],
    'Описание услуги ' || i,
    airline_ids.ids[(i % cardinality(airline_ids.ids)) + 1],
    tour_operator_ids.ids[(i % cardinality(tour_operator_ids.ids)) + 1]
FROM generate_series(1, 20000) AS i
CROSS JOIN country_ids
CROSS JOIN supplier_ids
CROSS JOIN airline_ids
CROSS JOIN tour_operator_ids;

INSERT INTO customer_order (
    created_at,
    client_id,
    employee_id,
    status_id,
    paid_at,
    total_amount
)
SELECT
    created_at,
    client_id,
    employee_id,
    status_id,
    CASE
        WHEN is_paid THEN created_at + INTERVAL '1 hour'
        ELSE NULL
    END,
    total_amount
FROM (
    SELECT
        NOW() - (random() * INTERVAL '1000 days') AS created_at,
        (i % 10) + 1 AS client_id,
        ((i * 7) % 10) + 1 AS employee_id,
        ((i * 3) % 10) + 1 AS status_id,
        (i % 3 <> 0) AS is_paid,
        round((random() * 490000 + 10000)::numeric, 2) AS total_amount
    FROM generate_series(1, 20000) AS i
) x;

INSERT INTO user_logs (
    created_at,
    user_id,
    event_data,
    ip_address
)
SELECT
    NOW() - INTERVAL '1 second' * (20000 - i),
    (i % 1000) + 1,
    jsonb_build_object(
        'event',
            CASE
                WHEN i % 5 = 0 THEN 'booking'
                WHEN i % 5 = 1 THEN 'login'
                WHEN i % 5 = 2 THEN 'view_tour'
                WHEN i % 5 = 3 THEN 'search'
                ELSE 'logout'
            END,
        'user_id', (i % 1000) + 1,
        'tour_id', (i % 20000) + 1,
        'amount', round((random() * 200000)::numeric, 2),
        'success', (random() > 0.2),
        'tags',
            CASE
                WHEN i % 3 = 0 THEN jsonb_build_array('promo', 'sale')
                WHEN i % 3 = 1 THEN jsonb_build_array('news')
                ELSE jsonb_build_array('updates', 'alert')
            END
    ),
    (
        '192.168.' ||
        ((i % 254) + 1) ||
        '.' ||
        (((i / 254) % 254) + 1)
    )::inet
FROM generate_series(1, 20000) AS i;

SELECT
    (SELECT COUNT(*) FROM service)        AS service_count,
    (SELECT COUNT(*) FROM customer_order) AS order_count,
    (SELECT COUNT(*) FROM user_logs)      AS user_logs_count;




EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM service WHERE name = 'Тур №15000';

CREATE INDEX IF NOT EXISTS idx_service_name ON service (name);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM service WHERE name = 'Тур №15000';





EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM customer_order
WHERE client_id = 3
  AND total_amount BETWEEN 50000 AND 150000;

CREATE INDEX IF NOT EXISTS idx_customer_order_client_amount
ON customer_order (client_id, total_amount);

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM customer_order
WHERE client_id = 3
  AND total_amount BETWEEN 50000 AND 150000;







EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM service
WHERE LOWER(name) = 'тур №10000';


CREATE INDEX IF NOT EXISTS idx_service_name_lower
ON service (LOWER(name));

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM service
WHERE LOWER(name) = 'тур №10000';









EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM customer_order
WHERE paid_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_customer_order_unpaid
ON customer_order (id)
WHERE paid_at IS NULL;

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM customer_order
WHERE paid_at IS NULL;






















EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM user_logs
WHERE ip_address = '192.168.15.1'::inet;

CREATE INDEX IF NOT EXISTS idx_user_logs_ip_hash
ON user_logs USING hash (ip_address);

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM user_logs
WHERE ip_address = '192.168.15.1'::inet;







EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM user_logs
WHERE ip_address << '192.168.15.0/24'::inet;

CREATE INDEX IF NOT EXISTS idx_user_logs_ip_gist
ON user_logs USING gist (ip_address inet_ops);

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM user_logs
WHERE ip_address << '192.168.15.0/24'::inet;





CREATE INDEX IF NOT EXISTS idx_customer_order_created_btree
ON customer_order (created_at);

SELECT pg_size_pretty(
    pg_relation_size('idx_customer_order_created_btree')
) AS btree_size;



DROP INDEX IF EXISTS idx_customer_order_created_btree;

CREATE INDEX IF NOT EXISTS idx_customer_order_created_brin
ON customer_order USING brin (created_at)
WITH (pages_per_range = 1);

SELECT pg_size_pretty(
    pg_relation_size('idx_customer_order_created_brin')
) AS brin_size;



EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM customer_order
WHERE created_at BETWEEN NOW() - INTERVAL '180 days'
                     AND NOW() - INTERVAL '90 days';



CREATE INDEX tmp_customer_order_created_sort
ON customer_order (created_at);
CLUSTER customer_order USING tmp_customer_order_created_sort;
DROP INDEX tmp_customer_order_created_sort;
ANALYZE customer_order;
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM customer_order
WHERE created_at BETWEEN NOW() - INTERVAL '180 days'
                     AND NOW() - INTERVAL '90 days';
















EXPLAIN (ANALYZE, BUFFERS)
SELECT service_type, country_id
FROM service
WHERE name = 'Тур №5555';
CREATE INDEX IF NOT EXISTS idx_service_name_cover
ON service (name)
INCLUDE (service_type, country_id);
DROP INDEX IF EXISTS idx_service_name;



EXPLAIN (ANALYZE, BUFFERS)
SELECT log_id, user_id, created_at
FROM user_logs
WHERE event_data @> '{"tags": ["promo"]}'::jsonb;


CREATE INDEX IF NOT EXISTS idx_user_logs_event_gin
ON user_logs USING gin (event_data);

EXPLAIN (ANALYZE, BUFFERS)
SELECT log_id, user_id, created_at
FROM user_logs
WHERE event_data @> '{"tags": ["promo"]}'::jsonb;



UPDATE service
SET country_id = 2
WHERE country_id = 1;
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM service
WHERE country_id = 1;

ANALYZE service;
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM service
WHERE country_id = 1;





CREATE INDEX IF NOT EXISTS idx_customer_order_created_cluster
ON customer_order (created_at);


EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM customer_order
WHERE created_at BETWEEN NOW() - INTERVAL '180 days'
                     AND NOW() - INTERVAL '90 days';



CLUSTER customer_order USING idx_customer_order_created_cluster;
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM customer_order
WHERE created_at BETWEEN NOW() - INTERVAL '180 days'
                     AND NOW() - INTERVAL '90 days';



CREATE INDEX IF NOT EXISTS idx_customer_order_employee_unused
ON customer_order (employee_id);
SELECT
    relname AS table_name,
    indexrelname AS index_name,
    idx_scan,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE relname IN ('service', 'customer_order', 'user_logs')
ORDER BY idx_scan ASC;


DROP INDEX IF EXISTS idx_customer_order_employee_unused;