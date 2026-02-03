/* **************************************************************************
FORMULA NAME: SC_ABS_IAFF_Vacation_Accrual_Matrix_FF
FORMULA TYPE: Global Absence Accrual Matrix
DESCRIPTION : This Formula returns accrual value for Vacation Accrued IAFF Plan based on length of service and hour type of worker.


Change History:
Name					Date 		Version 		Comments
-------------------------------------------------------------------------------
Vaishnavi Agrawal		08-Sep-2021 	        1.0 			Initial Version
Vaishnavi Agrawal		25-May-2022		1.1			Added Null check for adjustment VALUES
Vaishnavi Agrawal		13-Jul-2022		1.2			Defect ID #2395077 - Added effective date condition for vacation reference date
Sachin 				25-Jan-2023		1.3			Defect ID #2526354 - Added logic to check LTD/WCB absences entered in chunks, accrual calculation bases on hours and include advanced absence
Raghu Raman			14-Nov-2024		1.4			Defect ID #783 - Proration Issue to handle when Employee was hired during Ist Pay Period of Month
Sendil				05-FEB-2025     1.5 		Defect ID #864 - Vacation Accrual issue for Terminated Employees
****************************************************************************** */

/********Database Item Defaults********/
DEFAULT_DATA_VALUE FOR PER_PERSON_EIT_ALL_PERSON_ID                     IS 0
DEFAULT_DATA_VALUE FOR PER_PERSON_EIT_ALL_INFORMATION_TYPE              IS 'XX'
DEFAULT_DATA_VALUE FOR PER_PERSON_EIT_ALL_PEI_INFORMATION_CATEGORY      IS 'XX'
DEFAULT_DATA_VALUE FOR PER_PERSON_EIT_ALL_PEI_INFORMATION_DATE1         IS '4712/12/31' (DATE)
DEFAULT_DATA_VALUE FOR PER_PERSON_EIT_ALL_EFFECTIVE_END_DATE			IS '4712/12/31' (DATE)
DEFAULT_DATA_VALUE FOR PER_PERSON_EIT_ALL_EFFECTIVE_START_DATE			IS '4712/12/31' (DATE)
DEFAULT_DATA_VALUE FOR	ABS_EXT_ABSENCE_TYPE							IS 'XX'
DEFAULT_DATA_VALUE FOR	ABS_EXT_START_DATE								IS '4712/12/31' (DATE)
DEFAULT_DATA_VALUE FOR	ABS_EXT_END_DATE								IS '4712/12/31' (DATE)
DEFAULT_DATA_VALUE FOR	ABS_EXT_CREATION_DATE							IS '4712/12/31' (DATE)
DEFAULT_DATA_VALUE FOR	ABS_EXT_ABSENCE_STATUS_CD						IS	'XX'


DEFAULT FOR	ANC_ABS_ENTRS_SUBMITTED_DATE					IS '4712/12/31' (DATE)
DEFAULT FOR IV_PLANENROLLMENTSTARTDATE	IS '4712/12/31 00:00:00' (date) 
DEFAULT FOR IV_ACCRUALPERIODSTARTDATE	IS '4712/12/31 00:00:00' (date) 
DEFAULT FOR IV_ACCRUALPERIODENDDATE	IS '4712/12/31 00:00:00' (date) 
DEFAULT FOR PER_ASG_REL_DATE_START 		IS '4712/12/31' (date)   /* === Hire_date ===*/
DEFAULT FOR PER_ASG_NORMAL_HOURS		IS	00
DEFAULT FOR PER_ASG_FREQUENCY_MEANING	IS	'XX'
DEFAULT FOR CMP_ASSIGNMENT_SALARY_BASIS_NAME		IS	'XX'
DEFAULT FOR ANC_ABS_PLN_NAME			IS 'XX'
DEFAULT FOR IV_CALEDARSTARTDATE IS '4712/12/31 00:00:00' (date)
DEFAULT FOR IV_CALEDARENDDATE IS '4712/12/31 00:00:00' (date)
DEFAULT FOR IV_EVENT_DATES IS EMPTY_DATE_NUMBER
DEFAULT FOR IV_ACCRUAL_VALUES IS EMPTY_NUMBER_NUMBER
DEFAULT FOR PER_ASG_FTE_VALUE IS 1
DEFAULT FOR PER_ASG_REL_ACTUAL_TERMINATION_DATE IS '4712/12/31 00:00:00' (date)
DEFAULT FOR PER_ASG_STANDARD_WORKING_HOURS		IS	00
DEFAULT FOR ANC_ABS_ENTRS_START_DATE_DURATION IS	0

/*******Inputs*************/
INPUTS ARE
IV_PLANENROLLMENTSTARTDATE (DATE), IV_ACCRUAL, IV_EVENT_DATES, IV_ACCRUAL_VALUES, IV_CALEDARSTARTDATE 
(date), IV_CALEDARENDDATE (date), IV_ACCRUALPERIODSTARTDATE (DATE) , IV_ACCRUALPERIODENDDATE (DATE)



/************ VARIABLE DEFAULTS***************/
l_assignment_id				= 	GET_CONTEXT(HR_ASSIGNMENT_ID,0)
l_effective_date    		= 	GET_CONTEXT(EFFECTIVE_DATE, '0001/01/01 00:00:00'(date))
l_per_id					= 	GET_CONTEXT(PERSON_ID,0)
l_plan_id					=	GET_CONTEXT(ACCRUAL_PLAN_ID,0) 
l_enrl_dt					=	IV_PLANENROLLMENTSTARTDATE
l_accr_prdstrt_dt			=	IV_ACCRUALPERIODSTARTDATE
l_accr_prdend_dt			=	IV_ACCRUALPERIODENDDATE
l_hire_date					=	PER_ASG_REL_DATE_START
l_hire_mon					=	TO_CHAR(l_hire_date, 'MM/DD')
l_enrl_mon					=	TO_CHAR(l_enrl_dt, 'MM/DD')
l_wrk_hrs					=	0
i                  			=	1
l_eit_info_type     		=	'SCBT_VAC_ACCRL_REF_DATE'
l_eit_dt					=	'4712/12/31' (DATE)
l_year_end_dt				=	'4712/12/31' (DATE)
l_term_date					=	'4712/12/31' (DATE)
l_months					=	0
l_salary_basis				=	'X'
l_debug_flag 				=	'Y'
l_balance_dec				=	0
l_prorate_days				=	0
l_accrual					=	0
l_acc_rate					=	0
l_accr_balnc				=	0
l_prev_abs					=	'X'
l_ltd_prev_abs    			=	'X'
l_reverse_accr				=	0
l_days_in_month				=	14
l_open_abs_flg				=	'N'
l_ltd_open_abs_flg			=	'N'
l_adjustment_values         = 0
l_adjust_date= '4712/12/31' (DATE)
l_adjust_type= 'X'
l_std_wrk_hrs					=	0

l_hire_year=TO_CHAR(l_hire_date,'YYYY')


/* *********** Get values from DBI ************** */

/*Get Plan Name */
CHANGE_CONTEXTS(ACCRUAL_PLAN_ID	= l_plan_id, EFFECTIVE_DATE=l_effective_date)
(
	l_plan	=	ANC_ABS_PLN_NAME
)

CHANGE_CONTEXTS(HR_ASSIGNMENT_ID	=	l_assignment_id	,	EFFECTIVE_DATE = L_EFFECTIVE_DATE)
(
	l_wrk_hrs	=	PER_ASG_NORMAL_HOURS
	l_wrk_frq	=	PER_ASG_FREQUENCY_MEANING 
	l_std_wrk_hrs	=	PER_ASG_STANDARD_WORKING_HOURS	
)

