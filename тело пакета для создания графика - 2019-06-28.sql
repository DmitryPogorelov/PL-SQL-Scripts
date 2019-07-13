/********************************************************************************
             ---����� ������� ����������� �������� ������������---
*********************************************************************************/

CREATE OR REPLACE PACKAGE BODY make_schedule 
AS
/*******************************************************************************
�������� ���������. ����� �������� ����������, ��������� ������ �!!!
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
    --��������� ��������� �����. ���� �������� ������� �� �������, �� �������� ����������
    IF month_sched_in < make_schedule.g_min_month OR month_sched_in > make_schedule.g_max_month THEN
        RAISE not_valid_month;     
    END IF;
    --��������� ��������� ���. ���� �������� ������� �� �������, �� �������� ����������
    IF year_sched_in < make_schedule.g_min_year OR year_sched_in > make_schedule.g_max_year THEN
        RAISE not_valid_year;
    END IF;

    --������� ��������� ������ � ���������� ���������� ������
    make_schedule.g_month := month_sched_in;
    make_schedule.g_year := year_sched_in;
    --������ ����� �������������� ����� ��� ������������ ���� � ������ ��� ������
    v_varchar2_g_month := LTRIM(TO_CHAR(make_schedule.g_month, '09'), ' ');
    v_varchar2_g_year := LTRIM(TO_CHAR(make_schedule.g_year, '9999'), ' ');
    --���������� ��������� ���� ��� ���������� ���������� ���� � ������
    v_date := '01.' || v_varchar2_g_month || '.' || v_varchar2_g_year;
    --��������� ������ ����� ������ � ���� ���� � ���������� ���������� ������
    make_schedule.g_init_date := TO_DATE(v_date, make_schedule.g_date_format);
    --��������� ���������� ���� � ������ � ���������� ���������� ������
    make_schedule.g_days_in_month := EXTRACT(DAY FROM LAST_DAY(make_schedule.g_init_date));
    --������ ��������� �������� ���������� 5/2
    make_schedule.g_work_5_2.work_days := make_schedule.g_dir_work;
    make_schedule.g_work_5_2.holidays  := make_schedule.g_dir_holidays;
    --������ ��������� �������� ���������� 2/2
    make_schedule.g_work_2_2.work_days := make_schedule.g_seller_work;
    make_schedule.g_work_2_2.holidays  := make_schedule.g_seller_holidays;
    --�������� �������, ������� ��������� ��������� ��� ����������� � ����������� 5/2
    make_schedule.five_to_two_schedule();
    make_schedule.new_five_to_two_schedule();
    --������� ���������� ��� ����������� 2/2
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
--��������� ��� ������������ ������� 5/2--
***********************************************************************************************/
PROCEDURE five_to_two_schedule
IS

    v_worker employee_workdays_cur%ROWTYPE;
    v_curr_date DATE;
  
    v_day_of_week NUMBER;
    v_working_days_coll week_work_days_t;
  
BEGIN
    --��������� ��������� �������, ���� �� ������ - �� ���������--
    IF employee_workdays_cur%ISOPEN THEN 
        CLOSE employee_workdays_cur; 
    END IF;
    --��������� ������ ��� ������� ����������� � ������� ������ 5/2
    OPEN employee_workdays_cur (g_work_5_2.work_days, g_work_5_2.holidays);
  
    LOOP
         
        FETCH employee_workdays_cur INTO v_worker;
        --���� ��� ������ �� ������� �������, �� ������� �� �����
        IF employee_workdays_cur%NOTFOUND THEN
            EXIT;
        END IF;
         
        --���� ������ ��� �������� ���������� ��� ������� ������ ��� ����������, �� ���������� ����������
        IF make_schedule.work_schedule_exists(emp_id_in => v_worker.emp_id,
                                              month_in =>  make_schedule.g_month,
                                              year_in =>   make_schedule.g_year) THEN
            CONTINUE;
        END IF;      
         
        --�������� ������ ������ � ���������� � ����� ���������
        v_working_days_coll := v_worker.workdays_list;
         
        --��������� ���� ��� ���������� ������� ���� � ������
        FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
            --��������� ������� ���� (-1 �����, �.�. ������� ����� ���������� � �������)
            v_curr_date :=  make_schedule.g_init_date - 1 + day_counter;
            --���������, ����� ��� ������ ���� ������� ����
            v_day_of_week := (1 + TRUNC (v_curr_date) - TRUNC (v_curr_date, 'IW'));
           
            --���������, ���� �� ���� ���� ������ � ������ ������� ���� ��� ������� ����������
            --���� ����, �� ��������� ������� � �������� � ������� �������� ������
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
        --��������� ������ ��� ������� ����������
        COMMIT;
    END LOOP;
    --��������� ������--
    IF employee_workdays_cur%ISOPEN THEN
        CLOSE employee_workdays_cur;
    END IF;
  
