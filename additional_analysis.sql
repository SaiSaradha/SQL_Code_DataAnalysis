--
-- First Analysis : % of N vs A results at different levels

--Count of normal vs abnormal results for each group test code
select t1.group_test_code, t1.norm_abnorm, count(t1.norm_abnorm) from public."DQHI_Lab_Data" as t1
group by t1.group_test_code, t1.norm_abnorm
order by t1.group_test_code, t1.norm_abnorm;

--count of normal vs abnormal results overall
select norm_abnorm, count(norm_abnorm) from public."DQHI_Lab_Data"
group by norm_abnorm
order by norm_abnorm;

--count of normal vs abnormal for each component test within a group test code
select group_test_code, test_code, norm_abnorm, count(norm_abnorm) from public."DQHI_Lab_Data"
group by group_test_code, test_code, norm_abnorm
order by group_test_code, test_code, norm_abnorm;

--
--Second analysis: Male vs Female count for each group test code

select sex, group_test_code, count(distinct(patient_id)) from public."DQHI_Lab_Data"
group by sex, group_test_code;

-- Male vs Female count overall
select sex, count(distinct(patient_id)) from public."DQHI_Lab_Data"
group by sex;

--Male vs Female Normal vs Abnormal for each group test code
select sex, group_test_code, norm_abnorm, count(distinct(patient_id)) from public."DQHI_Lab_Data"
group by sex, group_test_code, norm_abnorm
order by sex, group_test_code, norm_abnorm;

--
-- Third Analysis : Turn Around time

-- Avg. TAT for each group test code
select group_test_code, avg(DATE_PART('minute', testing_complete::timestamp - received_in_lab::timestamp)) as TAT from public."DQHI_Lab_Data"
where s_no <> 200873 and s_no <> 293269 and s_no <> 293270 and s_no <> 293271 and s_no <> 5444468 and s_no <> 712437
group by group_test_code;




--
-- Fourth Analysis: Split of inappropriate test count:

-- by group test code:
select group_test_code, count(ia_flag) from public."DQHI_Lab_Data"
where ia_flag = 'true'
group by group_test_code;

-- overall:
select count(ia_flag) from public."DQHI_Lab_Data"
where ia_flag='true';

-- appropriate vs inappropriate :
select ia_flag, count(ia_flag) from public."DQHI_Lab_Data"
group by ia_flag;

-- appropriate vs inappropriate for each group test code :
select group_test_code, ia_flag, count(ia_flag) from public."DQHI_Lab_Data"
group by group_test_code, ia_flag
order by group_test_code, ia_flag;


select distinct (patient_id), count(ia_flag) as inappr_count, 0 as appr_count  from public."DQHI_Lab_Data" 
where ia_flag is true 
group by patient_id
union
select distinct (patient_id),0 as inappr_count, count(ia_flag) as appr_count from public."DQHI_Lab_Data" 
where ia_flag is false 
group by patient_id
order by inappr_count,appr_count desc;


select count(service) as abusers_service_count, service, sum(costdata.total_cost) as total_cost,sum(costdata.charge_to_patients) as charge_to_pat from public."DQHI_Lab_Data" as labdata
inner join 
public.dqhi_service_data as servicedata on (labdata.physician_id=servicedata.doctor_id)
inner join  public.dqhi_cost_data as costdata on (costdata.group_test_code=labdata.group_test_code)
where ia_flag is false
group by service
order by abusers_service_count desc;