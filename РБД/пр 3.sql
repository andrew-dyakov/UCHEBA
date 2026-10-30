-- 1.1. Категоризация заказов клиентов по сумме (total_amount)
SELECT 
    id AS order_id,
    client_id,
    total_amount,
    CASE 
        WHEN total_amount > 150000 THEN 'VIP (Свыше 150 000 руб.)'
        WHEN total_amount BETWEEN 50000 AND 150000 THEN 'Комфорт (50 000 - 150 000 руб.)'
        WHEN total_amount < 50000 AND total_amount > 0 THEN 'Бюджетный (До 50 000 руб.)'
        ELSE 'Ошибка данных или заказ без стоимости'
    END AS price_category
FROM 
    customer_order
ORDER BY 
    total_amount DESC;

-- 1.2. Подсчет групповых и одиночных бронирований в разрезе типов услуг
SELECT 
    s.service_type,
    COUNT(CASE WHEN oi.quantity > 1 THEN 1 ELSE NULL END) AS group_bookings,
    COUNT(CASE WHEN oi.quantity = 1 THEN 1 ELSE NULL END) AS single_bookings
FROM 
    service s
JOIN 
    order_item oi ON s.id = oi.service_id
GROUP BY 
    s.service_type;

-- 2.1. Скалярный подзапрос: заказы выше средней суммы
SELECT 
    id AS order_id, 
    client_id, 
    total_amount
FROM 
    customer_order
WHERE 
    total_amount > (SELECT AVG(total_amount) FROM customer_order);

-- 2.2. Многострочный подзапрос с IN (фильтрация по дате создания заказа)
SELECT 
    (full_name).last_name, 
    (full_name).first_name
FROM 
    client
WHERE 
    id IN (
        SELECT client_id 
        FROM customer_order 
        WHERE created_at >= '2025-02-01' AND created_at < '2025-03-01'
    );

-- 2.3. Коррелированный подзапрос с EXISTS (поиск по текстовому условию в связанной таблице)
SELECT 
    (full_name).last_name, 
    (full_name).first_name
FROM 
    employee e
WHERE 
    EXISTS (
        SELECT 1 
        FROM customer_order co
        JOIN order_status os ON co.status_id = os.id
        WHERE co.employee_id = e.id 
          AND os.name = 'Отменён клиентом'
    );

-- 2.4. Альтернативное решение задачи 2.3 с использованием JOIN
SELECT DISTINCT
    (e.full_name).last_name, 
    (e.full_name).first_name
FROM 
    employee e
JOIN 
    customer_order co ON e.id = co.employee_id
JOIN 
    order_status os ON co.status_id = os.id
WHERE 
    os.name = 'Отменён клиентом';


-- 3.1. Стандартное CTE: переписываем задачу 2.3
WITH cancelled_orders AS (
    -- Сначала находим ID всех сотрудников, у которых есть отмененные заказы
    SELECT DISTINCT employee_id 
    FROM customer_order co
    JOIN order_status os ON co.status_id = os.id
    WHERE os.name = 'Отменён клиентом'
)
-- Теперь используем наш CTE (cancelled_orders) как обычную таблицу
SELECT 
    (e.full_name).last_name, 
    (e.full_name).first_name
FROM 
    employee e
JOIN 
    cancelled_orders c ON e.id = c.employee_id;

-- 3.2. Рекурсивное CTE: обход дерева категорий
WITH RECURSIVE category_tree AS (
    
    -- 1. Якорный (начальный) запрос: находим "корень" иерархии
    SELECT 
        category_id, 
        name, 
        parent_id, 
        0 AS level -- Устанавливаем начальный уровень 0
    FROM 
        categories
    WHERE 
        parent_id IS NULL -- Корневые категории (Туры, Авиаперелёты и т.д.)

    UNION ALL

    -- 2. Рекурсивный запрос: присоединяем дочерние категории
    SELECT 
        c.category_id, 
        c.name, 
        c.parent_id, 
        ct.level + 1 AS level -- Увеличиваем уровень на 1
    FROM 
        categories c
    JOIN 
        category_tree ct ON c.parent_id = ct.category_id
)
-- Финальная выборка с красивым форматированием
SELECT 
    -- LPAD добавляет пробелы слева в зависимости от уровня (4 пробела на уровень)
    LPAD('', level * 4, ' ') || name AS visual_hierarchy, 
    level,
    name
FROM 
    category_tree
ORDER BY 
    level, category_id;

-- 4.1. Демонстрация строковых функций для работы с данными клиентов
SELECT 
    -- CONCAT: Формирование единой строки ФИО для вывода в печатные формы и договоры
    CONCAT((full_name).last_name, ' ', (full_name).first_name, ' ', (full_name).middle_name) AS formatted_fio,
    
    -- UPPER и SUBSTRING: Маскирование логина (первые 3 буквы заглавными + звездочки) для безопасности при отображении в интерфейсе
    CONCAT(UPPER(SUBSTRING(login FROM 1 FOR 3)), '***') AS masked_login,
    
    -- LENGTH: Подсчет количества символов в email (используется для валидации и ограничения длины поля)
    LENGTH(email) AS email_chars_count
FROM 
    client
LIMIT 5;

-- 4.2. Демонстрация функций работы с датой и временем для аналитики
SELECT 
    (full_name).last_name,
    birth_date,
    
    -- AGE: Расчёт точного возраста клиента на текущий день (в годах, месяцах и днях) для проверки совершеннолетия или сегментации
    AGE(CURRENT_DATE, birth_date) AS exact_client_age,
    
    -- EXTRACT: Извлечение номера месяца из даты создания заказа для построения графиков сезонности
    EXTRACT(MONTH FROM created_at) AS order_month_number,
    
    -- DATE_TRUNC: Округление даты создания заказа до начала месяца (удобно для группировки в финансовых отчетах)
    DATE_TRUNC('month', created_at) AS order_month_start
FROM 
    client c
JOIN 
    customer_order co ON c.id = co.client_id
LIMIT 5;

-- 4.3. Демонстрация математических функций для финансовых расчетов
SELECT 
    id AS order_id,
    total_amount,
    
    -- ROUND: Математическое округление итоговой суммы заказа до целого рубля (для красивого отображения в SMS и чеках без копеек)
    ROUND(total_amount) AS rounded_total,
    
    -- CEIL: Округление в большую сторону суммы агентского вознаграждения (например, 2.5% от заказа) до целого рубля
    CEIL(total_amount * 0.025) AS agent_fee_ceil,
    
    -- ABS: Получение абсолютного значения (бизнес-логика: отображение суммы возврата средств клиенту без знака "минус")
    ABS(-5000.00) AS abs_refund_example
FROM 
    customer_order
LIMIT 5;


-- 5.1. Создание таблицы логов и наполнение тестовыми JSONB-данными
CREATE TABLE IF NOT EXISTS user_logs (
    log_id SERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    user_id INT,
    event_data JSONB
);

INSERT INTO user_logs (user_id, event_data) VALUES
(1, '{"event": "login", "browser": "Chrome", "os": "Windows", "success": true}'),
(2, '{"event": "view_tour", "tour_id": 5, "duration_sec": 120}'),
(1, '{"event": "booking", "tour_id": 5, "amount": 85000, "success": true}'),
(3, '{"event": "login", "browser": "Safari", "os": "iOS", "success": false}'),
(4, '{"event": "view_tour", "tour_id": 2, "duration_sec": 45}'),
(2, '{"event": "booking", "tour_id": 2, "amount": 120000, "success": true}'),
(5, '{"event": "login", "browser": "Firefox", "os": "Linux", "success": true}');

-- 5.2. Фильтрация по JSONB внутри CTE с последующим JOIN к таблице клиентов
WITH successful_logins AS (
    -- Оператор @> проверяет, содержит ли event_data подмножество {"event": "login", "success": true}
    SELECT DISTINCT user_id 
    FROM user_logs 
    WHERE event_data @> '{"event": "login", "success": true}'
)
SELECT 
    (c.full_name).last_name, 
    (c.full_name).first_name, 
    c.email
FROM 
    client c
JOIN 
    successful_logins sl ON c.id = sl.user_id;

-- 5.3. Массовое обновление: добавляем новое поле "source" во все JSON-документы
UPDATE user_logs 
SET event_data = event_data || '{"source": "web"}'::jsonb;

-- Проверяем результат
SELECT log_id, event_data FROM user_logs LIMIT 3;

-- 5.4. Точечное изменение: меняем значение ключа 'success' на false для конкретной записи
UPDATE user_logs 
SET event_data = jsonb_set(
    event_data,             -- 1. Исходное поле
    '{success}',            -- 2. Путь к ключу в виде массива строк
    'false'::jsonb          -- 3. Новое значение (обязательно приводим к типу jsonb!)
)
WHERE log_id = 3;

-- Проверяем, что изменилось только нужное поле
SELECT log_id, event_data FROM user_logs WHERE log_id = 3;