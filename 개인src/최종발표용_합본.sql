SELECT SYSDATE, CURRENT_DATE, DBTIMEZONE, SESSIONTIMEZONE
FROM DUAL;

select to_char(sysdate, 'yyyy-mm-dd hh24:mi:ss'), to_char(current_date, 'yyyy-mm-dd hh24:mi:ss')
from dual;

ALTER SESSION SET TIME_ZONE ='Asia/Seoul';

------------------------------------------------------------------------------------------------------------------------

BEGIN -- 기초 교재 정보 추가 ★
 procTextbookIstAct_M('테스트교재명', '테스트출판사');
END;

-- 기초 교재 정보 조회 ★
select textbook_seq as "교재코드", name as "교재명", publisher as "출판사" from tbltextbook;

BEGIN -- 타겟 1: > 교재명 수정 ★
 procUpdateTextbookAct_M('B122', '1', '수정 교재명');
END;

BEGIN -- 타겟 1: > 교재코드로 찾아서 삭제 ★
 procTextbookDltAct_M('1', 'B122');
END;

BEGIN -- ① 로그인 기능 프로시저 ★
 procLogin_All('아이디(이름)','비밀번호','교사or학생or관리자');
END;
BEGIN -- ex) 교사 로그인하기
 procLogin_All('이윤후','2482932','교사');
END;
BEGIN -- ex) 학생 로그인하기
 procLogin_All('정하하','2654210','학생');
END;
BEGIN -- ex) 관리자 로그인하기
 procLogin_All('qkcu5302','adlj8683','관리자');
END;
--***** 비밀번호 오류시 오류출력문 출력
-- ⑥ 전체 교사 목록 출력하기 (강의 가능 과목까지 전부) ★
SELECT * FROM vwAllTeacher;
-- ⑦ 단일 교사 정보 출력하기 ★
SELECT
    b.name AS "교사명",
    c.name AS "과목명",
    a.subject_start_date AS "과목시작날짜",
    a.subject_end_date AS "과목종료날짜",
    f.name AS "과정명",
    d.course_start_date AS "과정시작일",
    d.course_end_date AS "과정종료일",
    g.name AS "교재명", e.name AS "강의실",
    d.course_progress AS "강의진행여부"
FROM tblOpenSubject a
    INNER JOIN tblTeacher b ON a.teacher_seq=b.teacher_seq
    INNER JOIN tblSubject c ON a.subject_seq=c.subject_seq
    INNER JOIN tblOpenCourse d ON a.open_course_seq=d.open_course_seq
    INNER JOIN tblClassroom e ON d.classroom_seq=e.classroom_seq
    INNER JOIN tblcourse f ON d.course_seq=f.course_seq
    INNER JOIN tblTextbook g ON a.textbook_seq=g.textbook_seq
        WHERE b.teacher_seq='T001';--교사코드 입력

--② 모든 개설 과정 정보 출력 ★
select * from vwAllCourse;

--③ 특정 개설 과정 정보 출력
--4-1) 등록된 개설 과목 정보 ★
SELECT b.name AS "과목명", a.subject_start_date AS "과목시작일", a.subject_end_date AS "과목종료일", d.name AS "교재명", c.name AS "교사명"
FROM tblOpenSubject a
INNER JOIN tblSubject b ON a.subject_seq=b.subject_seq
INNER JOIN tblTeacher c ON a.teacher_seq=c.teacher_seq
INNER JOIN tblTextbook d ON a.textbook_seq=d.textbook_seq
WHERE a.open_course_seq='OL007';--과정코드 입력

--4-2) 등록된 교육생 정보 ★
SELECT b.name AS "교육생 이름", b.idcard_number AS "주민번호 뒷자리", b.tel AS "전화번호", b.registration_date AS "등록일", a.completion_status AS "수료여부", a.completion_date AS "수료날짜", a.dropout_date AS "중도탈락날짜"
FROM tblRegister a
INNER JOIN tblStudent b ON a.student_seq=b.student_seq
WHERE a.open_course_seq='OL007';--과정코드 입력


