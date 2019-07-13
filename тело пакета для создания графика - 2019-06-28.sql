/********************************************************************************
             ---Пакет написан Погореловым Дмитрием Николаевичем---
*********************************************************************************/

CREATE OR REPLACE PACKAGE BODY make_schedule 
AS
/*******************************************************************************
Основная процедура. Чтобы получить расписание, запускаем только еЁ!!!
******************************************************************************/
PROCEDURE make_new_schedule (
month_sched_in              IN         NUMBER,
year_sched_in               IN         NUMBER DEFAULT EXTRACT(YEAR FROM SYSDATE)
)
IS
    v_varchar2_g_month VARCHAR2(2);
    v_varchar2_g_year VARCHAR2(4);
    v_date VARCHAR2(10);
  
    not_valid_month EXCEPTION;
    not_valid_year  EXCEPTION;
  
BEGIN
    --Проверяем введенный месяц. Если значение выходит за границы, то вызываем исключение
    IF month_sched_in < make_schedule.g_min_month OR month_sched_in > make_schedule.g_max_month THEN
        RAISE not_valid_month;     
    END IF;
    --Проверяем введенный год. Если значение выходит за границы, то вызываем исключение
    IF year_sched_in < make_schedule.g_min_year OR year_sched_in > make_schedule.g_max_year THEN
        RAISE not_valid_year;
    END IF;

    --Заносим параметры вызова в глобальные переменные пакета
    make_schedule.g_month := month_sched_in;
    make_schedule.g_year := year_sched_in;
    --Делаем явное преобразование типов для формирования ДАТЫ с первым днём месяца
    v_varchar2_g_month := LTRIM(TO_CHAR(make_schedule.g_month, '09'), ' ');
    v_varchar2_g_year := LTRIM(TO_CHAR(make_schedule.g_year, '9999'), ' ');
    --Собственно формируем дату для вычисления количества дней в месяце
    v_date := '01.' || v_varchar2_g_month || '.' || v_varchar2_g_year;
    --Сохраняем первое число месяца в виде даты в глобальную переменную пакета
    make_schedule.g_init_date := TO_DATE(v_date, make_schedule.g_date_format);
    --Сохраняем количество дней в месяце в глобальную переменную пакета
    make_schedule.g_days_in_month := EXTRACT(DAY FROM LAST_DAY(make_schedule.g_init_date));
    --Задаем параметры рабочего расписания 5/2
    make_schedule.g_work_5_2.work_days := make_schedule.g_dir_work;
    make_schedule.g_work_5_2.holidays  := make_schedule.g_dir_holidays;
    --Задаем параметры рабочего расписания 2/2
    make_schedule.g_work_2_2.work_days := make_schedule.g_seller_work;
    make_schedule.g_work_2_2.holidays  := make_schedule.g_seller_holidays;
    --Вызываем функцию, которая формирует распиание для сотрудников с пятидневкой 5/2
    make_schedule.five_to_two_schedule();
    make_schedule.new_five_to_two_schedule();
    --Считаем расписание для сотрудников 2/2
    --make_schedule.two_to_two_schedule();
    make_schedule.sched_second_algorythm();
  
EXCEPTION
    WHEN not_valid_month THEN
        RAISE_APPLICATION_ERROR(-20005, 'Wrong month! Month should be between 1 and 12!');
    WHEN not_valid_year THEN 
        RAISE_APPLICATION_ERROR(-20006, 'Wrong year! Year should be between 2000 and 9999!');
    WHEN OTHERS THEN
        RAISE;
END make_new_schedule;
/***********************************************************************************************
--Процедура для формирования графика 5/2--
***********************************************************************************************/
PROCEDURE five_to_two_schedule
IS

    v_worker employee_workdays_cur%ROWTYPE;
    v_curr_date DATE;
  
    v_day_of_week NUMBER;
    v_working_days_coll week_work_days_t;
  
