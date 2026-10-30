TRUNCATE TABLE service_hotel, purchase_item, order_item, phone, refund, purchase, payment, customer_order, service, employee, client, hotel, city, tour_operator, supplier, position, payment_type, order_status, airline, meal_type, country RESTART IDENTITY CASCADE;
TRUNCATE TABLE hotel RESTART IDENTITY CASCADE;
INSERT INTO country (name, code) VALUES
('Россия', 'RU'),
('Турция', 'TR'),
('Египет', 'EG'),
('Таиланд', 'TH'),
('ОАЭ', 'AE'),
('Италия', 'IT'),
('Испания', 'ES'),
('Греция', 'GR'),
('Кипр', 'CY'),
('Тунис', 'TN');


INSERT INTO meal_type (code, description) VALUES
('RO', 'Без питания'),
('BB', 'Завтрак'),
('HB', 'Полупансион (завтрак+ужин)'),
('FB', 'Полный пансион (завтрак+обед+ужин)'),
('AI', 'Всё включено'),
('UAI', 'Ультра всё включено'),
('EB', 'Только завтрак (европейский)'),
('CB', 'Континентальный завтрак'),
('BF', 'Шведский стол завтрак'),
('BR', 'Поздний завтрак');


INSERT INTO airline (name, iata_code) VALUES
('Аэрофлот', 'SU'),
('S7 Airlines', 'S7'),
('Turkish Airlines', 'TK'),
('Emirates', 'EK'),
('Flydubai', 'FZ'),
('Qatar Airways', 'QR'),
('Pegasus Airlines', 'PC'),
('Nordwind Airlines', 'N4'),
('Red Wings', 'WZ'),
('Utair', 'UT');


INSERT INTO order_status (name) VALUES
('Новый'),
('Подтверждён менеджером'),
('Ожидает оплаты'),
('Частично оплачен'),
('Оплачен полностью'),
('Выкуплен у поставщика'),
('Подтверждён поставщиком'),
('Отменён клиентом'),
('Отменён поставщиком'),
('Завершён');


INSERT INTO payment_type (name) VALUES
('Банковская карта (онлайн)'),
('Наличные в офисе'),
('СБП'),
('Криптовалюта'),
('Apple Pay'),
('Google Pay'),
('Безналичный перевод юр. лица'),
('Рассрочка от банка'),
('Кредит онлайн'),
('Бонусы лояльности');


INSERT INTO position (name) VALUES
('Генеральный директор'),
('Руководитель отдела продаж'),
('Старший менеджер по туризму'),
('Менеджер по работе с клиентами'),
('Менеджер по авиабилетам'),
('Менеджер по бронированию отелей'),
('Бухгалтер'),
('Системный администратор'),
('Курьер'),
('Стажёр');


INSERT INTO supplier (name, type) VALUES
('Travelport GDS', 'GDS'),
('Amadeus', 'GDS'),
('Sabre', 'GDS'),
('Ostrovok.ru', 'Отельный агрегатор'),
('Travelata', 'Отельный агрегатор'),
('MisterHotel', 'Отельный агрегатор'),
('Интурстрах', 'Страховая'),
('ERV', 'Страховая'),
('Liberty Insurance', 'Страховая'),
('Авиа Групп', 'Агрегатор авиабилетов');


INSERT INTO tour_operator (name, inn) VALUES
('Coral Travel', '1234567890'),
('Pegas Touristik', '2345678901'),
('ANEX Tour', '3456789012'),
('Intourist', '4567890123'),
('Sunmar', '5678901234'),
('Tez Tour', '6789012345'),
('Mouzenidis Travel', '7890123456'),
('Biblio Globus', '8901234567'),
('DSBW', '9012345678'),
('Русский Экспресс', '0123456789');