-- 과정별 출결관리 및 출결조회
-- procAttendanceManagementAct('과정코드', '0', '0')                  > 전체검색
-- procAttendanceManagementAct('과정코드', '이름', '0')                > 이름검색
-- procAttendanceManagementAct('과정코드', '시작날짜', '종료날짜')       > 날짜검색
--BEGIN -- ex 전체검색 ★
-- procAttendanceManagementAct('OL007', '0', '0');
--END;
BEGIN -- ex 이름검색 ★
 procAttendanceManagementAct('OL007', '이시조', '0');
END;
BEGIN -- ex 날짜검색 ★
 procAttendanceManagementAct('OL007', '2021-01-01', '2021-01-31');
END;


------------------------------------------------------------------------------------------------------------------------
--********** 개설과목 추가 프로시저 테스트 **********--
DECLARE
    VRESULT NUMBER;
BEGIN
    procAddOpenSubject_M
        ('SUB019',
         'T010',
         'B057',
         '2022-07-04',
         '2022-08-03',
         (CASE
              WHEN (SYSDATE BETWEEN TO_DATE('2022-07-04', 'YYYY-MM-DD') AND TO_DATE('2022-08-03', 'YYYY-MM-DD'))
                  THEN '강의중'
              WHEN (SYSDATE < TO_DATE('2022-07-04', 'YYYY-MM-DD')) THEN '강의예정'
              WHEN (SYSDATE > TO_DATE('2022-08-03', 'YYYY-MM-DD')) THEN '강의종료'
              ELSE '폐강'
             END),
         'N',
         'N',
         '',
         '',
         '',
         'OL006',
         VRESULT
        );
    if VRESULT = 1 THEN
        DBMS_OUTPUT.PUT_LINE('입력성공');
    else
        DBMS_OUTPUT.PUT_LINE('입력실패');
    end if;
end ;
------------------------------------------------------------------------------------------------------------------------
--********** 수정 되었는지 확인용 **********--
SELECT OPEN_COURSE_SEQ         AS 개설과정번호,
       OPEN_SUBJECT_SEQ        AS 개설과목번호,
       SUBJECT_SEQ             AS 과목번호,
       TEACHER_SEQ             AS 교사번호,
       TEXTBOOK_SEQ            AS 교재번호,
       SUBJECT_START_DATE      AS 과목시작일,
       SUBJECT_END_DATE        AS 과목종료일,
       SUBJECT_PROGRESS        AS 강의진행여부,
       SCORE_CHECK             AS 성적등록여부,
       TESTFILE_CHECK          AS 시험문제파일등록여부,
       ATTENDANCE_DISTRIBUTION AS 출결배점,
       WRITTEN_DISTRIBUTION    AS 필기배점,
       PRACTICAL_DISTRIBUTION  AS 실기배점
FROM TBLOPENSUBJECT
WHERE OPEN_COURSE_SEQ = 'OL006';
------------------------------------------------------------------------------------------------------------------------
--********** 삭제 프로시저 테스트 **********--
DECLARE
    V_RESULT NUMBER;
BEGIN
    ProcDeleteOpenSubject_M('OS082', V_RESULT);
    IF V_RESULT = 1 THEN
        DBMS_OUTPUT.PUT_LINE('삭제완료');
    else
        DBMS_OUTPUT.PUT_LINE('삭제실패');
    end if;
end;
------------------------------------------------------------------------------------------------------------------------
--********** 교사 변경 프로시저 테스트 **********--
DECLARE
    V_RESULT NUMBER;
BEGIN
    ProcUpdateOpenSubject_M('T009', 'OS081', V_RESULT);
    IF V_RESULT = 1 THEN
        DBMS_OUTPUT.PUT_LINE('수정성공');
    ELSE
        DBMS_OUTPUT.PUT_LINE('수정실패');
    end if;
end;
------------------------------------------------------------------------------------------------------------------------
--********** 교육생 추가 프로시저 테스트 **********--
DECLARE
    VRESULT NUMBER;
BEGIN
    ProcAddStudent_M(
            '강규준',
            '1234567',
            '010-5671-0790',
            VRESULT
        );
    IF VRESULT = 1 THEN
        DBMS_OUTPUT.PUT_LINE('등록성공');
    ELSE
        DBMS_OUTPUT.PUT_LINE('등록실패');
    end if;
end;
------------------------------------------------------------------------------------------------------------------------
--********** 교육생 추가 프로시저 확인용 **********--
SELECT *
FROM TBLSTUDENT;
------------------------------------------------------------------------------------------------------------------------
--********** 중도탈락 프로시저 테스트 **********--
DECLARE
    V_RESULT NUMBER;
BEGIN
    ProcUpdateStudentDropoutDate_M('S0126','OL003', 'N', '2021-12-03', V_RESULT);
    IF V_RESULT = 1 THEN
        DBMS_OUTPUT.PUT_LINE('중도탈락 처리 완료');
    ELSE
        DBMS_OUTPUT.PUT_LINE('중도탈락 처리 실패');
    end if;
end;
------------------------------------------------------------------------------------------------------------------------
--********** 수료 프로시저 테스트 **********--
DECLARE
    V_RESULT NUMBER;
BEGIN
    ProcUpdateStudentCompletionDate_M('S0126','OL003','Y','2021-12-03',V_RESULT);
    IF V_RESULT = 1 THEN
        DBMS_OUTPUT.PUT_LINE('수료처리 완료');
    ELSE
        DBMS_OUTPUT.PUT_LINE('수료처리 실패');
    end if;
END;
------------------------------------------------------------------------------------------------------------------------
--확인용
SELECT COUR.NAME                  AS 과정명,
       OPENCOUR.COURSE_START_DATE AS 과정시작날짜,
       OPENCOUR.COURSE_END_DATE   AS 과정종료날짜,
       ROOM.NAME                  AS 강의실,
       REG.COMPLETION_STATUS      AS 수료여부,
       REG.COMPLETION_DATE        AS 수료날짜,
       REG.DROPOUT_DATE           AS 중도탈락날짜,
       REG.STUDENT_SEQ            AS 교육생번호

FROM TBLSTUDENT STU
         INNER JOIN TBLREGISTER REG
                    on STU.STUDENT_SEQ = REG.STUDENT_SEQ
         INNER JOIN TBLOPENCOURSE OPENCOUR
                    on REG.OPEN_COURSE_SEQ = OPENCOUR.OPEN_COURSE_SEQ
         INNER JOIN TBLCOURSE COUR
                    on OPENCOUR.COURSE_SEQ = COUR.COURSE_SEQ
         INNER JOIN TBLCLASSROOM ROOM
                    on OPENCOUR.CLASSROOM_SEQ = ROOM.CLASSROOM_SEQ
WHERE STU.STUDENT_SEQ = 'S0126';
--초기화용
UPDATE TBLREGISTER
SET COMPLETION_STATUS='',
    COMPLETION_DATE='',
    DROPOUT_DATE=''
WHERE STUDENT_SEQ = 'S0126'
  AND OPEN_COURSE_SEQ = 'OL003';

------------------------------------------------------------------------------------------------------------------------
--********** 교육색 삭제 프로시저 테스트 **********--
DECLARE
    V_RESULT NUMBER;
BEGIN
    ProcDeleteStudent_M('S0502',V_RESULT);
    IF V_RESULT =1 THEN
        DBMS_OUTPUT.PUT_LINE('삭제완료');
    ELSE
        DBMS_OUTPUT.PUT_LINE('삭제실패');
    end if;
END;
------------------------------------------------------------------------------------------------------------------------
--*************** 교육생별 출력시 출력 정보 ***************--
SELECT * FROM VWOpenSubjectStudentScore_M WHERE 교육생이름 ='정문희';
------------------------------------------------------------------------------------------------------------------------
/*
교사
- 교사 스케줄 확인
- 성적 입출력 -> 출결/필기/실기점수 입력 -> scoreInfo -> 환산점수/총점점수 업데이트
*/

----------- 1.1) 교사별 > 강의스케줄 출력__뷰
select * from vwteacherschedul_t where 교사번호 = 'T001';


----------- 1.2) 특정 과목번호 선택 > 해당 과정 교육생 정보 출력_뷰
select * from vwopensubjectstudent_t where 개설과목번호 = 'OS001';


