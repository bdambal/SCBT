/* **************************************************************************
FORMULA NAME: SC_ABS_Casual_Illness_Leave_Accrual_FF
FORMULA TYPE: Global Absence Accrual Matrix
DESCRIPTION : This Formula returns accrual hours for casual illness leave bank. 

Change History:
Name					Date 			Version 		Comments
-------------------------------------------------------------------------------
Vaishnavi Agrawal		18-Feb-2022 	1.0 			Initial Version
Vaishnavi Agrawal		23-Mar-2022		1.1				IAFF: Return 0 accrual if employee is currently enrolled into IAFF monthly plan
Vaishnavi Agrawal		23-Apr-2022		1.2				Carryover: 16 hrs carryover for AUPE Permanent & temporary employees. 0 carryover
														for all other employee groups
Raghu Raman				18-Oct-2022		1.1				IAFF - Compare the Plan name for Employee Hired before 2023 and after 2024
Sendil					23-Jan-2025	    1.4				Removed Carryover from accrual FF
****************************************************************************** */


/* ************************ Database Item Defaults ******************************** */

DEFAULT FOR IV_ACCRUALPERIODSTARTDATE			IS '4712/12/31 00:00:00' (date) 
DEFAULT FOR IV_ACCRUALPERIODENDDATE				IS '4712/12/31 00:00:00' (date) 
DEFAULT FOR IV_PLANENROLLMENTSTARTDATE			IS '4712/12/31 00:00:00' (date) 
DEFAULT FOR PER_ASG_REL_DATE_START 				IS '4712/12/31' (date)   		/*  Hire_date */
DEFAULT FOR PER_ASG_FREQUENCY_MEANING			IS	'XX'
DEFAULT FOR PER_ASG_FTE_VALUE 					IS 	1
DEFAULT FOR PER_ASG_BARGAINING_UNIT_CODE 		IS 'XX'
DEFAULT FOR PER_ASG_BARGAINING_UNIT_CODE_NAME 	IS 'XX'
DEFAULT FOR PER_ASG_EMPLOYMENT_CATEGORY			IS	'XX'
DEFAULT FOR PER_ASG_STANDARD_WORKING_HOURS		IS	00
DEFAULT FOR PER_PER_LATEST_REHIRE_DATE 			IS '4712/12/31' (date)			/* Rehire Date */
DEFAULT FOR PER_PER_LATEST_TERMINATION_DATE		IS '4712/12/31' (date)			/* Termination Date */
DEFAULT FOR PER_PERSON_ENTERPRISE_HIRE_DATE		IS '4712/12/31' (date)			/* Enterprise Hire Date */

/* ****************************** Inputs ********************************************/
INPUTS ARE IV_ACCRUALPERIODSTARTDATE (DATE) , IV_ACCRUALPERIODENDDATE (DATE), IV_PLANENROLLMENTSTARTDATE (DATE)


/* ************************* Variable Defaults **************************************/

l_accr_prdstrt_dt			=	IV_ACCRUALPERIODSTARTDATE
l_accr_prdend_dt			=	IV_ACCRUALPERIODENDDATE
l_plan_enrl_dt				=	IV_PLANENROLLMENTSTARTDATE
l_hire_date					=	PER_ASG_REL_DATE_START
l_assignment_id				= 	GET_CONTEXT(HR_ASSIGNMENT_ID,0)
l_effective_date    		= 	GET_CONTEXT(EFFECTIVE_DATE, '0001/01/01 00:00:00'(date))
l_per_id					= 	GET_CONTEXT(PERSON_ID,0)
l_plan_id					=	GET_CONTEXT(ACCRUAL_PLAN_ID,0) 

l_ent_hire_dt				=	'0001/01/01'(date)
l_rehire_dt					=	'0001/01/01'(date)
l_term_dt					=	'0001/01/01'(date)
l_barg_unit					=	'X'
l_barg_unit_code			=	'X'
l_emp_grp					=	'X'
l_wrk_hrs					=	0
l_wrk_frq					=	'X'
l_unpaid_abs				=	'N'
l_asg_ctg					=	'X'
l_fte						=	1
l_year						=	0
l_acc_rate					=	0
l_accrual					=	0
l_prob_hrs					=	0
l_iaff_balance				=	0
l_debug_flag 				=	'Y'
ACCRUAL						=	0
/* CARRYOVER					=	0 */

/* ******************************** Formula **************************************/

/* fetch assignment details from core HR */

l_barg_unit 		=	PER_ASG_BARGAINING_UNIT_CODE_NAME 
l_barg_unit_code	=	PER_ASG_BARGAINING_UNIT_CODE
l_wrk_frq			=	PER_ASG_FREQUENCY_MEANING
l_wrk_hrs			=	PER_ASG_STANDARD_WORKING_HOURS
l_fte				=	PER_ASG_FTE_VALUE
l_asg_ctg			=	PER_ASG_EMPLOYMENT_CATEGORY