BEGIN
    --Проверяес состояние курсора, если он открыт - то закрываем--
    IF employee_workdays_cur%ISOPEN THEN 
        CLOSE employee_workdays_cur; 
    END IF;
    --Открываем курсор для выборки сотрудников с режимом работы 5/2
    OPEN employee_workdays_cur (g_work_5_2.work_days, g_work_5_2.holidays);
  
    LOOP
         
        FETCH employee_workdays_cur INTO v_worker;
        --Если все записи из курсора выбраны, то выходим из цикла
        IF employee_workdays_cur%NOTFOUND THEN
            EXIT;
        END IF;
         
        --Если график для текущего сотрудника для данного месяца уже существует, то пропускаем сотрудника
        IF make_schedule.work_schedule_exists(emp_id_in => v_worker.emp_id,
                                              month_in =>  make_schedule.g_month,
                                              year_in =>   make_schedule.g_year) THEN
            CONTINUE;
        END IF;      
         
        --Выбираем график работы в переменную с типом коллекции
        v_working_days_coll := v_worker.workdays_list;
         
        --Запускаем цикл для добавления рабочих дней в график
        FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
            --Вычисляем текущую дату (-1 нужен, т.к. счетчик цикла начинается с единицы)
            v_curr_date :=  make_schedule.g_init_date - 1 + day_counter;
            --Вычилсяем, каким днём недели была текущая дата
            v_day_of_week := (1 + TRUNC (v_curr_date) - TRUNC (v_curr_date, 'IW'));
           
            --Проверяем, есть ли этот день недели в списке рабочих дней для данного сотрудника
            --Если есть, то добавляем строчку с графиком в таблицу графиков работы
            FOR coll_counter IN 1..v_working_days_coll.COUNT LOOP
                IF v_day_of_week = v_worker.workdays_list(coll_counter) THEN
                    INSERT INTO work_schedule 
                        VALUES (
                               work_schedule_seq.NEXTVAL, 
                               v_curr_date, 
                               day_counter, 
                               make_schedule.g_month, 
                               make_schedule.g_year, 
                               v_worker.emp_id, 
                               'Y',
                               NULL
                               );
                    EXIT;
                END IF;
            END LOOP;
           
        END LOOP;
        --Сохраняем график для данного сотрудника
        COMMIT;
    END LOOP;
    --Закрываем курсор--
    IF employee_workdays_cur%ISOPEN THEN
        CLOSE employee_workdays_cur;
    END IF;
  
EXCEPTION
    WHEN OTHERS THEN --Закрываем курсор при ошибках
        IF employee_workdays_cur%ISOPEN THEN
            CLOSE employee_workdays_cur;
        END IF;
        --Откатываем изменения в графике для сотрудника, если возникла ошибка
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20007, 'Unhandled exception in procedure make_schedule.five_to_two_schedule!!!');
END five_to_two_schedule;

/***********************************************************************************
--Новая процедура для графика 5/2 с BULK COllect
**************************************************************************************/
PROCEDURE new_five_to_two_schedule
IS

    v_worker employee_workdays_cur%ROWTYPE;
    TYPE v_all_workers_t IS TABLE OF employee_workdays_cur%ROWTYPE;
    v_all_workers_c v_all_workers_t; --Переменная с типом коллекции для складирования данных о сотрудниках
    v_curr_date DATE;
  
    v_day_of_week NUMBER;
    v_working_days_coll week_work_days_t;
  
BEGIN
    --Проверяес состояние курсора, если он открыт - то закрываем--
    IF employee_workdays_cur%ISOPEN THEN 
        CLOSE employee_workdays_cur; 
    END IF;
    --Открываем курсор для выборки сотрудников с режимом работы 5/2
    OPEN employee_workdays_cur (g_work_5_2.work_days, g_work_5_2.holidays);
  
    FETCH employee_workdays_cur BULK COLLECT INTO v_all_workers_c;

    --Закрываем курсор--
    IF employee_workdays_cur%ISOPEN THEN
        CLOSE employee_workdays_cur;
    END IF;
    
    FOR curr_emp IN 1..v_all_workers_c.COUNT LOOP
        --Если график для текущего сотрудника для данного месяца уже существует, то пропускаем сотрудника
        IF make_schedule.work_schedule_exists(emp_id_in => v_all_workers_c(curr_emp).emp_id,
                                              month_in =>  make_schedule.g_month,
                                              year_in =>   make_schedule.g_year) THEN
            CONTINUE;
        END IF;
        
        --Выбираем график работы в переменную с типом коллекции
        v_working_days_coll := v_all_workers_c(curr_emp).workdays_list;
         
        --Запускаем цикл для добавления рабочих дней в график
        FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
            --Вычисляем текущую дату (-1 нужен, т.к. счетчик цикла начинается с единицы)
            v_curr_date :=  make_schedule.g_init_date - 1 + day_counter;
            --Вычилсяем, каким днём недели была текущая дата
            v_day_of_week := (1 + TRUNC (v_curr_date) - TRUNC (v_curr_date, 'IW'));
           
            --Проверяем, есть ли этот день недели в списке рабочих дней для данного сотрудника
            --Если есть, то добавляем строчку с графиком в таблицу графиков работы
            FOR coll_counter IN 1..v_working_days_coll.COUNT LOOP
                IF v_day_of_week = v_all_workers_c(curr_emp).workdays_list(coll_counter) THEN
                    INSERT INTO work_schedule 
                        VALUES (
                               work_schedule_seq.NEXTVAL, 
                               v_curr_date, 
                               day_counter, 
                               make_schedule.g_month, 
                               make_schedule.g_year, 
                               v_all_workers_c(curr_emp).emp_id, 
                               'Y',
                               NULL
                               );
                    EXIT;
                END IF;
            END LOOP;
           
        END LOOP;
        --Сохраняем график для данного сотрудника
        COMMIT;
        
    END LOOP;
  
