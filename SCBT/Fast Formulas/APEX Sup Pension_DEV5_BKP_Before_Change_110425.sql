/**********************************************************************
FORMULA NAME: APEX_SUP_PENSION_EE_PRESTAT_DEDN_CALCULATOR
FORMULA TYPE: Payroll
*****************************************************************************************************************************************************/
/* **************************************************************************************************************************************************
Change History:
Version	  Name          Date          Change id#  Description
-----------------------------------------------------------------------------------------------------------------------------------------------------
1.0       Vishal        22-Sep-2021		NA		 Added logic to process 'APEX Sup Pension EE','APEX ER Cont' and 'APEX Pension Service' Elements	
1.1       Vishal        21-Jun-2022     NA       Defect #2375689  fix 
1.2       Jay           30-Nov-2023     NA       Added Retro Amounts in YTD contributions for EE and ER to check the ceilings
                                                 Balances - APEX_SUP_PENSION_EE_RETRO_REL_YTD, APEX_ER_CONT_RETRO_REL_YTD
1.3       Jay           05-Dec-2023     NA		 Updated to calculate Pension service for 27 pay periods and precision to 5 decimal places
					  
----------------------------------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************************************/ 
ALIAS GROSS_EARNINGS_REL_RUN AS Gross_Earnings
ALIAS GROSS_EARNINGS_REL_NOCB_RUN AS Gross_Earnings_nocb
ALIAS NET_REL_RUN AS Net_Earnings
ALIAS NET_REL_NOCB_RUN AS Net_Earnings_nocb 
ALIAS APEX_SUP_PENSION_EE_ELIGIBLE_COMP_REL_NOCB_RUN AS Eligible_Compensation_NOCB
ALIAS GROSS_PAY_REL_TU_RUN AS Gross_Pay
ALIAS GROSS_PAY_REL_NOCB_RUN AS Gross_Pay_nocb



DEFAULT FOR Gross_Earnings IS 0
DEFAULT FOR Gross_Earnings_NOCB IS 0
DEFAULT FOR Net_Earnings IS 0
DEFAULT FOR Net_Earnings_NOCB IS 0
DEFAULT FOR Gross_Pay IS 0
DEFAULT FOR Gross_Pay_nocb IS 0

DEFAULT FOR APEX_SUP_PENSION_EE_ACCRUED_ASG_ITD IS 0
DEFAULT FOR APEX_SUP_PENSION_EE_ACCRUED_TRM_ITD IS 0
DEFAULT FOR APEX_SUP_PENSION_EE_ACCRUED_REL_ITD IS 0

DEFAULT FOR APEX_SUP_PENSION_EE_ARREAR_ASG_ITD IS 0
DEFAULT FOR APEX_SUP_PENSION_EE_ARREAR_TRM_ITD IS 0
DEFAULT FOR APEX_SUP_PENSION_EE_ARREAR_REL_ITD IS 0

DEFAULT FOR APEX_SUP_PENSION_EE_ELIGIBLE_COMP_ASG_RUN IS 0
DEFAULT FOR APEX_SUP_PENSION_EE_ELIGIBLE_COMP_TRM_RUN IS 0
DEFAULT FOR APEX_SUP_PENSION_EE_ELIGIBLE_COMP_REL_TU_RUN IS 0
DEFAULT FOR Eligible_Compensation_NOCB IS 0 

DEFAULT FOR PAY_EARN_PERIOD_NAME IS 'X'
DEFAULT FOR CMP_ASSIGNMENT_SALARY_BASIS_NAME IS 'X'
DEFAULT FOR PAY_EARN_PERIOD_START  is '0001/01/01 00:00:00' (date)
DEFAULT FOR PAY_EARN_PERIOD_END is '4712/12/31 00:00:00' (date)  
DEFAULT FOR ASG_HR_ASG_ID IS 0

DEFAULT_DATA_VALUE FOR PER_HIST_ASG_ASSIGNMENT_ID IS 0
DEFAULT_DATA_VALUE FOR PER_HIST_ASG_ASSIGNMENT_TYPE IS 'M'
DEFAULT_DATA_VALUE FOR PER_HIST_ASG_EFFECTIVE_START_DATE IS '1951/01/01 00:00:00'(DATE) 
DEFAULT_DATA_VALUE FOR PER_HIST_ASG_EFFECTIVE_END_DATE IS '1951/01/01 00:00:00'(DATE) 

DEFAULT FOR APEX_SUP_PENSION_EE_PAY_VALUE_REL_ENTRY_VALUE IS 0
DEFAULT FOR APEX_SUP_PENSION_EE_PENSIONABLE_EARNINGS_REL_ENTRY_VALUE IS 0
DEFAULT FOR APEX_SUP_PENSION_EE_PENSION_SERVICE_REL_ENTRY_VALUE IS 0
DEFAULT FOR SC_APEX_PENSION_SERVICE_REL_NOCB_PTD IS 0

