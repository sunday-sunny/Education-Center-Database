--������ - �������
INSERT INTO TBLJOBSEEKER (STUDENT_SEQ, OPEN_COURSE_SEQ, DESIRED_PLACE, MIN_SALARY, MAX_SALARY, ACADEMIC, EMPLOYMENT_STATE, EMPLOYMENT_DATE, RECRUITER_SEQ, TASK_SEQ) 
VALUES ((SELECT tblregister.student_seq FROM tblRegister WHERE STUDENT_SEQ = 'S0381' AND open_course_seq = 'OL001'),
(SELECT tblregister.open_course_seq FROM tblRegister WHERE STUDENT_SEQ = 'S0381' AND open_course_seq = 'OL001'),
'�λ걤����', 2000, 3000, '����', 'N', NULL,
(select tbljobposting.RECRUITER_SEQ from TBLJOBPOSTING WHERE tbljobposting.salary >= 2000 AND tbljobposting.EDUCATION_LEVEL LIKE '����' AND work_place LIKE '%�λ걤����%' AND rownum = 1),
(select tbltask.task_seq from tblTask where tbltask.name LIKE '������')); -- �������� �������

INSERT INTO TBLLICENSE (LICENSE_SEQ, NAME) 
VALUES ('SP111', 'ITQ'); --�ڰ��� ���
UPDATE TBLLICENSE SET NAME = 'ITQA'
WHERE LICENSE_SEQ = 'SP111'; --�ڰ��� ��������
DELETE FROM TBLLICENSE
WHERE LICENSE_SEQ = 'SP111'; --�ڰ�������

INSERT INTO TBLSTUDENTLICENSE (STUDENT_SEQ, LICENSE_SEQ, REGISTRATION_DATE) 
VALUES ((SELECT tblregister.student_seq FROM tblRegister WHERE STUDENT_SEQ = 'S0381' AND open_course_seq = 'OL001'), 
(SELECT LICENSE_SEQ from tblLicense where name = '��Ʈ��ũ������'), to_date('12/01/2019', 'MM/DD/YYYY')); --�������ڰ����Է�

INSERT INTO TBLCOMPANY (COMPANY_SEQ, NAME, BUSINESS_NUMBER, POSTCODE, ADDRESS, TEL) 
VALUES ('COM0051', '�׿�����', '229-12-76696', 32624, '��⵵ �����ֽ� �����1�� 6', '031-428-3246');  --������

INSERT INTO TBLJOBPOSTING (RECRUITER_SEQ, COMPANY_SEQ, WORK_PLACE, SALARY, EDUCATION_LEVEL, EMPLOYEE_NUMBER, START_DATE, END_DATE, STATE, TASK_SEQ) 
VALUES ('RE0061',
(select tblcompany.company_seq from tblCompany where tblcompany.name LIKE '�׿�����'),
(select regexp_substr((select tblcompany.address from tblcompany where tblcompany.name like '�׿�����'),'[^ ]+ \w+',1) from dual),
2600, '����', 8, to_date('2022-03-01', 'YYYY-MM-DD'), to_date('2022-11-26', 'YYYY-MM-DD'), 'ä�뿹��',
(select tbltask.task_seq from tblTask where tbltask.name LIKE '������'));  --����� �����Ƿ� ���

INSERT INTO TBLRECRUITER (RECRUITER_SEQ, NAME, POSITION, TEL, EMAIL) 
VALUES ('RE0061', '������', '�븮', '010-3389-2084', 'srhkras@gmail.com'); --����� ä������ ���
UPDATE TBLRECRUITER SET POSITION = '����'
WHERE RECRUITER_SEQ = 'RE0061'; --����� ä������ ����

select 
TBLJOBPOSTING.recruiter_seq as "������ȣ",
tblcompany.name as "�����",
TBLJOBPOSTING.work_place as "�ٹ���",
TBLJOBPOSTING.salary as "�޿�",
TBLJOBPOSTING.education_level as "�ʿ��з�",
TBLJOBPOSTING.employee_number as "ä���ο�",
tbltask.name as "������"
from tbltask join TBLJOBPOSTING
on(tbltask.TASK_SEQ = TBLJOBPOSTING.TASK_SEQ)
join tblcompany
on(TBLJOBPOSTING.company_seq = tblcompany.company_seq)
where WORK_PLACE like concat(concat('%',(select desired_place from TBLJOBSEEKER where student_seq = 'S0250' and open_course_seq = 'OL007')),'%')
and SALARY >= (select min_salary from TBLJOBSEEKER where student_seq = 'S0250' and open_course_seq = 'OL007')
and TO_CHAR(SYSDATE, 'YYYY-MM-DD') >= TO_CHAR(START_DATE, 'YYYY-MM-DD') 
and TO_CHAR(SYSDATE, 'YYYY-MM-DD') <= TO_CHAR(END_DATE, 'YYYY-MM-DD') 
and TBLTASK.name = '������'; --�����- �������� ã��

select TBLJOBSEEKER.student_seq as "��������ȣ",
TBLJOBSEEKER.open_course_seq as "����������ȣ",
TBLJOBSEEKER.desired_place as "����ٹ���",
TBLJOBSEEKER.min_salary as "�����������",
tbltask.name as "���������"
from TBLJOBSEEKER join tbltask
on(TBLJOBSEEKER.task_seq = tbltask.task_seq)
where TBLJOBSEEKER.desired_place like concat(concat('%',REGEXP_SUBSTR((select work_place from TBLJOBPOSTING where recruiter_seq= 'RE0059'),'\w+',1,1)),'%')
and min_salary <= (select salary from TBLJOBPOSTING where recruiter_seq= 'RE0059')
and TBLJOBSEEKER.TASK_SEQ = (select TASK_SEQ from TBLJOBPOSTING where recruiter_seq= 'RE0059'); --��� - ��ǿ� �´� �����ã��

