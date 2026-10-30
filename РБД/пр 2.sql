CREATE TABLE IF NOT EXISTS categories (
    category_id SERIAL PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    parent_id   INT,  -- Ссылка на родительскую категорию
    CONSTRAINT fk_parent_category
    FOREIGN KEY (parent_id)
    REFERENCES categories(category_id)
    ON DELETE CASCADE
);

COMMENT ON TABLE categories IS 'Иерархический справочник категорий услуг (туров, перелётов, отелей)';
COMMENT ON COLUMN categories.parent_id IS 'ID родительской категории (NULL — корневая категория)';
INSERT INTO categories (category_id, name, parent_id) VALUES
-- Корневые категории (родитель = NULL)
(1, 'Туры',                    NULL),
(2, 'Авиаперелёты',            NULL),
(3, 'Отели',                   NULL),
(4, 'Страхование',             NULL),

-- Подкатегории туров (родитель = 1)
(5, 'Пляжный отдых',           1),
(6, 'Экскурсионные туры',      1),
(7, 'Горнолыжные туры',        1),

-- Подкатегории перелётов (родитель = 2)
(8, 'Внутренние рейсы',        2),
(9, 'Международные рейсы',     2),

-- Подкатегории отелей (родитель = 3)
(10, 'Городские отели',        3),
(11, 'Курортные отели',        3),

-- Подкатегории 3-го уровня (вложенные подкатегории)
(12, 'Турция (пляжный)',       5),
(13, 'Египет (пляжный)',       5),
(14, 'Италия (экскурсии)',     6),
(15, 'Греция (экскурсии)',     6),
(16, 'Рейсы по России',        8),
(17, 'Рейсы в СНГ',            8);

SELECT *
FROM customer_order AS co
INNER JOIN client AS c ON co.client_id = c.id;

SELECT 
    tour_op.name AS tour_operator_name, 
    COUNT(s.id) AS service_count
FROM tour_operator AS tour_op
LEFT JOIN service AS s ON tour_op.id = s.tour_operator_id
GROUP BY tour_op.id, tour_op.name
ORDER BY service_count DESC;

SELECT 
    h.name AS hotel_name, 
    h.stars
FROM service_hotel AS sh
RIGHT JOIN hotel AS h ON sh.hotel_id = h.id
WHERE sh.service_id IS NULL;

SELECT 
    COALESCE(mt.code, 'Тип не указан') AS meal_type_code, 
    COUNT(h.id) AS hotel_count
FROM meal_type AS mt
FULL JOIN hotel AS h ON mt.id = h.meal_type_id
GROUP BY mt.id, mt.code
ORDER BY hotel_count DESC;

SELECT 
    (c.full_name).last_name || ' ' || (c.full_name).first_name AS client_name,
    a.name AS airline_name,
    a.iata_code
FROM client AS c
CROSS JOIN airline AS a
LIMIT 20; -- Ограничиваем вывод, так как строк будет 10 * 10 = 100

SELECT 
    c.name AS category_name,
    p.name AS parent_category_name
FROM categories AS c
LEFT JOIN categories AS p ON c.parent_id = p.category_id
ORDER BY c.category_id;

SELECT 
    (c.full_name).last_name AS client_surname,
    co.id AS order_id,
    s.name AS service_name,
    tour_op.name AS tour_operator
FROM client AS c
JOIN customer_order AS co ON c.id = co.client_id
JOIN order_item AS oi ON co.id = oi.order_id
JOIN service AS s ON oi.service_id = s.id
JOIN tour_operator AS tour_op ON s.tour_operator_id = tour_op.id
ORDER BY co.id;




-- Получить единый список контактов клиентов и сотрудников
SELECT 
    email AS contact, 
    'Клиент' AS type
FROM client
UNION
SELECT 
    login AS contact, 
    'Сотрудник' AS type
FROM employee
ORDER BY contact;

-- Найти услуги, которые были и проданы, и выкуплены
SELECT 
    s.name AS service_name,
    s.service_type
FROM order_item AS oi
JOIN service AS s ON oi.service_id = s.id
INTERSECT
SELECT 
    s.name AS service_name,
    s.service_type
FROM purchase_item AS pi
JOIN service AS s ON pi.service_id = s.id
ORDER BY service_name;

-- Найти услуги, которые проданы, но не выкуплены
SELECT 
    s.name AS service_name,
    s.service_type,
    oi.order_id
FROM order_item AS oi
JOIN service AS s ON oi.service_id = s.id
EXCEPT
SELECT 
    s.name AS service_name,
    s.service_type,
    pi.purchase_id
FROM purchase_item AS pi
JOIN service AS s ON pi.service_id = s.id
ORDER BY service_name;