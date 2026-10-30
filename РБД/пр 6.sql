-- =========================================================
-- 0. Подготовка дополнительных объектов для триггеров
-- =========================================================

-- Таблица для аудита смены статусов заказов
CREATE TABLE IF NOT EXISTS order_status_history (
    id              serial PRIMARY KEY,
    order_id        integer NOT NULL,
    old_status_id   integer,
    new_status_id   integer NOT NULL,
    old_status_name varchar(50),
    new_status_name varchar(50) NOT NULL,
    changed_at      timestamptz NOT NULL DEFAULT now(),
    changed_by      text NOT NULL DEFAULT current_user
);

COMMENT ON TABLE order_status_history IS
    'История изменения статусов заказов клиентов';

COMMENT ON COLUMN order_status_history.order_id IS
    'ID заказа, по которому изменился статус';

COMMENT ON COLUMN order_status_history.old_status_id IS
    'Старый статус заказа до изменения';

COMMENT ON COLUMN order_status_history.new_status_id IS
    'Новый статус заказа после изменения';

COMMENT ON COLUMN order_status_history.changed_at IS
    'Дата и время фиксации изменения';

COMMENT ON COLUMN order_status_history.changed_by IS
    'Пользователь БД, от имени которого произошло изменение';

-- Индекс для быстрого поиска истории по заказу
CREATE INDEX IF NOT EXISTS idx_order_status_history_order_id
    ON order_status_history (order_id);
-- =========================================================
-- 1. Триггерная функция: проверка суммы возврата
-- =========================================================

CREATE OR REPLACE FUNCTION fn_validate_refund_amount()
RETURNS TRIGGER AS $$
DECLARE
    v_payment_amount   numeric(10,2);
    v_already_refunded numeric(10,2);
    v_available        numeric(10,2);
BEGIN
    -- Получаем сумму платежа
    SELECT amount
      INTO v_payment_amount
      FROM payment
     WHERE id = NEW.payment_id;

    IF v_payment_amount IS NULL THEN
        RAISE EXCEPTION 'Платеж с id=% не найден', NEW.payment_id;
    END IF;

    -- Считаем уже сделанные возвраты
    IF TG_OP = 'UPDATE' THEN
        -- При UPDATE исключаем текущую запись
        SELECT COALESCE(SUM(amount), 0)
          INTO v_already_refunded
          FROM refund
         WHERE payment_id = NEW.payment_id
           AND id <> NEW.id;
    ELSE
        -- При INSERT учитываем все существующие возвраты
        SELECT COALESCE(SUM(amount), 0)
          INTO v_already_refunded
          FROM refund
         WHERE payment_id = NEW.payment_id;
    END IF;

    -- Доступная сумма для возврата
    v_available := v_payment_amount - v_already_refunded;

    -- Дополнительная защита, хотя CHECK тоже существует
    IF NEW.amount <= 0 THEN
        RAISE EXCEPTION 'Сумма возврата должна быть положительной';
    END IF;

    -- Главная проверка
    IF NEW.amount > v_available THEN
        RAISE EXCEPTION
            'Превышена доступная сумма возврата. Платеж=%, сумма платежа=%, уже возвращено=%, доступно=%, запрошено=%',
            NEW.payment_id,
            v_payment_amount,
            v_already_refunded,
            v_available,
            NEW.amount;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validate_refund_amount ON refund;

CREATE TRIGGER trg_validate_refund_amount
BEFORE INSERT OR UPDATE ON refund
FOR EACH ROW
EXECUTE FUNCTION fn_validate_refund_amount();

INSERT INTO refund (payment_id, refund_date, amount)
SELECT id, now(), 100000
FROM payment
WHERE amount = 99000
LIMIT 1;

INSERT INTO refund (payment_id, refund_date, amount)
SELECT id, now(), 10000
FROM payment
WHERE amount = 99000
LIMIT 1;

-- =========================================================
-- 2. Триггерная функция: пересчёт суммы заказа
-- =========================================================

CREATE OR REPLACE FUNCTION fn_update_order_total_after_item_change()
RETURNS TRIGGER AS $$
DECLARE
    v_order_id  integer;
    v_new_total numeric(10,2);
