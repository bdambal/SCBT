/********************************************************************
FORMULA NAME: SC_ABS_ELIG_EXC_AUPE_CASUAL
FORMULA TYPE: Participation and Rate Eligibility Formula 
DESCRIPTION: Absence Eligibility to exclude AUPE casual Employees 
---------------------------------------------------------------------------------
Anish Nair 25-Mar-2022 	Initial Version
Sendil	   14-May-2025	Assistant Deputy Chief Configuration Build  
*******************************************************************************/ 
DEFAULT FOR PER_ASG_EMPLOYMENT_CATEGORY IS ' ' 
DEFAULT FOR PER_ASG_BARGAINING_UNIT_CODE_NAME IS ' '
DEFAULT FOR PER_ASG_JOB_NAME IS ' '
DEFAULT FOR PER_ASG_ASSIGNMENT_STATUS_TYPE_LOOKUP_MEANING is ' '
ELIGIBLE = 'Y' 

L_Employment_Category = PER_ASG_EMPLOYMENT_CATEGORY
L_Brgaing_Unit = PER_ASG_BARGAINING_UNIT_CODE_NAME
L_Job_Name = PER_ASG_JOB_NAME
L_Assignment_Type = PER_ASG_ASSIGNMENT_STATUS_TYPE_LOOKUP_MEANING

l_log_accrual = ess_log_write(' ------------------ Starting Formula SC_ABS_ELIG_EXC_AUPE_CASUAL ------------------ ')


IF ((L_Employment_Category = 'CAS') AND (L_Brgaing_Unit = 'AUPE'))
THEN(ELIGIBLE = 'N')

IF ((L_Job_Name <> '10145 - Assistant Deputy Chief') AND (L_Brgaing_Unit = 'Classified Management'))
THEN(ELIGIBLE = 'N')


l_log_accrual = ess_log_write('Employment Category: 	' ||(L_Employment_Category))
l_log_accrual = ess_log_write('Bargaining Unit : 		' ||(L_Brgaing_Unit))
l_log_accrual = ess_log_write('Job Name :   		    ' ||L_Job_Name)
l_log_accrual = ess_log_write('Assignment Status :   	' ||L_Assignment_Type)
l_log_accrual = ess_log_write('Eligible :   		    ' ||ELIGIBLE)

l_log_accrual = ess_log_write(' ------------------ Ending Formula SC_ABS_ELIG_EXC_AUPE_CASUAL------------------ ')

RETURN ELIGIBLE