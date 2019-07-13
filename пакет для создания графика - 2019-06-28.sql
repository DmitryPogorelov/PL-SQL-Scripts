/********************************************************************************
             ---Пакет написан Погореловым Дмитрием Николаевичем---
*********************************************************************************/
CREATE OR REPLACE PACKAGE make_schedule
AUTHID CURRENT_USER
AS

--Тип для хранения графиков работы--
TYPE work_sched_type IS RECORD (
work_days employees.work_days%TYPE,
holidays  employees.holidays%TYPE
);

--Тип для строки итогового расписания
TYPE sched_row_t IS TABLE OF VARCHAR2(10);

--Тип для всей строки, включая название должности
TYPE header_plus_sched_row_t IS RECORD (
position employees.position%TYPE,
schedule sched_row_t
);

--Тип для всего расписания
TYPE whole_schedule_t IS TABLE OF header_plus_sched_row_t;

--Константы--
g_date_format CONSTANT VARCHAR2(10) := 'DD.MM.YYYY'; --Формат для разбора даты
g_min_month   CONSTANT NUMBER(2) := 1; --Минимальное значение месяца для проверки
g_max_month   CONSTANT NUMBER(2) := 12; --Максимальное значение месяца для проерки
g_min_year    CONSTANT NUMBER(4) := 2000; --Минимальное значение года для проверки. Почему 2000? Не знаю, но ограничение нужно!
g_max_year    CONSTANT NUMBER(4) := 9999; --Максимальное значение года для проверки. Почему 9999? Все переменные, которые работают
--с годом, заданы четырехзначными числами.
g_dir_work        CONSTANT NUMBER(1) := 5; --Количество рабочих дней директора и зама
g_dir_holidays    CONSTANT NUMBER(1) := 2; --Количество выходных дней директора и зама
g_seller_work     CONSTANT NUMBER(1) := 2; --Количество рабочих дней продавца
g_seller_holidays CONSTANT NUMBER(1) := 2; --Количество выходных дней продавца

--Глобальные переменные--
g_month                NUMBER(2) DEFAULT EXTRACT(MONTH FROM SYSDATE); --Здесь храним номер месяца для расчета
g_days_in_month        NUMBER(2); --Здесь храним количество дней в заданном месяце
g_year                 NUMBER(4) DEFAULT EXTRACT(YEAR FROM SYSDATE); --Здесь храним номер года для расчета
-- (по умолчанию - текущий год)
g_init_date            DATE; --Здесь храним первое число расчетного месяца в виде даты

--Переменные для хранения вариантов рабочих графиков
g_work_5_2 work_sched_type;
g_work_2_2 work_sched_type;

--Курсор для выборки сотрудников с определенным режимом работы
CURSOR employee_workdays_cur (
p_work_days  IN employees.work_days%TYPE,
p_holidays   IN employees.holidays%TYPE
)
IS
SELECT emp.emp_id, emp.workdays_list
FROM employees emp 
WHERE emp.work_days = p_work_days
AND emp.holidays = p_holidays
ORDER BY emp_id ASC;

--Стартовая процедура для формирования расписания--
PROCEDURE make_new_schedule (
month_sched_in              IN         NUMBER,
year_sched_in               IN         NUMBER DEFAULT EXTRACT(YEAR FROM SYSDATE)
);

--Процедура для формирования графика 5/2--
PROCEDURE five_to_two_schedule;

--Новая процедура для графика 5/2 с BULK COllect
PROCEDURE new_five_to_two_schedule;

--Процедура для формирования графика 2/2--
PROCEDURE two_to_two_schedule;

--Функция проеряет, есть ли для заданного сотруника уже расписание на заданный месяц и год
FUNCTION work_schedule_exists (
emp_id_in IN employees.emp_id%TYPE,
month_in  IN make_schedule.g_month%TYPE,
year_in   IN make_schedule.g_year%TYPE
) 
RETURN BOOLEAN;

--Функция упаковывает расписание во вложенную таблицу и возвращает ее 
FUNCTION give_me_a_schedule
RETURN whole_schedule_t;

/************************************************************************************
Процедуры для второго алгоритма
************************************************************************************/
PROCEDURE sched_second_algorythm; 
 
END make_schedule;