DEFAULT for APEX_SUP_PENSION_EE_RETRO_REL_YTD is 0 /*Update: 30-Nov JS*/
DEFAULT for APEX_ER_CONT_RETRO_REL_YTD is 0 /*Update: 30-Nov JS*/												
DEFAULT FOR SC_APEX_PENSIONABLE_HOURS_REL_NOCB_PTD IS 0

DEFAULT FOR APEX_SUP_PENSION_EE_REL_YTD IS 0

DEFAULT FOR APEX_ER_CONT_REL_YTD IS 0



DEFAULT FOR ENTRY_LEVEL IS 'PA'
DEFAULT FOR Prorate_Start IS '0001/01/01 00:00:00' (DATE)
DEFAULT FOR ELEMENT_ELEMENT_NAME is 'ZZZ'
DEFAULT FOR APEX_PENSION_OVERRIDE_OVERRIDE_PENSION_EE_REL_ENTRY_VALUE IS -1
DEFAULT FOR APEX_PENSION_OVERRIDE_OVERRIDE_PENSION_ER_REL_ENTRY_VALUE IS -1
DEFAULT FOR APEX_PENSION_OVERRIDE_OVERRIDE_PENSION_SERVICE_REL_ENTRY_VALUE IS -1
DEFAULT FOR APEX_PENSION_OVERRIDE_OVERRIDE_CALCULATED_PENSIONABLE_EARNINGS_REL_ENTRY_VALUE IS -1
DEFAULT FOR APEX_PENSION_OVERRIDE_OVERRIDE_CALCULATED_PENSIONABLE_HOURS_REL_ENTRY_VALUE IS -1

DEFAULT FOR APEX_SUP_PENSION_EE_RETRO_ASG_ITD IS 0
DEFAULT FOR APEX_SUP_PENSION_EE_RETRO_TRM_ITD IS 0
DEFAULT FOR APEX_SUP_PENSION_EE_RETRO_REL_ITD IS 0
DEFAULT FOR APEX_SUP_PENSION_EE_RETRO_ASG_RUN IS 0
DEFAULT FOR APEX_SUP_PENSION_EE_RETRO_TRM_RUN IS 0
DEFAULT FOR APEX_SUP_PENSION_EE_RETRO_REL_RUN IS 0
DEFAULT FOR APEX_ER_CONT_RETRO_ASG_RUN IS 0
DEFAULT FOR APEX_ER_CONT_RETRO_TRM_RUN IS 0
DEFAULT FOR APEX_ER_CONT_RETRO_REL_RUN IS 0
INPUTS ARE Prorate_Start (DATE)

Formula_Name = '[APEX_SUP_PENSION_EE_PRESTAT_CALCULATOR]'
element_name = ELEMENT_ELEMENT_NAME
ee_context_id = GET_CONTEXT(ELEMENT_ENTRY_ID,0)
l_person_id      = GET_CONTEXT(PERSON_ID,0)
l_payroll_rel_id = GET_CONTEXT(PAYROLL_ASSIGNMENT_ID,0)
l_hr_term_id = GET_CONTEXT(PAYROLL_TERM_ID,0)
l_EE_contibution = 0
l_debug_flag = 'Y'

/*APEX Pension Override Element Defaults*/
l_override_EE = APEX_PENSION_OVERRIDE_OVERRIDE_PENSION_EE_REL_ENTRY_VALUE 
l_override_ER = APEX_PENSION_OVERRIDE_OVERRIDE_PENSION_ER_REL_ENTRY_VALUE 
l_override_pen_service = APEX_PENSION_OVERRIDE_OVERRIDE_PENSION_SERVICE_REL_ENTRY_VALUE
l_override_cal_pen_earnings = APEX_PENSION_OVERRIDE_OVERRIDE_CALCULATED_PENSIONABLE_EARNINGS_REL_ENTRY_VALUE
l_override_pen_hours = APEX_PENSION_OVERRIDE_OVERRIDE_CALCULATED_PENSIONABLE_HOURS_REL_ENTRY_VALUE
L_PAY_PERIODS_PER_YEAR = 0

IF (Prorate_Start WAS DEFAULTED) THEN
(
  EE_ID = TO_CHAR(ee_context_id)
)
ELSE
(
  EE_ID = TO_CHAR(ee_context_id) + TO_CHAR(Prorate_Start,'DDMMYYYY')
)
dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' ee_context_id = '||TO_CHAR(ee_context_id))
dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' EE_ID = '||EE_ID)

