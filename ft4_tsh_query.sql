
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    GUIDELINE 4: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			--	Any FT4 test that is not preceded by an abnormal TSH test is considered inappropriate.


-- Filter FT4 and TSH filter based on conditions
select s_no,lefttable.patient_id, lefttable.testing_complete, righttable.testing_complete,  
DATE_PART('day', lefttable.testing_complete::timestamp - righttable.testing_complete::timestamp) from (
(select s_no, patient_id,testing_complete from public."DQHI_Lab_Data" where group_test_code='FT4') as lefttable
left join 
lateral (select patient_id,testing_complete, group_test_code, norm_abnorm from public."DQHI_Lab_Data" where
DATE_PART('day', lefttable.testing_complete::timestamp - testing_complete::timestamp)<=0 ) as righttable
on lefttable.patient_id=righttable.patient_id)
group by lefttable.patient_id, lefttable.testing_complete, righttable.testing_complete, righttable.group_test_code, righttable.norm_abnorm, s_no
having (righttable.group_test_code='TSH' and righttable.norm_abnorm='A' and count(righttable.group_test_code='TSH')>0) or
(count(righttable.group_test_code='TSH')=0)


--Update rows for ft4 condition check
update public."DQHI_Lab_Data" set ia_flag=true
where s_no in (
select s_no from (
(select s_no, patient_id,testing_complete from public."DQHI_Lab_Data" where group_test_code='FT4') as lefttable
left join 
lateral (select patient_id,testing_complete, group_test_code, norm_abnorm from public."DQHI_Lab_Data" where
DATE_PART('day', lefttable.testing_complete::timestamp - testing_complete::timestamp)<=0 ) as righttable
on lefttable.patient_id=righttable.patient_id)
group by lefttable.patient_id, lefttable.testing_complete, righttable.testing_complete, righttable.group_test_code, righttable.norm_abnorm, s_no
having (righttable.group_test_code='TSH' and righttable.norm_abnorm='A' and count(righttable.group_test_code='TSH')>0) or
(count(righttable.group_test_code='TSH')=0));


--Query to pull the updated records of fourth guideline
select * from public."DQHI_Lab_Data" where ia_flag is true and group_test_code='FT4';