----------- 3.3.2.2) 성적정보테이블 > 필기점수 환산 입력(수정)_프로시저
declare
    vopen_subject_seq   tblscoreinfo.opensubject_seq%type   := 'OS001';   -- 개설과목번호
    vtest_type          tbltest.type%type                   := '필기';    -- 시험타입
    vstudent_seq        tblstudent.student_seq%type         := 'S0004';   -- 학생번호
    pscore              number                              := 70;       -- 점수 (여기를 수정)
    vresult             number;
begin
    procAddWtScore_T(vopen_subject_seq, vtest_type , vstudent_seq , pscore, vresult);

    if vresult = 1 then
        dbms_output.put_line('필기점수 입력 성공');
        dbms_output.put_line('(과목 : ' || vopen_subject_seq || ', 타입 : ' || vtest_type ||', 학생 : ' || vstudent_seq ||', 필기점수 : ' || pscore || ')');
    else
        dbms_output.put_line('필기점수 입력 실패');
    end if;

end;
-- 여기먼저 보여주고 성적 변경 프로시저 실행
-- 시연)
-- 1. 변경 전/후 필기점수 + 환산점수 확인
-- [시험결과] 테이블
select * from tbltestresult
where test_seq = 'TEST0001' and student_seq = 'S0004';

-- [성적정보] 테이블
select * from tblscoreinfo
where opensubject_seq = 'OS001' and student_seq = 'S0004';
------------------------------------------------------------------------------------------------------------------------

--시연용


--------------------------------교육생 성적 조회

--[ 교육생이 로그인에 성공하면 ]
select * from tblstudent where student_seq = 'S0038';
--시연용 : 로그인을 위해 이 학생번호를 가진 학생의 기본 정보를 조회하여 이름과 비밀번호를 알아낸다
BEGIN -- ***
 procLogin_All('김조하','1770114','학생');
END;





-- *** 이름과 패스워드를 넣으면 학생번호(기본키)를 반환해주는 함수 ***

select * from tblstudent where student_seq = fnlogin_st('김조하', '1770114');


--[ 교육생 개인의 정보와 교육생이 수강한 과정명, 과정기간(시작 년월일, 끝 년월일), 강의실이 타이틀로 출력된다. ]

--[ 교육생은 한개의 과정만을 등록해서 수강한다. ]
select
    st.student_seq as "교육생 번호",
    st.name as "교육생 이름",
    st.tel as "전화번호",
    st.registration_date as "등록일자",
    c.name as "수강한 과정 이름",
    oc.course_start_date as "과정 시작일",
    oc.course_end_date as "과정 종료일",
    cr.name as "강의실 이름"
from tblregister r
    inner join tblstudent st
        on r.student_seq = st.student_seq
    inner join tblopencourse oc
        on r.open_course_seq = oc.open_course_seq
    inner join tblclassroom cr
        on oc.classroom_seq = cr.classroom_seq
    inner join tblcourse c
        on oc.course_seq = c.course_seq
where st.student_seq = fnlogin_st('김조하', '1770114');
--로그인할 경우 자동으로 로그인한 교육생의 '교육생번호'를 통해 해당하는 정보들을 보여준다.
--교육생은 '겹치지 않는' 한 개의 과정만을 등록해서 수강한다.




-----------------------------------교육생 출결관리 및 출결조회


-- *** 학생번호를 넣으면 현재 이 학생이 듣고 있는 과정번호를 반환해주는 함수 ***


select fnGetcourseSeq_ST('S0038') from dual;    --과정번호 함수 실행 확인용
select fnGetcourseSeq_ST(fnlogin_st('김조하', '1770114')) from dual;    --과정번호 함수 실행 확인용



--[ 매일의 근태를(출근 1회, 퇴근1회)를 기록할 수 있다. ]

--현재 날짜로 자동입력한다.
--근태 시간은 교육생이 직접 입력할 수 있도록 한다.



-- *** 오늘자 출근 시간 입력 + 지각 근태유형 입력 저장 프로시저 ***
-- ***** (출근 시간, 학생번호) -> 오늘자 출근 시간 입력 실행 익명 프로시저 *****
declare
    vresult number;
