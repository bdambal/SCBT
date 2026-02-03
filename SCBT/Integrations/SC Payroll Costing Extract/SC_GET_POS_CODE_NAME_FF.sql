INPUTS ARE DATA_ELEMENTS (TEXT_TEXT)
RET=ESS_LOG_WRITE('SC_GET_POS_CODE_NAME_FF Fast Formula Started')
l_per_number = '0'
l_cost_id = 0
IF DATA_ELEMENTS.EXISTS('Cost_Id') THEN
(
	l_cost_id= to_number(DATA_ELEMENTS['Cost_Id'])
)
 
RET=ESS_LOG_WRITE('l_cost_id' || to_char(l_cost_id))
l_val = GET_VALUE_SET('SC_GET_DATE_VS', '|=P_COST_ID='''		||TO_CHAR(l_cost_id)||'''')||' '
IF l_val = ' ' then
(
	IF DATA_ELEMENTS.EXISTS('Pay_Period_Start_Date') THEN
	(
		l_eff_dt= (DATA_ELEMENTS['Pay_Period_Start_Date'])
	)	
)
ELSE
(
	l_eff_dt = trim(l_val)
)
IF DATA_ELEMENTS.EXISTS('Employee_Number') THEN
(
	l_per_number= DATA_ELEMENTS['Employee_Number']
)
l_eff_dt = SUBSTR(l_eff_dt, 1, 10)
RET=ESS_LOG_WRITE('l_per_number' || (l_per_number))
RET=ESS_LOG_WRITE('l_eff_dt' || (l_eff_dt))
l_val = (GET_VALUE_SET('SC_GET_POS_CODE_NAME_VS',
								'|=P_PERSON_NUMBER='''		||(l_per_number)||''''||
								'|P_EFFECTIVE_DATE='''||l_eff_dt||''''))
rule_value = l_val
 
RET=ESS_LOG_WRITE('Final Value ' || (l_val))
RET=ESS_LOG_WRITE('SC_GET_POS_CODE_NAME_FF Fast Formula Ended')
RETURN rule_value