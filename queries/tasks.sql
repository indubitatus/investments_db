-- 1. Посчитайте, сколько компаний закрылось

SELECT COUNT(id)
FROM company 
WHERE status = 'closed';

-- 2. Отобразите количество привлечённых средств для новостных компаний США. Используйте данные из таблицы company. Отсортируйте таблицу по убыванию значений в поле funding_total

SELECT funding_total
FROM company
WHERE category_code = 'news' AND country_code='USA'
ORDER BY funding_total DESC;

-- 3. Найдите общую сумму сделок по покупке одних компаний другими в долларах. Отберите сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно

SELECT SUM(price_amount)
FROM acquisition
WHERE acquired_at  BETWEEN '2011-01-01' AND '2014-01-01'
      AND term_code = 'cash';

-- 4. Отобразите имя, фамилию и названия аккаунтов людей в поле network_username, у которых названия аккаунтов начинаются на 'Silver'

SELECT first_name,
       last_name,
       twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%';

-- 5. Выведите на экран всю информацию о людях, у которых названия аккаунтов в поле network_username содержат подстроку 'money', а фамилия начинается на 'K'

SELECT *
FROM people
WHERE twitter_username LIKE '%money%' AND last_name LIKE 'K%';

-- 6. Для каждой страны отобразите общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране. Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируйте данные по убыванию суммы

SELECT country_code,
      SUM(funding_total) as sum
FROM company
GROUP BY country_code
ORDER BY sum DESC;

-- 7. Составьте таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату.
-- Оставьте в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению.

SELECT funded_at,
       MIN(raised_amount),
       MAX(raised_amount)
FROM funding_round

GROUP BY funded_at
HAVING MIN(raised_amount) != 0 AND MIN(raised_amount) != MAX(raised_amount);

-- 8. Создайте поле с категориями:
-- Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию high_activity.
-- Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию middle_activity.
-- Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию low_activity.
-- Отобразите все поля таблицы fund и новое поле с категориями.

SELECT  *,
        CASE
            WHEN invested_companies >= 100 THEN 'high_activity'
            WHEN invested_companies < 100 AND invested_companies >= 20 THEN 'middle_activity'
            WHEN invested_companies < 20 THEN 'low_activity'   
        END
FROM fund;

-- 9. Для каждой из категорий, назначенных в предыдущем задании, посчитайте округлённое до ближайшего целого числа среднее количество инвестиционных раундов, в которых фонд принимал участие. Выведите на экран категории и среднее число инвестиционных раундов. Отсортируйте таблицу по возрастанию среднего

SELECT 
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity,
       ROUND(AVG(investment_rounds)) AS r
FROM fund
GROUP BY activity
ORDER BY r;

-- 10. Проанализируйте, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы. 
-- Для каждой страны посчитайте минимальное, максимальное и среднее число компаний, в которые инвестировали фонды этой страны, основанные с 2010 по 2012 год включительно. Исключите страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю. 
-- Выгрузите десять самых активных стран-инвесторов: отсортируйте таблицу по среднему количеству компаний от большего к меньшему. Затем добавьте сортировку по коду страны в лексикографическом порядке.

SELECT country_code, MIN(invested_companies),
       MAX(invested_companies),
       AVG(invested_companies)
FROM fund
WHERE founded_at BETWEEN '2010-01-01' AND '2012-12-31'
GROUP BY country_code
HAVING MIN(invested_companies) != 0 
ORDER BY AVG(invested_companies) DESC, country_code
LIMIT 10;

-- 11. Отобразите имя и фамилию всех сотрудников стартапов. Добавьте поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна.

SELECT first_name, 
       last_name,
       instituition
FROM people AS p
LEFT JOIN education AS ed ON ed.person_id=p.id;

-- 12. Для каждой компании найдите количество учебных заведений, которые окончили её сотрудники. Выведите название компании и число уникальных названий учебных заведений. Составьте топ-5 компаний по количеству университетов.

SELECT c.name,
       COUNT(DISTINCT ed.instituition ) 