INSERT INTO city (name, country_id, iata_code) VALUES
('Москва',     (SELECT id FROM country WHERE code='RU'), 'MOW'),
('Санкт-Петербург', (SELECT id FROM country WHERE code='RU'), 'LED'),
('Анталья',    (SELECT id FROM country WHERE code='TR'), 'AYT'),
('Стамбул',    (SELECT id FROM country WHERE code='TR'), 'IST'),
('Хургада',    (SELECT id FROM country WHERE code='EG'), 'HRG'),
('Шарм-эль-Шейх', (SELECT id FROM country WHERE code='EG'), 'SSH'),
('Бангкок',    (SELECT id FROM country WHERE code='TH'), 'BKK'),
('Пхукет',     (SELECT id FROM country WHERE code='TH'), 'HKT'),
('Дубай',      (SELECT id FROM country WHERE code='AE'), 'DXB'),
('Рим',        (SELECT id FROM country WHERE code='IT'), 'ROM'),
('Барселона',  (SELECT id FROM country WHERE code='ES'), 'BCN'),
('Афины',      (SELECT id FROM country WHERE code='GR'), 'ATH'),
('Ларнака',    (SELECT id FROM country WHERE code='CY'), 'LCA'),
('Монастир',   (SELECT id FROM country WHERE code='TN'), 'MIR');


INSERT INTO hotel (name, country_id, city_id, stars, full_address, description, meal_type_id) VALUES
('Sunset Beach Resort', (SELECT id FROM country WHERE code='TR'), (SELECT id FROM city WHERE iata_code='AYT'), 5, ROW('07100', 'Турция', 'Анталья', 'Lara Beach', 'Bina Yolu No:15', NULL), 'Первый берег, огромный аквапарк', (SELECT id FROM meal_type WHERE code='AI')),
('Grand Whale', (SELECT id FROM country WHERE code='RU'), (SELECT id FROM city WHERE iata_code='MOW'), 4, ROW('141008', 'Россия', 'Москва', 'Ленинградское шоссе', '37', '1B'), 'Уютный отель рядом с аэропортом Шереметьево', (SELECT id FROM meal_type WHERE code='BB')),
('Jaz Aquamarine', (SELECT id FROM country WHERE code='EG'), (SELECT id FROM city WHERE iata_code='HRG'), 5, ROW('84511', 'Египет', 'Хургада', 'Safaga Road', '1', NULL), 'Семейный отдых, дайвинг', (SELECT id FROM meal_type WHERE code='UAI')),
('Green Park Resort', (SELECT id FROM country WHERE code='TH'), (SELECT id FROM city WHERE iata_code='HKT'), 4, ROW('83150', 'Таиланд', 'Пхукет', 'Patong Beach Road', '133', NULL), 'Шумный район, рядом с барами', (SELECT id FROM meal_type WHERE code='HB')),
('Atlantis The Palm', (SELECT id FROM country WHERE code='AE'), (SELECT id FROM city WHERE iata_code='DXB'), 5, ROW('00000', 'ОАЭ', 'Дубай', 'Palm Jumeirah', '1', NULL), 'Легендарный отель с аквапарком', (SELECT id FROM meal_type WHERE code='AI')),
('Hilton Istanbul Bosphorus', (SELECT id FROM country WHERE code='TR'), (SELECT id FROM city WHERE iata_code='IST'), 5, ROW('34400', 'Турция', 'Стамбул', 'Harbiye Mah.', 'Cumhuriyet Cad. 50', NULL), 'Вид на Босфор', (SELECT id FROM meal_type WHERE code='HB')),
('Barcelo Raval', (SELECT id FROM country WHERE code='ES'), (SELECT id FROM city WHERE iata_code='BCN'), 4, ROW('08001', 'Испания', 'Барселона', 'Raval', '19', NULL), 'Современный дизайн, центр', (SELECT id FROM meal_type WHERE code='BB')),
('Divani Apollon Palace', (SELECT id FROM country WHERE code='GR'), (SELECT id FROM city WHERE iata_code='ATH'), 5, ROW('16671', 'Греция', 'Афины', 'Apollonos 10', 'Vouliagmeni', NULL), 'СПА-центр, частный пляж', (SELECT id FROM meal_type WHERE code='FB')),
('Radisson Blu Hotel Moscow', (SELECT id FROM country WHERE code='RU'), (SELECT id FROM city WHERE iata_code='MOW'), 4, ROW('123456', 'Россия', 'Москва', 'ул. 3-я Ямского поля', '5', NULL), 'Бизнес-отель в центре', (SELECT id FROM meal_type WHERE code='BB')),
('Simbel Hotel', (SELECT id FROM country WHERE code='EG'), (SELECT id FROM city WHERE iata_code='SSH'), 3, ROW('87654', 'Египет', 'Шарм-эль-Шейх', 'Naama Bay', '10', NULL), 'Бюджетный вариант, до моря 5 минут', (SELECT id FROM meal_type WHERE code='HB'));

