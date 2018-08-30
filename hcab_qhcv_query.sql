--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    GUIDELINE 3: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		--	Instances where patients receive a positive HCAB and don’t receive a follow up QHCV are considered inappropriate, 
				--as are instances where patients receive a QHCV without first having a positive HCAB.

-- Updates the inappropriate rows by setting ia_flag to true after validating the rows
-- NOTE: ia_flag - if set true (Inappropriate) 
					-- else Appropriate 

-- CONDITION 1: 
	-- HCAB +ve and QHCV present within 90 days
-- CONDITION 2: 
	-- HCAB -ve and QHCV not present within 90 days
-- CONDITION 3:
	-- QHCV present without prior HCAB tests
select lefttable.s_no from
((select * from public."DQHI_Lab_Data" as t1
where group_test_code='HCAB') as lefttable
left join 
lateral (select * from public."DQHI_Lab_Data" as t2 where  
(DATE_PART('day', t2.testing_complete::timestamp - lefttable.testing_complete::timestamp)>0) and
(DATE_PART('day', t2.testing_complete::timestamp - lefttable.testing_complete::timestamp)<90)) as righttable 
on lefttable.patient_id=righttable.patient_id)
group by lefttable.patient_id, righttable.group_test_code, lefttable.testing_complete, 
righttable.testing_complete, lefttable.group_test_code, lefttable.norm_abnorm, lefttable.s_no
having 
(lefttable.norm_abnorm='N' and righttable.group_test_code='QHCV' and count(righttable.group_test_code='QHCV')>0) or 
(lefttable.norm_abnorm='A' and count(righttable.group_test_code='QHCV')=0) 
union
select lefttable1.s_no from ((select * from public."DQHI_Lab_Data" as t1
where group_test_code='QHCV') as lefttable1
left join 
lateral (select * from public."DQHI_Lab_Data" as t2 where  
(DATE_PART('day', lefttable1.testing_complete::timestamp - t2.testing_complete::timestamp)>0) and
(DATE_PART('day', lefttable1.testing_complete::timestamp - t2.testing_complete::timestamp)<90)) as righttable1 
on lefttable1.patient_id=righttable1.patient_id)
group by lefttable1.patient_id, righttable1.group_test_code, lefttable1.testing_complete, 
righttable1.testing_complete, lefttable1.group_test_code, lefttable1.norm_abnorm, lefttable1.s_no
having 
(count(righttable1.group_test_code='HCAB')=0) 
;

-- Creating temporary table to store the inappropriate tests details for updation of rows
insert into public.HCAB_TEMP values(-- result of previously executed query)
;

--Updation of inappropriate rows 
update public."DQHI_Lab_Data" set ia_flag = true where s_no in( select s_no from temp_table);


--Query to pull the updated records of third guideline
select * from public."DQHI_Lab_Data" where group_test_code in ('QHCV','HCAB') and ia_flag is true;