EXCEPTION
    WHEN OTHERS THEN --Закрываем курсор при ошибках
        IF employee_workdays_cur%ISOPEN THEN
            CLOSE employee_workdays_cur;
        END IF;
        --Откатываем изменения в графике для сотрудника, если возникла ошибка
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20011, 'Unhandled exception in procedure make_schedule.new_five_to_two_schedule!!!');

END new_five_to_two_schedule;

/***********************************************************************************
--Процедура для формирования графика 2/2--
************************************************************************************/
PROCEDURE two_to_two_schedule
IS
    
    v_worker                 employee_workdays_cur%ROWTYPE;
    v_curr_date              DATE;
    v_frame                  NUMBER(3) := make_schedule.g_work_2_2.work_days + make_schedule.g_work_2_2.holidays;
    v_curr_emp               NUMBER(3) := 0;
    
    v_move                   NUMBER(3) := 0;
    v_day                    NUMBER(3) := 0;
    
    c_first_seller           CONSTANT NUMBER(1) := 1;
    c_second_seller          CONSTANT NUMBER(1) := 2;
    c_third_seller           CONSTANT NUMBER(1) := 3;
    c_fourth_seller          CONSTANT NUMBER(1) := 4;
    
    --Курсор для поиска последнего запланированного дня работы
    --Этот курсор используется для того, чтобы графики двух последовательных месяцев создавались корректно
    CURSOR last_work_date (
        p_emp_id IN employees.emp_id%TYPE, 
        p_month  IN make_schedule.g_month%TYPE, 
        p_year   IN make_schedule.g_year%TYPE
        )
        IS
        select work_date from (
        select ws.work_date
        FROM work_schedule ws
        WHERE ws.emp_id = p_emp_id
        AND ws.month_num = p_month
        AND ws.year_num = p_year
        ORDER BY ws.work_date DESC)
        WHERE ROWNUM < 3;
        
    --Переменная для выборки данных из курсора last_work_date
    v_previous_month_date           last_work_date%ROWTYPE;
    
    v_previous_date_last            DATE;
    v_previous_date_last_minus_one  DATE;
    
    v_previous_month                make_schedule.g_month%TYPE;
    v_previous_year                 make_schedule.g_year%TYPE;
    
    v_previous_month_found          BOOLEAN := FALSE;
    v_day_fits                      BOOLEAN := FALSE;
    
BEGIN
    --Проверяес состояние курсора, если он открыт - то закрываем--
    IF employee_workdays_cur%ISOPEN THEN 
        CLOSE employee_workdays_cur; 
    END IF;
    --Открываем курсор для выборки сотрудников с режимом работы 2/2
    OPEN employee_workdays_cur (g_work_2_2.work_days, g_work_2_2.holidays);
        LOOP
            FETCH employee_workdays_cur INTO v_worker;
            --Если все записи из курсора выбраны, то выходим из цикла
            IF employee_workdays_cur%NOTFOUND THEN
                EXIT;
            END IF;
         
            --Если график для текущего сотрудника для данного месяца уже существует, то пропускаем сотрудника
            IF make_schedule.work_schedule_exists(emp_id_in => v_worker.emp_id,
                                                  month_in =>  make_schedule.g_month,
                                                  year_in =>   make_schedule.g_year) THEN
                                 
                CONTINUE;
            END IF; 

            --Находим месяц и год предыдущего месяца--
            v_previous_month := EXTRACT(MONTH FROM (g_init_date - 1));
            v_previous_year  := EXTRACT(YEAR FROM (g_init_date - 1));

            --Проверяем, есть ли график за предыдущий месяц
            IF last_work_date%ISOPEN THEN
                CLOSE last_work_date;
            END IF;
            --Ищем, есть ли расписание на предыдущий месяц, чтобы взять его за точку отсчета            
            OPEN last_work_date (v_worker.emp_id, v_previous_month, v_previous_year);
            FETCH last_work_date INTO v_previous_month_date;
            IF last_work_date%FOUND THEN 
              v_previous_date_last := v_previous_month_date.work_date;
              FETCH last_work_date INTO v_previous_month_date;
              IF last_work_date%FOUND THEN
                  v_previous_date_last_minus_one := v_previous_month_date.work_date;
                  v_previous_month_found := TRUE;
              END IF;
            END IF;
            --Закрываем курсор--
            IF last_work_date%ISOPEN THEN
                CLOSE last_work_date;
            END IF;
            
            --Вычисляем отсутп с учетом предыдущего месяца
            IF (g_init_date - v_previous_date_last) > 2 THEN
                v_curr_emp := c_first_seller - 1;
            ELSIF (g_init_date - v_previous_date_last) > 1 THEN
                v_curr_emp := c_second_seller - 1;
            ELSIF (g_init_date - v_previous_date_last) = 1 AND (g_init_date - v_previous_date_last_minus_one) = 2 THEN
                v_curr_emp := c_third_seller - 1;
            ELSE
                v_curr_emp := - 1;
            END IF;
            --Если расписания в предыдущем месяце нет, то создаем расписание с чистого листа
            IF NOT v_previous_month_found THEN
                --Вычисляем смещение в днях для графика
                v_move := MOD(employee_workdays_cur%ROWCOUNT, v_frame);
                IF v_move = c_second_seller THEN 
                    v_curr_emp := c_second_seller - 1;
                ELSIF v_move = c_third_seller THEN 
                    v_curr_emp := c_third_seller - 1;
                ELSIF v_move = c_fourth_seller THEN 
                    v_curr_emp := c_fourth_seller - 1;
                ELSE 
                    v_curr_emp := c_first_seller - 1;
                END IF;         
            END IF;
            --Запускаем цикл для формирования расписания
            FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
                --Вычисляем текущую дату (-1 нужен, т.к. счетчик цикла начинается с единицы)
                v_curr_date :=  make_schedule.g_init_date - 1 + day_counter;
                --Для рабочих дней добавляем рабочий день в таблицу. Считаем, что рабочие дни идут первыми
                v_day := MOD(day_counter - v_curr_emp, v_frame);
                v_day_fits := FALSE;
                FOR inner_i IN 1..make_schedule.g_work_2_2.work_days LOOP
                    IF v_day = inner_i THEN
                        v_day_fits := TRUE;
                        EXIT;
                    END IF;
                END LOOP;
                
                --Если день подходит для графика - добавляем его в табличку
                IF v_day_fits THEN
                  
                    INSERT INTO work_schedule VALUES (
                             work_schedule_seq.NEXTVAL, 
                             v_curr_date, 
                             day_counter, 
                             make_schedule.g_month, 
                             make_schedule.g_year, 
                             v_worker.emp_id, 
                             'Y',
                             NULL
                             );
                  
                END IF;
            END LOOP;
            --Сохраняем график для данного сотрудника
            COMMIT;
        --Конец цикла по сторудникам
        END LOOP;
    --Закрываем курсор--
    IF employee_workdays_cur%ISOPEN THEN
       CLOSE employee_workdays_cur;
    END IF;
  