EXCEPTION
    WHEN OTHERS THEN --��������� ������ ��� �������
        IF employee_workdays_cur%ISOPEN THEN
            CLOSE employee_workdays_cur;
        END IF;
        --���������� ��������� � ������� ��� ����������, ���� �������� ������
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20007, 'Unhandled exception in procedure make_schedule.five_to_two_schedule!!!');
END five_to_two_schedule;

/***********************************************************************************
--����� ��������� ��� ������� 5/2 � BULK COllect
**************************************************************************************/
PROCEDURE new_five_to_two_schedule
IS

    v_worker employee_workdays_cur%ROWTYPE;
    TYPE v_all_workers_t IS TABLE OF employee_workdays_cur%ROWTYPE;
    v_all_workers_c v_all_workers_t; --���������� � ����� ��������� ��� ������������� ������ � �����������
    v_curr_date DATE;
  
    v_day_of_week NUMBER;
    v_working_days_coll week_work_days_t;
  
BEGIN
    --��������� ��������� �������, ���� �� ������ - �� ���������--
    IF employee_workdays_cur%ISOPEN THEN 
        CLOSE employee_workdays_cur; 
    END IF;
    --��������� ������ ��� ������� ����������� � ������� ������ 5/2
    OPEN employee_workdays_cur (g_work_5_2.work_days, g_work_5_2.holidays);
  
    FETCH employee_workdays_cur BULK COLLECT INTO v_all_workers_c;

    --��������� ������--
    IF employee_workdays_cur%ISOPEN THEN
        CLOSE employee_workdays_cur;
    END IF;
    
    FOR curr_emp IN 1..v_all_workers_c.COUNT LOOP
        --���� ������ ��� �������� ���������� ��� ������� ������ ��� ����������, �� ���������� ����������
        IF make_schedule.work_schedule_exists(emp_id_in => v_all_workers_c(curr_emp).emp_id,
                                              month_in =>  make_schedule.g_month,
                                              year_in =>   make_schedule.g_year) THEN
            CONTINUE;
        END IF;
        
        --�������� ������ ������ � ���������� � ����� ���������
        v_working_days_coll := v_all_workers_c(curr_emp).workdays_list;
         
        --��������� ���� ��� ���������� ������� ���� � ������
        FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
            --��������� ������� ���� (-1 �����, �.�. ������� ����� ���������� � �������)
            v_curr_date :=  make_schedule.g_init_date - 1 + day_counter;
            --���������, ����� ��� ������ ���� ������� ����
            v_day_of_week := (1 + TRUNC (v_curr_date) - TRUNC (v_curr_date, 'IW'));
           
            --���������, ���� �� ���� ���� ������ � ������ ������� ���� ��� ������� ����������
            --���� ����, �� ��������� ������� � �������� � ������� �������� ������
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
        --��������� ������ ��� ������� ����������
        COMMIT;
        
    END LOOP;
  
EXCEPTION
    WHEN OTHERS THEN --��������� ������ ��� �������
        IF employee_workdays_cur%ISOPEN THEN
            CLOSE employee_workdays_cur;
        END IF;
        --���������� ��������� � ������� ��� ����������, ���� �������� ������
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20011, 'Unhandled exception in procedure make_schedule.new_five_to_two_schedule!!!');

END new_five_to_two_schedule;

