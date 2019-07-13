/********************************************************************************
             ---Ïàêåò íàïèñàí Ïîãîðåëîâûì Äìèòðèåì Íèêîëàåâè÷åì---
*********************************************************************************/
CREATE OR REPLACE PACKAGE make_schedule
AUTHID CURRENT_USER
AS

--Òèï äëÿ õðàíåíèÿ ãðàôèêîâ ðàáîòû--
TYPE work_sched_type IS RECORD (
work_days employees.work_days%TYPE,
holidays  employees.holidays%TYPE
);

--Òèï äëÿ ñòðîêè èòîãîâîãî ðàñïèñàíèÿ
TYPE sched_row_t IS TABLE OF VARCHAR2(10);

--Òèï äëÿ âñåé ñòðîêè, âêëþ÷àÿ íàçâàíèå äîëæíîñòè
TYPE header_plus_sched_row_t IS RECORD (
position employees.position%TYPE,
schedule sched_row_t
);

--Òèï äëÿ âñåãî ðàñïèñàíèÿ
TYPE whole_schedule_t IS TABLE OF header_plus_sched_row_t;

--Êîíñòàíòû--
g_date_format CONSTANT VARCHAR2(10) := 'DD.MM.YYYY'; --Ôîðìàò äëÿ ðàçáîðà äàòû
g_min_month   CONSTANT NUMBER(2) := 1; --Ìèíèìàëüíîå çíà÷åíèå ìåñÿöà äëÿ ïðîâåðêè
g_max_month   CONSTANT NUMBER(2) := 12; --Ìàêñèìàëüíîå çíà÷åíèå ìåñÿöà äëÿ ïðîåðêè
g_min_year    CONSTANT NUMBER(4) := 2000; --Ìèíèìàëüíîå çíà÷åíèå ãîäà äëÿ ïðîâåðêè. Ïî÷åìó 2000? Íå çíàþ, íî îãðàíè÷åíèå íóæíî!
g_max_year    CONSTANT NUMBER(4) := 9999; --Ìàêñèìàëüíîå çíà÷åíèå ãîäà äëÿ ïðîâåðêè. Ïî÷åìó 9999? Âñå ïåðåìåííûå, êîòîðûå ðàáîòàþò
--ñ ãîäîì, çàäàíû ÷åòûðåõçíà÷íûìè ÷èñëàìè.
g_dir_work        CONSTANT NUMBER(1) := 5; --Êîëè÷åñòâî ðàáî÷èõ äíåé äèðåêòîðà è çàìà
g_dir_holidays    CONSTANT NUMBER(1) := 2; --Êîëè÷åñòâî âûõîäíûõ äíåé äèðåêòîðà è çàìà
g_seller_work     CONSTANT NUMBER(1) := 2; --Êîëè÷åñòâî ðàáî÷èõ äíåé ïðîäàâöà
g_seller_holidays CONSTANT NUMBER(1) := 2; --Êîëè÷åñòâî âûõîäíûõ äíåé ïðîäàâöà

--Ãëîáàëüíûå ïåðåìåííûå--
g_month                NUMBER(2) DEFAULT EXTRACT(MONTH FROM SYSDATE); --Çäåñü õðàíèì íîìåð ìåñÿöà äëÿ ðàñ÷åòà
g_days_in_month        NUMBER(2); --Çäåñü õðàíèì êîëè÷åñòâî äíåé â çàäàííîì ìåñÿöå
g_year                 NUMBER(4) DEFAULT EXTRACT(YEAR FROM SYSDATE); --Çäåñü õðàíèì íîìåð ãîäà äëÿ ðàñ÷åòà
-- (ïî óìîë÷àíèþ - òåêóùèé ãîä)
g_init_date            DATE; --Çäåñü õðàíèì ïåðâîå ÷èñëî ðàñ÷åòíîãî ìåñÿöà â âèäå äàòû

--Ïåðåìåííûå äëÿ õðàíåíèÿ âàðèàíòîâ ðàáî÷èõ ãðàôèêîâ
g_work_5_2 work_sched_type;
g_work_2_2 work_sched_type;

--Êóðñîð äëÿ âûáîðêè ñîòðóäíèêîâ ñ îïðåäåëåííûì ðåæèìîì ðàáîòû
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

--Ñòàðòîâàÿ ïðîöåäóðà äëÿ ôîðìèðîâàíèÿ ðàñïèñàíèÿ--
PROCEDURE make_new_schedule (
month_sched_in              IN         NUMBER,
year_sched_in               IN         NUMBER DEFAULT EXTRACT(YEAR FROM SYSDATE)
);

--Ïðîöåäóðà äëÿ ôîðìèðîâàíèÿ ãðàôèêà 5/2--
PROCEDURE five_to_two_schedule;

--Íîâàÿ ïðîöåäóðà äëÿ ãðàôèêà 5/2 ñ BULK COllect
PROCEDURE new_five_to_two_schedule;

--Ïðîöåäóðà äëÿ ôîðìèðîâàíèÿ ãðàôèêà 2/2--
PROCEDURE two_to_two_schedule;

--Ôóíêöèÿ ïðîåðÿåò, åñòü ëè äëÿ çàäàííîãî ñîòðóíèêà óæå ðàñïèñàíèå íà çàäàííûé ìåñÿö è ãîä
FUNCTION work_schedule_exists (
emp_id_in IN employees.emp_id%TYPE,
month_in  IN make_schedule.g_month%TYPE,
year_in   IN make_schedule.g_year%TYPE
) 
RETURN BOOLEAN;

--Ôóíêöèÿ óïàêîâûâàåò ðàñïèñàíèå âî âëîæåííóþ òàáëèöó è âîçâðàùàåò åå 
FUNCTION give_me_a_schedule
RETURN whole_schedule_t;

/************************************************************************************
Ïðîöåäóðû äëÿ âòîðîãî àëãîðèòìà
************************************************************************************/
PROCEDURE sched_second_algorythm; 
 
END make_schedule;