EXCEPTION
    WHEN OTHERS THEN 
        --Закрываем курсор при ошибках
        IF employee_workdays_cur%ISOPEN THEN
            CLOSE employee_workdays_cur;
        END IF;
        --Закрываем курсор при ошибках
        IF last_work_date%ISOPEN THEN
            CLOSE last_work_date;
        END IF;
        --Откатываем изменения в графике для сотрудника, если возникла ошибка
        ROLLBACK;
        
        RAISE_APPLICATION_ERROR(-20008, 'Unhandled exception in procedure make_schedule.two_to_two_schedule!!!');
END two_to_two_schedule;
/******************************************************************************************
--Функция проверяет, есть ли для заданного сотруника уже расписание на заданный месяц и год
********************************************************************************************/
FUNCTION work_schedule_exists (
emp_id_in IN employees.emp_id%TYPE,
month_in  IN make_schedule.g_month%TYPE,
year_in   IN make_schedule.g_year%TYPE
) 
RETURN BOOLEAN
IS

    CURSOR any_work_rec_cur (
        p_emp_id IN employees.emp_id%TYPE, 
        p_month  IN make_schedule.g_month%TYPE, 
        p_year   IN make_schedule.g_year%TYPE
        ) 
    IS
        SELECT count(ws.sched_id) AS cnt
        FROM work_schedule ws
        WHERE ws.emp_id = p_emp_id
        AND ws.month_num = p_month
        AND ws.year_num = p_year;

    v_return_value BOOLEAN DEFAULT FALSE;
    v_cnt any_work_rec_cur%ROWTYPE;

BEGIN
    --Проверяес состояние курсора, если он открыт - то закрываем--
    IF any_work_rec_cur%ISOPEN THEN 
        CLOSE any_work_rec_cur; 
    END IF;  

    --Открываем курсор и проверяем количество строк--
    OPEN any_work_rec_cur(emp_id_in, month_in, year_in);
    FETCH any_work_rec_cur INTO v_cnt;
     --Проверяес состояние курсора, если он открыт - то закрываем--
    IF any_work_rec_cur%ISOPEN THEN 
        CLOSE any_work_rec_cur; 
    END IF;
    --Проверяем количество записей. Если больше нуля, то возвращаем TRUE
    IF v_cnt.cnt > 0 THEN
        v_return_value := TRUE;
    END IF;
    --Возвращаем ответ о наличии расписания на текущий месяц
    RETURN v_return_value;
EXCEPTION
    WHEN OTHERS THEN
        --Проверяес состояние курсора, если он открыт - то закрываем--
        IF any_work_rec_cur%ISOPEN THEN 
            CLOSE any_work_rec_cur; 
        END IF;  
      
        RAISE_APPLICATION_ERROR(-20009, 'Unhandled exception in FUNCTION make_schedule.work_schedule_exists!!!');
        RETURN FALSE;