/***********************************************************************************
--��������� ��� ������������ ������� 2/2--
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
    
    --������ ��� ������ ���������� ���������������� ��� ������
    --���� ������ ������������ ��� ����, ����� ������� ���� ���������������� ������� ����������� ���������
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
        
    --���������� ��� ������� ������ �� ������� last_work_date
    v_previous_month_date           last_work_date%ROWTYPE;
    
    v_previous_date_last            DATE;
    v_previous_date_last_minus_one  DATE;
    
    v_previous_month                make_schedule.g_month%TYPE;
    v_previous_year                 make_schedule.g_year%TYPE;
    
    v_previous_month_found          BOOLEAN := FALSE;
    v_day_fits                      BOOLEAN := FALSE;
    
BEGIN
    --��������� ��������� �������, ���� �� ������ - �� ���������--
    IF employee_workdays_cur%ISOPEN THEN 
        CLOSE employee_workdays_cur; 
    END IF;
    --��������� ������ ��� ������� ����������� � ������� ������ 2/2
    OPEN employee_workdays_cur (g_work_2_2.work_days, g_work_2_2.holidays);
        LOOP
            FETCH employee_workdays_cur INTO v_worker;
            --���� ��� ������ �� ������� �������, �� ������� �� �����
            IF employee_workdays_cur%NOTFOUND THEN
                EXIT;
            END IF;
         
            --���� ������ ��� �������� ���������� ��� ������� ������ ��� ����������, �� ���������� ����������
            IF make_schedule.work_schedule_exists(emp_id_in => v_worker.emp_id,
                                                  month_in =>  make_schedule.g_month,
                                                  year_in =>   make_schedule.g_year) THEN
                                 
                CONTINUE;
            END IF; 

            --������� ����� � ��� ����������� ������--
            v_previous_month := EXTRACT(MONTH FROM (g_init_date - 1));
            v_previous_year  := EXTRACT(YEAR FROM (g_init_date - 1));

            --���������, ���� �� ������ �� ���������� �����
            IF last_work_date%ISOPEN THEN
                CLOSE last_work_date;
            END IF;
            --����, ���� �� ���������� �� ���������� �����, ����� ����� ��� �� ����� �������            
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
            --��������� ������--
            IF last_work_date%ISOPEN THEN
                CLOSE last_work_date;
            END IF;
            
            --��������� ������ � ������ ����������� ������
            IF (g_init_date - v_previous_date_last) > 2 THEN
                v_curr_emp := c_first_seller - 1;
            ELSIF (g_init_date - v_previous_date_last) > 1 THEN
                v_curr_emp := c_second_seller - 1;
            ELSIF (g_init_date - v_previous_date_last) = 1 AND (g_init_date - v_previous_date_last_minus_one) = 2 THEN
                v_curr_emp := c_third_seller - 1;
            ELSE
                v_curr_emp := - 1;
            END IF;
            --���� ���������� � ���������� ������ ���, �� ������� ���������� � ������� �����
            IF NOT v_previous_month_found THEN
                --��������� �������� � ���� ��� �������
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
            --��������� ���� ��� ������������ ����������
            FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
                --��������� ������� ���� (-1 �����, �.�. ������� ����� ���������� � �������)
                v_curr_date :=  make_schedule.g_init_date - 1 + day_counter;
                --��� ������� ���� ��������� ������� ���� � �������. �������, ��� ������� ��� ���� �������
                v_day := MOD(day_counter - v_curr_emp, v_frame);
                v_day_fits := FALSE;
                FOR inner_i IN 1..make_schedule.g_work_2_2.work_days LOOP
                    IF v_day = inner_i THEN
                        v_day_fits := TRUE;
                        EXIT;
                    END IF;
                END LOOP;
                
                --���� ���� �������� ��� ������� - ��������� ��� � ��������
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
            --��������� ������ ��� ������� ����������
            COMMIT;
        --����� ����� �� �����������
        END LOOP;
    --��������� ������--
    IF employee_workdays_cur%ISOPEN THEN
       CLOSE employee_workdays_cur;
    END IF;
  
EXCEPTION
    WHEN OTHERS THEN 
        --��������� ������ ��� �������
        IF employee_workdays_cur%ISOPEN THEN
            CLOSE employee_workdays_cur;
        END IF;
        --��������� ������ ��� �������
        IF last_work_date%ISOPEN THEN
            CLOSE last_work_date;
        END IF;
        --���������� ��������� � ������� ��� ����������, ���� �������� ������
        ROLLBACK;
        
        RAISE_APPLICATION_ERROR(-20008, 'Unhandled exception in procedure make_schedule.two_to_two_schedule!!!');
END two_to_two_schedule;
/******************************************************************************************
--������� ���������, ���� �� ��� ��������� ��������� ��� ���������� �� �������� ����� � ���
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
    --��������� ��������� �������, ���� �� ������ - �� ���������--
    IF any_work_rec_cur%ISOPEN THEN 
        CLOSE any_work_rec_cur; 
    END IF;  

    --��������� ������ � ��������� ���������� �����--
    OPEN any_work_rec_cur(emp_id_in, month_in, year_in);
    FETCH any_work_rec_cur INTO v_cnt;
     --��������� ��������� �������, ���� �� ������ - �� ���������--
    IF any_work_rec_cur%ISOPEN THEN 
        CLOSE any_work_rec_cur; 
    END IF;
    --��������� ���������� �������. ���� ������ ����, �� ���������� TRUE
    IF v_cnt.cnt > 0 THEN
        v_return_value := TRUE;
    END IF;
    --���������� ����� � ������� ���������� �� ������� �����
    RETURN v_return_value;
EXCEPTION
    WHEN OTHERS THEN
        --��������� ��������� �������, ���� �� ������ - �� ���������--
        IF any_work_rec_cur%ISOPEN THEN 
            CLOSE any_work_rec_cur; 
        END IF;  
      
        RAISE_APPLICATION_ERROR(-20009, 'Unhandled exception in FUNCTION make_schedule.work_schedule_exists!!!');
        RETURN FALSE;
END work_schedule_exists;
/************************************************************************
--������� ����������� ���������� �� ��������� ������� � ���������� �� 
***********************************************************************/
FUNCTION give_me_a_schedule
RETURN whole_schedule_t
IS
    --������ ��� ������ ���������� �� ���������� ����������
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
    --������ ��� ������� ������ � ����������
    v_sched_rec schedule_row_cur%ROWTYPE;

    --������ ��� ������� ����������� � ���������� ����������
    CURSOR employees_list_cur 
    IS
    SELECT emp.emp_id, emp.position
    FROM employees emp
    ORDER BY emp.work_days DESC, emp.emp_id ASC, emp.position ASC;

    --������ ��� ������ � ����������
    v_loc_worker employees_list_cur%ROWTYPE;

    --������ ����������
    v_sched_row sched_row_t := sched_row_t();

    --���������� ���������� � ��� ����������
    v_return_sched whole_schedule_t := whole_schedule_t();