BEGIN
    -- Определяем, заказ какой строки нужно пересчитать
    IF TG_OP = 'DELETE' THEN
        v_order_id := OLD.order_id;
    ELSE
        v_order_id := NEW.order_id;
    END IF;

    -- Пересчитываем сумму всех позиций заказа
    SELECT COALESCE(SUM(quantity * price), 0)
      INTO v_new_total
      FROM order_item
     WHERE order_id = v_order_id;

    -- Обновляем итоговую сумму в шапке заказа
    UPDATE customer_order
       SET total_amount = v_new_total
     WHERE id = v_order_id;

    -- Для AFTER-триггера RETURN формально не важен,
    -- но синтаксически требуется вернуть NEW, OLD или NULL
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_order_total_after_item_change ON order_item;
CREATE TRIGGER trg_update_order_total_after_item_change
AFTER INSERT OR UPDATE OR DELETE ON order_item
FOR EACH ROW
EXECUTE FUNCTION fn_update_order_total_after_item_change();

-- =========================================================
-- Тест триггера 2: автоматический пересчёт total_amount
-- =========================================================

DO $$
DECLARE
    v_order_id   integer;
    v_service_id integer;
    v_total      numeric(10,2);
BEGIN
    -- Создаём тестовый заказ
    INSERT INTO customer_order (
        client_id,
        employee_id,
        status_id,
        paid_at,
        total_amount
    )
    VALUES (
        (SELECT id FROM client WHERE login = 'ivan_i'),
        (SELECT id FROM employee WHERE login = 'a_smirnov'),
        (SELECT id FROM order_status WHERE name = 'Новый'),
        NULL,
        0
    )
    RETURNING id INTO v_order_id;

    -- Берём существующую услугу
    SELECT id
      INTO v_service_id
      FROM service
     WHERE name = 'Тур в Анталию 7 дней';

    -- 1. INSERT позиции заказа
    INSERT INTO order_item (service_id, order_id, quantity, price)
    VALUES (v_service_id, v_order_id, 1, 10000);

    SELECT total_amount
      INTO v_total
      FROM customer_order
     WHERE id = v_order_id;

    RAISE NOTICE 'После INSERT: total_amount = % (ожидалось 10000)', v_total;

    -- 2. UPDATE позиции заказа
    UPDATE order_item
       SET quantity = 2
     WHERE order_id = v_order_id
       AND service_id = v_service_id;

    SELECT total_amount
      INTO v_total
      FROM customer_order
     WHERE id = v_order_id;

    RAISE NOTICE 'После UPDATE: total_amount = % (ожидалось 20000)', v_total;

    -- 3. DELETE позиции заказа
    DELETE FROM order_item
     WHERE order_id = v_order_id
       AND service_id = v_service_id;

    SELECT total_amount
      INTO v_total
      FROM customer_order
     WHERE id = v_order_id;

    RAISE NOTICE 'После DELETE: total_amount = % (ожидалось 0)', v_total;

    -- Удаляем тестовый заказ
    DELETE FROM customer_order
     WHERE id = v_order_id;

    RAISE NOTICE 'Тестовые данные удалены';
END $$;

