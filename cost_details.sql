--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    QUESTION 2: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			--	Cost incurred by the hospital and charge incurred by the patients


select labdata.group_test_code, sum(costdata.charge_to_patients) as charge_to_patients,sum(costdata.labor_cost) as labor_cost, sum(costdata.supply_cost) as supply_cost,
sum(costdata.equipment_cost) as equip_cost, sum(costdata.other_cost) as other_cost, sum(costdata.overhead_cost) as overhead_cost,
sum(costdata.total_cost) as total_cost, sum(costdata.variable_cost) as vc_cost, sum(costdata.total_cost+costdata.variable_cost) as overall_cost from public."DQHI_Lab_Data"  as labdata
inner join
public.dqhi_cost_data as costdata
on labdata.group_test_code=costdata.group_test_code
where ia_flag is true 
group by labdata.group_test_code, labdata.test_code,
costdata.total_cost, costdata.variable_cost;

