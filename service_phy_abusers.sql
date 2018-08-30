--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    QUESTION 3: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			--	Determine biggest abusers - Service / Providers


select count(physician_id) as abusers_phyid_count, physician_id from public."DQHI_Lab_Data" as labdata
inner join 
public.dqhi_service_data as servicedata
on labdata.physician_id=servicedata.doctor_id
where ia_flag is true
group by physician_id
order by abusers_phyid_count desc;


select service, physician_id, count(physician_id)  as abusers_phyid_count from public."DQHI_Lab_Data" as labdata
inner join 
public.dqhi_service_data as servicedata
on labdata.physician_id=servicedata.doctor_id
where ia_flag is true
group by physician_id, service
order by service asc , abusers_phyid_count DESC;

select count(service) as abusers_service_count, service, sum(costdata.total_cost) as total_cost,sum(costdata.charge_to_patients) as charge_to_pat from public."DQHI_Lab_Data" as labdata
inner join 
public.dqhi_service_data as servicedata on (labdata.physician_id=servicedata.doctor_id)
inner join  public.dqhi_cost_data as costdata on (costdata.group_test_code=labdata.group_test_code)
where ia_flag is true
group by service
order by abusers_service_count desc;


select count(ia_flag) as abusers_phyid_count, physician_id,
sum(costdata.total_cost) as total_cost,sum(costdata.charge_to_patients) as charge_to_pat from public."DQHI_Lab_Data" as labdata
inner join 
public.dqhi_service_data as servicedata on (labdata.physician_id=servicedata.doctor_id)
inner join  public.dqhi_cost_data as costdata on (costdata.group_test_code=labdata.group_test_code)
where ia_flag is true
group by physician_id
order by abusers_phyid_count desc;