IF l_debug_flag = 'Y' THEN
(
	l_log_accrual = ess_log_write(' ------------------ Starting Formula SC_ABS_Casual_Illness_Leave_Accrual_FF ------------------ ')
	l_log_accrual = ess_log_write('Person ID : 					' ||TO_CHAR(l_per_id))
	l_log_accrual = ess_log_write('Assignment ID: 					' ||TO_CHAR(l_assignment_id))
	l_log_accrual = ess_log_write('Effective Date : 				' ||TO_CHAR(l_effective_date,'YYYY-MM-DD'))
	l_log_accrual = ess_log_write('Accrual Period Start Date : 			' ||TO_CHAR(l_accr_prdstrt_dt,'YYYY-MM-DD'))
	l_log_accrual = ess_log_write('Accrual Period End Date : 			' ||TO_CHAR(l_accr_prdend_dt,'YYYY-MM-DD'))
	l_log_accrual = ess_log_write('Enterprise Hire Date : 				' ||TO_CHAR(l_hire_date,'YYYY-MM-DD'))
	l_log_accrual = ess_log_write('FTE : 						' ||TO_CHAR(l_fte))
	l_log_accrual = ess_log_write('Assignment Category : 				' ||l_asg_ctg)
	l_log_accrual = ess_log_write('Standard Working Hours : 			' ||TO_CHAR(l_wrk_hrs))
	l_log_accrual = ess_log_write('Work Frequency : 				' ||l_wrk_frq)
	l_log_accrual = ess_log_write('Bargaining Unit : 				' ||l_barg_unit)
	l_log_accrual = ess_log_write('Bargaining Unit Code : 				' ||l_barg_unit_code)
	
	
)

/* ************************************* Logic ******************************************* */

l_emp_grp	=	SUBSTR(l_barg_unit,1,INSTR(l_barg_unit, ' ')-1) 		/* Check employee group- Classified / Library / Contracts / AUPE / IAFF */