BEGIN
    --��������� ��������� � ����������
    v_return_sched.EXTEND(1);
    v_return_sched(v_return_sched.LAST).position := TO_CHAR(g_init_date, 'MM.YYYY');
    
    FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
        v_sched_row.EXTEND(1);
        v_sched_row(v_sched_row.LAST) := TO_CHAR((TO_DATE(g_init_date + day_counter - 1)), 'DY');
    END LOOP;
    
    v_return_sched(v_return_sched.LAST).schedule := v_sched_row;
    
    --��������� ����� Position � ����� ������
    v_return_sched.EXTEND(1);
    v_return_sched(v_return_sched.LAST).position := 'Position';
    
    FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
        v_sched_row(day_counter) := TO_CHAR(day_counter);
    END LOOP;
    
    v_return_sched(v_return_sched.LAST).schedule := v_sched_row;
    
    --��������� � ���������� ������ ��� �����������
    --��������� ��������� �������, ���� �� ������ - �� ���������--
    IF employees_list_cur%ISOPEN THEN 
        CLOSE employees_list_cur; 
    END IF;
    --��������� ������ ��� ������� �����������
    OPEN employees_list_cur;
    LOOP
        FETCH employees_list_cur INTO v_loc_worker;
        --���� ��� ������ �� ������� �������, �� ������� �� �����
        IF employees_list_cur%NOTFOUND THEN
            EXIT;
        END IF;
        --��������� ������ � ���������� � ����������
        v_return_sched.EXTEND(1);
        v_return_sched(v_return_sched.LAST).position := v_loc_worker.position;
        
        --������� ������ ����� �� ��������������
        FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
            v_sched_row(day_counter) := ' ';
        END LOOP;
        
        --�������� ������ �� ������� ���������� � ������ ����������
        IF schedule_row_cur%ISOPEN THEN 
            CLOSE schedule_row_cur; 
        END IF;
        OPEN schedule_row_cur (v_loc_worker.emp_id, make_schedule.g_month, make_schedule.g_year);
        LOOP
          
            FETCH schedule_row_cur INTO v_sched_rec;
            --���� ��� ������ �� ������� �������, �� ������� �� �����
            IF schedule_row_cur%NOTFOUND THEN
                EXIT;
            END IF;
            --� ������ ������ ����������� ������� �������� ���
            v_sched_row(v_sched_rec.day_num) := v_sched_rec.is_working;
             
        END LOOP;
        --��������� ������� � ���������� � �������� ���������
        v_return_sched(v_return_sched.LAST).schedule := v_sched_row;
        --��������� ������ � ��������� ������
        IF schedule_row_cur%ISOPEN THEN 
            CLOSE schedule_row_cur; 
        END IF;
        
    END LOOP;
    --��������� ������ � ��������� ������
    IF employees_list_cur%ISOPEN THEN 
        CLOSE employees_list_cur; 
    END IF;
    --���������� ���������� ����������� �������
    RETURN v_return_sched;

