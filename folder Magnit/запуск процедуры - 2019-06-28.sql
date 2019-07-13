/********************************************************************************
             ---Êîä äëÿ çàïóñêà ïàêåòà make_schedule---
*********************************************************************************/

DECLARE
month_to_schedule NUMBER(2) := 1;
year_to_schedule NUMBER(4) := 2018;
v_res make_schedule.whole_schedule_t := make_schedule.whole_schedule_t();

v_line VARCHAR2(500);

BEGIN
  make_schedule.make_new_schedule(month_sched_in => month_to_schedule, year_sched_in => year_to_schedule);
  
  v_res := make_schedule.give_me_a_schedule;
  
    FOR i IN 1..v_res.COUNT LOOP
      
        v_line := v_res(i).position; 
    
        FOR j IN 1..v_res(i).schedule.COUNT LOOP  
            v_line := v_line || CHR(9) || v_res(i).schedule(j);
        END LOOP;
    
        DBMS_OUTPUT.put_line(v_line);
    END LOOP;
END;


-- select count(*) from work_schedule
-- select * from work_schedule
-- delete from work_schedule
-- select * from work_schedule

-- select * from employees
-- delete from employees where emp_id = 21
-- commit