FROM company AS c
JOIN people AS p ON c.id=p.company_id
JOIN education AS ed ON ed.person_id=p.id
GROUP BY c.name
ORDER BY COUNT(DISTINCT ed.id) DESC
LIMIT 5;

-- 13. Составьте список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним.

SELECT DISTINCT c.name
FROM company as c
JOIN funding_round AS f ON f.company_id=c.id
WHERE c.status='closed' AND f.is_last_round = 1 AND f.is_first_round  = 1;

-- 14. Составьте список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании.

SELECT DISTINCT p.id
FROM people AS p
WHERE company_id IN (SELECT DISTINCT c.id
                    FROM company as c
                    JOIN funding_round AS f ON f.company_id=c.id
                    WHERE c.status='closed' AND f.is_last_round = 1 AND f.is_first_round  = 1);


-- 15. Составьте таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник.

SELECT DISTINCT p.id as people_id,
       ed.instituition  as ed_id
FROM people as p
JOIN education AS ed ON ed.person_id=p.id
WHERE p.id IN (SELECT DISTINCT p.id
                    FROM people AS p
                    WHERE company_id IN (SELECT DISTINCT c.id
                    FROM company as c
                    JOIN funding_round AS f ON f.company_id=c.id
                    WHERE c.status='closed' AND f.is_last_round = 1 AND f.is_first_round  = 1) );

-- 16. Посчитайте количество учебных заведений для каждого сотрудника из предыдущего задания. При подсчёте учитывайте, что некоторые сотрудники могли окончить одно и то же заведение дважды.

SELECT person_id,
      COUNT(ed.instituition)
FROM education AS ed
WHERE person_id IN (SELECT DISTINCT p.id as people_id FROM people as p
JOIN education AS ed ON ed.person_id=p.id
WHERE p.id IN (SELECT DISTINCT p.id
                    FROM people AS p
                    WHERE company_id IN (SELECT DISTINCT c.id
                    FROM company as c
                    JOIN funding_round AS f ON f.company_id=c.id
                    WHERE c.status='closed' AND f.is_last_round = 1 AND f.is_first_round  = 1) );

)
GROUP BY person_id

-- 17. Дополните предыдущий запрос и выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники разных компаний. Нужно вывести только одну запись, группировка здесь не понадобится.

SELECT AVG(s.count)
FROM (
SELECT person_id,
      COUNT( ed.instituition )
FROM education AS ed
WHERE person_id IN (SELECT DISTINCT p.id as people_id FROM people as p
JOIN education AS ed ON ed.person_id=p.id
WHERE p.id IN (SELECT DISTINCT p.id
                    FROM people AS p
                    WHERE company_id IN (SELECT DISTINCT c.id
                    FROM company as c
                    JOIN funding_round AS f ON f.company_id=c.id
                    WHERE c.status='closed' AND f.is_last_round = 1 AND f.is_first_round  = 1) )

)
GROUP BY person_id) as s;

-- 18. Напишите похожий запрос: выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Facebook

SELECT AVG(s.count)
FROM (
SELECT  person_id,
        COUNT( ed.instituition )
FROM education AS ed
WHERE person_id IN (SELECT DISTINCT p.id as people_id FROM people as p
JOIN education AS ed ON ed.person_id=p.id
WHERE p.id IN (SELECT DISTINCT p.id
                    FROM people AS p
                    WHERE company_id IN (SELECT DISTINCT c.id
                    FROM company as c
                    JOIN funding_round AS f ON f.company_id=c.id
                    WHERE c.name ='Facebook') )

)
GROUP BY person_id) as s;

/* 19. Составьте таблицу из полей:
name_of_fund — название фонда;
name_of_company — название компании;
amount — сумма инвестиций, которую привлекла компания в раунде.
В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно.
*/
  
SELECT f.name, 
       c.name, 
       fr.raised_amount
FROM investment AS inv
JOIN company AS c ON c.id=inv.company_id 
JOIN fund AS f on f.id=inv.fund_id
JOIN funding_round AS fr ON fr.id=inv.funding_round_id 
WHERE (EXTRACT(YEAR FROM funded_at) = 2012 OR  EXTRACT(YEAR FROM funded_at) = 2013)
      AND c.milestones > 6;

