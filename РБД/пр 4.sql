-- Задание №9: Материализованное представление для трат клиентов

-- 1. Создаем материализованное представление
CREATE MATERIALIZED VIEW client_total_spent AS
SELECT
    c.id AS client_id,
    (c.full_name).last_name || ' ' || (c.full_name).first_name AS client_name,
    COUNT(co.id) AS orders_count,
    COALESCE(SUM(co.total_amount), 0) AS total_spent
FROM client c
LEFT JOIN customer_order co ON c.id = co.client_id
GROUP BY c.id, c.full_name;

-- Проверяем исходные данные
SELECT * FROM client_total_spent WHERE client_name LIKE 'Иванов%';

-- 2. Добавляем новый заказ для клиента Иванов И.И. в исходную таблицу
INSERT INTO customer_order (created_at, client_id, employee_id, status_id, paid_at, total_amount)
VALUES (
    CURRENT_TIMESTAMP,
    (SELECT id FROM client WHERE login = 'ivan_i'),
    (SELECT id FROM employee WHERE login = 'a_smirnov'),
    (SELECT id FROM order_status WHERE name = 'Новый'),
    NULL,
    50000.00
);

-- 3. Проверяем материализованное представление (данные еще НЕ обновились, так как оно хранит снимок)
SELECT * FROM client_total_spent WHERE client_name LIKE 'Иванов%';

-- 4. Выполняем ручное обновление материализованного представления
REFRESH MATERIALIZED VIEW client_total_spent;

-- 5. Снова проверяем (теперь сумма total_spent увеличилась на 50000)
SELECT * FROM client_total_spent WHERE client_name LIKE 'Иванов%';

-- --- Очистка тестовых данных (чтобы не засорять БД) ---
DELETE FROM customer_order 
WHERE total_amount = 50000.00 
  AND client_id = (SELECT id FROM client WHERE login = 'ivan_i') 
  AND created_at >= CURRENT_DATE;
REFRESH MATERIALIZED VIEW client_total_spent;

-- 6. Проверяем удаление
SELECT * FROM client_total_spent WHERE client_name LIKE 'Иванов%';