END work_schedule_exists;
/************************************************************************
--Функция упаковывает расписание во вложенную таблицу и возвращает ее 
***********************************************************************/
FUNCTION give_me_a_schedule
RETURN whole_schedule_t
IS
    --Курсор для выбора расписания по указанному сотруднику
    CURSOR schedule_row_cur (
        emp_id_cur_in IN work_schedule.emp_id%TYPE,
        month_cur_in  IN work_schedule.month_num%TYPE,
        year_cur_in   IN work_schedule.year_num%TYPE
        )
        IS
        SELECT ws.day_num, ws.is_working
        FROM work_schedule ws
        WHERE ws.emp_id = emp_id_cur_in
        AND ws.month_num = month_cur_in
        AND ws.year_num = year_cur_in
        ORDER BY ws.day_num ASC;
    --Запись для выборки данных о расписании
    v_sched_rec schedule_row_cur%ROWTYPE;

    --Курсор для выборки сотрудников с названиями должностей
    CURSOR employees_list_cur 
    IS
    SELECT emp.emp_id, emp.position
    FROM employees emp
    ORDER BY emp.work_days DESC, emp.emp_id ASC, emp.position ASC;

    --Запись для данных о сотруднике
    v_loc_worker employees_list_cur%ROWTYPE;

    --Строка расписания
    v_sched_row sched_row_t := sched_row_t();

    --Расписание складываем в эту переменную
    v_return_sched whole_schedule_t := whole_schedule_t();

BEGIN
    --Добавляем заголовок в расписание
    v_return_sched.EXTEND(1);
    v_return_sched(v_return_sched.LAST).position := TO_CHAR(g_init_date, 'MM.YYYY');
    
    FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
        v_sched_row.EXTEND(1);
        v_sched_row(v_sched_row.LAST) := TO_CHAR((TO_DATE(g_init_date + day_counter - 1)), 'DY');
    END LOOP;
    
    v_return_sched(v_return_sched.LAST).schedule := v_sched_row;
    
    --Добавляем слова Position и числа месяца
    v_return_sched.EXTEND(1);
    v_return_sched(v_return_sched.LAST).position := 'Position';
    
    FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
        v_sched_row(day_counter) := TO_CHAR(day_counter);
    END LOOP;
    
    v_return_sched(v_return_sched.LAST).schedule := v_sched_row;
    
    --Добавляем в расписание строки для сотрудников
    --Проверяем состояние курсора, если он открыт - то закрываем--
    IF employees_list_cur%ISOPEN THEN 
        CLOSE employees_list_cur; 
    END IF;
    --Открываем курсор для выборки сотрудников
    OPEN employees_list_cur;
    LOOP
        FETCH employees_list_cur INTO v_loc_worker;
        --Если все записи из курсора выбраны, то выходим из цикла
        IF employees_list_cur%NOTFOUND THEN
            EXIT;
        END IF;
        --Добавляем строку о сотруднике в расписание
        v_return_sched.EXTEND(1);
        v_return_sched(v_return_sched.LAST).position := v_loc_worker.position;
        
        --Очищаем запись перед ее использованием
        FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
            v_sched_row(day_counter) := ' ';
        END LOOP;
        
        --Выбираем данные из таблицы расписания о данном сотруднике
        IF schedule_row_cur%ISOPEN THEN 
            CLOSE schedule_row_cur; 
        END IF;
        OPEN schedule_row_cur (v_loc_worker.emp_id, make_schedule.g_month, make_schedule.g_year);
        LOOP
          
            FETCH schedule_row_cur INTO v_sched_rec;
            --Если все записи из курсора выбраны, то выходим из цикла
            IF schedule_row_cur%NOTFOUND THEN
                EXIT;
            END IF;
            --В нужные ячейки проставляем признак рабочего дня
            v_sched_row(v_sched_rec.day_num) := v_sched_rec.is_working;
             
        END LOOP;
        --Сохраняем строчку с расписание в итоговую коллекцию
        v_return_sched(v_return_sched.LAST).schedule := v_sched_row;
        --Проверяем статус и закрываем курсор
        IF schedule_row_cur%ISOPEN THEN 
            CLOSE schedule_row_cur; 
        END IF;
        
    END LOOP;
    --Проверяем статус и закрываем курсор
    IF employees_list_cur%ISOPEN THEN 
        CLOSE employees_list_cur; 
    END IF;
    --Возвращаем расписание вызывающему скрипту
    RETURN v_return_sched;

EXCEPTION
    WHEN OTHERS THEN
    --Закрываем все курсоры, которые могут быть открыты  
    IF employees_list_cur%ISOPEN THEN 
        CLOSE employees_list_cur; 
    END IF;
    IF schedule_row_cur%ISOPEN THEN 
        CLOSE schedule_row_cur; 
    END IF;
    
    RAISE_APPLICATION_ERROR(-20010, 'Unhandled exception in FUNCTION make_schedule.give_me_a_schedule!!!');

END give_me_a_schedule;

/************************************************************************************
Процедуры для второго алгоритма
************************************************************************************/
PROCEDURE sched_second_algorythm
IS

