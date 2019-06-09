/*************************************************************
**                                                          **
**  1. Скрипт не создаёт НИКАКИХ объектов в базе данных     **
**  2. Скрипт использует только DBMS_OUTPUT                 **
**  3. --Запускаем через SQL * Plus--                       **
**                                                          **
*************************************************************/
SET SERVEROUTPUT ON SIZE 3000;
SET SERVEROUTPUT ON FORMAT WRAPPED;
DECLARE
TYPE rowList_t IS VARRAY(30) OF VARCHAR2(70);
currTable rowList_t := rowList_t();

TYPE coordRecord_t IS RECORD (rowN NUMBER, colN NUMBER, charN VARCHAR2(1));
TYPE coordArray_t IS VARRAY(2000) OF coordRecord_t;
coordArray_v coordArray_t := coordArray_t();

rowId NUMBER := 0;
i NUMBER := 0;
j NUMBER := 0;
k NUMBER := 0;

BEGIN
-------------------------Строка 1-----------------------
rowId := 1;
FOR j IN 1..69 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
-------------------------Строка 2-----------------------
rowId := rowId + 1;
FOR j IN 1..2 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 68..69 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
-------------------------Строка 3-----------------------
rowId := rowId + 1;
FOR j IN 1..2 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 68..69 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 25;
coordArray_v(coordArray_v.LAST).charN := '-';
FOR j IN 26..27 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '=';
END LOOP;
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 29;
coordArray_v(coordArray_v.LAST).charN := 'P';
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 30;
coordArray_v(coordArray_v.LAST).charN := 'D';
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 31;
coordArray_v(coordArray_v.LAST).charN := 'N';
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 33;
coordArray_v(coordArray_v.LAST).charN := 'S';
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 34;
coordArray_v(coordArray_v.LAST).charN := 'o';
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 35;
coordArray_v(coordArray_v.LAST).charN := 'f';
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 36;
coordArray_v(coordArray_v.LAST).charN := 't';
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 37;
coordArray_v(coordArray_v.LAST).charN := 'w';
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 38;
coordArray_v(coordArray_v.LAST).charN := 'a';
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 39;
coordArray_v(coordArray_v.LAST).charN := 'r';
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 40;
coordArray_v(coordArray_v.LAST).charN := 'e';
FOR j IN 42..43 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '=';
END LOOP;
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 44;
coordArray_v(coordArray_v.LAST).charN := '-';
-------------------------Строка 4-----------------------
rowId := rowId + 1;
FOR j IN 1..2 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 68..69 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
-------------------------Строка 5-----------------------
rowId := rowId + 1;
FOR j IN 1..69 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
-------------------------Строка 6-----------------------
rowId := rowId + 1;
-------------------------Строка 7-----------------------
rowId := rowId + 1;
FOR j IN 13..19 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
-------------------------Строка 7-----------------------
rowId := rowId + 1;
FOR j IN 12..14 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 18..19 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 25..27 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 31..32 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 35..36 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 40..45 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 48..49 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 53..58 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
-------------------------Строка 8-----------------------
rowId := rowId + 1;
FOR j IN 12..14 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 18..19 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 24..25 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 27..28 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 31..32 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 35..36 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 39..40 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 44..45 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 48..49 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 52..53 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 58..59 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
-------------------------Строка 9-----------------------
rowId := rowId + 1;
FOR j IN 13..14 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 18..19 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 28..29 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 31..32 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 35..36 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 38..39 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 44..45 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 48..49 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 52..53 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 58..59 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
-------------------------Строка 10-----------------------
rowId := rowId + 1;
FOR j IN 14..19 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 27;
coordArray_v(coordArray_v.LAST).charN := '#';
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 28;
coordArray_v(coordArray_v.LAST).charN := '#';
FOR j IN 31..36 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 38..39 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 44..45 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 48..53 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 58..59 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
-------------------------Строка 11-----------------------
rowId := rowId + 1;
FOR j IN 13..14 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 13..14 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 18..19 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 28..29 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 31..32 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 35..36 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 38..39 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 44..45 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 48..49 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 52..53 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 58..59 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
-------------------------Строка 12-----------------------
rowId := rowId + 1;
FOR j IN 12..13 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 18..19 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 24..25 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 27..28 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 31..32 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 35..36 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 39..40 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 44..45 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 48..49 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 52..53 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 58..59 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
-------------------------Строка 13-----------------------
rowId := rowId + 1;
FOR j IN 11..12 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 18..19 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 25..27 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 31..32 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 35..36 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 40..46 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 48..49 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 53..58 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
-------------------------Строка 14-----------------------
rowId := rowId + 1;
-------------------------Строка 15-----------------------
rowId := rowId + 1;
FOR j IN 10..16 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 19..20 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 31..32 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 36..39 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 43..48 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 53..54 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
-------------------------Строка 16-----------------------
rowId := rowId + 1;
FOR j IN 10..11 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 16..17 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 19..20 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 31..32 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 35..36 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 39..40 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 42..43 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 48..49 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 53..54 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
-------------------------Строка 17-----------------------
rowId := rowId + 1;
FOR j IN 10..11 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 16..17 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 19..20 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 30..31 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 34..35 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 42..43 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 48..49 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 53..54 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
-------------------------Строка 18-----------------------
rowId := rowId + 1;
FOR j IN 10..11 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 16..17 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 19..20 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 30..31 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 35..37 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 42..43 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 48..49 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 53..54 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
-------------------------Строка 19-----------------------
rowId := rowId + 1;
FOR j IN 10..16 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 19..20 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 29..30 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 37..39 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 42..43 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 48..49 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 53..54 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
-------------------------Строка 20-----------------------
rowId := rowId + 1;
FOR j IN 10..11 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 19..20 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 29..30 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 39..40 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 42..43 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 47..49 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 53..54 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
-------------------------Строка 21-----------------------
rowId := rowId + 1;
FOR j IN 10..11 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 19..20 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 28..29 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 34..35 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 38..39 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 42..43 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 48..50 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 53..54 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
-------------------------Строка 22-----------------------
rowId := rowId + 1;
FOR j IN 10..11 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 19..26 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 28..29 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 35..38 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 43..48 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 50..51 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
FOR j IN 53..60 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '@';
END LOOP;
-------------------------Строка 23-----------------------
rowId := rowId + 1;
-------------------------Строка 24-----------------------
rowId := rowId + 1;
FOR j IN 1..70 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
-------------------------Строка 25-----------------------
rowId := rowId + 1;
FOR j IN 1..2 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 69..70 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
-------------------------Строка 26-----------------------
rowId := rowId + 1;
FOR j IN 1..2 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 32;
coordArray_v(coordArray_v.LAST).charN := 'T';
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 33;
coordArray_v(coordArray_v.LAST).charN := 'H';
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 34;
coordArray_v(coordArray_v.LAST).charN := 'E';
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 36;
coordArray_v(coordArray_v.LAST).charN := 'E';
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 37;
coordArray_v(coordArray_v.LAST).charN := 'N';
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := 38;
coordArray_v(coordArray_v.LAST).charN := 'D';
FOR j IN 69..70 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
-------------------------Строка 27-----------------------
rowId := rowId + 1;
FOR j IN 1..2 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
FOR j IN 69..70 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
-------------------------Строка 28-----------------------
rowId := rowId + 1;
FOR j IN 1..70 LOOP
coordArray_v.EXTEND;
coordArray_v(coordArray_v.LAST).rowN := rowId;
coordArray_v(coordArray_v.LAST).colN := j;
coordArray_v(coordArray_v.LAST).charN := '#';
END LOOP;
--Plot array initialization--
FOR j IN 1..29 LOOP
  currTable.EXTEND;
  FOR k IN 1..69 LOOP
    currTable(currTable.LAST) := currTable(currTable.LAST) || ' ';
  END LOOP;
END LOOP;
--Plot array filling--
FOR j IN 1..coordArray_v.COUNT LOOP

currTable(coordArray_v(j).rowN) := SUBSTR(currTable(coordArray_v(j).rowN), 1, (coordArray_v(j).colN-1)) || coordArray_v(j).charN || SUBSTR(currTable(coordArray_v(j).rowN), (coordArray_v(j).colN+1));
 
END LOOP;

--Plot array printing--
FOR j IN 1..currTable.COUNT LOOP
DBMS_OUTPUT.PUT_LINE(currTable(j));
END LOOP;
END;
/
