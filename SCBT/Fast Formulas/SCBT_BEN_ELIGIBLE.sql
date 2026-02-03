/*****************************************************************************
FORMULA NAME: SCBT_BEN_ELIGIBLE
FORMULA TYPE: Person Selection Rule
DESCRIPTION: 
Change History:
Name Date Comments
-----------------------------------------------
Nancy	   30-Mar-2025	 	1.0	    Initial Version
*******************************************************************************/
DEFAULT FOR PER_ASG_BARGAINING_UNIT_CODE IS 'X'
DEFAULT FOR PER_ASG_EMPLOYMENT_CATEGORY is 'X'
DEFAULT FOR PER_PER_LATEST_REHIRE_DATE IS '1951/01/01 00:00:00'(DATE)
DEFAULT FOR BEN_IV_PERSON_ID  is '300000057160741' 
INPUTS ARE BEN_IV_PERSON_ID

L_OUTPUT='N'
l_LOS_3_MONTH='N'
l_LOS_6_MONTH='N'
l_LOS_12_MONTH='N'
l_row='X'
l_Person_ID = BEN_IV_PERSON_ID
l_SEN_DATE='X' 


Person_BargainingUnit_Code = PER_ASG_BARGAINING_UNIT_CODE
Asg_Cat = PER_ASG_EMPLOYMENT_CATEGORY
l_row=Person_BargainingUnit_Code+ '-'+ Asg_Cat


l_Eff_Date = GET_CONTEXT(EFFECTIVE_DATE,to_date('1900/01/01 00:00:00'))

/* l_SEN_DATE = GET_VALUE_SET('SCBT_BEN_SENIORITY_DATE','|=P_PERSON_ID='''||l_Person_ID||''''|| '=|P_EFFECTIVE_DATE=''' || to_char(l_Eff_Date,'YYYY/MM/DD') ||'''') */

l_SEN_DATE = GET_VALUE_SET('SCBT_BEN_SENIORITY_DATE','|=P_PERSON_ID='''||l_Person_ID||'''|P_EFFECTIVE_DATE='''||to_char(TRUNC(l_Eff_Date), 'YYYY/MM/DD')||'''')

l_LOS= MONTHS_BETWEEN(TO_DATE(l_SEN_DATE,'YYYY/MM/DD'),l_Eff_Date )


CHANGE_CONTEXTS(LEGISLATIVE_DATA_GROUP_ID = 300000005316085)
(
 l_LOS_3_MONTH = GET_TABLE_VALUE('SCBT_BEN_LOS_AC_LE','LOS3Months',l_row, 'N')
 l_LOS_6_MONTH = GET_TABLE_VALUE('SCBT_BEN_LOS_AC_LE','LOS6Months',l_row, 'N')
 l_LOS_12_MONTH = GET_TABLE_VALUE('SCBT_BEN_LOS_AC_LE','LOS12Months',l_row, 'N')
) 
log = ess_log_write('l_Eff_Date -'+ to_char(l_Eff_Date))
log = ess_log_write('l_Person_ID -'+ l_Person_ID)
log = ess_log_write('Person_BargainingUnit_Code =>' + Person_BargainingUnit_Code)
log = ess_log_write('PER_ASG_EMPLOYMENT_CATEGORY =>' + PER_ASG_EMPLOYMENT_CATEGORY)
log = ess_log_write('l_row =>' + l_row)

log = ess_log_write('l_LOS =>'+ to_char(l_LOS ))
log = ess_log_write('l_SEN_DATE =>'+ l_SEN_DATE )


IF (l_LOS_3_MONTH='Y'AND l_LOS = 3) or (l_LOS_6_MONTH ='Y'AND l_LOS= 6) or (l_LOS_12_MONTH ='Y'AND l_LOS= 12)
THEN
L_OUTPUT='Y'

return L_OUTPUT