CURSOR get_employees_cur IS --Этот курсор выбирает сотрудников с указанной формулой рабочих/выходных дней
    select ey.emp_id 
    from employees ey
    where ey.work_days = make_schedule.g_work_2_2.work_days
    and ey.holidays = make_schedule.g_work_2_2.holidays
    ORDER BY ey.emp_id ASC;

v_get_employees get_employees_cur%ROWTYPE;

--Курсор находит максимальное окончание недели в первом фрейме   
CURSOR get_firstweekend_cur (
    p_month  IN make_schedule.g_month%TYPE, 
    p_year   IN make_schedule.g_year%TYPE,
    p_frame  IN make_schedule.g_year%TYPE
)
IS
    select MAX(work_date) AS end_date 
    FROM work_schedule ws
    WHERE ws.month_num = p_month
    AND ws.year_num = p_year
    AND ws.frame_mark = 'E'
    AND ws.day_num >= 1 
    AND ws.day_num <= p_frame
    AND ws.emp_id IN (
        SELECT emp_id 
        FROM employees e 
        WHERE e.work_days = make_schedule.g_work_2_2.work_days 
        AND e.holidays = make_schedule.g_work_2_2.holidays);
    
v_endweek get_firstweekend_cur%ROWTYPE;
    
--Курсор находит количество дней без продавцов в первом фрейме
CURSOR get_zerosellers_cur (
    p_month  IN make_schedule.g_month%TYPE, 
    p_year   IN make_schedule.g_year%TYPE,
    p_frame  IN make_schedule.g_year%TYPE    
)
IS
SELECT count(distinct(work_date)) AS cnt_outer 
    FROM work_schedule ws
    WHERE ws.month_num = p_month
    AND ws.year_num = p_year
    AND ws.day_num >= 1 
    AND ws.day_num <= p_frame
    AND ws.emp_id IN (
        SELECT emp_id 
        FROM employees e 
        WHERE e.work_days = make_schedule.g_work_2_2.work_days 
        AND e.holidays = make_schedule.g_work_2_2.holidays);
    
v_zerosellers get_zerosellers_cur%ROWTYPE;

--Курсор находит минимальное количество сотрудников, которые работают в дни первого фрейма
CURSOR get_min_emp_cur (
    p_month  IN make_schedule.g_month%TYPE, 
    p_year   IN make_schedule.g_year%TYPE,
    p_frame  IN make_schedule.g_year%TYPE
)
IS
select emp_each_day, count(*) AS cnt_outer 
from (
select count(*) AS emp_each_day, work_date AS end_date 
    FROM work_schedule ws
    WHERE ws.month_num = p_month
    AND ws.year_num = p_year
    AND ws.day_num >= 1 
    AND ws.day_num <= p_frame
    AND ws.emp_id IN (
        SELECT emp_id 
        FROM employees e 
        WHERE e.work_days = make_schedule.g_work_2_2.work_days 
        AND e.holidays = make_schedule.g_work_2_2.holidays)
    GROUP BY work_date) GROUP BY emp_each_day ORDER BY emp_each_day ASC;
    
v_get_min_emp get_min_emp_cur%ROWTYPE;

--Курсор выбирает минимальную дату в первом фрейме, когда работает меньше всего народу
CURSOR get_min_emp_date_cur (
    p_month                 IN make_schedule.g_month%TYPE, 
    p_year                  IN make_schedule.g_year%TYPE,
    p_frame                 IN make_schedule.g_year%TYPE,
    p_min_emp               IN make_schedule.g_year%TYPE
)
IS
select work_date AS use_date 
FROM (
    select count(*) AS emp_each_day, work_date
    FROM work_schedule ws
    WHERE ws.month_num = p_month
    AND ws.year_num = p_year
    AND ws.day_num >= 1 
    AND ws.day_num <= p_frame  
    AND ws.emp_id IN (
        SELECT emp_id 
        FROM employees e 
        WHERE e.work_days = make_schedule.g_work_2_2.work_days 
        AND e.holidays = make_schedule.g_work_2_2.holidays) 
    GROUP BY work_date
    )
WHERE emp_each_day = p_min_emp;

TYPE min_dates_arr_t IS TABLE OF get_min_emp_date_cur%ROWTYPE;

v_min_dates_arr min_dates_arr_t;

--Курсор ищет окончание рабочего цикла внутри последнего фрейма предыдущего месяца
CURSOR get_prev_month_cur (
    p_date_from             IN DATE, 
    p_date_to               IN DATE,
    p_emp_id                IN employees.emp_id%TYPE
)
IS
    select MAX(work_date) AS last_work_day
    FROM work_schedule ws
    WHERE ws.work_date >= p_date_from
    AND ws.work_date < p_date_to
    AND ws.emp_id = p_emp_id
    AND ws.frame_mark = 'E';
    
v_prev_month_work_end get_prev_month_cur%ROWTYPE;