/* 20. Выгрузите таблицу, в которой будут такие поля:
название компании-покупателя;
сумма сделки;
название компании, которую купили;
сумма инвестиций, вложенных в купленную компанию;
доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.
Не учитывайте те сделки, в которых сумма покупки равна нулю. Если сумма инвестиций в компанию равна нулю, исключите такую компанию из таблицы. 
Отсортируйте таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в лексикографическом порядке. Ограничьте таблицу первыми десятью записями.
*/ 

SELECT ing.name, 
       a.price_amount,
       ed.name AS purch, 
       ed.funding_total,
       ROUND(a.price_amount / ed.funding_total)
FROM acquisition AS a
LEFT JOIN company AS ing ON ing.id=a.acquiring_company_id 
LEFT JOIN company AS ed ON ed.id=a.acquired_company_id
WHERE a.price_amount != 0 AND
      ed.funding_total != 0
ORDER BY a.price_amount DESC, ed.name
LIMIT 10;

-- 21. Выгрузите таблицу, в которую войдут названия компаний из категории social, получившие финансирование с 2010 по 2013 год включительно. Проверьте, что сумма инвестиций не равна нулю. Выведите также номер месяца, в котором проходил раунд финансирования.

SELECT c.name, 
       EXTRACT(MONTH FROM funded_at)
FROM company AS c
JOIN funding_round AS f ON f.company_id=c.id
WHERE c.category_code = 'social'
      AND f.funded_at BETWEEN '2010-01-01' AND '2013-12-31'
      AND f.raised_amount != 0;

/* 
22. Отберите данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. Сгруппируйте данные по номеру месяца и получите таблицу, в которой будут поля:
номер месяца, в котором проходили раунды;
количество уникальных названий фондов из США, которые инвестировали в этом месяце;
количество компаний, купленных за этот месяц;
общая сумма сделок по покупкам в этом месяце.
*/

WITH a AS
(SELECT EXTRACT(MONTH FROM f.funded_at) AS month, 
        COUNT(DISTINCT fu.name) AS f_cnt
 FROM funding_round AS f
 JOIN investment AS inv ON inv.funding_round_id = f.id
 JOIN fund AS fu ON fu.id = inv.fund_id 
WHERE f.funded_at BETWEEN '2010-01-01' AND '2013-12-31'
 AND fu.country_code = 'USA'
 GROUP BY month
)

SELECT a.month,
       a.f_cnt,
       comp.comp_cnt,
       comp.comp_sum
FROM a
JOIN (SELECT EXTRACT(MONTH FROM acquired_at ) AS comp_month,
        COUNT(acquired_company_id ) AS comp_cnt,
        SUM(price_amount) AS comp_sum
FROM acquisition
      WHERE acquired_at BETWEEN '2010-01-01' AND '2013-12-31'
GROUP BY comp_month) AS comp ON comp.comp_month = a.month;

-- 23. Составьте сводную таблицу и выведите среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. Данные за каждый год должны быть в отдельном поле. Отсортируйте таблицу по среднему значению инвестиций за 2011 год от большего к меньшему.

WITH 
i AS (SELECT AVG(funding_total) as sum_total_2011,
            country_code as c_2011
     FROM company 
     WHERE EXTRACT(YEAR FROM founded_at) = 2011
     GROUP BY country_code), 
j AS (SELECT AVG(funding_total) as sum_total_2012,
            country_code as c_2012
     FROM company 
     WHERE EXTRACT(YEAR FROM founded_at) = 2012
     GROUP BY country_code), 
     
k AS (SELECT AVG(funding_total) as sum_total_2013,
      country_code as c_2013
     FROM company 
     WHERE EXTRACT(YEAR FROM founded_at) = 2013
     GROUP BY country_code)

SELECT c_2011,
       sum_total_2011,
       sum_total_2012,
       sum_total_2013
FROM i 
INNER JOIN j ON i.c_2011=j.c_2012
INNER JOIN k ON k.c_2013=i.c_2011
ORDER BY sum_total_2011 DESC