INSERT INTO client (full_name, passport_data, email, login, password, birth_date)
VALUES
(ROW('Иванов', 'Иван', 'Иванович'), ROW('4510', '123456', 'УФМС России по г. Москве', '2015-03-10'),
 'ivanov@mail.ru', 'ivan_i', 'pass123', '1990-07-15'),

(ROW('Петрова', 'Анна', 'Сергеевна'), ROW('5012', '789012', 'МВД по Республике Татарстан', '2018-11-20'),
 'anna.petrova@list.ru', 'annap', 'qwerty', '1988-12-01'),

(ROW('Сидоров', 'Алексей', 'Владимирович'), ROW('4612', '345678', 'УФМС по Ростовской области', '2020-01-25'),
 'sid_alex@yandex.ru', 'alexs', '1q2w3e', '1985-03-22'),

(ROW('Козлова', 'Елена', 'Дмитриевна'), ROW('4711', '987654', 'Отдел УФМС по г. Санкт-Петербург', '2019-06-30'),
 'lenakozlova@gmail.com', 'lenak', 'zaq12wsx', '1995-08-11'),

(ROW('Морозов', 'Дмитрий', 'Алексеевич'), ROW('4522', '556677', 'УФМС по Краснодарскому краю', '2021-02-14'),
 'morozov_d@bk.ru', 'dmorozov', 'pass321', '2000-11-05'),

(ROW('Волкова', 'Ольга', 'Николаевна'), ROW('4923', '443322', 'УФМС по Новосибирской области', '2017-09-17'),
 'volkova_o@inbox.ru', 'olga_v', 'olga123', '1992-04-28'),

(ROW('Никитин', 'Павел', 'Олегович'), ROW('5020', '111222', 'УМВД по Владимирской области', '2022-12-10'),
 'pavel_n@rambler.ru', 'paveln', 'pavel2020', '1998-10-19'),

(ROW('Семёнова', 'Татьяна', 'Игоревна'), ROW('4815', '334455', 'УФМС по Свердловской области', '2016-05-05'),
 'tatiana_s@yandex.ru', 'tat_s', 'tatianna', '1996-09-23'),

(ROW('Григорьев', 'Артём', 'Станиславович'), ROW('5100', '778899', 'УФМС по Красноярскому краю', '2023-01-18'),
 'artem_g@mail.ru', 'artemg', 'artem123', '2001-02-14'),

(ROW('Михайлова', 'Юлия', 'Андреевна'), ROW('4625', '990011', 'УФМС по Воронежской области', '2019-08-22'),
 'julia_mih@list.ru', 'juliam', 'julia456', '1993-12-05');