begin
    procAddDayAttendanceStart_ST('09:00:55','S0038', vresult);

    if vresult = 1 then
        dbms_output.put_line('출근시간 입력 완료');
    elsif vresult = 2 then
        dbms_output.put_line('출근시간 입력 완료. 근태유형 지각 처리 되었습니다.');
    else
        dbms_output.put_line('이미 출근시간을 입력하셨습니다.');    --중복레코드 / 입력값 오류..?
    end if;
end;


-- ***** (퇴근 시간, 학생번호) -> 오늘자 퇴근 시간 입력 실행 익명 프로시저 *****
declare
    vresult number;
begin
    procAddDayAttendanceEnd_ST('18:03:33','S0038', vresult);

    if vresult = 1 then
        dbms_output.put_line('퇴근시간 입력 완료.');
    elsif vresult = 2 then
        dbms_output.put_line('퇴근시간 입력 완료. 근태유형 정상 처리 되었습니다.');
    else
        dbms_output.put_line('이미 퇴근시간을 입력하셨습니다.');    --중복레코드 / 입력값 오류..?
    end if;
end;




-- + 관리자 요구사항에 추가해야할 필요 있어 보이는 것 : 근태 추가/수정하기
-- 관리자 혹은 교육생이 근태를 추가 입력해야 함

--TA03	조퇴
--TA04	외출
--TA05	병가
--TA06	기타


-- *** 오늘자 나머지 근태유형(조퇴, 외출, 병가, 기타) 입력/수정 저장 프로시저 ***

-- ***** (학생번호, 근태유형번호) -> 오늘자 근태유형 입력/수정 실행 익명 프로시저 *****
declare
    vresult number;
begin
    procAddAttendance_ST('S0038', 'TA03', vresult);

    if vresult = 1 then
        dbms_output.put_line('근태유형 입력 완료.');
    elsif vresult = 2 then
        dbms_output.put_line('근태유형 수정 완료.');
    else
        dbms_output.put_line('근태유형 입력/수정에 실패했습니다.');    --입력값 오류,..? 될 일이 없나
    end if;
end;




-- *** 원하는날짜 나머지 근태유형(조퇴, 외출, 병가, 기타) 수정 저장 프로시저 ***

--1)
-- *** (날짜, 학생번호, 근태유형번호) -> 원하는 날짜 근태유형 수정 실행 저장 프로시저 ***



-- ***** (날짜, 학생번호, 근태유형번호) -> 원하는 날짜 근태유형 수정 실행 익명 프로시저 *****
BEGIN
 procWantUpdateAttendanceAct_ST('2021-12-06', fnlogin_st('김조하', '1770114'), 'TA04');
END;



--* 출결/근태 테이블 간단 확인용

select * from tbldayattendance where student_seq = 'S0038' order by day_attendance_date desc;     --출퇴근 잘 입력됐나 간단 확인결

delete from tbldayattendance where student_seq = 'S0038' and to_char(day_attendance_date, 'yyyy-mm-dd') = to_char(current_date, 'yyyy-mm-dd') and is_attendance = '출근';    --방금 입력한 오늘자 출근 레코드 삭제

delete from tbldayattendance where student_seq = 'S0038' and to_char(day_attendance_date, 'yyyy-mm-dd') = to_char(current_date, 'yyyy-mm-dd') and is_attendance = '퇴근';    --방금 입력한 오늘자 퇴근 레코드 삭제


select * from tblattendance where student_seq = 'S0038' order by attendance_date desc;    --근태유형 잘 입력됐나 간단 확인

delete from tblattendance where student_seq = 'S0038' and to_char(attendance_date, 'yyyy-mm-dd') = to_char(current_date, 'yyyy-mm-dd');    --방금 입력한 오늘자 근태 레코드 삭제





--원래요구사항에는 이렇게
--* 확인용으로 교육생변 전체 출결조회 하나

--[ 모든 출결 조회는 근태 상황을 구분할 수 있다.(정상, 지각, 조퇴, 외출, 병가, 기타) ]

--[ 다른 교육생의 현황은 조회할 수 없다. ]

select
distinct
    s.student_seq as "교육생 번호",
    s.name as "교육생 이름",
    a.attendance_date as "날짜",
    att.attendance_type as "근태 상황",
    to_char(da.time, 'hh24:mi:ss') as "시간",
    da.is_attendance as "출/퇴근"