IF EE_ID = '0' THEN
(  
  dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' Element Entry Id context not set')
  Error_Mesg = GET_MESG('PAY','PAY_CONTEXT_NOT_FOUND', 'CONTEXT_NAME', 'Element Entry Identifier', 'ELE_NAME', element_name)
  RETURN Error_Mesg
) 
ELSE 
(

  /*   --------------------------------------------------------------------------------
  **   Attachment Level determines the appropriate Dimension used to calculate 
  **   the Deduction 
  **   --------------------------------------------------------------------------------
  */
  Attachment_Level = ENTRY_LEVEL
  IF (Attachment_Level = 'PA') THEN
  (  
    /* Assignment Level */
    Eligible_Compensation = APEX_SUP_PENSION_EE_ELIGIBLE_COMP_ASG_RUN
    Arrears_Balance = APEX_SUP_PENSION_EE_ARREAR_ASG_ITD
    Amount_Accrued = APEX_SUP_PENSION_EE_ACCRUED_ASG_ITD
	retro_run = APEX_SUP_PENSION_EE_RETRO_ASG_RUN
	retro_er_Run = APEX_ER_CONT_RETRO_ASG_RUN										  
  )
  ELSE IF (Attachment_Level = 'AP' or Attachment_Level = 'PT') THEN
  (  
    /* Terms Level */
    Eligible_Compensation = APEX_SUP_PENSION_EE_ELIGIBLE_COMP_TRM_RUN
    Arrears_Balance = APEX_SUP_PENSION_EE_ARREAR_TRM_ITD
    Amount_Accrued = APEX_SUP_PENSION_EE_ACCRUED_TRM_ITD
		retro_run = APEX_SUP_PENSION_EE_RETRO_TRM_RUN
	retro_er_Run = APEX_ER_CONT_RETRO_TRM_RUN  
  )
  ELSE IF (Attachment_Level = 'PR') THEN
  ( 
    /* Relationship Level */
    Eligible_Compensation = APEX_SUP_PENSION_EE_ELIGIBLE_COMP_REL_TU_RUN
    Arrears_Balance = APEX_SUP_PENSION_EE_ARREAR_REL_ITD
    Amount_Accrued = APEX_SUP_PENSION_EE_ACCRUED_REL_ITD
	retro_run = APEX_SUP_PENSION_EE_RETRO_REL_RUN
	retro_er_Run = APEX_ER_CONT_RETRO_REL_RUN								  
  )

  dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' Gross_Earnings = '||TO_CHAR(Gross_Earnings))
  dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' Gross_Earning NOCB = '||TO_CHAR(Gross_Earnings_NOCB))
  dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' Net_Earnings = '||TO_CHAR(Net_Earnings))
  dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' Net_Earning NOCB = '||TO_CHAR(Net_Earnings_NOCB))
  dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' Gross_Pay = '||TO_CHAR(Gross_Pay))
  dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' Gross_Pay_nocb= '||TO_CHAR(Gross_Pay_nocb))
  dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' Eligible_Compensation = '||TO_CHAR(Eligible_Compensation))
  dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' Eligible_Compensation_NOCB = '||TO_CHAR(Eligible_Compensation_NOCB)) 
  dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' Arrears_Balance = '||TO_CHAR(Arrears_Balance))
  dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' Amount_Accrued = '||TO_CHAR(Amount_Accrued))
   dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' retro_run = '||TO_CHAR(retro_run))
	  dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' retro_run = '||TO_CHAR(retro_er_run))					   
  dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' EE_ID = '||EE_ID)
/* V1.0 Begin*/

/* Added logic to process 'APEX Sup Pension EE','APEX ER Cont' and 'APEX Pension Service' Elements*/

l_cal_pension_earning           = 0
l_ee_rate                       = 0
l_er_rate                       = 0
l_apex_con_limit                = 0
l_apex_period_limit             = 0
l_EE_contibution                = 0
l_ER_contibution                = 0
L_SUP_PENSION_COMP_ASG_RUN      = 0
l_max_annual_ER_con_limit       = 0
ER_CONTRIBUTION                 = 0
CALCULATED_PENSIONABLE_EARNINGS = 0
PENSION_HOURS                   = 0
hr_asg_id                       = 0
l_asg_primary_flag              = 'X'
l_FTE                           = 0
PENSION_SERVICE                 = 0
l_APEX_ASG_RUN                  = 0
L_PAY_EARN_PERIOD_NAME 			= PAY_EARN_PERIOD_NAME
l_max_period_EE_con_limit 		= 0
l_max_annual_EE_con_limit 		= 0
l_max_period_ER_con_limit		= 0
l_max_annual_ER_con_limit		= 0
Dedn_Amt						= 0
l_SC_APEX_PENSION_SERVICE_REL_NOCB_PTD =0
l_SC_APEX_PENSIONABLE_HOURS_REL_NOCB_PTD=0
l_annual_normal_hours =0
l_APEX_SUP_PENSION_EE_REL_YTD =0
l_APEX_ER_CONT_REL_YTD=0

l_year = to_char(PAY_EARN_REGULAR_PROCESS_DATE,'YYYY')
l_payroll_name = PAYROLL_NAME
    dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' l_year = '||l_year)
            
    dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' l_payroll_name = '||l_payroll_name)
	if l_payroll_name = 'Biweekly' then
	(
		if l_year ='2024' THEN
			L_PAY_PERIODS_PER_YEAR = 27
		else 
			L_PAY_PERIODS_PER_YEAR = 26
	)
	ELSE if l_payroll_name = 'Monthly' then
	(
	  L_PAY_PERIODS_PER_YEAR = 12
	)