IF (l_emp_grp = 'Classified' OR l_emp_grp = 'Library' OR (l_emp_grp = 'Contracts' AND (l_asg_ctg = 'FT' OR l_asg_ctg = 'PT'))) THEN
(
	l_acc_rate	=	TO_NUMBER(GET_TABLE_VALUE('SC_ABS_CASUAL_ILLNESS_ACCRUAL_RATE_UDT',l_barg_unit_code,TO_CHAR(l_wrk_hrs),'0'))
	l_accrual	=	l_acc_rate * ROUND(l_fte, 2)
	
	IF l_debug_flag = 'Y' THEN
	(
		l_log_accrual = ess_log_write('------------- Employee Group: ' ||l_emp_grp)
		l_log_accrual = ess_log_write('Accrual Rate : 					' ||TO_CHAR(l_acc_rate))			/* 70 / 80 */
	)
	
)
ELSE IF (l_barg_unit = 'IAFF') THEN
(


    l_hire_year=TO_CHAR(l_hire_date,'YYYY')
	
	If l_hire_year > '2023' Then
	(
	l_iaff_plan_name	=	'Casual_Illness IAFF'	
	)

	Else
	(
	l_iaff_plan_name	=	'Casual Illness IAFF'
	)	
	
	l_log_accrual = ess_log_write('l_hire_year  : 				' ||l_hire_year)
	l_log_accrual = ess_log_write('l_iaff_plan_name : 				' ||l_iaff_plan_name)
	


	l_acc_rate	=	TO_NUMBER(GET_TABLE_VALUE('SC_ABS_CASUAL_ILLNESS_ACCRUAL_RATE_UDT',l_barg_unit_code,TO_CHAR(l_wrk_hrs),'0'))
	l_accrual	=	l_acc_rate * ROUND(l_fte, 2)
	
	/* Change as per Version 1.1 */
	/* Return 0 accrual if employee is currently enrolled into IAFF monthly plan */
	
	l_iaff_monthly_enrld	=	0
	l_iaff_strt					=	'0001/01/01'(date)
	l_iaff_end					=	'0001/01/01'(date)
	l_iaff_last					=	'0001/01/01'(date)
	
	l_iaff_monthly_enrld	=	GET_ENRT_DTLS(l_iaff_plan_name,l_iaff_strt,l_iaff_end,l_iaff_last)
	IF l_debug_flag = 'Y' THEN
	(
		l_log_accrual = ess_log_write('IAFF Monthly enrollment : 			' ||to_char(l_iaff_monthly_enrld))
		l_log_accrual = ess_log_write('IAFF Monthly start date : 			' ||to_char(l_iaff_strt))
		l_log_accrual = ess_log_write('IAFF Monthly end date : 			' ||to_char(l_iaff_end))
	)
	
	IF (l_iaff_monthly_enrld = 1 AND (l_iaff_end >= l_accr_prdstrt_dt OR ISNULL(l_iaff_end) = 'N') ) THEN
	(
		l_accrual	=	0
	)
	/* End-Change as per Version 1.1 */
	
	
	/* Check if max accrual limit has reached in Casual Illness IAFF Monthly Plan in previous year */
	/*
	l_tmp_eff_dt	=	TO_CHAR(TO_NUMBER(TO_CHAR(l_effective_date,'YYYY')) - 1)												
	l_iaff_plan_id	=	GET_VALUE_SET('SC_ABS_Plan_ID_Name_VS',
								'|=p_plan_name='''		||l_iaff_plan_name||''''||
								'|p_eff_dt='''			||to_char(l_effective_date, 'YYYY/MM/DD')||'''')	
								
	l_iaff_balance	=	TO_NUMBER(GET_VALUE_SET('SC_ABS_GI_IAFF_Monthly_Accrued_Balance_VS',
								'|=p_person_id='''		||to_char(l_per_id)||''''||
								'|p_plan_id='''   		||l_iaff_plan_id||''''||
								'|p_effective_dt='''	||l_tmp_eff_dt||'/12/31'||''''))
	
	IF (l_iaff_balance < l_acc_rate OR ISNULL(l_iaff_balance)='N') THEN									
	(																									
		l_accrual	=	0
	)
	ELSE IF ( l_iaff_balance >= l_acc_rate ) THEN
	(
		l_accrual	=	l_acc_rate * ROUND(l_fte, 2)
	)
	*/
	IF l_debug_flag = 'Y' THEN
	(
		l_log_accrual = ess_log_write('------------- Employee Group: ' ||l_emp_grp)
		l_log_accrual = ess_log_write('Accrual Rate : 					' ||TO_CHAR(l_acc_rate))				/* 216 / 199.44 / 144 */
	)
)
ELSE IF (l_barg_unit = 'AUPE') THEN																				/* SCBT_AUPE */
(
	IF (l_asg_ctg = 'FR' OR l_asg_ctg = 'FT' OR l_asg_ctg = 'PR' OR l_asg_ctg = 'PT') THEN
	(
		l_acc_rate	=	TO_NUMBER(GET_TABLE_VALUE('SC_ABS_CASUAL_ILLNESS_ACCRUAL_RATE_UDT',l_barg_unit_code,'1','0'))
		l_accrual	=	l_acc_rate * ROUND(l_fte, 2)
		IF l_debug_flag = 'Y' THEN
		(
			l_log_accrual = ess_log_write('------------- Employee Group: ' ||l_barg_unit)						/* AUPE */
			l_log_accrual = ess_log_write('Accrual Rate : 					' ||TO_CHAR(l_acc_rate))			/* 80 */
		)
		
		/* Change as per Version 1.2 */
		/* CARRYOVER	=	16 */ /*Commented as per version 1.4*/
		/* End-Change as per Version 1.2 */
	)
)

/* ******************************* Stopping Annual Accrual ***************************** */

IF( TO_CHAR(l_effective_date,'YYYY') > TO_CHAR(l_plan_enrl_dt,'YYYY')) THEN 
(
	l_curr_year	=	TO_CHAR(l_effective_date,'YYYY')
	l_prev_year	=	TO_CHAR(TO_NUMBER(l_curr_year) - 1)
	l_unpaid_abs	=	GET_VALUE_SET('SC_ABS_Spcl_Unpaid_Absence_VS',
								'|=p_person_id='''		||to_char(l_per_id)||''''||
								'|p_last_yr_dt='''   	||'12-31-'||l_prev_year||''''||
								'|p_curr_yr_dt='''		||'01-01-'||l_curr_year||'''')

	IF(l_unpaid_abs	=	'Y') THEN
	(
		l_accrual	=	0
	
	
		IF l_debug_flag = 'Y' THEN
		(
			l_log_accrual =	ess_log_write('---- Ongoing Unpaid Absence at year end----')
			l_log_accrual = ess_log_write('Current year : 					' ||l_curr_year)
			l_log_accrual = ess_log_write('Previous year : 				' ||l_prev_year)
			l_log_accrual = ess_log_write('Ongoing Unpaid Absence : 			' ||l_unpaid_abs)
		)
	)
)
/* **************************************************************************************** */

IF l_debug_flag = 'Y' THEN
(
	l_log_accrual = ess_log_write('Returned Accrual value : 			' ||to_char(l_accrual))
	/* l_log_accrual = ess_log_write('Returned Carryover value : 			' ||to_char(CARRYOVER)) */ /*Commented as per version 1.4*/
)

ACCRUAL	=	l_accrual
RETURN ACCRUAL/* , CARRYOVER */ /*Commented as per version 1.4*/