INSERT INTO employee (full_name, position_id, login, password, is_active)
VALUES
(ROW('Быстрова', 'Мария', 'Ивановна'), (SELECT id FROM position WHERE name='Генеральный директор'), 'm_bystrova', 'dir123', true),
(ROW('Смирнов', 'Андрей', 'Петрович'), (SELECT id FROM position WHERE name='Руководитель отдела продаж'), 'a_smirnov', 'head123', true),
(ROW('Кузнецова', 'Светлана', 'Владимировна'), (SELECT id FROM position WHERE name='Старший менеджер по туризму'), 'sv_kuz', 'senior123', true),
(ROW('Попов', 'Александр', 'Николаевич'), (SELECT id FROM position WHERE name='Менеджер по работе с клиентами'), 'al_popov', 'manager1', true),
(ROW('Лебедева', 'Екатерина', 'Дмитриевна'), (SELECT id FROM position WHERE name='Менеджер по авиабилетам'), 'kat_lebed', 'air123', true),
(ROW('Новиков', 'Игорь', 'Олегович'), (SELECT id FROM position WHERE name='Менеджер по бронированию отелей'), 'igor_nov', 'hotel123', true),
(ROW('Соколова', 'Антонина', 'Васильевна'), (SELECT id FROM position WHERE name='Бухгалтер'), 'ant_sokol', 'buh123', true),
(ROW('Воробьёв', 'Денис', 'Алексеевич'), (SELECT id FROM position WHERE name='Системный администратор'), 'den_vorob', 'admin123', true),
(ROW('Зайцева', 'Оксана', 'Романовна'), (SELECT id FROM position WHERE name='Менеджер по работе с клиентами'), 'ok_zait', 'manager2', true),
(ROW('Фёдоров', 'Максим', 'Сергеевич'), (SELECT id FROM position WHERE name='Стажёр'), 'max_fedorov', 'student1', true);


INSERT INTO service (name, service_type, country_id, departure_city, supplier_id, description, airline_id, tour_operator_id)
VALUES
('Тур в Анталию 7 дней', 'tour', (SELECT id FROM country WHERE code='TR'), 'Москва (MOW)',
 (SELECT id FROM supplier WHERE name='Travelport GDS'), 'Перелёт+отель+трансфер+питание AI',
 (SELECT id FROM airline WHERE iata_code='SU'), (SELECT id FROM tour_operator WHERE name='Coral Travel')),

('Тур на Пхукет 14 дней', 'tour', (SELECT id FROM country WHERE code='TH'), 'Москва (MOW)',
 (SELECT id FROM supplier WHERE name='Amadeus'), 'Экзотический отдых с дайвингом',
 (SELECT id FROM airline WHERE iata_code='S7'), (SELECT id FROM tour_operator WHERE name='ANEX Tour')),

('Авиабилеты Москва-Дубай', 'flight', (SELECT id FROM country WHERE code='AE'), 'Москва (MOW)',
 (SELECT id FROM supplier WHERE name='Amadeus'), 'Эконом-класс, туда-обратно',
 (SELECT id FROM airline WHERE iata_code='EK'), (SELECT id FROM tour_operator WHERE name='Tez Tour')),

('Авиабилеты СПб-Стамбул', 'flight', (SELECT id FROM country WHERE code='TR'), 'Санкт-Петербург (LED)',
 (SELECT id FROM supplier WHERE name='Sabre'), 'Багаж 23 кг',
 (SELECT id FROM airline WHERE iata_code='TK'), (SELECT id FROM tour_operator WHERE name='Pegas Touristik')),

('Тур в Хургаду 10 дней', 'tour', (SELECT id FROM country WHERE code='EG'), 'Москва (MOW)',
 (SELECT id FROM supplier WHERE name='Ostrovok.ru'), 'Отель 5*, UAI',
 (SELECT id FROM airline WHERE iata_code='S7'), (SELECT id FROM tour_operator WHERE name='Sunmar')),

('Тур в Шарм-эль-Шейх 8 дней', 'tour', (SELECT id FROM country WHERE code='EG'), 'Москва (MOW)',
 (SELECT id FROM supplier WHERE name='Travelata'), 'Бюджетный отдых',
 (SELECT id FROM airline WHERE iata_code='N4'), (SELECT id FROM tour_operator WHERE name='Intourist')),

('Авиабилеты Москва-Бангкок', 'flight', (SELECT id FROM country WHERE code='TH'), 'Москва (MOW)',
 (SELECT id FROM supplier WHERE name='Amadeus'), 'Трансфер в аэропорту',
 (SELECT id FROM airline WHERE iata_code='SU'), (SELECT id FROM tour_operator WHERE name='Biblio Globus')),

('Тур в Рим 5 дней', 'tour', (SELECT id FROM country WHERE code='IT'), 'Москва (MOW)',
 (SELECT id FROM supplier WHERE name='Travelport GDS'), 'Экскурсионный тур',
 (SELECT id FROM airline WHERE iata_code='S7'), (SELECT id FROM tour_operator WHERE name='DSBW')),