IF (
	(ISNULL(l_override_EE)='Y') AND 
	(l_override_EE <> -1)  AND
	(ISNULL(l_override_ER)='Y') AND 
	(l_override_ER<> -1) 
	) THEN 
	(	
	 Dedn_Amt = l_override_EE
	 ER_CONTRIBUTION = l_override_ER
	 PENSION_SERVICE = l_override_pen_service
	 CALCULATED_PENSIONABLE_EARNINGS = l_override_cal_pen_earnings
	 PENSION_HOURS = l_override_pen_hours
	 
	 l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ': APEX Pension Override Information Element Entry TRUE ' )
	 l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ': l_override_EE : '||TO_CHAR(l_override_EE ))
	 l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ': l_override_ER : '||TO_CHAR(l_override_ER ))
	 l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ': l_override_cal_pen_earnings : '||TO_CHAR(l_override_cal_pen_earnings ))
	 l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ': l_override_pen_service : '||TO_CHAR(l_override_pen_service ))
	 l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ': l_override_pen_hours : '||TO_CHAR(l_override_pen_hours ))
	)
ELSE 
(
 	 l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ': APEX Pension Override Information Element Entry FALSE ' )
 /*Pension Service Calculation Start*/

i = 1 
	WHILE (RUN_INCLUDED_PAYROLL_ASGS.EXISTS(i)) LOOP 
	( 
		IF l_debug_flag = 'Y' THEN
			(
				l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| 'Inside While Loop RUN_INCLUDED_PAYROLL_ASGS[i]: ' || to_char(RUN_INCLUDED_PAYROLL_ASGS[i]))
			)
			
		CHANGE_CONTEXTS(PAYROLL_ASSIGNMENT_ID = RUN_INCLUDED_PAYROLL_ASGS[i]) 
		( 
			HR_ASGS[i] = ASG_HR_ASG_ID
			hr_asg_id = ASG_HR_ASG_ID
			
			l_ee_rate = TO_NUMBER(GET_TABLE_VALUE('SCBT_PAY_FF_DEFAULTS', 'Rate','APEX Pension EE Rate'))/100
            l_apex_con_limit = TO_NUMBER(GET_TABLE_VALUE('SCBT_PAY_FF_DEFAULTS', 'Limit','Apex Pension Annual Contribution Limit'))
            
            l_apex_period_limit = l_apex_con_limit/ L_PAY_PERIODS_PER_YEAR  /*To adjust period limit for 27 PP*/
			
			l_APEX_SUP_PENSION_EE_REL_YTD = APEX_SUP_PENSION_EE_REL_YTD + APEX_SUP_PENSION_EE_RETRO_REL_YTD /*Update: 30-Nov JS - To include Retro Pension when checking YTD contributions amount*/
			
			l_APEX_ER_CONT_REL_YTD = APEX_ER_CONT_REL_YTD + APEX_ER_CONT_RETRO_REL_YTD /*Update: 30-Nov JS - To include Retro Pension when checking YTD contributions amount*/
			
		            
            /*Pensionable Earnings START */ 
            
            L_SUP_PENSION_COMP_ASG_RUN =  L_SUP_PENSION_COMP_ASG_RUN+APEX_SUP_PENSION_EE_ELIGIBLE_COMP_ASG_RUN /*APEX_SUP_PENSION_EE_ELIGIBLE_COMP_REL_RUN*/ 
			
			l_log=PAY_INTERNAL_LOG_WRITE('L_SUP_PENSION_COMP_ASG_RUN :'                    ||' '||TO_CHAR(L_SUP_PENSION_COMP_ASG_RUN))
			
			IF L_SUP_PENSION_COMP_ASG_RUN<>0
			THEN
			(
            
			l_cal_pension_earning = LEAST(l_apex_period_limit, L_SUP_PENSION_COMP_ASG_RUN)
            
            /*Pensionable Earnings END   */   
            
             /* EE CONTRIBUTION */
            l_max_period_EE_con_limit = l_apex_period_limit * l_ee_rate
            l_max_annual_EE_con_limit = l_apex_con_limit * l_ee_rate
            l_EE_contibution = (l_cal_pension_earning * l_ee_rate)- retro_run
  

            /* ER CONTRIBUTION */
            
            l_er_rate = TO_NUMBER(GET_TABLE_VALUE('SCBT_PAY_FF_DEFAULTS', 'Rate','APEX Pension ER Rate'))/100
            l_max_period_ER_con_limit = l_apex_period_limit * l_er_rate
            l_max_annual_ER_con_limit = l_apex_con_limit * l_er_rate
            l_ER_contibution = (l_cal_pension_earning * l_er_rate) - retro_er_Run
 
           /* Checking for EE/ER Contributions are not exceeding the periodic and annual contribution limits.*/
		   
		   
		   /*Defect #2375689  fix*/
		   
		    IF ((l_APEX_SUP_PENSION_EE_REL_YTD)<=l_max_annual_EE_con_limit)	
           THEN
          (
 	        
                 l_EE_contibution=LEAST((l_max_annual_EE_con_limit-(l_APEX_SUP_PENSION_EE_REL_YTD)),l_EE_contibution)
		         l_EE_contibution=GREATEST(l_EE_contibution,0)
		 
		    ) 
	       ELSE
	      (
	        l_EE_contibution=0
		 
		   ) 
	       
			l_actual_pensionable_earnings = 0
			l_calculated_ER_contibution = l_ER_contibution
		   
			l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ' l_calculated_ER_contibution: ' || to_char(l_ER_contibution))
	
	
		   IF ((l_APEX_ER_CONT_REL_YTD)<=l_max_annual_ER_con_limit)	
           THEN
          (
 	        
                 l_ER_contibution=LEAST((l_max_annual_ER_con_limit-(l_APEX_ER_CONT_REL_YTD)),l_ER_contibution)
		         l_ER_contibution=GREATEST(l_ER_contibution,0)
		 
		    ) 
	       ELSE
	      (
	        l_ER_contibution=0
		 
		   ) 
		   
		      		  
           
             /*  IF (l_EE_contibution<=(l_max_period_EE_con_limit+l_max_annual_EE_con_limit))
               THEN
               (
  	            
				l_EE_contibution = GREATEST(LEAST(l_EE_contibution,((l_max_period_EE_con_limit+l_max_annual_EE_con_limit)-l_EE_contibution)),0)
  	           
  	           
  	            )
  	        
              ELSE
                (
                  l_EE_contibution=0
  	            
  	            ) 
  	         
  	         
               IF (l_ER_contibution<=(l_max_period_ER_con_limit+l_max_annual_ER_con_limit))
               THEN
                (
  	           
			     l_ER_contibution = GREATEST(LEAST(l_ER_contibution,((l_max_period_ER_con_limit+l_max_annual_ER_con_limit)-l_ER_contibution)),0)
  	           
  	           
  	             )
  	           
               ELSE
                 (
                   l_ER_contibution=0
  	             
  	             )  
  	        
            */
            
                Dedn_Amt=l_EE_contibution
                ER_CONTRIBUTION=l_ER_contibution
                CALCULATED_PENSIONABLE_EARNINGS=l_cal_pension_earning
				
			/* Prorate Pension earning based on actual er amount */
		IF (l_ER_contibution = 0 AND l_EE_contibution = 0 ) THEN  
		(
			CALCULATED_PENSIONABLE_EARNINGS = 0
		)
		
		IF (l_ER_contibution > 0 ) AND (l_calculated_ER_contibution > l_ER_contibution)  THEN 
		(
			l_actual_pensionable_earnings = (l_ER_contibution * l_cal_pension_earning)/l_calculated_ER_contibution
			CALCULATED_PENSIONABLE_EARNINGS = LEAST(l_apex_period_limit, l_actual_pensionable_earnings)
		)			
			
		l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ' l_actual_EE_contibution: ' || to_char(l_EE_contibution))
		l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ' l_actual_ER_contibution: ' || to_char(l_ER_contibution))
		l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ' l_actual_pensionable_earnings: ' || to_char(CALCULATED_PENSIONABLE_EARNINGS))
			/* Prorate Pension earning based on actual er amount */	
			
			IF l_debug_flag = 'Y' THEN
			(
				l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ' HR_ASGS[i]: ' || to_char(HR_ASGS[i]))
				l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ' l_APEX_ASG_RUN: ' || to_char(l_APEX_ASG_RUN))
				
				
			)
		  )	
		) 
     i = i + 1 
	)

	
    /*CALL_FORMULA(
                'SCBT PAY Apex Pension Service Fast Formula',
	            HR_ASGS              > 'HR_ASGS',
	            PAY_EARN_PERIOD_END  >'l_effective_date',
	            l_asg_primary_flag   < 'l_asg_primary_flag' DEFAULT 'X',
			    l_FTE                <'l_FTE' DEFAULT 0
			   
				)

	
	 IF INSTR(L_PAY_EARN_PERIOD_NAME,'Biweekly')>0 AND l_asg_primary_flag ='Y' AND l_FTE<>0
	 THEN 
	 (
	   PENSION_SERVICE = ROUND(l_FTE/26, 4)
	  
	 )
	 ELSE 
	 IF INSTR(L_PAY_EARN_PERIOD_NAME,'Monthly')>0 AND l_asg_primary_flag ='Y'AND l_FTE<>0
	 THEN
	 (	 
       PENSION_SERVICE = ROUND(l_FTE/1,4)
       
	 ) */
	 
	 CALL_FORMULA(
                                                'SCBT PAY Apex Asg Annual Hrs Fast Formula',
                                                HR_ASGS              > 'HR_ASGS',
                                                PAY_EARN_PERIOD_END  >'l_effective_date',
                                                l_asg_primary_flag   < 'l_asg_primary_flag_return' DEFAULT 'X',
                                                l_FTE                <'l_FTE' DEFAULT 0,
												l_annual_normal_hours < 'l_normal_hours' DEFAULT 0
                                                )
												
			l_SC_APEX_PENSION_SERVICE_REL_NOCB_PTD = SC_APEX_PENSION_SERVICE_REL_NOCB_PTD            
			l_SC_APEX_PENSIONABLE_HOURS_REL_NOCB_PTD= SC_APEX_PENSIONABLE_HOURS_REL_NOCB_PTD
			

			l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ' l_SC_APEX_PENSION_SERVICE_REL_NOCB_PTD: ' || to_char(l_SC_APEX_PENSION_SERVICE_REL_NOCB_PTD))
			l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ' l_SC_APEX_PENSIONABLE_HOURS_REL_NOCB_PTD: ' || to_char(l_SC_APEX_PENSIONABLE_HOURS_REL_NOCB_PTD))
			l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ' l_asg_primary_flag: ' || (l_asg_primary_flag))
			l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ' l_annual_normal_hours: ' || to_char(l_annual_normal_hours))													
			l_normal_hours=0			
			PENSION_HOURS = l_SC_APEX_PENSIONABLE_HOURS_REL_NOCB_PTD
            			

            IF (
				l_asg_primary_flag ='Y' AND l_annual_normal_hours<>0  AND l_SC_APEX_PENSIONABLE_HOURS_REL_NOCB_PTD <> 0 
				/*l_FTE<>0 /* AND (l_partial_LTD<>0 OR l_pension_EE<>0) */ /* Commented by Arun */
				)
            THEN 
            (
			   /*PENSION_SERVICE = ROUND((l_FTE/PAY_PERIODS_PER_YEAR),4)*/
				
				l_normal_hours = l_annual_normal_hours / PAY_PERIODS_PER_YEAR

              
				
				TOTAL_PENSION_SERVICE = (l_SC_APEX_PENSIONABLE_HOURS_REL_NOCB_PTD/l_normal_hours)/L_PAY_PERIODS_PER_YEAR
								
				PENSION_SERVICE = ROUND(GREATEST (TOTAL_PENSION_SERVICE-l_SC_APEX_PENSION_SERVICE_REL_NOCB_PTD,0),5)
		
				l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ' : APEX Pension Service Calculation TRUE : ')
			    l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ' CALCULATED TOTAL_PENSION_SERVICE: ' || to_char(TOTAL_PENSION_SERVICE))				
			    l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ' CALCULATED PENSION_SERVICE: ' || to_char(PENSION_SERVICE))
 							 
            )
	 

  /* Pension Service Calculation End*/	
 
    l_log=PAY_INTERNAL_LOG_WRITE('l_ee_rate :'                                     ||' '||TO_CHAR(l_ee_rate))
    l_log=PAY_INTERNAL_LOG_WRITE('l_apex_con_limit:'                               ||' '||TO_CHAR(l_apex_con_limit))
    l_log=PAY_INTERNAL_LOG_WRITE('l_apex_period_limit :'                           ||' '||TO_CHAR(l_apex_period_limit))
    l_log=PAY_INTERNAL_LOG_WRITE('L_SUP_PENSION_COMP_ASG_RUN :'                    ||' '||TO_CHAR(L_SUP_PENSION_COMP_ASG_RUN))
    l_log=PAY_INTERNAL_LOG_WRITE('l_cal_pension_earning :'                         ||' '||TO_CHAR(l_cal_pension_earning))
    l_log=PAY_INTERNAL_LOG_WRITE('l_max_period_EE_con_limit :'                     ||' '||TO_CHAR(l_max_period_EE_con_limit))
    l_log=PAY_INTERNAL_LOG_WRITE('l_max_annual_EE_con_limit :'                     ||' '||TO_CHAR(l_max_annual_EE_con_limit))
    l_log=PAY_INTERNAL_LOG_WRITE('l_EE_contibution :'                              ||' '||TO_CHAR(l_EE_contibution))
    l_log=PAY_INTERNAL_LOG_WRITE('l_er_rate :'                                     ||' '||TO_CHAR(l_er_rate))
    l_log=PAY_INTERNAL_LOG_WRITE('l_apex_con_limit :'                              ||' '||TO_CHAR(l_apex_con_limit))
    l_log=PAY_INTERNAL_LOG_WRITE('l_max_period_ER_con_limit :'                     ||' '||TO_CHAR(l_max_period_ER_con_limit))
    l_log=PAY_INTERNAL_LOG_WRITE('l_max_annual_ER_con_limit :'                     ||' '||TO_CHAR(l_max_annual_ER_con_limit))
    l_log=PAY_INTERNAL_LOG_WRITE('l_ER_contibution : '                             ||' '||TO_CHAR(l_ER_contibution))
    l_log=PAY_INTERNAL_LOG_WRITE(' Apex Payroll Rel Id :'                          ||' '||TO_CHAR(l_payroll_rel_id))
	l_log=PAY_INTERNAL_LOG_WRITE(' Apex Payroll l_hr_term_id : '                   ||' '||TO_CHAR(l_hr_term_id))
	l_log=PAY_INTERNAL_LOG_WRITE(' Apex Payroll hr_asg_id :'                       ||' '||TO_CHAR(hr_asg_id))
	l_log=PAY_INTERNAL_LOG_WRITE(' Apex Payroll l_asg_primary_flag :'              ||' '||(l_asg_primary_flag))
	l_log=PAY_INTERNAL_LOG_WRITE(' Apex Payroll l_FTE :'                           ||' '||TO_CHAR(l_FTE))
	l_log=PAY_INTERNAL_LOG_WRITE(' Apex Payroll PENSION_SERVICE :'                 ||' '||TO_CHAR(PENSION_SERVICE))
	l_log=PAY_INTERNAL_LOG_WRITE(' Apex Payroll PENSION_HOURS :'                 ||' '||TO_CHAR(PENSION_HOURS))
	l_log=PAY_INTERNAL_LOG_WRITE(' Apex Payroll CALCULATED_PENSIONABLE_EARNINGS :' ||' '||TO_CHAR(CALCULATED_PENSIONABLE_EARNINGS))
	l_log=PAY_INTERNAL_LOG_WRITE(' Apex Payroll l_APEX_SUP_PENSION_EE_REL_YTD :' ||' '||TO_CHAR(l_APEX_SUP_PENSION_EE_REL_YTD))
	l_log=PAY_INTERNAL_LOG_WRITE(' Apex Payroll l_APEX_ER_CONT_REL_YTD :' ||' '||TO_CHAR(l_APEX_ER_CONT_REL_YTD))

	
	IF APEX_SUP_PENSION_EE_PAY_VALUE_REL_ENTRY_VALUE was defaulted 
	then
	(
		Dedn_Amt = Dedn_Amt
	)
	else
	(
		Dedn_Amt = APEX_SUP_PENSION_EE_PAY_VALUE_REL_ENTRY_VALUE
	)
	
	IF APEX_SUP_PENSION_EE_PENSIONABLE_EARNINGS_REL_ENTRY_VALUE was defaulted 
	then
	(
		CALCULATED_PENSIONABLE_EARNINGS = CALCULATED_PENSIONABLE_EARNINGS
	)
	else
	(
		CALCULATED_PENSIONABLE_EARNINGS = APEX_SUP_PENSION_EE_PENSIONABLE_EARNINGS_REL_ENTRY_VALUE
	)
	
	IF APEX_SUP_PENSION_EE_PENSION_SERVICE_REL_ENTRY_VALUE was defaulted 
	then
	(
		PENSION_SERVICE = PENSION_SERVICE
	)
	else
	(
		PENSION_SERVICE = APEX_SUP_PENSION_EE_PENSION_SERVICE_REL_ENTRY_VALUE
	)
	
																l_log=PAY_INTERNAL_LOG_WRITE(' Apex Payroll Final_calc_earnings :' ||' '||TO_CHAR(CALCULATED_PENSIONABLE_EARNINGS))	
)
	
