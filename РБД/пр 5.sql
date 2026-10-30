CREATE OR REPLACE FUNCTION get_client_total_spent(p_client_id INT)
RETURNS NUMERIC(10,2) AS $$
DECLARE
    total_spent NUMERIC(10,2);
    client_exists BOOLEAN;
BEGIN
    -- Проверка существования клиента
    SELECT EXISTS(SELECT 1 FROM client WHERE id = p_client_id) INTO client_exists;
    
    IF NOT client_exists THEN
        RAISE EXCEPTION 'Клиент с ID % не найден.', p_client_id;
    END IF;

    -- Подсчет суммы (только для заказов со статусом "Оплачен полностью")
    SELECT COALESCE(SUM(total_amount), 0.00) INTO total_spent
    FROM customer_order
    WHERE client_id = p_client_id 
      AND status_id = (SELECT id FROM order_status WHERE name = 'Оплачен полностью');
      
    RETURN total_spent;
END;
$$ LANGUAGE plpgsql;

-- Вызов функции:
SELECT id, (full_name).last_name AS surname, get_client_total_spent(id) AS total_spent
FROM client
ORDER BY total_spent DESC;


CREATE OR REPLACE FUNCTION get_hotel_info(
    p_hotel_id INT, 
    OUT h_name VARCHAR, 
    OUT h_stars SMALLINT, 
    OUT h_country VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    SELECT h.name, h.stars, c.name 
    INTO h_name, h_stars, h_country
    FROM hotel h
    JOIN country c ON h.country_id = c.id
    WHERE h.id = p_hotel_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Отель с ID % не найден.', p_hotel_id;
    END IF;
END;
$$;

-- Вызов функции:
SELECT * FROM get_hotel_info(1);
CREATE OR REPLACE FUNCTION get_client_orders(p_client_id INT)
RETURNS TABLE (
    order_id INT,
    created_at TIMESTAMPTZ,
    total_amount NUMERIC(10,2),
    status_name VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY 
    SELECT co.id, co.created_at, co.total_amount, os.name
    FROM customer_order co
    JOIN order_status os ON co.status_id = os.id
    WHERE co.client_id = p_client_id;
END;
$$;

-- Вызов функции:
SELECT * FROM get_client_orders(1); -- Для клиента с id=1 (Иванов)


CREATE OR REPLACE PROCEDURE process_order_payment(
    p_order_id INT,
    p_payment_amount NUMERIC(10,2),
    p_payment_type_id INT,
    OUT p_success BOOLEAN,
    OUT p_message TEXT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_order_total NUMERIC(10,2);
    v_order_status INT;
    v_paid_status_id INT;
BEGIN
    -- Получаем ID статуса "Оплачен полностью"
    SELECT id INTO v_paid_status_id FROM order_status WHERE name = 'Оплачен полностью';

    -- Блокируем строку заказа (FOR UPDATE) для предотвращения состояния гонки
    SELECT total_amount, status_id INTO v_order_total, v_order_status
    FROM customer_order
    WHERE id = p_order_id
    FOR UPDATE;

    -- Проверка 1: Заказ существует?
    IF NOT FOUND THEN
        p_success := FALSE;
        p_message := 'Ошибка: Заказ не найден.';
        ROLLBACK;
        RETURN;
    END IF;

    -- Проверка 2: Заказ не отменен?
    IF v_order_status IN ((SELECT id FROM order_status WHERE name IN ('Отменён клиентом', 'Отменён поставщиком'))) THEN
        p_success := FALSE;
        p_message := 'Ошибка: Заказ отменен, оплата невозможна.';
        ROLLBACK;
        RETURN;
    END IF;

    -- Проверка 3: Сумма оплаты корректна?
    IF p_payment_amount <= 0 OR p_payment_amount > v_order_total THEN
        p_success := FALSE;
        p_message := 'Ошибка: Некорректная сумма оплаты.';
        ROLLBACK;
        RETURN;
    END IF;

    -- Успешные DML-операции
    INSERT INTO payment (order_id, amount, status_id, payment_type_id)
    VALUES (p_order_id, p_payment_amount, v_paid_status_id, p_payment_type_id);

    UPDATE customer_order
    SET paid_at = CURRENT_TIMESTAMP,
        status_id = v_paid_status_id
    WHERE id = p_order_id;

    -- Фиксация транзакции
    COMMIT;
    p_success := TRUE;
    p_message := 'Оплата успешно проведена.';
END;
$$;

DO $$
DECLARE
    v_success BOOLEAN;
    v_message TEXT;
BEGIN
    -- Попытка 1: Успешная оплата (Заказ id=3, сумма 45000, тип оплаты СБП id=3)
    CALL process_order_payment(3, 45000.00, 3, v_success, v_message);
    RAISE NOTICE 'Попытка 1: %', v_message;

    -- Попытка 2: Неудачная (Заказ не существует)
    CALL process_order_payment(9999, 1000.00, 1, v_success, v_message);
    RAISE NOTICE 'Попытка 2: %', v_message;
END;
$$;


-- Шаг 1. Анализ "ДО"
SELECT email FROM client WHERE login = 'annap';
SELECT * FROM phone WHERE client_id = (SELECT id FROM client WHERE login = 'annap');

-- Шаг 2. Выполняем атомарную операцию
BEGIN;
    UPDATE client 
    SET email = 'anna_new@mail.ru' 
    WHERE login = 'annap';

    INSERT INTO phone (client_id, phone_number)
    VALUES ((SELECT id FROM client WHERE login = 'annap'), '+79111223344');
COMMIT;

-- Шаг 3. Анализ "ПОСЛЕ"
SELECT email FROM client WHERE login = 'annap';
SELECT * FROM phone WHERE client_id = (SELECT id FROM client WHERE login = 'annap');


-- Ошибка возникнет из-за того, что id = 1 уже существует в таблице country (это Россия).
BEGIN;
    -- 1. Успешное обновление (звезды отеля изменятся, но пока только внутри транзакции)
    UPDATE hotel SET stars = 5 WHERE id = 10; 
    
    -- 2. Намеренная ошибка: нарушение PRIMARY KEY (id=1 уже есть)
    INSERT INTO country (id, name, code) 
    VALUES (1, 'Тестовая страна', 'TST');
    
COMMIT; 


SELECT stars FROM hotel WHERE id = 10;

ROLLBACK;

SELECT stars FROM hotel WHERE id = 10;


BEGIN;
SELECT stars FROM hotel WHERE id = 10; -- Первое чтение
SELECT pg_sleep(10);
SELECT stars FROM hotel WHERE id = 10; -- Второе чтение
COMMIT;


UPDATE hotel SET stars = 2 WHERE id = 10;
COMMIT;


BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT stars FROM hotel WHERE id = 10; 
SELECT pg_sleep(10);
SELECT stars FROM hotel WHERE id = 10; 
COMMIT;


UPDATE hotel SET stars = 2 WHERE id = 10;
COMMIT;

BEGIN;
UPDATE hotel SET stars = 1 WHERE id = 10;
SELECT pg_sleep(10); -- Ждем 10 секунд
ROLLBACK;


SELECT stars FROM hotel WHERE id = 10;


BEGIN;
SELECT COUNT(*) FROM order_item WHERE order_id = 1; -- Первое чтение
SELECT pg_sleep(10);
SELECT COUNT(*) FROM order_item WHERE order_id = 1; -- Второе чтение
COMMIT;

BEGIN;
INSERT INTO order_item (service_id, order_id, quantity, price) 
VALUES (2, 1, 1, 10000);
COMMIT;


BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT COUNT(*) FROM order_item WHERE order_id = 1; 
SELECT pg_sleep(10);
SELECT COUNT(*) FROM order_item WHERE order_id = 1; 
COMMIT;

BEGIN;
INSERT INTO order_item (service_id, order_id, quantity, price) 
VALUES (2, 1, 1, 10000);
COMMIT;