v_prev_month_exists BOOLEAN := FALSE;
    
--Локальные переменные--
v_use_date get_min_emp_date_cur%ROWTYPE;
  
v_prev_records_found BOOLEAN := FALSE;
v_curr_emp               NUMBER(3) := 0;
v_curr_date              DATE;
v_frame                  NUMBER(3);
 
v_day NUMBER(3);
v_day_fits BOOLEAN; 
v_move NUMBER(3);

v_cycle_mark VARCHAR2(1);

v_rand_num PLS_INTEGER;
 
BEGIN
  
    v_frame := make_schedule.g_work_2_2.work_days + make_schedule.g_work_2_2.holidays;

    OPEN get_employees_cur;
    LOOP
        FETCH get_employees_cur INTO v_get_employees;
        --Если все записи из курсора выбраны, то выходим из цикла
        IF get_employees_cur%NOTFOUND THEN
            EXIT;
        END IF;  
        
        --Если график для текущего сотрудника для данного месяца уже существует, то пропускаем сотрудника
        IF make_schedule.work_schedule_exists(emp_id_in => v_get_employees.emp_id,
                                                  month_in =>  make_schedule.g_month,
                                                  year_in =>   make_schedule.g_year) THEN
                                 
            CONTINUE;
        END IF; 

        --Проверяем, есть ли график в предыдущем месяце для сотрудника
        v_prev_month_exists := FALSE;
        OPEN get_prev_month_cur (make_schedule.g_init_date - v_frame, make_schedule.g_init_date, v_get_employees.emp_id);
        FETCH get_prev_month_cur INTO v_prev_month_work_end;
        IF get_prev_month_cur%FOUND AND v_prev_month_work_end.last_work_day IS NOT NULL THEN
            v_prev_month_exists := TRUE;
        END IF;
        CLOSE get_prev_month_cur;

        --Если график в предыдущем месяце нашелся
        IF v_prev_month_exists THEN
          
            v_curr_emp := (make_schedule.g_init_date - v_prev_month_work_end.last_work_day + 1) + (make_schedule.g_work_2_2.work_days - make_schedule.g_work_2_2.holidays);
            
            FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
                --Вычисляем текущую дату (-1 нужен, т.к. счетчик цикла начинается с единицы)
                v_curr_date :=  make_schedule.g_init_date - 1 + day_counter;
                --Для первого и второго дня добавляем рабочий день в таблицу
                v_day := MOD(day_counter + v_curr_emp, v_frame);
                
                v_day_fits := FALSE;
                FOR inner_i IN 1..make_schedule.g_work_2_2.work_days LOOP
                    IF v_day = inner_i THEN
                        v_day_fits := TRUE;
                        EXIT;
                    END IF;
                END LOOP;
                
                IF  v_day_fits THEN
                    IF v_day = 1 THEN v_cycle_mark := 'B';
                    ELSIF v_day = make_schedule.g_work_2_2.work_days THEN v_cycle_mark := 'E';
                    ELSE v_cycle_mark := NULL;
                    END IF;
                
                    INSERT INTO work_schedule VALUES (
                         work_schedule_seq.NEXTVAL, 
                         v_curr_date, 
                         day_counter, 
                         make_schedule.g_month, 
                         make_schedule.g_year, 
                         v_get_employees.emp_id, 
                         'Y',
                         v_cycle_mark
                         );
                END IF;
            END LOOP; 
            COMMIT;
        
            CONTINUE; -- Переходим к следующему сотруднику
        END IF;

        --Если график для сотрудника в предыдущем месяце не нашелся
        IF get_employees_cur%ROWCOUNT = 1 THEN -- Для первого сотрудника
            FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
                --Вычисляем текущую дату (-1 нужен, т.к. счетчик цикла начинается с единицы)
                v_curr_date :=  make_schedule.g_init_date - 1 + day_counter;
                --Для первого и второго дня добавляем рабочий день в таблицу
                v_day := MOD(day_counter, v_frame);
                
                v_day_fits := FALSE;
                FOR inner_i IN 1..make_schedule.g_work_2_2.work_days LOOP
                    IF v_day = inner_i THEN
                        v_day_fits := TRUE;
                        EXIT;
                    END IF;
                END LOOP;
                
                IF  v_day_fits THEN
                    IF v_day = 1 THEN v_cycle_mark := 'B';
                    ELSIF v_day = make_schedule.g_work_2_2.work_days THEN v_cycle_mark := 'E';
                    ELSE v_cycle_mark := NULL;
                    END IF;
                
                    INSERT INTO work_schedule VALUES (
                             work_schedule_seq.NEXTVAL, 
                             v_curr_date, 
                             day_counter, 
                             make_schedule.g_month, 
                             make_schedule.g_year, 
                             v_get_employees.emp_id, 
                             'Y',
                             v_cycle_mark
                             );
                END IF;
            END LOOP;  
            COMMIT;  
            
        ELSIF get_employees_cur%ROWCOUNT > 1 THEN
            --Определяем, есть ли дни без продавцов  
            OPEN get_zerosellers_cur (make_schedule.g_month, make_schedule.g_year, v_frame);
            FETCH get_zerosellers_cur INTO v_zerosellers;
            CLOSE get_zerosellers_cur;
            IF v_zerosellers.cnt_outer <> v_frame THEN --Если дни без продавцов найдены
        
                OPEN get_firstweekend_cur (make_schedule.g_month, make_schedule.g_year, v_frame);
                FETCH get_firstweekend_cur INTO v_endweek;
                CLOSE get_firstweekend_cur;
            
                --v_curr_emp := v_endweek.end_date - make_schedule.g_init_date;
                v_curr_emp := EXTRACT(DAY FROM v_endweek.end_date) - (make_schedule.g_work_2_2.work_days - make_schedule.g_work_2_2.holidays);
            
                FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
                    --Вычисляем текущую дату (-1 нужен, т.к. счетчик цикла начинается с единицы)
                    v_curr_date :=  make_schedule.g_init_date - 1 + day_counter;
                    --Для первого и второго дня добавляем рабочий день в таблицу
                    v_day := MOD(day_counter + v_curr_emp, v_frame);
                
                    v_day_fits := FALSE;
                    FOR inner_i IN 1..make_schedule.g_work_2_2.work_days LOOP
                        IF v_day = inner_i THEN
                            v_day_fits := TRUE;
                            EXIT;
                        END IF;
                    END LOOP;
                
                    IF  v_day_fits THEN
                        IF v_day = 1 THEN v_cycle_mark := 'B';
                        ELSIF v_day = make_schedule.g_work_2_2.work_days THEN v_cycle_mark := 'E';
                        ELSE v_cycle_mark := NULL;
                        END IF;
                
                        INSERT INTO work_schedule VALUES (
                             work_schedule_seq.NEXTVAL, 
                             v_curr_date, 
                             day_counter, 
                             make_schedule.g_month, 
                             make_schedule.g_year, 
                             v_get_employees.emp_id, 
                             'Y',
                             v_cycle_mark
                             );
                    END IF;
                END LOOP; 
                COMMIT;
            ELSE --Если дни без продавцов не найдены
                --Находим минимальное количество сотрудников в день, которое есть в первом фрейме
                OPEN get_min_emp_cur (make_schedule.g_month, make_schedule.g_year, v_frame);
                FETCH get_min_emp_cur INTO v_get_min_emp;
                CLOSE get_min_emp_cur;
                --Выбираем минимальную дату в первом фрейме, когда работает меньше всего народу
                
                OPEN get_min_emp_date_cur (make_schedule.g_month, make_schedule.g_year, v_frame, v_get_min_emp.emp_each_day);
                FETCH get_min_emp_date_cur BULK COLLECT INTO v_min_dates_arr;
                CLOSE get_min_emp_date_cur;
                --Если дат с минимальным количеством сотрдуников больше одного, то вводим случайный выюор даты
                
                v_rand_num := ceil(dbms_random.value(0, 1) * v_min_dates_arr.COUNT);
                
                --Вычисляем смещение
                v_curr_emp := v_frame - ( v_min_dates_arr(v_rand_num).use_date - make_schedule.g_init_date);
            
                FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
                    --Вычисляем текущую дату (-1 нужен, т.к. счетчик цикла начинается с единицы)
                    v_curr_date :=  make_schedule.g_init_date - 1 + day_counter;
                    --Для первого и второго дня добавляем рабочий день в таблицу
                    v_day := MOD(day_counter + v_curr_emp, v_frame);
                
                    v_day_fits := FALSE;
                    FOR inner_i IN 1..make_schedule.g_work_2_2.work_days LOOP
                        IF v_day = inner_i THEN
                            v_day_fits := TRUE;
                            EXIT;
                        END IF;
                    END LOOP;
                
                    IF  v_day_fits THEN
                        IF v_day = 1 THEN v_cycle_mark := 'B';
                        ELSIF v_day = make_schedule.g_work_2_2.work_days THEN v_cycle_mark := 'E';
                        ELSE v_cycle_mark := NULL;
                        END IF;
                
                        INSERT INTO work_schedule VALUES (
                             work_schedule_seq.NEXTVAL, 
                             v_curr_date, 
                             day_counter, 
                             make_schedule.g_month, 
                             make_schedule.g_year, 
                             v_get_employees.emp_id, 
                             'Y',
                             v_cycle_mark
                             );
                    END IF;
                END LOOP;
                COMMIT;
            
                --Окончание работы со смещением
            END IF;  

        END IF;
        
    END LOOP;
    CLOSE get_employees_cur;
  
EXCEPTION
    WHEN OTHERS THEN
        IF get_employees_cur%ISOPEN THEN CLOSE get_employees_cur; END IF;

END sched_second_algorythm;

/**********************************************************
--Окончание тела пакета make_schedule
**********************************************************/
END make_schedule;