/* V1.0 End*/	

  CALL_FORMULA(
    'GLB_DEDN_DUMMY_GUARANTEED_NET',
    Guaranteed_Net < 'Guaranteed_Net' DEFAULT 0
  )

  dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' Guaranteed_Net = '||TO_CHAR(Guaranteed_Net)) 
  /*
    CALL_FORMULA(
      'GLB_DEDN_PSTAT_CALC',
      Gross_Earnings > 'Gross_Earnings',
      Gross_Earnings_nocb > 'Gross_Earnings_NOCB',
      Net_Earnings > 'Net_Earnings',
      Net_Earnings_nocb > 'Net_Earnings_NOCB',
      Gross_Pay > 'Gross_Pay',
      Gross_Pay_nocb > 'Gross_Pay_nocb',
      Eligible_Compensation > 'Eligible_Compensation',
      Eligible_Compensation_NOCB > 'Eligible_Compensation_NOCB', 
      Arrears_Balance > 'Arrears_Balance',
      Amount_Accrued > 'Amount_Accrued',
      EE_ID > 'EE_ID',
      Guaranteed_Net > 'Guaranteed_Net',
      Dedn_Amt < 'Dedn_Amt' DEFAULT 0,
      To_Total_Owed < 'To_Total_Owed' DEFAULT 0,
      To_Arrears < 'To_Arrears' DEFAULT 0,
      Not_Taken < 'Not_Taken' DEFAULT 0,
      Mesg < 'Mesg' DEFAULT 'ZZZ',
      Error_Mesg < 'Error_Mesg' DEFAULT 'ZZZ',
      Stop_Entry < 'Stop_Entry' DEFAULT 'N'
  )
  */

  CALL_FORMULA(
      'GLB_DEDN_PSTAT_CALC',
      Gross_Earnings > 'Gross_Earnings',
      Gross_Earnings_nocb > 'Gross_Earnings_NOCB',
      Net_Earnings > 'Net_Earnings',
      Net_Earnings_nocb > 'Net_Earnings_NOCB',
      Gross_Pay > 'Gross_Pay',
      Gross_Pay_nocb > 'Gross_Pay_nocb',
      Dedn_Amt > 'Eligible_Compensation',
      Dedn_Amt > 'Eligible_Compensation_NOCB', 
      Arrears_Balance > 'Arrears_Balance',
      Amount_Accrued > 'Amount_Accrued',
      EE_ID > 'EE_ID',
      Guaranteed_Net > 'Guaranteed_Net',
      Dedn_Amt < 'Dedn_Amt' DEFAULT 0,
      To_Total_Owed < 'To_Total_Owed' DEFAULT 0,
      To_Arrears < 'To_Arrears' DEFAULT 0,
      Not_Taken < 'Not_Taken' DEFAULT 0,
      Mesg < 'Mesg' DEFAULT 'ZZZ',
      Error_Mesg < 'Error_Mesg' DEFAULT 'ZZZ',
      Stop_Entry < 'Stop_Entry' DEFAULT 'N'
  )  
  IF (Error_Mesg ='There are no Earnings available to calculate the deduction.') THEN
  (
    Mesg = GET_MESG('PAY','PAY_NO_EARNINGS_FOR_DEDUCTION', 'ELE_NAME', element_name)
    RETURN Mesg, Dedn_Amt, Not_Taken 
  )
  ELSE IF (Error_Mesg <> 'ZZZ') THEN
  (
    RETURN Error_Mesg
  )

  /* For PreTax Iteration Begin */
      l_pretax_value = 0
      IF (WSA_EXISTS('PRETAX_PAY_VALUE','NUMBER_NUMBER')) THEN
        (
          l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| '  - Array found for PRETAX_PAY_VALUE')
          wsa_pretax_pay_value = WSA_GET('PRETAX_PAY_VALUE',EMPTY_NUMBER_NUMBER)
    IF wsa_pretax_pay_value.EXISTS(ee_context_id) THEN
          ( l_pretax_value = wsa_pretax_pay_value[ee_context_id] 
    l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| '  -exsits PRETAX_PAY_VALUE=' || to_char(l_pretax_value))
       if (ENTRY_LEVEL='PR' and Gross_Pay <> Gross_Pay_nocb ) then (

    l_pretax_value = dedn_amt + l_pretax_value
    l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| '  -summary PRETAX_PAY_VALUE' || to_char(l_pretax_value))

    )
     )
     else 
     (
        l_pretax_value = dedn_amt 
     )


    wsa_pretax_pay_value[ee_context_id]=l_pretax_value

        )    
  else (
        wsa_pretax_pay_value[ee_context_id] = dedn_amt 
  l_pretax_value = dedn_amt
  )
  l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| '  - dedn amount=' || to_char(l_pretax_value))  
        WSA_SET('PRETAX_PAY_VALUE',wsa_pretax_pay_value)

        l_tru_id =GET_CONTEXT(TAX_UNIT_ID,0)
  PRETAX_TRU_KEY='PRETAX_TRU_KEY'||'_'||to_char(ee_context_id)
  WSA_SET(PRETAX_TRU_KEY,l_tru_id)
  l_cb_id =GET_CONTEXT(CALC_BREAKDOWN_ID,0)
  PRETAX_CB_KEY='PRETAX_CB_KEY'||'_'||to_char(ee_context_id)
  WSA_SET(PRETAX_CB_KEY,l_cb_id)

        IF (WSA_EXISTS('PRETAX_STOP_ENTRY','TEXT_NUMBER')) THEN
        (
          l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| ' - Array found for PRETAX_STOP_ENTRY')
          wsa_pretax_stop_entry = WSA_GET('PRETAX_STOP_ENTRY',EMPTY_TEXT_NUMBER)
        )    
        wsa_pretax_stop_entry[ee_context_id] = stop_entry
        WSA_SET('PRETAX_STOP_ENTRY',wsa_pretax_stop_entry)


         /* For PreTax Iteration End */


  /* ------------------------------------------------------------------------
  ** We need to check if Stop_Entry IS populated, AS regardless of what value 
  ** it holds, processing will stop if its returned
  ** ------------------------------------------------------------------------
  */
  IF Stop_Entry = 'Y' THEN 
  (
    Mesg = GET_MESG('PAY','PAY_TOTAL_OWED_REACHED', 'ELE_NAME', element_name)
    RETURN Dedn_Amt, Stop_Entry, To_Total_Owed, Mesg, To_Arrears, Not_Taken,ER_CONTRIBUTION,PENSION_SERVICE,CALCULATED_PENSIONABLE_EARNINGS,PENSION_HOURS  
  )
  ELSE
  (
    IF (Mesg <> 'ZZZ') THEN RETURN Dedn_Amt, To_Total_Owed, To_Arrears, Not_Taken, Mesg,ER_CONTRIBUTION,PENSION_SERVICE,CALCULATED_PENSIONABLE_EARNINGS,PENSION_HOURS 
    ELSE RETURN Dedn_Amt, To_Total_Owed, To_Arrears, Not_Taken,ER_CONTRIBUTION,PENSION_SERVICE,CALCULATED_PENSIONABLE_EARNINGS,PENSION_HOURS    
  )  
)