('Авиабилеты Барселона-Москва', 'flight', (SELECT id FROM country WHERE code='ES'), 'Барселона (BCN)',
 (SELECT id FROM supplier WHERE name='Sabre'), 'Невозвратный тариф',
 (SELECT id FROM airline WHERE iata_code='S7'), (SELECT id FROM tour_operator WHERE name='Русский Экспресс')),

('Тур в Афины 6 дней', 'tour', (SELECT id FROM country WHERE code='GR'), 'Москва (MOW)',
 (SELECT id FROM supplier WHERE name='Ostrovok.ru'), 'Исторические достопримечательности',
 (SELECT id FROM airline WHERE iata_code='SU'), (SELECT id FROM tour_operator WHERE name='Mouzenidis Travel'));

INSERT INTO customer_order (created_at, client_id, employee_id, status_id, paid_at, total_amount)
VALUES
('2025-01-10 10:15:00+03', (SELECT id FROM client WHERE login='ivan_i'), (SELECT id FROM employee WHERE login='a_smirnov'), (SELECT id FROM order_status WHERE name='Оплачен полностью'), '2025-01-10 12:00:00+03', 85000.00),
('2025-01-15 14:30:00+03', (SELECT id FROM client WHERE login='annap'), (SELECT id FROM employee WHERE login='al_popov'), (SELECT id FROM order_status WHERE name='Частично оплачен'), NULL, 120000.00),
('2025-01-20 09:45:00+03', (SELECT id FROM client WHERE login='alexs'), (SELECT id FROM employee WHERE login='kat_lebed'), (SELECT id FROM order_status WHERE name='Новый'), NULL, 45000.00),
('2025-02-05 11:20:00+03', (SELECT id FROM client WHERE login='lenak'), (SELECT id FROM employee WHERE login='igor_nov'), (SELECT id FROM order_status WHERE name='Подтверждён менеджером'), NULL, 210000.00),
('2025-02-10 16:00:00+03', (SELECT id FROM client WHERE login='dmorozov'), (SELECT id FROM employee WHERE login='a_smirnov'), (SELECT id FROM order_status WHERE name='Выкуплен у поставщика'), '2025-02-11 10:00:00+03', 67000.00),
('2025-02-18 13:45:00+03', (SELECT id FROM client WHERE login='olga_v'), (SELECT id FROM employee WHERE login='al_popov'), (SELECT id FROM order_status WHERE name='Подтверждён поставщиком'), '2025-02-19 09:30:00+03', 99000.00),
('2025-03-01 12:10:00+03', (SELECT id FROM client WHERE login='paveln'), (SELECT id FROM employee WHERE login='kat_lebed'), (SELECT id FROM order_status WHERE name='Отменён клиентом'), NULL, 0.00),
('2025-03-05 15:30:00+03', (SELECT id FROM client WHERE login='tat_s'), (SELECT id FROM employee WHERE login='igor_nov'), (SELECT id FROM order_status WHERE name='Оплачен полностью'), '2025-03-06 14:20:00+03', 32000.00),
('2025-03-10 10:00:00+03', (SELECT id FROM client WHERE login='artemg'), (SELECT id FROM employee WHERE login='al_popov'), (SELECT id FROM order_status WHERE name='Завершён'), '2025-03-10 18:00:00+03', 183000.00),
('2025-03-15 09:20:00+03', (SELECT id FROM client WHERE login='juliam'), (SELECT id FROM employee WHERE login='a_smirnov'), (SELECT id FROM order_status WHERE name='Ожидает оплаты'), NULL, 56000.00);

INSERT INTO payment (order_id, payment_date, amount, status_id, payment_type_id)
VALUES
((SELECT id FROM customer_order WHERE total_amount=85000), '2025-01-10 12:00:00+03', 85000,
 (SELECT id FROM order_status WHERE name='Оплачен полностью'), (SELECT id FROM payment_type WHERE name='Банковская карта (онлайн)')),

