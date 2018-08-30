--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    GUIDELINE 2: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		--	Any Tacrolimus specimen collected on an inpatient outside of these time ranges is considered inappropriate.


-- Updates the inappropriate rows by setting ia_flag to true after validating the rows
-- NOTE: ia_flag - if set true (Inappropriate) 
					-- else Appropriate 
UPDATE public."DQHI_Lab_Data"
SET ia_flag=true
WHERE s_no in (
select t1.s_no
from public."DQHI_Lab_Data" as t1
	where upper(t1.patient_type)='INPATIENT' and 
	upper(t1.group_test_code)='TACRO' and
	((t1.specimen_collected::time not between time '07:30:00' and '09:00:00') and
	 (t1.specimen_collected::time not between time '19:30:00' and '21:00:00')));
              
--Query for Tacrolimus Guideline testing: Time validations are done based on the guideline ground rules
select * from public."DQHI_Lab_Data" as t1
	where upper(t1.patient_type)='INPATIENT' and 
	upper(t1.group_test_code)='TACRO' and
	((t1.specimen_collected::time not between time '07:30:00' and '09:00:00') and
	 (t1.specimen_collected::time not between time '19:30:00' and '21:00:00'));
	

	
-- Alternate Query to pull inappropriate records of GUIDELINE 1 alone:
select * from public."DQHI_Lab_Data" where ia_flag is true and group_test_code='TACRO';


	
	

            
	
