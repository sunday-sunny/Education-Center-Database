DELETE FROM TBLSUPPORTSYSTEM
WHERE STUDENT_SEQ = 'S0496' AND open_course_seq = 'OL015'; --������������
INSERT INTO TBLSUPPORTSYSTEM (STUDENT_SEQ, OPEN_COURSE_SEQ, TRAINING_INSENTIVE, EMPLOYEE_SUPPORT) 
VALUES ('S0496', 'OL015', 'Y', 'Y'); --�������� �Է�
UPDATE TBLSUPPORTSYSTEM SET EMPLOYEE_SUPPORT = 'N'
WHERE STUDENT_SEQ = 'S0496' AND open_course_seq = 'OL015'; --�������μ���

select DISTINCT
STUDENT_SEQ as "���Ϲ�� ������������ȣ"
from TBLSUPPORTSYSTEM 
where TRAINING_INSENTIVE = 'Y'; --���Ϲ�� �Ʒ������ ���ɱ����� ��ȸ

select DISTINCT
STUDENT_SEQ as "��������������� ������������ȣ"
 from TBLSUPPORTSYSTEM
where EMPLOYEE_SUPPORT = 'Y'; --������� �������� ����������� ���� ��������ȸ