((SELECT id FROM customer_order WHERE total_amount=120000), '2025-01-16 09:00:00+03', 50000,
 (SELECT id FROM order_status WHERE name='Частично оплачен'), (SELECT id FROM payment_type WHERE name='СБП')),

((SELECT id FROM customer_order WHERE total_amount=120000), '2025-02-01 15:45:00+03', 30000,
 (SELECT id FROM order_status WHERE name='Частично оплачен'), (SELECT id FROM payment_type WHERE name='Банковская карта (онлайн)')),

((SELECT id FROM customer_order WHERE total_amount=210000), '2025-02-06 14:00:00+03', 210000,
 (SELECT id FROM order_status WHERE name='Оплачен полностью'), (SELECT id FROM payment_type WHERE name='Безналичный перевод юр. лица')),

((SELECT id FROM customer_order WHERE total_amount=67000), '2025-02-11 10:00:00+03', 67000,
 (SELECT id FROM order_status WHERE name='Оплачен полностью'), (SELECT id FROM payment_type WHERE name='Наличные в офисе')),

((SELECT id FROM customer_order WHERE total_amount=99000), '2025-02-19 09:30:00+03', 99000,
 (SELECT id FROM order_status WHERE name='Оплачен полностью'), (SELECT id FROM payment_type WHERE name='Apple Pay')),

((SELECT id FROM customer_order WHERE total_amount=32000), '2025-03-06 14:20:00+03', 32000,
 (SELECT id FROM order_status WHERE name='Оплачен полностью'), (SELECT id FROM payment_type WHERE name='Google Pay')),

((SELECT id FROM customer_order WHERE total_amount=183000), '2025-03-10 18:00:00+03', 183000,
 (SELECT id FROM order_status WHERE name='Оплачен полностью'), (SELECT id FROM payment_type WHERE name='Криптовалюта')),

((SELECT id FROM customer_order WHERE total_amount=56000), '2025-03-16 11:30:00+03', 25000,
 (SELECT id FROM order_status WHERE name='Частично оплачен'), (SELECT id FROM payment_type WHERE name='Банковская карта (онлайн)')),

((SELECT id FROM customer_order WHERE total_amount=45000), '2025-01-21 10:00:00+03', 45000,
 (SELECT id FROM order_status WHERE name='Оплачен полностью'), (SELECT id FROM payment_type WHERE name='СБП'));


INSERT INTO purchase (order_id, purchase_date, supplier_id, cost_amount)
VALUES
((SELECT id FROM customer_order WHERE total_amount=85000), '2025-01-12 09:00:00+03',
 (SELECT id FROM supplier WHERE name='Travelport GDS'), 72000),

((SELECT id FROM customer_order WHERE total_amount=210000), '2025-02-07 11:00:00+03',
 (SELECT id FROM supplier WHERE name='Amadeus'), 189000),

((SELECT id FROM customer_order WHERE total_amount=67000), '2025-02-12 10:30:00+03',
 (SELECT id FROM supplier WHERE name='Sabre'), 58000),

((SELECT id FROM customer_order WHERE total_amount=99000), '2025-02-20 08:45:00+03',
 (SELECT id FROM supplier WHERE name='Ostrovok.ru'), 87000),

((SELECT id FROM customer_order WHERE total_amount=32000), '2025-03-07 14:00:00+03',
 (SELECT id FROM supplier WHERE name='Travelata'), 28500),

((SELECT id FROM customer_order WHERE total_amount=183000), '2025-03-11 09:30:00+03',
 (SELECT id FROM supplier WHERE name='Amadeus'), 164700),

((SELECT id FROM customer_order WHERE total_amount=120000), '2025-02-02 10:00:00+03',
 (SELECT id FROM supplier WHERE name='Ostrovok.ru'), 105000),

((SELECT id FROM customer_order WHERE total_amount=45000), '2025-01-22 12:00:00+03',
 (SELECT id FROM supplier WHERE name='Travelport GDS'), 38000),

((SELECT id FROM customer_order WHERE total_amount=56000), '2025-03-17 15:00:00+03',
 (SELECT id FROM supplier WHERE name='Sabre'), 49000),

((SELECT id FROM customer_order WHERE total_amount=183000), '2025-03-12 11:20:00+03',
 (SELECT id FROM supplier WHERE name='Интурстрах'), 10000); 


INSERT INTO refund (payment_id, refund_date, amount)
VALUES
((SELECT id FROM payment WHERE amount=50000), '2025-02-20 16:00:00+03', 50000),  
((SELECT id FROM payment WHERE amount=45000), '2025-01-25 14:30:00+03', 45000),  
((SELECT id FROM payment WHERE amount=25000), '2025-03-18 09:00:00+03', 25000);   

INSERT INTO phone (client_id, phone_number) VALUES
((SELECT id FROM client WHERE login='ivan_i'), '+79031234567'),
((SELECT id FROM client WHERE login='ivan_i'), '+74951234567'),
((SELECT id FROM client WHERE login='annap'), '+79501234567'),
((SELECT id FROM client WHERE login='annap'), '+79261234567'),
((SELECT id FROM client WHERE login='alexs'), '+79051234567'),
((SELECT id FROM client WHERE login='lenak'), '+79221234567'),
((SELECT id FROM client WHERE login='lenak'), '+79271234567'),
((SELECT id FROM client WHERE login='dmorozov'), '+79651234567'),
((SELECT id FROM client WHERE login='olga_v'), '+79041234567'),
((SELECT id FROM client WHERE login='paveln'), '+79521234567'),
((SELECT id FROM client WHERE login='tat_s'), '+79231234567'),
((SELECT id FROM client WHERE login='artemg'), '+79061234567'),
((SELECT id FROM client WHERE login='juliam'), '+79511234567'),
((SELECT id FROM client WHERE login='juliam'), '+74951234568'),
((SELECT id FROM client WHERE login='ivan_i'), '+79031234568'),
((SELECT id FROM client WHERE login='annap'), '+79221234568'),
((SELECT id FROM client WHERE login='dmorozov'), '+79651234568'),
((SELECT id FROM client WHERE login='olga_v'), '+79041234568'),
((SELECT id FROM client WHERE login='paveln'), '+79521234568'),
((SELECT id FROM client WHERE login='tat_s'), '+79231234568');


INSERT INTO order_item (service_id, order_id, quantity, price)
VALUES
((SELECT id FROM service WHERE name='Тур в Анталию 7 дней'), (SELECT id FROM customer_order WHERE total_amount=85000), 1, 85000),
((SELECT id FROM service WHERE name='Авиабилеты Москва-Дубай'), (SELECT id FROM customer_order WHERE total_amount=120000), 2, 60000),
((SELECT id FROM service WHERE name='Тур в Хургаду 10 дней'), (SELECT id FROM customer_order WHERE total_amount=45000), 1, 45000),
((SELECT id FROM service WHERE name='Тур на Пхукет 14 дней'), (SELECT id FROM customer_order WHERE total_amount=210000), 1, 210000),
((SELECT id FROM service WHERE name='Авиабилеты СПб-Стамбул'), (SELECT id FROM customer_order WHERE total_amount=67000), 1, 67000),
((SELECT id FROM service WHERE name='Тур в Шарм-эль-Шейх 8 дней'), (SELECT id FROM customer_order WHERE total_amount=99000), 1, 99000),
((SELECT id FROM service WHERE name='Авиабилеты Москва-Бангкок'), (SELECT id FROM customer_order WHERE total_amount=32000), 1, 32000),
((SELECT id FROM service WHERE name='Тур в Рим 5 дней'), (SELECT id FROM customer_order WHERE total_amount=183000), 1, 183000),
((SELECT id FROM service WHERE name='Авиабилеты Барселона-Москва'), (SELECT id FROM customer_order WHERE total_amount=56000), 1, 56000),
((SELECT id FROM service WHERE name='Тур в Афины 6 дней'), (SELECT id FROM customer_order WHERE total_amount=183000), 2, 91500),
((SELECT id FROM service WHERE name='Авиабилеты Москва-Дубай'), (SELECT id FROM customer_order WHERE total_amount=56000), 2, 28000); 