from tblattendance a
    inner join tblattendancetype att
        on a.attendance_type_seq = att.attendance_type_seq
    inner join tbldayattendance da
        on a.student_seq = da.student_seq
            and a.open_course_seq = da.open_course_seq
            and a.attendance_date = da.day_attendance_date
    inner join tblstudent s
        on s.student_seq = a.student_seq
where s.student_seq = fnlogin_st('김조하', '1770114')
order by a.attendance_date desc;
--교육생 로그인 시 자동으로 where 조건에 학생 번호가 붙어 해당 교육생의 전체 출결이 조회된다.
--fnlogin_st('김조하', '1770114');  --학생번호 'S0038'


------------------------------------------------------------------------------------------------------------------------

--각 과정 교육생들의 평균 점수, 최고 점수, 최저 점수를 조회
select open_course_seq as "과정번호",
round(avg(SUBJECT_SCORE),0) as "과정평균점수",
max(SUBJECT_SCORE) as "최고점수",
min(SUBJECT_SCORE) as "최저점수"
from tblScoreInfo
group by open_course_seq;

--각과목별 평균점수
select opensubject_seq as "과목번호",
round(avg(SUBJECT_SCORE),1) as "과목평균점수"
from tblScoreInfo
where SUBJECT_SCORE is not null
group by opensubject_seq
order by avg(SUBJECT_SCORE) desc;

--취업율 (전체 학생 대비 취업률 (수강종료대비 X))
BEGIN
 procEmploymentRate_A();
END;
--수료율
BEGIN
procCompletionRate_A();
END;
--채용공고정보입력 -구직자찾기
select TBLJOBSEEKER.student_seq as "교육생번호",
    TBLJOBSEEKER.open_course_seq as "개강과정번호",
    TBLJOBSEEKER.desired_place as "희망근무지",
    TBLJOBSEEKER.min_salary as "희망최저연봉",
    tbltask.name as "희망직무명"
    from TBLJOBSEEKER join tbltask
    on(TBLJOBSEEKER.task_seq = tbltask.task_seq)
    where TBLJOBSEEKER.desired_place like concat(concat('%',REGEXP_SUBSTR((select work_place from TBLJOBPOSTING where recruiter_seq= 'RE0059'),'\w+',1,1)),'%')
    and min_salary <= (select salary from TBLJOBPOSTING where recruiter_seq= 'RE0059')
    and TBLJOBSEEKER.TASK_SEQ = (select TASK_SEQ from TBLJOBPOSTING where recruiter_seq= 'RE0059');

--교육생 정보입력 -기업찾기
 select
    TBLJOBPOSTING.recruiter_seq as "모집번호",
    tblcompany.name as "기업명",
    TBLJOBPOSTING.work_place as "근무지",
    TBLJOBPOSTING.salary as "급여",
    TBLJOBPOSTING.education_level as "필요학력",
    TBLJOBPOSTING.employee_number as "채용인원",
    tbltask.name as "직무명"
    from tbltask join TBLJOBPOSTING
    on(tbltask.TASK_SEQ = TBLJOBPOSTING.TASK_SEQ)
    join tblcompany
    on(TBLJOBPOSTING.company_seq = tblcompany.company_seq)
    where WORK_PLACE like concat(concat('%',(select desired_place from TBLJOBSEEKER where student_seq =  'S0250' and open_course_seq = 'OL007')),'%')
    and SALARY >= (select min_salary from TBLJOBSEEKER where student_seq =  'S0250' and open_course_seq = 'OL007')
    and TO_CHAR(SYSDATE, 'YYYY-MM-DD') >= TO_CHAR(START_DATE, 'YYYY-MM-DD')
    and TO_CHAR(SYSDATE, 'YYYY-MM-DD') <= TO_CHAR(END_DATE, 'YYYY-MM-DD')
    and tblJobPosting.task_seq = (select TBLJOBSEEKER.task_seq from TBLJOBSEEKER where student_seq =  'S0250' and open_course_seq = 'OL007');

--평가점수입력
BEGIN
    procUpdateEvalScore_A();
end;