/*Get salary basis*/
CHANGE_CONTEXTS(EFFECTIVE_DATE=l_effective_date,HR_ASSIGNMENT_ID= l_assignment_id)
(
	l_salary_basis	=	CMP_ASSIGNMENT_SALARY_BASIS_NAME
	l_salary_basis	=	UPPER(l_salary_basis)
	l_salary_basis	=	REPLACE(l_salary_basis,' ','_')
)

/*get ‘Vacation Accrual Reference Date’ from Person EIT (Seniority Date) */
l_eit_dt	=	l_hire_date			/*Default to hire date*/
CHANGE_CONTEXTS(EFFECTIVE_DATE = l_effective_date)
(
 
    WHILE PER_PERSON_EIT_ALL_PERSON_ID.EXISTS(i) LOOP
    (
        IF (PER_PERSON_EIT_ALL_INFORMATION_TYPE[i]             = l_eit_info_type
            AND PER_PERSON_EIT_ALL_PEI_INFORMATION_CATEGORY[i]  = l_eit_info_type
			)  
          THEN
        (
			/* V1.2 Added condition to check currently active EIT date */
			
			IF (l_effective_date >= PER_PERSON_EIT_ALL_EFFECTIVE_START_DATE[i] 
				AND l_effective_date <= PER_PERSON_EIT_ALL_EFFECTIVE_END_DATE[i])
			THEN
            (
				l_eit_dt	=  PER_PERSON_EIT_ALL_PEI_INFORMATION_DATE1[i]
			    EXIT
			)	
        )
        i = i + 1
    )
    
)

/* Get Termination Date */
CHANGE_CONTEXTS(EFFECTIVE_DATE=l_effective_date,HR_ASSIGNMENT_ID= l_assignment_id)
(
	l_term_date	=	PER_ASG_REL_ACTUAL_TERMINATION_DATE
)


/* *********** LOGIC ************** */


/*calculate length of service*/
l_len_service	=	TRUNC(MONTHS_BETWEEN(l_effective_date,l_eit_dt)/ 12 ,2)

/*fetch accrual rate from UDT*/
l_acc_rate		=	TO_NUMBER(GET_TABLE_VALUE('SC_ABS_ACCRUAL_RATE_UDT',l_salary_basis,TO_CHAR(l_len_service),'0'))


/*Proration based on hire*/
IF (TO_CHAR(l_eit_dt ,'MM/DD') <> '01/01') 									        /*To check EIT Date is not 1st Jan*/
	AND (TO_CHAR(l_eit_dt ,'YY/MM/DD') >= TO_CHAR(l_accr_prdstrt_dt,'YY/MM/DD'))
	AND (TO_CHAR(l_eit_dt ,'YY/MM/DD') <= TO_CHAR(l_accr_prdend_dt,'YY/MM/DD')) /*To check EIT date is between First Pay period date*/
	AND (TO_CHAR(l_eit_dt ,'DD') <> '01')		THEN						/*To check EIT date is not First date of month*/
(																			/*Prorate to the Payroll calendar end date for that month*/
	l_prorate_days	=	DAYS_BETWEEN(l_effective_date,l_eit_dt) + 1
	l_accrual		=	l_prorate_days * (l_acc_rate/l_days_in_month)
	
)
ELSE																											
(
	l_accrual		=	l_acc_rate
)

IF l_debug_flag = 'Y' THEN
(
	l_log_accrual = ess_log_write(' ------------------ Starting Formula SC_ABS_IAFF_Vacation_Accrual_Matrix_FF ------------------ ')
	l_log_accrual = ess_log_write('Enrollment Date : 					' ||TO_CHAR(l_enrl_dt,'YYYY-MM-DD'))
	l_log_accrual = ess_log_write('Effective Date : 					' ||TO_CHAR(l_effective_date,'YYYY-MM-DD'))
	l_log_accrual = ess_log_write('l_days_in_month: 					' ||to_char(l_days_in_month))
	l_log_accrual = ess_log_write('Vacation Accrual Reference Date : 			' ||TO_CHAR(l_eit_dt))
	l_log_accrual = ess_log_write('Termination Date : 					' ||TO_CHAR(l_term_date,'YYYY-MM-DD'))
	l_log_accrual = ess_log_write('Length of Service : 					' ||to_char(l_len_service))
	l_log_accrual = ess_log_write('Salary Basis : 						' ||l_salary_basis)
	l_log_accrual = ess_log_write('Accrual Rate : 						' ||to_char(l_acc_rate))
	l_log_accrual = ess_log_write('Accrued vacation: 					' ||to_char(l_accrual))
	
	l_log_accrual = ess_log_write('Prorated days for first month after hire : 		' ||TO_CHAR(l_prorate_days))
	l_log_accrual = ess_log_write('ACCRUALPERIODSTARTDATE : 				' || TO_CHAR(l_accr_prdstrt_dt,'YYYY-MM-DD'))
	l_log_accrual = ess_log_write('ACCRUALPERIODENDDATE : 					' || TO_CHAR(l_accr_prdend_dt,'YYYY-MM-DD'))
	l_log_accrual = ess_log_write('Plan enrollment start date + 1 year : 			' || TO_CHAR(ADD_MONTHS(l_enrl_dt,12) ,'YY/MM'))
	l_log_accrual = ess_log_write('Assignment ID: 					' ||to_char(l_assignment_id))
	l_log_accrual = ess_log_write('Assignment Normal hours: 					' ||to_char(l_wrk_hrs))
	l_log_accrual = ess_log_write('Assignment Standard hours: 					' ||to_char(l_std_wrk_hrs))
	
	l_log_accrual = ess_log_write('Plan Name : 		'||l_plan)
	
	
	
)


/* *****************************************	Stopping accruals  - Unpaid absence types ************************************************* */

