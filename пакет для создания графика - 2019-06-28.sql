/********************************************************************************
             ---����� ������� ����������� �������� ������������---
*********************************************************************************/
CREATE OR REPLACE PACKAGE make_schedule
AUTHID CURRENT_USER
AS

--��� ��� �������� �������� ������--
TYPE work_sched_type IS RECORD (
work_days employees.work_days%TYPE,
holidays  employees.holidays%TYPE
);

--��� ��� ������ ��������� ����������
TYPE sched_row_t IS TABLE OF VARCHAR2(10);

--��� ��� ���� ������, ������� �������� ���������
TYPE header_plus_sched_row_t IS RECORD (
position employees.position%TYPE,
schedule sched_row_t
);

--��� ��� ����� ����������
TYPE whole_schedule_t IS TABLE OF header_plus_sched_row_t;

--���������--
g_date_format CONSTANT VARCHAR2(10) := 'DD.MM.YYYY'; --������ ��� ������� ����
g_min_month   CONSTANT NUMBER(2) := 1; --����������� �������� ������ ��� ��������
g_max_month   CONSTANT NUMBER(2) := 12; --������������ �������� ������ ��� �������
g_min_year    CONSTANT NUMBER(4) := 2000; --����������� �������� ���� ��� ��������. ������ 2000? �� ����, �� ����������� �����!
g_max_year    CONSTANT NUMBER(4) := 9999; --������������ �������� ���� ��� ��������. ������ 9999? ��� ����������, ������� ��������
--� �����, ������ ��������������� �������.
g_dir_work        CONSTANT NUMBER(1) := 5; --���������� ������� ���� ��������� � ����
g_dir_holidays    CONSTANT NUMBER(1) := 2; --���������� �������� ���� ��������� � ����
g_seller_work     CONSTANT NUMBER(1) := 2; --���������� ������� ���� ��������
g_seller_holidays CONSTANT NUMBER(1) := 2; --���������� �������� ���� ��������

--���������� ����������--
g_month                NUMBER(2) DEFAULT EXTRACT(MONTH FROM SYSDATE); --����� ������ ����� ������ ��� �������
g_days_in_month        NUMBER(2); --����� ������ ���������� ���� � �������� ������
g_year                 NUMBER(4) DEFAULT EXTRACT(YEAR FROM SYSDATE); --����� ������ ����� ���� ��� �������
-- (�� ��������� - ������� ���)
g_init_date            DATE; --����� ������ ������ ����� ���������� ������ � ���� ����

--���������� ��� �������� ��������� ������� ��������
g_work_5_2 work_sched_type;
g_work_2_2 work_sched_type;

--������ ��� ������� ����������� � ������������ ������� ������
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

--��������� ��������� ��� ������������ ����������--
PROCEDURE make_new_schedule (
month_sched_in              IN         NUMBER,
year_sched_in               IN         NUMBER DEFAULT EXTRACT(YEAR FROM SYSDATE)
);

--��������� ��� ������������ ������� 5/2--
PROCEDURE five_to_two_schedule;

--����� ��������� ��� ������� 5/2 � BULK COllect
PROCEDURE new_five_to_two_schedule;

--��������� ��� ������������ ������� 2/2--
PROCEDURE two_to_two_schedule;

--������� ��������, ���� �� ��� ��������� ��������� ��� ���������� �� �������� ����� � ���
FUNCTION work_schedule_exists (
emp_id_in IN employees.emp_id%TYPE,
month_in  IN make_schedule.g_month%TYPE,
year_in   IN make_schedule.g_year%TYPE
) 
RETURN BOOLEAN;

--������� ����������� ���������� �� ��������� ������� � ���������� �� 
FUNCTION give_me_a_schedule
RETURN whole_schedule_t;

/************************************************************************************
��������� ��� ������� ���������
************************************************************************************/
PROCEDURE sched_second_algorythm; 
 
END make_schedule;