CREATE OR REPLACE FUNCTION fn_log_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO order_status_history (
        order_id,
        old_status_id,
        new_status_id,
        old_status_name,
        new_status_name
    )
    VALUES (
        NEW.id,
        OLD.status_id,
        NEW.status_id,
        (SELECT name FROM order_status WHERE id = OLD.status_id),
        (SELECT name FROM order_status WHERE id = NEW.status_id)
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_order_status_change ON customer_order;

CREATE TRIGGER trg_log_order_status_change
AFTER UPDATE OF status_id ON customer_order
FOR EACH ROW
WHEN (OLD.status_id IS DISTINCT FROM NEW.status_id)
EXECUTE FUNCTION fn_log_order_status_change();

-- =========================================================
-- Тест триггера 3: аудит смены статуса заказа
-- =========================================================

DO $$
DECLARE
    v_order_id      integer;
    v_count_before  integer;
    v_count_after   integer;
BEGIN
    -- Создаём тестовый заказ со статусом "Новый"
    INSERT INTO customer_order (
        client_id,
        employee_id,
        status_id,
        paid_at,
        total_amount
    )
    VALUES (
        (SELECT id FROM client WHERE login = 'ivan_i'),
        (SELECT id FROM employee WHERE login = 'a_smirnov'),
        (SELECT id FROM order_status WHERE name = 'Новый'),
        NULL,
        12345
    )
    RETURNING id INTO v_order_id;

    -- Считаем записи в истории до изменения
    SELECT COUNT(*)
      INTO v_count_before
      FROM order_status_history;

    -- Меняем статус заказа
    UPDATE customer_order
       SET status_id = (
           SELECT id
           FROM order_status
           WHERE name = 'Подтверждён менеджером'
       )
     WHERE id = v_order_id;

    -- Считаем записи после изменения
    SELECT COUNT(*)
      INTO v_count_after
      FROM order_status_history;

    IF v_count_after = v_count_before + 1 THEN
        RAISE NOTICE 'Триггер аудита сработал корректно: добавлена 1 запись в историю';
    ELSE
        RAISE NOTICE 'Ошибка: триггер аудита не сработал или сработал некорректно';
    END IF;

    -- Запоминаем количество
    v_count_before := v_count_after;

    -- Обновляем заказ без смены статуса
    UPDATE customer_order
       SET total_amount = total_amount
     WHERE id = v_order_id;

    SELECT COUNT(*)
      INTO v_count_after
      FROM order_status_history;

    IF v_count_after = v_count_before THEN
        RAISE NOTICE 'Обновление без смены статуса не создало запись в истории — корректно';
    ELSE
        RAISE NOTICE 'Ошибка: создана лишняя запись в истории';
    END IF;

    -- Просмотр последней записи истории для проверки
    RAISE NOTICE 'Последняя запись истории: %',
        (
            SELECT json_build_object(
                'order_id', h.order_id,
                'old_status', h.old_status_name,
                'new_status', h.new_status_name,
                'changed_by', h.changed_by
            )
            FROM order_status_history h
            WHERE h.order_id = v_order_id
            ORDER BY h.id DESC
            LIMIT 1
        );

    -- Очищаем тестовые данные
    DELETE FROM order_status_history
     WHERE order_id = v_order_id;

    DELETE FROM customer_order
     WHERE id = v_order_id;

    RAISE NOTICE 'Тестовые данные удалены';
END $$;

-- =========================================================
-- Явный курсор: построчный вывод заказов
-- =========================================================

DO $$
DECLARE
    -- Объявление курсора: связываем курсор с SQL-запросом
    cur_orders CURSOR FOR
        SELECT
            o.id AS order_id,
            c.login AS client_login,
            concat_ws(
                ' ',
                (c.full_name).last_name,
                (c.full_name).first_name,
                (c.full_name).middle_name
            ) AS client_fio,
            e.login AS employee_login,
            os.name AS status_name,
            o.total_amount
        FROM customer_order o
        JOIN client c ON c.id = o.client_id
        JOIN employee e ON e.id = o.employee_id
        JOIN order_status os ON os.id = o.status_id
        ORDER BY o.id;

    -- Переменная для текущей строки курсора
    r RECORD;
BEGIN
    -- Открытие курсора: выполняется запрос
    OPEN cur_orders;

    LOOP
        -- Извлечение следующей строки
        FETCH cur_orders INTO r;

        -- Если данных больше нет, выходим из цикла
        EXIT WHEN NOT FOUND;

        -- Обработка строки: вывод в консоль
        RAISE NOTICE
            'Заказ % | клиент: % (%) | менеджер: % | статус: % | сумма: %',
            r.order_id,
            r.client_login,
            r.client_fio,
            r.employee_login,
            r.status_name,
            r.total_amount;
    END LOOP;

    -- Закрытие курсора: освобождение ресурсов
    CLOSE cur_orders;
END $$;

-- =========================================================
-- Неявный курсор: функция, возвращающая таблицу
-- =========================================================

DROP FUNCTION IF EXISTS get_client_order_summary();

CREATE FUNCTION get_client_order_summary()
RETURNS TABLE (
    client_id_out  integer,
    full_name_out  text,
    email_out      varchar(50),
    orders_count   bigint,
    total_spent    numeric(10,2)
)
AS $$
DECLARE
    rec RECORD;
BEGIN
    -- Неявный курсор:
    -- PostgreSQL автоматически выполняет OPEN, FETCH, CLOSE
    FOR rec IN
        SELECT
            c.id AS client_id,
            concat_ws(
                ' ',
                (c.full_name).last_name,
                (c.full_name).first_name,
                (c.full_name).middle_name
            ) AS fio,
            c.email,
            COUNT(o.id) AS orders_count,
            COALESCE(SUM(o.total_amount), 0) AS total_spent
        FROM client c
        LEFT JOIN customer_order o ON o.client_id = c.id
        GROUP BY
            c.id,
            c.email,
            (c.full_name).last_name,
            (c.full_name).first_name,
            (c.full_name).middle_name
        ORDER BY c.id
    LOOP
        -- Присваиваем значения выходным полям функции
        client_id_out := rec.client_id;
        full_name_out := rec.fio;
        email_out     := rec.email;
        orders_count  := rec.orders_count;
        total_spent   := rec.total_spent;

        -- Добавляем текущую строку в итоговый табличный результат
        RETURN NEXT;
    END LOOP;

    -- Завершение функции
    RETURN;
END;
$$ LANGUAGE plpgsql;


-- =========================================================
-- Получение результата функции как обычной таблицы
-- =========================================================

SELECT *
FROM get_client_order_summary();