/* *****************************Checking absence entered in chunk ****************** */
l_abs_sum		=	0
a				=	1
l_latest_abs[a]	=	'X'
l_latest_abs_temp=	'X'
l_unpaid_abs_sum = 0
l_latest_abs_temp	=	GET_VALUE_SET('SC_ABS_Unpaid_Absence_Detail_VS',
								'|=p_person_id='''		||to_char(l_per_id)||''''||
								'|p_accr_prdend_dt='''	||to_char(l_accr_prdend_dt, 'YYYY/MM/DD')||'''')

							
IF(ISNULL(l_latest_abs_temp)	= 'N') THEN
(
	l_prev_abs		=	l_latest_abs_temp
)
ELSE
(
	l_latest_abs[a]	=	l_latest_abs_temp	
)
/*log values*/
IF l_debug_flag = 'Y' THEN
(
	l_log_accrual = ess_log_write('l_latest_abs['||to_char(a)||'] : 	'||l_latest_abs[a])
	l_log_accrual = ess_log_write('l_latest_abs_temp : 		'||l_latest_abs_temp)
	l_log_accrual = ess_log_write('l_prev_abs : 		'||l_prev_abs)
	l_log_accrual = ess_log_write('ISNULL(l_prev_abs) : 	'||ISNULL(l_prev_abs))
)
WHILE (ISNULL(l_prev_abs)	<>	'N') LOOP
(
	l_abs_entry_id[a]	=	SUBSTR(l_latest_abs[a],1, INSTR(l_latest_abs[a], '~')-1)
	l_temp[a] 			=	SUBSTR(l_latest_abs[a], INSTR(l_latest_abs[a], '~')+1)
	l_abs_strt_dt[a]	=	SUBSTR(l_temp[a],1, INSTR(l_temp[a], '~')-1)
	l_temp2[a]			=	SUBSTR(l_temp[a] , INSTR(l_temp[a], '~')+1)
	
	/* l_abs_end_dt[a]		=	SUBSTR(l_temp[a], INSTR(l_temp[a], '~')+1) */

	/* open ended absence */
	IF (ISNULL(SUBSTR(l_temp2[a],1, INSTR(l_temp2[a], '~')-1)) = 'N') THEN
	(	l_abs_end_dt[a]	=	to_char(l_accr_prdend_dt, 'YYYY/MM/DD')
		l_open_abs_flg	=	'Y'
	)
	ELSE
	(	l_abs_end_dt[a]		=	SUBSTR(l_temp2[a],1, INSTR(l_temp2[a], '~')-1)
		l_unpaid_dur[a]		=	TO_NUMBER(SUBSTR(l_temp2[a], INSTR(l_temp2[a], '~')+1))	)
		
	/* ***************** */
	
	l_abs_sum			=	l_abs_sum + DAYS_BETWEEN(to_date(l_abs_end_dt[a]), to_date(l_abs_strt_dt[a]) ) +1
	l_prev_abs_end_dt	=	ADD_DAYS(TO_DATE(l_abs_strt_dt[a]),-1)
	l_prev_abs			=	' '
	l_prev_abs			=	GET_VALUE_SET('SC_ABS_Previous_Unpaid_Absence_Detail_VS',
								'|=p_person_id='''		||to_char(l_per_id)||''''||
								'|p_prev_abs_end_dt='''	||to_char(l_prev_abs_end_dt, 'YYYY/MM/DD')||'''')
	
	/*log values*/
	IF l_debug_flag = 'Y' THEN
	(
		l_log_accrual = ess_log_write('------------checking chunk absences-----------')
		l_log_accrual = ess_log_write('l_latest_abs['||to_char(a)||'] : 	'||l_latest_abs[a])
		l_log_accrual = ess_log_write('l_abs_entry_id : 	'||l_abs_entry_id[a])
		l_log_accrual = ess_log_write('l_abs_strt_dt : 	'||l_abs_strt_dt[a])
		l_log_accrual = ess_log_write('l_abs_end_dt : 		'||l_abs_end_dt[a])
		l_log_accrual = ess_log_write('l_abs_sum : 		'||to_char(l_abs_sum))
		l_log_accrual = ess_log_write('l_unpaid_dur : 		'||to_char(l_unpaid_dur[a]))
		l_log_accrual = ess_log_write('l_prev_abs : 		'||l_prev_abs)
		l_log_accrual = ess_log_write('ISNULL(l_prev_abs) : 	'||ISNULL(l_prev_abs))
	)
	
	IF( ISNULL(l_prev_abs)	=	'Y') THEN
	(
		a				=	a + 1
		l_latest_abs[a]	=	l_prev_abs
	)
	ELSE
	( 
		EXIT
	)
	
)
IF l_debug_flag = 'Y' THEN
(
	l_log_accrual = ess_log_write('outside while loop l_abs_sum : 		'||to_char(l_abs_sum))
	l_log_accrual = ess_log_write('a : 		'||to_char(a))
)


/* ----------------------------- Reversing ACCRUAL ------------------------------ */	
/* 1. 30 days minimum absence criteria*/
IF (l_abs_sum > 30) THEN	
(
	z	=	1
	WHILE (z<=a) LOOP
	(	
		l_abs_duration_curr		=	0
		l_abs_duration			=	0
		l_abs_duration_retro	=	0
		l_abs_std_dur			=   0
		l_abs_duration_hr		= 	0
		l_abs_id				=	to_number(l_abs_entry_id[z])
		l_abs_strt				=	to_date(l_abs_strt_dt[z])
		l_abs_end				=	to_date(l_abs_end_dt[z])
		l_unpaid_abs_dur  		= 	l_unpaid_dur[z]
		CHANGE_CONTEXTS(ABSENCE_ENTRY_ID= l_abs_id, EFFECTIVE_DATE=l_effective_date)
		(
			l_abs_creatn_dt	=	ANC_ABS_ENTRS_SUBMITTED_DATE
			l_abs_std_dur = ANC_ABS_ENTRS_START_DATE_DURATION
		)
		l_abs_duration	=	DAYS_BETWEEN(l_abs_end, l_abs_strt ) +1
		
		IF (l_accr_prdstrt_dt <= l_abs_strt AND l_abs_strt <= l_accr_prdend_dt) THEN		/*Absence strt_dt in current accrual prd*/
		(
			IF (l_accr_prdstrt_dt <= l_abs_end AND l_abs_end <= l_accr_prdend_dt) THEN		/*Absence end_dt in current accrual prd*/
			(
				l_unpaid_abs_sum = l_unpaid_abs_sum + l_unpaid_abs_dur
			)
					
			ELSE IF (l_accr_prdend_dt <=l_abs_end OR ABS_EXT_END_DATE WAS DEFAULTED) THEN /*Absence end_dt after accrual prd OR dflt*/
			(
				l_abs_duration_curr	=	DAYS_BETWEEN(l_accr_prdend_dt, l_abs_strt ) +1
				l_abs_duration_hr =	l_abs_duration_curr * l_abs_std_dur		
				l_unpaid_abs_sum = l_unpaid_abs_sum + l_abs_duration_hr		
			)
		)
					
		ELSE IF (l_abs_strt < l_accr_prdstrt_dt) THEN									/*Absence strt_dt before current accrual prd*/
		(
			IF (l_accr_prdstrt_dt <= l_abs_end AND l_abs_end <= l_accr_prdend_dt) THEN		/*Absence end_dt in current accrual prd*/
			(
				l_abs_duration_curr	=	DAYS_BETWEEN(l_abs_end, l_accr_prdstrt_dt ) +1 
				l_abs_duration_hr =	l_abs_duration_curr * l_abs_std_dur		
				l_unpaid_abs_sum = l_unpaid_abs_sum + l_abs_duration_hr	
			)
			ELSE IF(l_accr_prdend_dt <=l_abs_end OR ABS_EXT_END_DATE WAS DEFAULTED) THEN /*Absence end_dt after accrual prd OR dflt*/
			(
				l_abs_duration_curr	=	DAYS_BETWEEN(l_accr_prdend_dt, l_accr_prdstrt_dt) +1
				l_abs_duration_hr =	l_abs_duration_curr * l_abs_std_dur		
				l_unpaid_abs_sum = l_unpaid_abs_sum + l_abs_duration_hr
			)
		)
					
		/*retro accrual*/
		IF ((l_accr_prdstrt_dt <= l_abs_creatn_dt AND l_abs_creatn_dt <= l_accr_prdend_dt) 
			AND	( l_abs_strt < l_accr_prdstrt_dt  )) THEN
		(
			IF( l_abs_end < l_accr_prdstrt_dt ) THEN
			(
				l_abs_duration_retro	= DAYS_BETWEEN(l_abs_end, l_abs_strt ) +1
				l_unpaid_abs_sum = l_unpaid_abs_sum + l_unpaid_abs_dur
			)
							
			ELSE 
			(
				l_abs_duration_retro	= DAYS_BETWEEN(ADD_DAYS(l_accr_prdstrt_dt, - 1), l_abs_strt ) +1
				l_abs_duration_hr =	l_abs_duration_retro * l_abs_std_dur		
				l_unpaid_abs_sum = l_unpaid_abs_sum + l_abs_duration_hr
			)
		)
		
		/* previous month's open ended absences */
		l_open_abs_duration		=	0
		l_days_in_prev_month	=	0
		IF (l_open_abs_flg		=	'Y') THEN
		(
			IF ((l_abs_duration	-	l_abs_duration_curr) > 0 AND (l_abs_duration	-	l_abs_duration_curr) < 31 ) THEN
			(
				l_open_abs_duration	=	l_abs_duration	-	l_abs_duration_curr
				l_days_in_prev_month=	TO_NUMBER(TO_CHAR(last_day(ADD_DAYS(l_accr_prdstrt_dt, - 1)),'DD'))
				l_reverse_accr		=	l_reverse_accr + ROUND((l_open_abs_duration * (l_acc_rate/l_days_in_prev_month)),2)
				l_log_accrual = ess_log_write('Reverse Accrual1 : 		-'||to_char(l_reverse_accr))
			)
		)
		

				
		IF l_debug_flag = 'Y' THEN
		(
			l_log_accrual = ess_log_write('Absence Type : 			'||'Unpaid 30 days criteria')
			l_log_accrual = ess_log_write('z : 		'||to_char(z))
			l_log_accrual = ess_log_write('Check l_latest_abs['||to_char(z)||'] : 	'||l_latest_abs[z])
			l_log_accrual = ess_log_write('Absence Creation Date : 	'||to_char(l_abs_creatn_dt))
			l_log_accrual = ess_log_write('Absence Start Date : 		'||to_char(l_abs_strt))
			l_log_accrual = ess_log_write('Absence End Date : 		'||to_char(l_abs_end))
			l_log_accrual = ess_log_write('Total Absence duration : 	'||to_char(l_abs_duration))
			l_log_accrual = ess_log_write('Unpaid Absence duration sum : 	'||to_char(l_unpaid_abs_sum))
			l_log_accrual = ess_log_write('Absence duration in current accrual period: '||to_char(l_abs_duration_curr))
			l_log_accrual = ess_log_write('Retro Absence duration : 	'||to_char(l_abs_duration_retro))
			l_log_accrual = ess_log_write('Open Ended Absence duration : 	'||to_char(l_open_abs_duration))
			l_log_accrual = ess_log_write('Reverse Accrual : 		-'||to_char(l_reverse_accr))
		)		
		z	=	z+1
	)
	
			if(l_unpaid_abs_sum >= l_wrk_hrs) then (
l_reverse_accr = l_acc_rate
)

else if (l_unpaid_abs_sum < l_wrk_hrs) then (
l_reverse_accr	=	l_reverse_accr + ROUND(((l_unpaid_abs_sum/l_wrk_hrs)*l_acc_rate),2)
)
	
)


/*checking advanced absence entries*/

n				=	1
l_un_adv_latest_abs[n]	=	'X'
l_adv_unpaid_abs_dur[n] = 0
l_un_adv_latest_abs_temp=	'X'
l_unpaid_prev_abs		=	'X'
l_unpaid_adv_abssum = 0
l_un_adv_latest_abs_temp	=	GET_VALUE_SET('SC_ABS_Advanced_Unpaid_Absence_Detail_VS',
								'|=p_person_id='''		||to_char(l_per_id)||''''||
								'|p_accr_prdend_dt='''	||to_char(l_accr_prdend_dt, 'YYYY/MM/DD')||'''')

l_unpaid_adv_temp 			=	SUBSTR(l_un_adv_latest_abs_temp, INSTR(l_un_adv_latest_abs_temp, '~')+1)
l_unpaid_adv_abs_strt_dt	=	SUBSTR(l_unpaid_adv_temp,1, INSTR(l_unpaid_adv_temp, '.')-1)


IF l_debug_flag = 'Y' THEN

(
	l_log_accrual = ess_log_write('------------checking Unpaid Advanced absence entries-----------')
	l_log_accrual = ess_log_write('l_un_adv_latest_abs_temp : 		'||l_un_adv_latest_abs_temp)
	l_log_accrual = ess_log_write('l_unpaid_adv_abs_strt_dt : 		'||l_unpaid_adv_abs_strt_dt)

)


IF(ISNULL(l_un_adv_latest_abs_temp)	= 'N') THEN
(
	l_unpaid_prev_abs		=	l_un_adv_latest_abs_temp
)
ELSE
(
	l_un_adv_latest_abs[n]	=	l_un_adv_latest_abs_temp	
)

if (TO_DATE(l_unpaid_adv_abs_strt_dt,'YYYY-MM-DD HH24:MI:SS') >= l_accr_prdstrt_dt) THEN (

WHILE (ISNULL(l_unpaid_prev_abs)	<>	'N') LOOP
(
	
	l_adv_temp_dur[n] 			=	SUBSTR(l_un_adv_latest_abs[n], INSTR(l_un_adv_latest_abs[n], '~')+1)
	l_unpaid_strt_dt[n]	=	SUBSTR(l_adv_temp_dur[n],1, INSTR(l_adv_temp_dur[n], '.')-1)
	l_adv_unpaid_abs_dur[n]	=	TO_NUMBER(SUBSTR(l_un_adv_latest_abs[n] ,1, INSTR(l_un_adv_latest_abs[n] , '~')-1))
	l_unpaid_abs_sum = l_unpaid_abs_sum + l_adv_unpaid_abs_dur[n]
	l_prev_abs_end_dt	=	ADD_DAYS(TO_DATE(l_unpaid_strt_dt[n]),-1)
	l_unpaid_prev_abs			=	' '
	l_unpaid_prev_abs			=	GET_VALUE_SET('SC_ABS_Previous_Adv_Unpaid_Absence_Detail_VS',
								'|=p_person_id='''		||to_char(l_per_id)||''''||
								'|p_prev_abs_end_dt='''	||to_char(l_prev_abs_end_dt, 'YYYY/MM/DD')||'''')
	
	/*log values*/
	IF l_debug_flag = 'Y' THEN
	(
		l_log_accrual = ess_log_write('------------checking continuous absences-----------')
		l_log_accrual = ess_log_write('l_latest_abs['||to_char(n)||'] : 	'||l_un_adv_latest_abs[n])
		l_log_accrual = ess_log_write('l_abs_strt_dt : 	'||l_unpaid_strt_dt[n])
		l_log_accrual = ess_log_write('l_unpaid_dur : 		'||to_char(l_adv_unpaid_abs_dur[n]))
		l_log_accrual = ess_log_write('l_unpaid_prev_abs : 		'||l_unpaid_prev_abs)
		l_log_accrual = ess_log_write('ISNULL(l_unpaid_prev_abs) : 	'||ISNULL(l_unpaid_prev_abs))
		l_log_accrual = ess_log_write('Unpaid Adv Absence duration sum : 	'||to_char(l_unpaid_abs_sum))
	)
	
	IF( ISNULL(l_unpaid_prev_abs)	=	'Y') THEN
	(
		n				=	n + 1
		l_un_adv_latest_abs[n]	=	l_unpaid_prev_abs
	)
	ELSE
	( 
		EXIT
	))
	
	if (n>=30) then(
	
	if(l_unpaid_abs_sum >= l_wrk_hrs) then (
l_reverse_accr = l_acc_rate
)

else if (l_unpaid_abs_sum < l_wrk_hrs) then (
l_reverse_accr	=	l_reverse_accr + ROUND(((l_unpaid_abs_sum/l_wrk_hrs)*l_acc_rate),2)
)
	
	
	))

/* 2. LTD & Unpaid WCB absence type- Stop accruals from day 1 -  Advanced*/

/*version 1.3 starts*/



t =	0
l_adv_latest_abs_temp=	'X'
l_adv_abs_dur=	0
l_abs_adv_temp=	'X'
l_adv_abs_strt_dt=	'X'

l_adv_latest_abs_temp	=	GET_VALUE_SET('SC_ABS_Advanced_LTD_WCB_Absence_Detail_VS',
								'|=p_person_id='''		||to_char(l_per_id)||''''||
								'|p_accr_prdend_dt='''	||to_char(l_accr_prdend_dt, 'YYYY/MM/DD')||'''')
								
								
	
	l_abs_adv_temp 			=	SUBSTR(l_adv_latest_abs_temp, INSTR(l_adv_latest_abs_temp, '~')+1)
	l_adv_abs_strt_dt	=	SUBSTR(l_abs_adv_temp,1, INSTR(l_abs_adv_temp, '.')-1)

	if (TO_DATE(l_adv_abs_strt_dt,'YYYY-MM-DD HH24:MI:SS') >= l_accr_prdstrt_dt) THEN (
	l_adv_abs_dur	=	TO_NUMBER(SUBSTR(l_adv_latest_abs_temp,1, INSTR(l_adv_latest_abs_temp, '~')-1))
	)
	
	
IF l_debug_flag = 'Y' THEN

(
	l_log_accrual = ess_log_write('------------checking LTD_WCB Advanced absence entries-----------')
	l_log_accrual = ess_log_write('l_adv_latest_abs_temp : 		'||l_adv_latest_abs_temp)
	l_log_accrual = ess_log_write('l_adv_abs_dur : 		'||TO_CHAR(l_adv_abs_dur))
	l_log_accrual = ess_log_write('l_abs_adv_temp : 		'||l_abs_adv_temp)
	l_log_accrual = ess_log_write('l_adv_abs_strt_dt : 		'||l_adv_abs_strt_dt)
)

if(l_adv_latest_abs_temp <> 'X' ) then
(

l_adv_start = to_date(l_adv_abs_strt_dt,'YYYY-MM-DD HH24:MI:SS')
l_abs_duration_curr = 0

WHILE (l_adv_start >= l_accr_prdstrt_dt  ) LOOP
(

t = t+1
l_adv_temp = ADD_DAYS(l_adv_start,-1)
l_adv_abs_dur = l_adv_abs_dur + l_abs_duration_curr


IF l_debug_flag = 'Y' THEN

(
	
	l_log_accrual = ess_log_write('LTD_WCB Advanced absence entry['||to_char(t)||']')
	l_log_accrual = ess_log_write('l_advanced_absence : 		'||TO_CHAR(l_adv_start))
	l_log_accrual = ess_log_write('l_abs_duration_curr 		'||TO_CHAR(l_abs_duration_curr))
	l_log_accrual = ess_log_write('l_adv_abs_dur : 		'||TO_CHAR(l_adv_abs_dur))
	l_log_accrual = ess_log_write('Adv Reverse Accrual : 		-'||to_char(l_reverse_accr))
)
l_adv_latest_abs_tempr	=	GET_VALUE_SET('SC_ABS_Advanced_LTD_WCB_Absence_Detail_VS',
								'|=p_person_id='''		||to_char(l_per_id)||''''||
								'|p_accr_prdend_dt='''	||to_char((l_adv_temp), 'YYYY/MM/DD')||'''')
								
	l_abs_duration_curr	=	TO_NUMBER(SUBSTR(l_adv_latest_abs_tempr,1, INSTR(l_adv_latest_abs_tempr, '~')-1))
	l_abs_adv_tempr 			=	SUBSTR(l_adv_latest_abs_tempr, INSTR(l_adv_latest_abs_tempr, '~')+1)
	l_adv_abs_strt_dt	=	SUBSTR(l_abs_adv_tempr,1, INSTR(l_abs_adv_tempr, '.')-1)
	l_adv_start = to_date(l_adv_abs_strt_dt,'YYYY-MM-DD HH24:MI:SS')
	
IF l_debug_flag = 'Y' THEN
(
	l_log_accrual = ess_log_write('l_advanced_previous_absence : 		'||TO_CHAR(l_adv_start))
)

IF (l_adv_start < l_accr_prdstrt_dt ) THEN
(
EXIT
)
)

)












/* 2. LTD & Unpaid WCB absence type- Stop accruals from day 1 -  Basic */

l_ltd_abs_sum		=	0
d				=	1
l_ltd_latest_abs[d]	=	'X'
l_ltd_latest_abs_temp=	'X'


l_ltd_latest_abs_temp	=	GET_VALUE_SET('SC_ABS_LTD_WCB_Absence_Detail_VS',
								'|=p_person_id='''		||to_char(l_per_id)||''''||
								'|p_accr_prdend_dt='''	||to_char(l_accr_prdend_dt, 'YYYY/MM/DD')||'''')
								

IF(ISNULL(l_ltd_latest_abs_temp)	= 'N') THEN
(
	l_ltd_prev_abs		=	l_ltd_latest_abs_temp
)
ELSE
(
	l_ltd_latest_abs[d]	=	l_ltd_latest_abs_temp	
)
/*log values*/
IF l_debug_flag = 'Y' THEN
(
	l_log_accrual = ess_log_write('l_ltd_latest_abs['||to_char(d)||'] : 	'||l_ltd_latest_abs[d])
	l_log_accrual = ess_log_write('l_ltd_latest_abs_temp : 		'||l_ltd_latest_abs_temp)
	l_log_accrual = ess_log_write('l_ltd_prev_abs : 		'||l_ltd_prev_abs)
	l_log_accrual = ess_log_write('ISNULL(l_ltd_prev_abs) : 	'||ISNULL(l_ltd_prev_abs))
)

WHILE (ISNULL(l_ltd_prev_abs)	<>	'N') LOOP

(
	l_abs_entry_id[d]	=	SUBSTR(l_ltd_latest_abs[d],1, INSTR(l_ltd_latest_abs[d], '~')-1)
	l_ltd_temp[d] 			=	SUBSTR(l_ltd_latest_abs[d], INSTR(l_ltd_latest_abs[d], '~')+1)
	l_abs_strt_dt[d]	=	SUBSTR(l_ltd_temp[d],1, INSTR(l_ltd_temp[d], '~')-1)
	 l_ltd_temp2[d]		=	SUBSTR(l_ltd_temp[d], INSTR(l_ltd_temp[d], '~')+1) 
	 l_ltd_dur[d]	= TO_NUMBER(SUBSTR(l_ltd_temp2[d], INSTR(l_ltd_temp2[d], '~')+1))

	/* open ended absence */
	IF (ISNULL(SUBSTR(l_ltd_temp2[d],1, INSTR(l_ltd_temp2[d], '~')-1)) = 'N') THEN
	(	l_abs_end_dt[d]	=	to_char(l_accr_prdend_dt, 'YYYY/MM/DD')
	l_ltd_dur[d]	= l_wrk_hrs
		l_open_abs_flg	=	'Y'
		EXIT
	)
	ELSE
	(	
	l_abs_end_dt[d]	=	SUBSTR(l_ltd_temp2[d],1, INSTR(l_ltd_temp2[d], '~')-1)
	l_ltd_dur[d]	= TO_NUMBER(SUBSTR(l_ltd_temp2[d], INSTR(l_ltd_temp2[d], '~')+1))
	)
	
	
		l_ltd_abs_sum			=	l_ltd_abs_sum + DAYS_BETWEEN(to_date(l_abs_end_dt[d]), to_date(l_abs_strt_dt[d]) ) +1
	l_prev_abs_end_dt	=	ADD_DAYS(TO_DATE(l_abs_strt_dt[d]),-1)
	l_ltd_prev_abs			=	' '
	l_ltd_prev_abs			=	GET_VALUE_SET('SC_ABS_Previous_LTD_WCB_Absence_Detail_VS',
								'|=p_person_id='''		||to_char(l_per_id)||''''||
								'|p_prev_abs_end_dt='''	||to_char(l_prev_abs_end_dt, 'YYYY/MM/DD')||'''')
	
	/*log values*/
	IF l_debug_flag = 'Y' THEN
	(
		l_log_accrual = ess_log_write('------------checking LTD_WCB chunk absences-----------')
		l_log_accrual = ess_log_write('l_ltd_latest_abs['||to_char(d)||'] : 	'||l_ltd_latest_abs[d])
		l_log_accrual = ess_log_write('l_abs_entry_id : 	'||l_abs_entry_id[d])
		l_log_accrual = ess_log_write('l_abs_strt_dt : 	'||l_abs_strt_dt[d])
		l_log_accrual = ess_log_write('l_abs_end_dt : 		'||l_abs_end_dt[d])
		l_log_accrual = ess_log_write('l_ltd_dur : 		'||to_char(l_ltd_dur[d]))
		l_log_accrual = ess_log_write('l_ltd_abs_sum : 		'||to_char(l_ltd_abs_sum))
		l_log_accrual = ess_log_write('l_ltd_prev_abs : 		'||l_ltd_prev_abs)
		l_log_accrual = ess_log_write('ISNULL(l_ltd_prev_abs) : 	'||ISNULL(l_ltd_prev_abs))
	)
	
	IF( ISNULL(l_ltd_prev_abs)	=	'Y') THEN
	(
		d				=	d + 1
		l_ltd_latest_abs[d]	=	l_ltd_prev_abs
	)
	ELSE
	( 
		EXIT
	)
	
)




IF l_debug_flag = 'Y' THEN
(
	l_log_accrual = ess_log_write('outside while loop l_ltd_abs_sum : 		'||to_char(l_ltd_abs_sum))

	l_log_accrual = ess_log_write('d : 		'||to_char(d))
)


IF (l_ltd_abs_sum > 0) THEN	
( 

y	=	1
	WHILE (y<=d) LOOP
	(
		l_abs_duration_curr		=	0
		l_abs_days				=   0
		l_abs_duration_retro	=	0  
		l_abs_std_dur			=   0
		l_abs_id				=	to_number(l_abs_entry_id[y])
		l_abs_strt				=	to_date(l_abs_strt_dt[y])
		l_abs_end				=	to_date(l_abs_end_dt[y])	
		l_abs_duration			=	l_ltd_dur[y]
		CHANGE_CONTEXTS(ABSENCE_ENTRY_ID= l_abs_id, EFFECTIVE_DATE=l_effective_date)
		(
			l_abs_ltd_creatn_dt	=	ANC_ABS_ENTRS_SUBMITTED_DATE
			l_abs_std_dur = ANC_ABS_ENTRS_START_DATE_DURATION
			
		)
		
		l_abs_days	=	DAYS_BETWEEN(l_abs_end, l_abs_strt ) +1
		
			
			IF (l_accr_prdstrt_dt <= l_abs_strt AND l_abs_strt <= l_accr_prdend_dt) THEN		/*Absence strt_dt in current accrual prd*/
		(
			IF (l_accr_prdstrt_dt <= l_abs_end AND l_abs_end <= l_accr_prdend_dt) THEN		/*Absence end_dt in current accrual prd*/
			(
				l_adv_abs_dur = l_adv_abs_dur + l_abs_duration
			)
					
			ELSE IF (l_accr_prdend_dt <=l_abs_end OR ABS_EXT_END_DATE WAS DEFAULTED) THEN /*Absence end_dt after accrual prd OR dflt*/
			(
				l_abs_duration_curr	=	DAYS_BETWEEN(l_accr_prdend_dt, l_abs_strt ) +1	
				l_abs_duration_curr =	l_abs_duration_curr * l_abs_std_dur
				l_adv_abs_dur = l_adv_abs_dur + l_abs_duration_curr
			)
		)
					
		ELSE IF (l_abs_strt < l_accr_prdstrt_dt) THEN									/*Absence strt_dt before current accrual prd*/
		(
			IF (l_accr_prdstrt_dt <= l_abs_end AND l_abs_end <= l_accr_prdend_dt) THEN		/*Absence end_dt in current accrual prd*/
			(
				l_abs_duration_curr	=	DAYS_BETWEEN(l_abs_end, l_accr_prdstrt_dt ) +1 
				l_abs_duration_curr =	l_abs_duration_curr * l_abs_std_dur
				l_adv_abs_dur = l_adv_abs_dur + l_abs_duration_curr
			)
			ELSE IF(l_accr_prdend_dt <=l_abs_end OR ABS_EXT_END_DATE WAS DEFAULTED) THEN /*Absence end_dt after accrual prd OR dflt*/
			(
				l_abs_duration_curr	=	DAYS_BETWEEN(l_accr_prdend_dt, l_accr_prdstrt_dt) +1
				l_abs_duration_curr =	l_abs_duration_curr * l_abs_std_dur
				l_adv_abs_dur = l_adv_abs_dur + l_abs_duration_curr
			)
		)
					
		/*retro accrual
		IF ((l_accr_prdstrt_dt <= l_abs_ltd_creatn_dt AND l_abs_ltd_creatn_dt <= l_accr_prdend_dt) 
			AND	( l_abs_strt < l_accr_prdstrt_dt  )) THEN
		(
			IF( l_abs_end < l_accr_prdstrt_dt ) THEN
			(
				l_abs_duration_retro	= DAYS_BETWEEN(l_abs_end, l_abs_strt ) +1
			)
							
			ELSE 
			(
				l_abs_duration_retro	= DAYS_BETWEEN(ADD_DAYS(l_accr_prdstrt_dt, - 1), l_abs_strt ) +1
			)
		)*/
		
		/*l_reverse_accr	=	l_reverse_accr + ROUND(((l_abs_duration_curr + l_abs_duration_retro ) * (l_acc_rate/l_days_in_month)),2)
		l_log_accrual = ess_log_write('Reverse Accrual2 : 		-'||to_char(l_reverse_accr))*/
				
		IF l_debug_flag = 'Y' THEN
		(
			l_log_accrual = ess_log_write('Absence Type : 			'||'LTD / WCB')
			l_log_accrual = ess_log_write('y : 		'||to_char(y))
			l_log_accrual = ess_log_write('Absence Creation Date : 	'||to_char(l_abs_ltd_creatn_dt))
			l_log_accrual = ess_log_write('Absence Start Date : 		'||to_char(l_abs_strt))
			l_log_accrual = ess_log_write('Absence End Date : 		'||to_char(l_abs_end))
			l_log_accrual = ess_log_write('Absence duration in current accrual period: '||to_char(l_abs_duration_curr))
			l_log_accrual = ess_log_write('Retro Absence duration : 	'||to_char(l_abs_duration_retro))
			l_log_accrual = ess_log_write('Total Absence duration : 	'||to_char(l_abs_days))
			l_log_accrual = ess_log_write('Standard Absence duration : 	'||to_char(l_abs_std_dur))
			l_log_accrual = ess_log_write('Reverse Accrual : 		-'||to_char(l_reverse_accr))
		)
		y = y + 1	
			
	)		
			
)
l_log_accrual = ess_log_write('FINAL2 l_adv_abs_dur : 		'||TO_CHAR(l_adv_abs_dur))

if(l_adv_abs_dur >= l_wrk_hrs) then (
l_reverse_accr = l_acc_rate
)

else if (l_adv_abs_dur < l_wrk_hrs) then (
l_reverse_accr	=	l_reverse_accr + ROUND(((l_adv_abs_dur/l_wrk_hrs)*l_acc_rate),2)
)

l_log_accrual = ess_log_write('Final Reverse Accrual : 		-'||to_char(l_reverse_accr))

/*version 1.3 ends*/

	
/* 3. Return to work absence type*/
l_rtw_sum = 0
l_rtw_abs	=	GET_VALUE_SET('SC_ABS_RTW_Absence_Detail_VS',
								'|=p_person_id='''		||to_char(l_per_id)||''''||
								'|p_accr_prdend_dt='''	||to_char(l_accr_prdend_dt, 'YYYY/MM/DD')||'''')
IF(ISNULL(l_rtw_abs)='Y') THEN 
(
	l_abs_duration_curr		=	0
	l_abs_duration			=	0
	l_abs_duration_retro	=	0
	l_modified_hrs			=	0
	l_retro_modified_hrs	=	0
	
	l_rtw_abs_entry_id		=	to_number(SUBSTR(l_rtw_abs,1, INSTR(l_rtw_abs, '~')-1))
	l_temp_rtw				=	SUBSTR(l_rtw_abs, INSTR(l_rtw_abs, '~')+1)
	l_abs_strt			=	to_date(SUBSTR(l_temp_rtw,1, INSTR(l_temp_rtw, '~')-1))
	l_temp2_rtw		=	SUBSTR(l_temp_rtw, INSTR(l_temp_rtw, '~')+1)
	l_rtw_dur	= TO_NUMBER(SUBSTR(l_temp2_rtw, INSTR(l_temp2_rtw, '~')+1))
	l_abs_end			=	to_date(SUBSTR(l_temp2_rtw,1, INSTR(l_temp2_rtw, '~')-1))
									
	
	CHANGE_CONTEXTS(ABSENCE_ENTRY_ID= l_rtw_abs_entry_id, EFFECTIVE_DATE=l_effective_date)
	(
		l_abs_rtw_creatn_dt	=	ANC_ABS_ENTRS_SUBMITTED_DATE
	)

	IF (l_accr_prdstrt_dt <= l_abs_strt AND l_abs_strt <= l_accr_prdend_dt) THEN		/*Absence strt_dt in current accrual prd*/
	(
		IF (l_accr_prdstrt_dt <= l_abs_end AND l_abs_end <= l_accr_prdend_dt) THEN		/*Absence end_dt in current accrual prd*/
		(
			l_abs_duration_curr	=	DAYS_BETWEEN(l_abs_end, l_abs_strt ) +1	
			l_rtw_sum = l_rtw_sum + l_rtw_dur
			l_modified_hrs	=	TO_NUMBER(GET_VALUE_SET('SC_ABS_Modified_Hours_VS',
								'|=p_person_id='''		||to_char(l_per_id)||''''||
								'|p_start_date='''	||to_char(l_abs_strt, 'YYYY/MM/DD')||''''||
								'|p_end_date='''	||to_char(l_abs_end, 'YYYY/MM/DD')||''''))
		)
				
		ELSE IF (l_accr_prdend_dt <=l_abs_end OR ABS_EXT_END_DATE WAS DEFAULTED) THEN /*Absence end_dt after accrual prd OR dflt*/
		(
			l_abs_duration_curr	=	DAYS_BETWEEN(l_accr_prdend_dt, l_abs_strt ) +1	
			l_rtw_sum = l_rtw_sum + l_rtw_dur
			l_modified_hrs	=	TO_NUMBER(GET_VALUE_SET('SC_ABS_Modified_Hours_VS',
								'|=p_person_id='''		||to_char(l_per_id)||''''||
								'|p_start_date='''	||to_char(l_abs_strt, 'YYYY/MM/DD')||''''||
								'|p_end_date='''	||to_char(l_accr_prdend_dt, 'YYYY/MM/DD')||''''))
		)
	)
				
	ELSE IF (l_abs_strt < l_accr_prdstrt_dt) THEN									/*Absence strt_dt before current accrual prd*/
	(
		IF (l_accr_prdstrt_dt <= l_abs_end AND l_abs_end <= l_accr_prdend_dt) THEN		/*Absence end_dt in current accrual prd*/
		(
			l_abs_duration_curr	=	DAYS_BETWEEN(l_abs_end, l_accr_prdstrt_dt ) +1 
			l_rtw_sum = l_rtw_sum + l_rtw_dur
			l_modified_hrs	=	TO_NUMBER(GET_VALUE_SET('SC_ABS_Modified_Hours_VS',
								'|=p_person_id='''		||to_char(l_per_id)||''''||
								'|p_start_date='''	||to_char(l_accr_prdstrt_dt, 'YYYY/MM/DD')||''''||
								'|p_end_date='''	||to_char(l_abs_end, 'YYYY/MM/DD')||''''))
		)
		ELSE IF(l_accr_prdend_dt <=l_abs_end OR ABS_EXT_END_DATE WAS DEFAULTED) THEN /*Absence end_dt after accrual prd OR dflt*/
		(
			l_abs_duration_curr	=	DAYS_BETWEEN(l_accr_prdend_dt, l_accr_prdstrt_dt) +1
			l_rtw_sum = l_rtw_sum + l_rtw_dur
			l_modified_hrs	=	TO_NUMBER(GET_VALUE_SET('SC_ABS_Modified_Hours_VS',
								'|=p_person_id='''		||to_char(l_per_id)||''''||
								'|p_start_date='''	||to_char(l_accr_prdstrt_dt, 'YYYY/MM/DD')||''''||
								'|p_end_date='''	||to_char(l_accr_prdend_dt, 'YYYY/MM/DD')||''''))
		)
	)
	
	/*retro accrual*/
	IF ((l_accr_prdstrt_dt <= l_abs_rtw_creatn_dt AND l_abs_rtw_creatn_dt <= l_accr_prdend_dt) 
		AND	( l_abs_strt < l_accr_prdstrt_dt  )) THEN
	(
		IF( l_abs_end < l_accr_prdstrt_dt ) THEN
		(
			l_abs_duration_retro	=	DAYS_BETWEEN(l_abs_end, l_abs_strt ) +1
			l_rtw_sum = l_rtw_sum + l_rtw_dur
			l_retro_modified_hrs	=	TO_NUMBER(GET_VALUE_SET('SC_ABS_Modified_Hours_VS',
										'|=p_person_id='''		||to_char(l_per_id)||''''||
										'|p_start_date='''	||to_char(l_abs_strt, 'YYYY/MM/DD')||''''||
										'|p_end_date='''	||to_char(l_abs_end, 'YYYY/MM/DD')||''''))
		)				
		ELSE 
		(
			l_abs_duration_retro	=	DAYS_BETWEEN(ADD_DAYS(l_accr_prdstrt_dt, - 1), l_abs_strt ) +1
			l_rtw_sum = l_rtw_sum + l_rtw_dur
			l_retro_modified_hrs	=	TO_NUMBER(GET_VALUE_SET('SC_ABS_Modified_Hours_VS',
										'|=p_person_id='''		||to_char(l_per_id)||''''||
										'|p_start_date='''	||to_char(l_abs_strt, 'YYYY/MM/DD')||''''||
										'|p_end_date='''	||to_char(ADD_DAYS(l_accr_prdstrt_dt, - 1), 'YYYY/MM/DD')||''''))
		)
	)
	
	
	l_rtw_hrs		=	l_modified_hrs + l_retro_modified_hrs
	l_reverse_accr	=	l_reverse_accr + ROUND(((l_rtw_sum/l_wrk_hrs)*l_acc_rate),2)
	l_log_accrual = ess_log_write('Reverse Accrual3 : 		-'||to_char(l_reverse_accr))
l_log_accrual = ess_log_write(' Accrual : 		'||to_char(l_accrual))
	IF (l_rtw_hrs <> 0 OR l_wrk_frq = 'Monthly') THEN 
	(
		l_accrual		=	l_accrual	+ 	ROUND(((l_rtw_hrs/l_wrk_hrs)*l_acc_rate),2)
	)
	
	IF l_debug_flag = 'Y' THEN
	(
		l_log_accrual = ess_log_write('Absence Type : 			'||'RTW')
		l_log_accrual = ess_log_write('Absence Creation Date : 	'||to_char(l_abs_rtw_creatn_dt))
		l_log_accrual = ess_log_write('Absence Start Date : 		'||to_char(l_abs_strt))
		l_log_accrual = ess_log_write('Absence End Date : 		'||to_char(l_abs_end))
		l_log_accrual = ess_log_write('l_rtw_dur : 		'||to_char(l_rtw_dur))
		l_log_accrual = ess_log_write('l_rtw_sum : 		'||to_char(l_rtw_sum))
		l_log_accrual = ess_log_write('Absence duration in current accrual period: '||to_char(l_abs_duration_curr))
		l_log_accrual = ess_log_write('Modified Hours in current accrual period : 	'||to_char(l_modified_hrs))
		l_log_accrual = ess_log_write('Retro Absence duration : 	'||to_char(l_abs_duration_retro))
		l_log_accrual = ess_log_write('Retro Modified Hours : 	'||to_char(l_retro_modified_hrs))
		l_log_accrual = ess_log_write('Return to Work Hours : 		'||to_char(l_rtw_hrs))
		l_log_accrual = ess_log_write('Reverse Accrual : 		-'||to_char(l_reverse_accr))
		l_log_accrual = ess_log_write('Added Accrual : 		'||to_char(l_accrual))
		l_log_accrual = ess_log_write('Working Hours : 		'||to_char(l_wrk_hrs))
		l_log_accrual = ess_log_write('Working Hours Frequency : 		'||l_wrk_frq)
				
	)
)

/* ************* Final accrual calculation ***************** */
ACCRUAL			=	l_accrual - l_reverse_accr

IF l_debug_flag = 'Y' THEN
(
	l_log_accrual = ess_log_write('Returned Accrual: ' ||to_char(ACCRUAL))
)

/* *****************************Check if accrual bank balance is going negative then make it 0 ****************** */
l_accr_balnc	=	TO_NUMBER(GET_VALUE_SET('SC_ABS_Accrual_Bal_First_Year_VS',
								'|=p_person_id='''		||to_char(l_per_id)||''''||
								'|p_plan_id='''   		||to_char(l_plan_id)||''''||
								'|p_year_end_dt='''		||to_char(l_accr_prdend_dt, 'YYYY/MM/DD')||''''))

IF (l_accr_balnc + l_accrual - l_reverse_accr) <  0 THEN
(
	ACCRUAL	=	-l_accr_balnc
	IF l_debug_flag = 'Y' THEN
	(
		l_log_accrual = ess_log_write('l_accr_balnc : ' || TO_CHAR(l_accr_balnc))
		l_log_accrual = ess_log_write('adjusted accrual : ' || to_char(ACCRUAL))
	)	
)

/* **************************	Termination Based Proration: no accrual for termination month ********************************************* */
IF (ISNULL(l_term_date)='Y' AND TO_CHAR(l_term_date,'YYYY') <> '4712') THEN
(
	/* IF (TO_CHAR(l_term_date,'MM-YYYY') = TO_CHAR(l_effective_date,'MM-YYYY' )) THEN */
	
	/* Update 1.5 */
	
	IF ( (TO_CHAR(l_term_date,'YYYY-MM-DD') >= TO_CHAR(l_accr_prdstrt_dt,'YYYY-MM-DD')) AND (TO_CHAR(l_term_date,'YYYY-MM-DD') <= TO_CHAR(l_accr_prdend_dt,'YYYY-MM-DD'))) THEN
	(
		ACCRUAL	=	0
		
		IF l_debug_flag = 'Y' THEN
		(
			l_log_accrual = ess_log_write('Returned Accrual in termination month : ' || to_char(ACCRUAL))
			l_log_accrual = ess_log_write('Termination Date_1 : ' || to_char(l_term_date,'YYYY-MM-DD'))
			l_log_accrual = ess_log_write('ACCRUALPERIODSTARTDATE_1 : ' || TO_CHAR(l_accr_prdstrt_dt,'YYYY-MM-DD'))
			l_log_accrual = ess_log_write('ACCRUALPERIODENDDATE_1 : ' || TO_CHAR(l_accr_prdend_dt,'YYYY-MM-DD'))
		)
	)
)

/* **************************	Logic to reduce/add balance of accrual (Dec 31st amount) at anniversary date******************************* */

/* IF (l_enrl_mon <> '01/01') AND ( TO_CHAR(ADD_MONTHS(l_enrl_dt,12) ,'YY/MM') = TO_CHAR(l_effective_date,'YY/MM')) */
/* IF (l_hire_mon <> '01/01') AND ( TO_CHAR(ADD_MONTHS(l_hire_date,12) ,'YY/MM') = TO_CHAR(l_effective_date,'YY/MM')) */
IF (l_hire_mon <> '01/01') AND ( TO_CHAR(ADD_MONTHS(l_hire_date,12) ,'YY/MM/DD') >= TO_CHAR(l_accr_prdstrt_dt,'YY/MM/DD'))
AND ( TO_CHAR(ADD_MONTHS(l_hire_date,12) ,'YY/MM/DD') <= TO_CHAR(l_accr_prdend_dt,'YY/MM/DD'))
THEN
(


If l_hire_year = '2023' THEN
(
	l_plan_id	=	300000014089647
)


	l_log_accrual = ess_log_write('Person ID : ' || to_char(l_per_id))
	l_log_accrual = ess_log_write('l_plan_id : ' || to_char(l_plan_id))
	

	l_temp_dt		=	'31-12-' || to_char(l_hire_date, 'YYYY')
	l_year_end_dt	=	to_date(l_temp_dt)
	/* get accrual balance till Dec 31st from Value set*/
	l_balance_dec	=	TO_NUMBER(GET_VALUE_SET('SC_ABS_Accrual_Bal_First_Year_VS',
								'|=p_person_id='''		||to_char(l_per_id)||''''||
								'|p_plan_id='''   		||to_char(l_plan_id)||''''||
								'|p_year_end_dt='''		||to_char(l_year_end_dt, 'YYYY/MM/DD')||''''))
								



	IF (ISNULL(l_balance_dec)='Y') /*V1.1 Changes added null check */
	THEN
	(

		ADJUSTMENTVALUES[1]	= -(l_balance_dec)
		ADJUSTMENTDATES[1]	= l_effective_date
		ADJUSTMENTTYPES[1]	= 'UBA' 				/*Adjustment Reason: Unpaid Balance Adjustment  */
		
		IF l_debug_flag = 'Y' THEN
		(
			l_log_accrual = ess_log_write('Temp date string : ' || l_temp_dt)
			l_log_accrual = ess_log_write('Year end date : ' || to_char(l_year_end_dt))
			l_log_accrual = ess_log_write('Periodic accrual as of Dec 31st : ' || to_char(l_balance_dec))
			
			 
			l_log_accrual = ess_log_write('ADJUSTMENTVALUES[1]	: '||TO_CHAR(l_adjustment_values))
			l_log_accrual = ess_log_write('ADJUSTMENTDATES[1]	: '||TO_CHAR(l_adjust_date))
			l_log_accrual = ess_log_write('ADJUSTMENTTYPES[1]	: '||l_adjust_type)
			

			
		)
	)
)


IF l_debug_flag = 'Y' THEN
(
	l_log_accrual = ess_log_write('Returned Accrual after adjustments : ' ||to_char(ACCRUAL))
)

RETURN ACCRUAL, ADJUSTMENTVALUES, ADJUSTMENTDATES, ADJUSTMENTTYPES	 