EXCEPTION
    WHEN OTHERS THEN
    --��������� ��� �������, ������� ����� ���� �������  
    IF employees_list_cur%ISOPEN THEN 
        CLOSE employees_list_cur; 
    END IF;
    IF schedule_row_cur%ISOPEN THEN 
        CLOSE schedule_row_cur; 
    END IF;
    
    RAISE_APPLICATION_ERROR(-20010, 'Unhandled exception in FUNCTION make_schedule.give_me_a_schedule!!!');

END give_me_a_schedule;

/************************************************************************************
��������� ��� ������� ���������
************************************************************************************/
PROCEDURE sched_second_algorythm
IS

CURSOR get_employees_cur IS --���� ������ �������� ����������� � ��������� �������� �������/�������� ����
    select ey.emp_id 
    from employees ey
    where ey.work_days = make_schedule.g_work_2_2.work_days
    and ey.holidays = make_schedule.g_work_2_2.holidays
    ORDER BY ey.emp_id ASC;

v_get_employees get_employees_cur%ROWTYPE;

--������ ������� ������������ ��������� ������ � ������ ������   
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
    
--������ ������� ���������� ���� ��� ��������� � ������ ������
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

--������ ������� ����������� ���������� �����������, ������� �������� � ��� ������� ������
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

--������ �������� ����������� ���� � ������ ������, ����� �������� ������ ����� ������
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

--������ ���� ��������� �������� ����� ������ ���������� ������ ����������� ������
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
    
