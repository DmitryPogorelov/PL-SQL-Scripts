/********************************************************************************
         ---Код для создания объектов для пакета make_schedule---
*********************************************************************************/

--Создаем тип для коллекции, в которой храним рабочие дни для пятидневщиков--
CREATE TYPE week_work_days_t IS TABLE OF NUMBER(1);

--Таблица для хранения сведений о сотрудниках--
CREATE TABLE employees (
emp_id                 NUMBER(8)          NOT NULL CONSTRAINT employees_PK PRIMARY KEY,
position               VARCHAR2(15)       NOT NULL,
work_days              NUMBER(1)          NOT NULL,
holidays               NUMBER(1)          NOT NULL,
workdays_list          week_work_days_t
)
NESTED TABLE workdays_list STORE AS workdays_list_nt;

CREATE BITMAP INDEX employees_2_col_index ON employees (work_days, holidays);

--СОздаём последовательность для первичных ключей таблицы employee

CREATE SEQUENCE employees_seq
 START WITH     1
 INCREMENT BY   1
 MAXVALUE       99999999
 NOCYCLE;

--Заполняем таблицу с сотрудниками данными--

INSERT INTO employees VALUES (employees_seq.NEXTVAL, 'Director', 5, 2, week_work_days_t(1,2,3,4,5));
INSERT INTO employees VALUES (employees_seq.NEXTVAL, 'Dir_deputy', 5, 2, week_work_days_t(1,4,5,6,7));
INSERT INTO employees VALUES (employees_seq.NEXTVAL, 'Seller 1', 2, 2, NULL);
INSERT INTO employees VALUES (employees_seq.NEXTVAL, 'Seller 2', 2, 2, NULL);
INSERT INTO employees VALUES (employees_seq.NEXTVAL, 'Seller 3', 2, 2, NULL);

COMMIT;

--Создаем таблицу для графиков

CREATE TABLE work_schedule (
sched_id     NUMBER(15)    NOT NULL CONSTRAINT work_sched_PK PRIMARY KEY,
work_date    DATE,
day_num       NUMBER(2),
month_num     NUMBER(2),
year_num     NUMBER(4),
emp_id       NUMBER(8),
is_working   VARCHAR2(1),
frame_mark   VARCHAR2(1),
CONSTRAINT work_sched_employees_FK
  FOREIGN KEY (emp_id)
  REFERENCES employees (emp_id)
);

--Создаем последовательность для первичных ключей таблицы work_schedule--
CREATE SEQUENCE work_schedule_seq
 START WITH     1
 INCREMENT BY   1
 MAXVALUE       999999999999999
 NOCYCLE;
 
--Создаём индекс для таблички с расписаниями. Тестирование показало, что bitmap index позволяет 
--снизить количество чтений при запросах по сравнению с обычным индексом.
CREATE BITMAP INDEX work_schedule_3_col_index ON work_schedule (emp_id, month_num, year_num);

CREATE BITMAP INDEX work_schedule_emp_col_index ON work_schedule (emp_id);

ANALYZE TABLE work_schedule COMPUTE STATISTICS FOR TABLE FOR ALL INDEXES FOR ALL INDEXED COLUMNS;

ANALYZE TABLE employees COMPUTE STATISTICS FOR TABLE FOR ALL INDEXES FOR ALL INDEXED COLUMNS;