INSERT INTO purchase_item (service_id, purchase_id, quantity, cost_price)
VALUES
((SELECT id FROM service WHERE name='Тур в Анталию 7 дней'), (SELECT id FROM purchase WHERE cost_amount=72000), 1, 72000),
((SELECT id FROM service WHERE name='Авиабилеты Москва-Дубай'), (SELECT id FROM purchase WHERE cost_amount=189000), 2, 94500),
((SELECT id FROM service WHERE name='Тур в Хургаду 10 дней'), (SELECT id FROM purchase WHERE cost_amount=38000), 1, 38000),
((SELECT id FROM service WHERE name='Тур на Пхукет 14 дней'), (SELECT id FROM purchase WHERE cost_amount=189000), 1, 189000),
((SELECT id FROM service WHERE name='Авиабилеты СПб-Стамбул'), (SELECT id FROM purchase WHERE cost_amount=58000), 1, 58000),
((SELECT id FROM service WHERE name='Тур в Шарм-эль-Шейх 8 дней'), (SELECT id FROM purchase WHERE cost_amount=87000), 1, 87000),
((SELECT id FROM service WHERE name='Авиабилеты Москва-Бангкок'), (SELECT id FROM purchase WHERE cost_amount=28500), 1, 28500),
((SELECT id FROM service WHERE name='Тур в Рим 5 дней'), (SELECT id FROM purchase WHERE cost_amount=164700), 1, 164700),
((SELECT id FROM service WHERE name='Авиабилеты Барселона-Москва'), (SELECT id FROM purchase WHERE cost_amount=49000), 1, 49000),
((SELECT id FROM service WHERE name='Тур в Афины 6 дней'), (SELECT id FROM purchase WHERE cost_amount=164700), 2, 82350),
((SELECT id FROM service WHERE name='Тур в Анталию 7 дней'), (SELECT id FROM purchase WHERE cost_amount=105000), 1, 105000),
((SELECT id FROM service WHERE name='Тур в Рим 5 дней'), (SELECT id FROM purchase WHERE cost_amount=10000), 1, 10000);


INSERT INTO service_hotel (service_id, hotel_id) VALUES
((SELECT id FROM service WHERE name='Тур в Анталию 7 дней'), (SELECT id FROM hotel WHERE name='Sunset Beach Resort')),
((SELECT id FROM service WHERE name='Тур на Пхукет 14 дней'), (SELECT id FROM hotel WHERE name='Green Park Resort')),
((SELECT id FROM service WHERE name='Тур в Хургаду 10 дней'), (SELECT id FROM hotel WHERE name='Jaz Aquamarine')),
((SELECT id FROM service WHERE name='Тур в Шарм-эль-Шейх 8 дней'), (SELECT id FROM hotel WHERE name='Simbel Hotel')),
((SELECT id FROM service WHERE name='Тур в Рим 5 дней'), (SELECT id FROM hotel WHERE name='Radisson Blu Hotel Moscow')), 
((SELECT id FROM service WHERE name='Тур в Афины 6 дней'), (SELECT id FROM hotel WHERE name='Divani Apollon Palace')),
((SELECT id FROM service WHERE name='Тур в Анталию 7 дней'), (SELECT id FROM hotel WHERE name='Hilton Istanbul Bosphorus')), 
((SELECT id FROM service WHERE name='Тур на Пхукет 14 дней'), (SELECT id FROM hotel WHERE name='Barcelo Raval')); 




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


INSERT INTO user_logs (user_id, event_data) VALUES
(1, '{"event": "login", "browser": "Chrome", "os": "Windows", "success": true}'),
(2, '{"event": "view_tour", "tour_id": 5, "duration_sec": 120}'),
(1, '{"event": "booking", "tour_id": 5, "amount": 85000, "success": true}'),
(3, '{"event": "login", "browser": "Safari", "os": "iOS", "success": false}'),
(4, '{"event": "view_tour", "tour_id": 2, "duration_sec": 45}'),
(2, '{"event": "booking", "tour_id": 2, "amount": 120000, "success": true}'),
(5, '{"event": "login", "browser": "Firefox", "os": "Linux", "success": true}');