--��������� ����������--
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
        --���� ��� ������ �� ������� �������, �� ������� �� �����
        IF get_employees_cur%NOTFOUND THEN
            EXIT;
        END IF;  
        
        --���� ������ ��� �������� ���������� ��� ������� ������ ��� ����������, �� ���������� ����������
        IF make_schedule.work_schedule_exists(emp_id_in => v_get_employees.emp_id,
                                                  month_in =>  make_schedule.g_month,
                                                  year_in =>   make_schedule.g_year) THEN
                                 
            CONTINUE;
        END IF; 

        --���������, ���� �� ������ � ���������� ������ ��� ����������
        v_prev_month_exists := FALSE;
        OPEN get_prev_month_cur (make_schedule.g_init_date - v_frame, make_schedule.g_init_date, v_get_employees.emp_id);
        FETCH get_prev_month_cur INTO v_prev_month_work_end;
        IF get_prev_month_cur%FOUND AND v_prev_month_work_end.last_work_day IS NOT NULL THEN
            v_prev_month_exists := TRUE;
        END IF;
        CLOSE get_prev_month_cur;

        --���� ������ � ���������� ������ �������
        IF v_prev_month_exists THEN
          
            v_curr_emp := (make_schedule.g_init_date - v_prev_month_work_end.last_work_day + 1) + (make_schedule.g_work_2_2.work_days - make_schedule.g_work_2_2.holidays);
            
            FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
                --��������� ������� ���� (-1 �����, �.�. ������� ����� ���������� � �������)
                v_curr_date :=  make_schedule.g_init_date - 1 + day_counter;
                --��� ������� � ������� ��� ��������� ������� ���� � �������
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
        
            CONTINUE; -- ��������� � ���������� ����������
        END IF;

        --���� ������ ��� ���������� � ���������� ������ �� �������
        IF get_employees_cur%ROWCOUNT = 1 THEN -- ��� ������� ����������
            FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
                --��������� ������� ���� (-1 �����, �.�. ������� ����� ���������� � �������)
                v_curr_date :=  make_schedule.g_init_date - 1 + day_counter;
                --��� ������� � ������� ��� ��������� ������� ���� � �������
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
            --����������, ���� �� ��� ��� ���������  
            OPEN get_zerosellers_cur (make_schedule.g_month, make_schedule.g_year, v_frame);
            FETCH get_zerosellers_cur INTO v_zerosellers;
            CLOSE get_zerosellers_cur;
            IF v_zerosellers.cnt_outer <> v_frame THEN --���� ��� ��� ��������� �������
        
                OPEN get_firstweekend_cur (make_schedule.g_month, make_schedule.g_year, v_frame);
                FETCH get_firstweekend_cur INTO v_endweek;
                CLOSE get_firstweekend_cur;
            
                --v_curr_emp := v_endweek.end_date - make_schedule.g_init_date;
                v_curr_emp := EXTRACT(DAY FROM v_endweek.end_date) - (make_schedule.g_work_2_2.work_days - make_schedule.g_work_2_2.holidays);
            
                FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
                    --��������� ������� ���� (-1 �����, �.�. ������� ����� ���������� � �������)
                    v_curr_date :=  make_schedule.g_init_date - 1 + day_counter;
                    --��� ������� � ������� ��� ��������� ������� ���� � �������
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
            ELSE --���� ��� ��� ��������� �� �������
                --������� ����������� ���������� ����������� � ����, ������� ���� � ������ ������
                OPEN get_min_emp_cur (make_schedule.g_month, make_schedule.g_year, v_frame);
                FETCH get_min_emp_cur INTO v_get_min_emp;
                CLOSE get_min_emp_cur;
                --�������� ����������� ���� � ������ ������, ����� �������� ������ ����� ������
                
                OPEN get_min_emp_date_cur (make_schedule.g_month, make_schedule.g_year, v_frame, v_get_min_emp.emp_each_day);
                FETCH get_min_emp_date_cur BULK COLLECT INTO v_min_dates_arr;
                CLOSE get_min_emp_date_cur;
                --���� ��� � ����������� ����������� ����������� ������ ������, �� ������ ��������� ����� ����
                
                v_rand_num := ceil(dbms_random.value(0, 1) * v_min_dates_arr.COUNT);
                
                --��������� ��������
                v_curr_emp := v_frame - ( v_min_dates_arr(v_rand_num).use_date - make_schedule.g_init_date);
            
                FOR day_counter IN 1..make_schedule.g_days_in_month LOOP
                    --��������� ������� ���� (-1 �����, �.�. ������� ����� ���������� � �������)
                    v_curr_date :=  make_schedule.g_init_date - 1 + day_counter;
                    --��� ������� � ������� ��� ��������� ������� ���� � �������
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
            
                --��������� ������ �� ���������
            END IF;  

        END IF;
        
    END LOOP;
    CLOSE get_employees_cur;
  
EXCEPTION
    WHEN OTHERS THEN
        IF get_employees_cur%ISOPEN THEN CLOSE get_employees_cur; END IF;

END sched_second_algorythm;

/**********************************************************
--��������� ���� ������ make_schedule
**********************************************************/
END make_schedule;
