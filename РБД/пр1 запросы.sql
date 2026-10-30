-- 1. Выбор всех столбцов (*) для быстрой проверки содержимого таблицы.
SELECT * FROM airline;

-- 2. Выбор конкретных полей с псевдонимом (AS) и вычисление математического выражения в списке выборки.
SELECT service_id, quantity, price, (quantity * price) AS "Итоговая стоимость" 
FROM order_item;

-- 3. Получение списка уникальных значений с удалением дубликатов (DISTINCT).
SELECT DISTINCT service_type FROM service;

-- 4. Фильтрация по диапазону (BETWEEN) и логическому условию (AND).
SELECT id, total_amount 
FROM customer_order 
WHERE total_amount BETWEEN 50000 AND 150000 
  AND status_id = (SELECT id FROM order_status WHERE name = 'Оплачен полностью');

-- 5. Проверка вхождения в множество (IN) и сравнение со строковым шаблоном (LIKE).
SELECT name, service_type 
FROM service 
WHERE service_type IN ('tour', 'flight') AND name LIKE '%Авиабилеты%';

-- 6. Корректная проверка на отсутствие значения (IS NULL), так как сравнение с NULL вернет UNKNOWN.
SELECT id, total_amount, paid_at 
FROM customer_order 
WHERE paid_at IS NULL;

-- 7. Группировка данных по типу услуги с подсчетом количества (GROUP BY) и сортировка результата (ORDER BY).
SELECT service_type, COUNT(*) AS "Количество" 
FROM service 
GROUP BY service_type 
ORDER BY "Количество" DESC;

-- 8. Группировка заказов по клиентам и фильтрация сформированных групп по общей сумме (HAVING).
SELECT client_id, SUM(total_amount) AS "Общая сумма" 
FROM customer_order 
GROUP BY client_id 
HAVING SUM(total_amount) > 100000;

-- 9. Группировка отелей по странам, фильтрация групп по средней звездности (HAVING) и сортировка (ORDER BY).
SELECT country_id, AVG(stars) AS "Средняя звездность" 
FROM hotel 
GROUP BY country_id 
HAVING AVG(stars) >= 4 
ORDER BY "Средняя звездность" DESC;
-- 10. Точечное обновление данных одной строки с обязательным фильтром WHERE.
UPDATE client 
SET email = 'new_ivanov@mail.ru' 
WHERE login = 'ivan_i';
-- 11. Массовое обновление данных с использованием математического выражения и условия WHERE.
UPDATE hotel 
SET stars = stars + 1 
WHERE name = 'Simbel Hotel' AND stars < 5;
-- 12. Безопасное удаление конкретной записи с точным условием фильтрации WHERE.
DELETE FROM phone 
WHERE phone_number = '+79031234568' 
  AND client_id = (SELECT id FROM client WHERE login = 'ivan_i');
-- 13. Удаление записи о возврате средств по идентификатору платежа с условием WHERE.
DELETE FROM refund 
WHERE payment_id = (SELECT id FROM payment WHERE amount = 25000);
-- 14. Попытка удаления страны, на которую ссылаются города и отели (должна выдать ошибку).
DELETE FROM country 
WHERE code = 'TR';
-- 15. Создаем тестового клиента для демонстрации CASCADE
INSERT INTO client (full_name, passport_data, email, login, password, birth_date)
VALUES (
    ROW('Тестовый', 'Клиент', 'Тестович'),
    ROW('9999', '000000', 'Тест', '2025-01-01'),
    'test_cascade@mail.ru',
    'test_cascade',
    'test123',
    '1990-01-01'
);
-- 16. Добавляем телефоны для тестового клиента
INSERT INTO phone (client_id, phone_number)
VALUES 
    ((SELECT id FROM client WHERE login = 'test_cascade'), '+79990000001'),
    ((SELECT id FROM client WHERE login = 'test_cascade'), '+79990000002');
-- 17. Проверяем, что телефоны добавлены
SELECT * FROM phone 
WHERE client_id = (SELECT id FROM client WHERE login = 'test_cascade');
-- 18. Удаляем тестового клиента - телефоны удалятся автоматически (CASCADE)
DELETE FROM client 
WHERE login = 'test_cascade';
-- 19. Проверяем, что телефоны удалены каскадно
SELECT * FROM phone 
WHERE client_id = (SELECT id FROM client WHERE login = 'test_cascade');
