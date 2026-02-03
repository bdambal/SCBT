/* **************************************************************************
FORMULA NAME: SC_ABS_CI_Carryover_FF
FORMULA TYPE: Global Absence Carryover
DESCRIPTION : 

Change History:
Name					Date 			Version 		Comments
-------------------------------------------------------------------------------
Krishnendu Roy			24-Jan-2023 	1.0 			Initial Version
Sendil					23-Jan-2024		1.1				Update IF condition to exclude leave balance
****************************************************************************** */

/* ************************ Database Item Defaults ******************************** */
DEFAULT FOR PER_ASG_FTE_VALUE 					IS 1
DEFAULT FOR PER_ASG_EMPLOYMENT_CATEGORY 		IS 'XX'
DEFAULT FOR PER_ASG_BARGAINING_UNIT_CODE_NAME 	IS 'XX'
INPUTS ARE  IV_ACCRUALPERIODSTARTDATE      (DATE)
           ,IV_ACCRUALPERIODENDDATE        (DATE)

/* ************************* Variable Defaults **************************************/
l_assignment_id				= 	GET_CONTEXT(HR_ASSIGNMENT_ID,0)
L_PERSON_ID 				=   GET_CONTEXT(PERSON_ID,0)
L_Accrual_Plan_ID1  		= 	GET_CONTEXT(ACCRUAL_PLAN_ID,0)
l_effective_date    		= 	GET_CONTEXT(EFFECTIVE_DATE, '0001/01/01 00:00:00'(date))
L_Eff_Dt    				= 	add_years(IV_ACCRUALPERIODENDDATE,-1)
l_fte						=	1
L_Leave_Balance1			=	' '
carryover 			=	1
l_debug_flag 				=	'Y'

/* ******************************** Formula **************************************/
l_log_accrual = ess_log_write(' ------------------ Starting Formula SC_ABS_CI_Carryover_FF ------------------ ')
/* fetch Employee Group from Core HR */
CHANGE_CONTEXTS (HR_ASSIGNMENT_ID	=	l_assignment_id, EFFECTIVE_DATE	= l_effective_date)
(
	l_barg_unit 		=	PER_ASG_BARGAINING_UNIT_CODE_NAME 
	l_asg_ctg			=	PER_ASG_EMPLOYMENT_CATEGORY
	l_fte				=	PER_ASG_FTE_VALUE
)

/* L_Leave_Balance1 = GET_VALUE_SET('SC_ABS_GET_PLAN_BALANCE','|=P_PERSON_ID='''||TO_CHAR(L_PERSON_ID)||''''||
																	 '|P_EFFECTIVE_DATE='''||TO_CHAR(L_Eff_Dt,'YYYY/MM/DD')||''''||
																	 '|P_ABSENCE_ID='''||to_char(L_Accrual_Plan_ID1)||'''') */

/* L_Leave_Balance1 = to_number(GET_VALUE_SET('SC_BALANCE')) */
/* l_log_accrual = ess_log_write('L_Leave_Balance1 : 						' ||(L_Leave_Balance1)) */
l_log_accrual = ess_log_write('L_Eff_Dt : 						' ||TO_CHAR(L_Eff_Dt,'YYYY/MM/DD'))
l_log_accrual = ess_log_write('L_Accrual_Plan_ID1 : 						' ||TO_CHAR(L_Accrual_Plan_ID1))
l_log_accrual = ess_log_write('L_PERSON_ID : 						' ||TO_CHAR(L_PERSON_ID))

/* IF (l_barg_unit = 'AUPE') THEN	
(
	IF ( l_asg_ctg = 'FR' OR 
		 l_asg_ctg = 'FT' OR
		 l_asg_ctg = 'PT' OR
		 l_asg_ctg = 'PR') THEN
	(
		IF to_number(L_Leave_Balance1) >= 16 then
		(
			carryover = 16		
		)
		ELSE
		(
			carryover = to_number(L_Leave_Balance1)
		)
	)
	ELSE
	(
		carryover = 0
	)
	
)
ELSE 
(
	carryover = 0
) */

IF ((l_barg_unit = 'AUPE') AND (l_asg_ctg = 'FR' OR l_asg_ctg = 'FT' OR l_asg_ctg = 'PT' OR l_asg_ctg = 'PR') )THEN	
(
		
			carryover = 16

			l_log_accrual = ess_log_write('carryover If:  ' ||TO_CHAR(carryover))
)

ELSE 
(
	carryover = 0
	
	l_log_accrual = ess_log_write('carryover Else:  ' ||TO_CHAR(carryover))
)

l_log_accrual = ess_log_write('Assignment ID: 					' ||TO_CHAR(l_assignment_id))
l_log_accrual = ess_log_write('FTE : 						' ||TO_CHAR(l_fte))
l_log_accrual = ess_log_write('Assignment Category : 				' ||l_asg_ctg)
l_log_accrual = ess_log_write('Bargaining Unit : 				' ||l_barg_unit)
l_log_accrual = ess_log_write('carryover : 				' ||TO_CHAR(carryover))

l_log_accrual = ess_log_write(' ------------------ Ending Formula SC_ABS_CI_Carryover_FF ------------------ ')
RETURN carryover