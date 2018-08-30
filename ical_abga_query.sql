--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    GUIDELINE 1: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
					--	Any ICAL ordered within 15 minutes of an ABGA is considered inappropriate.
   

-- Updates the inappropriate rows by setting ia_flag to true after validating the rows
-- NOTE: ia_flag - if set true (Inappropriate) 
					-- else Appropriate 
UPDATE public."DQHI_Lab_Data"
SET ia_flag=true
WHERE s_no in (
select t1.s_no
from public."DQHI_Lab_Data" as t1
inner join public."DQHI_Lab_Data" as t2
on t1.patient_id=t2.patient_id and
t1.order_released::timestamp::date=t2.order_released::timestamp::date and
upper(t1.group_test_code)='ICAL' and
upper(t2.group_test_code)='ABGA'
where (((DATE_PART('day', t1.order_released::timestamp - t2.order_released::timestamp) * 24 + 
               DATE_PART('hour', t1.order_released::timestamp - t2.order_released::timestamp)) * 60 +
               DATE_PART('minute', t1.order_released::timestamp - t2.order_released::timestamp)) < 15) and 
              ((DATE_PART('day', t1.order_released::timestamp - t2.order_released::timestamp) * 24 + 
               DATE_PART('hour', t1.order_released::timestamp - t2.order_released::timestamp)) * 60 +
               DATE_PART('minute', t1.order_released::timestamp - t2.order_released::timestamp) >=0));             

              
              
--Query for ICAL - ABGA Guideline : Compares the time difference between ICAL and ABGA and determines the inappropriate records
select t1.s_no as t1_s, t2.s_no as t2_s, t1.sex,t1.patient_type,t1.patient_id,t1.order_number,t1.physician_id,t1.stay_ward,t1.test_code,t1.test_name,
t1.group_test_code as t1_gtc,t1."result",t1.norm_abnorm,t1.order_released as t1_test_ordered,t1.scheduled_collection,t1.specimen_collected,t1.received_in_lab,t1.testing_complete, t2.order_released as t2_test_ordered,
t2.group_test_code as t2_gtc,t1.ia_flag, ((DATE_PART('day', t1.order_released::timestamp - t2.order_released::timestamp) * 24 + 
               DATE_PART('hour', t1.order_released::timestamp - t2.order_released::timestamp)) * 60 +
               DATE_PART('minute', t1.order_released::timestamp - t2.order_released::timestamp)) as date_diff 
from public."DQHI_Lab_Data" as t1
inner join public."DQHI_Lab_Data" as t2
on t1.patient_id=t2.patient_id and
t1.order_released::timestamp::date=t2.order_released::timestamp::date and
upper(t1.group_test_code)='ICAL' and
upper(t2.group_test_code)='ABGA' 
where (((DATE_PART('day', t1.order_released::timestamp - t2.order_released::timestamp) * 24 + 
               DATE_PART('hour', t1.order_released::timestamp - t2.order_released::timestamp)) * 60 +
               DATE_PART('minute', t1.order_released::timestamp - t2.order_released::timestamp)) < 15) and 
              ((DATE_PART('day', t1.order_released::timestamp - t2.order_released::timestamp) * 24 + 
               DATE_PART('hour', t1.order_released::timestamp - t2.order_released::timestamp)) * 60 +
               DATE_PART('minute', t1.order_released::timestamp - t2.order_released::timestamp) >=0) 
            ;
             
              
-- Alternate Query to pull inappropriate records of GUIDELINE 1 alone:
select * from public."DQHI_Lab_Data" where ia_flag is true and group_test_code='ICAL';

         