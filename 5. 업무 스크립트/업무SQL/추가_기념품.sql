--���ǰ����
INSERT INTO TBLGIFT (GIFT_SEQ, NAME, PRICE) 
VALUES ('GIFT11', '�ż��� ��ȭ�� ��ǰ��', 10000); --���ǰ �߰�
UPDATE TBLGIFT SET NAME = '�Ե� ��ȭ�� ��ǰ��'
WHERE GIFT_SEQ = 'GIFT11'; -- ���ǰ����
DELETE FROM TBLGIFT
WHERE GIFT_SEQ = 'GIFT11'; --���ǰ����

select OPEN_COURSE_SEQ as "������ȣ", 
REGEXP_REPLACE(LISTAGG(tblgift.name, ',') within group (order by tblgift.name), '([^,]+)(,\1)*(,|$)', '\1\3') as "������ ���� ���ǰ" 
from tblGetgift join tblgift
on(tblGetgift.gift_seq = tblgift.gift_seq)
group by tblgetgift.open_course_seq; --���� ���� �������� ���ǰ�� Ȯ��

select OPEN_COURSE_SEQ as "������ȣ", 
STUDENT_SEQ as "��������ȣ", 
REGEXP_REPLACE(LISTAGG(tblgift.name, ',') within group (order by tblgift.name), '([^,]+)(,\1)*(,|$)', '\1\3') as "�������� ���� ���ǰ" 
from tblGetgift join tblgift
on(tblGetgift.gift_seq = tblgift.gift_seq)
group by tblgetgift.OPEN_COURSE_SEQ, tblgetgift.STUDENT_SEQ;--������ ���޹��� ���ǰ Ȯ��
