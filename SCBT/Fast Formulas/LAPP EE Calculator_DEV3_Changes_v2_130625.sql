/**********************************************************************
FORMULA NAME: LAPP_EE_PRESTAT_DEDN_CALCULATOR
FORMULA TYPE: Payroll
***********************************************************************/
/* **************************************************************************************************************************************************
Change History:
Version	  Name          Date          Change id#  Description
-----------------------------------------------------------------------------------------------------------------------------------------------------
1.0       Vishal        16-Nov-2021		NA		Added logic to process 'LAPP EE','LAPP ER' and 'LAPP EE by ER' Elements.	
2.0       Arun			24-May-2023		123		Changed pension service rounding from 4 to 5 decimals
3.0	  	  Jay		    12/22/23		        2024 changes
4.0		  Sendil								LAPP Pension Enhancement Changes
----------------------------------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************************************/

ALIAS GROSS_EARNINGS_REL_RUN AS Gross_Earnings
ALIAS GROSS_EARNINGS_REL_NOCB_RUN AS Gross_Earnings_nocb
ALIAS NET_REL_RUN AS Net_Earnings
ALIAS NET_REL_NOCB_RUN AS Net_Earnings_nocb 
ALIAS LAPP_EE_ELIGIBLE_COMP_REL_NOCB_RUN AS Eligible_Compensation_NOCB
ALIAS GROSS_PAY_REL_TU_RUN AS Gross_Pay
ALIAS GROSS_PAY_REL_NOCB_RUN AS Gross_Pay_nocb

DEFAULT FOR Gross_Earnings IS 0
DEFAULT FOR Gross_Earnings_NOCB IS 0
DEFAULT FOR Net_Earnings IS 0
DEFAULT FOR Net_Earnings_NOCB IS 0
DEFAULT FOR Gross_Pay IS 0
DEFAULT FOR Gross_Pay_nocb IS 0

DEFAULT FOR LAPP_EE_ACCRUED_ASG_ITD IS 0
DEFAULT FOR LAPP_EE_ACCRUED_TRM_ITD IS 0
DEFAULT FOR LAPP_EE_ACCRUED_REL_ITD IS 0

DEFAULT FOR LAPP_EE_ARREAR_ASG_ITD IS 0
DEFAULT FOR LAPP_EE_ARREAR_TRM_ITD IS 0
DEFAULT FOR LAPP_EE_ARREAR_REL_ITD IS 0

DEFAULT FOR LAPP_EE_ELIGIBLE_COMP_ASG_RUN IS 0
DEFAULT FOR LAPP_EE_ELIGIBLE_COMP_TRM_RUN IS 0
DEFAULT FOR LAPP_EE_ELIGIBLE_COMP_REL_TU_RUN IS 0
DEFAULT FOR Eligible_Compensation_NOCB IS 0 

DEFAULT FOR ENTRY_LEVEL IS 'PA'
DEFAULT FOR Prorate_Start IS '0001/01/01 00:00:00' (DATE)
DEFAULT FOR ELEMENT_ELEMENT_NAME is 'ZZZ'
DEFAULT FOR TEST_LAPP_PENSION_INFO_ACCRUED_ASG_ITD IS 0
DEFAULT FOR TEST_LAPP_PENSION_INFO_ACCRUED_TRM_ITD IS 0
DEFAULT FOR TEST_LAPP_PENSION_INFO_ACCRUED_REL_ITD IS 0
DEFAULT FOR TEST_LAPP_PENSION_INFO_ARREAR_ASG_ITD IS 0
DEFAULT FOR TEST_LAPP_PENSION_INFO_ARREAR_TRM_ITD IS 0
DEFAULT FOR TEST_LAPP_PENSION_INFO_ARREAR_REL_ITD IS 0
DEFAULT FOR TEST_LAPP_PENSION_INFO_ELIGIBLE_COMP_ASG_RUN IS 0
DEFAULT FOR TEST_LAPP_PENSION_INFO_ELIGIBLE_COMP_TRM_RUN IS 0
DEFAULT FOR TEST_LAPP_PENSION_INFO_ELIGIBLE_COMP_REL_RUN IS 0
DEFAULT FOR Eligible_Compensation_NOCB IS 0 
DEFAULT FOR ENTRY_LEVEL IS 'PA'
DEFAULT FOR Prorate_Start IS '0001/01/01 00:00:00' (DATE)
DEFAULT FOR PAYROLL_PERIOD_TYPE IS 'X'
DEFAULT FOR PAY_EARN_PERIOD_NAME IS 'X'
DEFAULT FOR LAPP_PENSION_INFO_OVERRIDE_PENSION_EE_OVER_YMPE_REL_ENTRY_VALUE IS 0
DEFAULT FOR LAPP_PENSION_INFO_PENSIONER_FLAG_REL_ENTRY_VALUE IS 0
DEFAULT FOR LAPP_EE_PENSIONER_FLAG_REL_ENTRY_VALUE IS 0
DEFAULT FOR LAPP_EE_THIRTY_FIVE_YEARS_FLAG_REL_ENTRY_VALUE IS 0
DEFAULT FOR SC_LAPP_PENSIONABLE_EARNINGS_ASG_RUN IS 0
DEFAULT FOR SC_LTD_EARNINGS_FOR_LAPP_ASG_PTD IS 0
DEFAULT FOR SC_LAPP_PENSIONABLE_EARNINGS_ASG_PTD IS 0
DEFAULT FOR SC_LAPP_PENSIONABLE_EARNINGS_REL_NOCB_PTD IS 0
DEFAULT FOR SC_LAPP_PENSIONABLE_EARNINGS_REL_NOCB_RUN IS 0
DEFAULT FOR SC_UNPAID_ABSENCE_HOURS_FOR_LAPP_REL_NOCB_PTD IS 0
DEFAULT FOR  LAPP_EE_ELIGIBLE_COMP_ASG_RUN IS 0
DEFAULT FOR  LAPP_EE_ELIGIBLE_COMP_REL_RUN IS 0
DEFAULT FOR  LAPP_EE_REL_RUN IS 0
DEFAULT FOR  LAPP_EE_ASG_YTD IS 0
DEFAULT FOR  LAPP_ER_ASG_YTD IS 0
DEFAULT FOR  LAPP_EE_REL_YTD IS 0
DEFAULT FOR  LAPP_ER_REL_YTD IS 0
DEFAULT FOR  LAPP_EE_REL_NOCB_YTD IS 0
DEFAULT FOR  LAPP_ER_REL_NOCB_YTD IS 0 
DEFAULT FOR  SC_LTD_EARNINGS_FOR_LAPP_REL_NOCB_PTD IS 0
DEFAULT FOR  SC_UNPAID_ABSENCE_EARNINGS_FOR_LAPP_REL_NOCB_PTD IS 0
DEFAULT FOR  SC_LTD_EARNINGS_FOR_LAPP_REL_NOCB_RUN IS 0
DEFAULT FOR LAPP_PENSION_OVERRIDE_PENSIONER_FLAG_REL_ENTRY_VALUE IS 0
DEFAULT FOR LAPP_PENSION_OVERRIDE_PENSION_ELIGIBILITY_REL_ENTRY_VALUE IS 0
DEFAULT FOR LAPP_PENSION_OVERRIDE_THIRTY_FIVE_YEARS_FLAG_REL_ENTRY_VALUE IS 0
DEFAULT FOR LAPP_PENSION_OVERRIDE_OVERRIDE_LAPP_EE_OVER_YMPE_REL_ENTRY_VALUE IS -1
DEFAULT FOR LAPP_PENSION_OVERRIDE_OVERRIDE_LAPP_EE_UNDER_YMPE_REL_ENTRY_VALUE IS -1
DEFAULT FOR LAPP_PENSION_OVERRIDE_OVERRIDE_LAPP_EE_REL_ENTRY_VALUE IS  -1
DEFAULT FOR LAPP_PENSION_OVERRIDE_OVERRIDE_LAPP_EE_BY_ER_OVER_YMPE_REL_ENTRY_VALUE IS  -1
DEFAULT FOR LAPP_PENSION_OVERRIDE_OVERRIDE_LAPP_EE_BY_ER_UNDER_YMPE_REL_ENTRY_VALUE IS  -1
DEFAULT FOR LAPP_PENSION_OVERRIDE_OVERRIDE_PENSION_SERVICE_REL_ENTRY_VALUE IS  -1
DEFAULT FOR LAPP_PENSION_OVERRIDE_OVERRIDE_LAPP_EE_ON_ER_REL_ENTRY_VALUE IS  -1
DEFAULT FOR LAPP_PENSION_OVERRIDE_OVERRIDE_LAPP_ER_OVER_YMPE_REL_ENTRY_VALUE IS  -1
DEFAULT FOR LAPP_PENSION_OVERRIDE_OVERRIDE_LAPP_ER_UNDER_YMPE_REL_ENTRY_VALUE IS  -1
DEFAULT FOR LAPP_PENSION_OVERRIDE_OVERRIDE_LAPP_ER_REL_ENTRY_VALUE  IS  -1
DEFAULT FOR LAPP_PENSION_OVERRIDE_OVERRIDE_PENSIONABLE_EARNINGS_REL_ENTRY_VALUE IS  -1
DEFAULT FOR LAPP_PENSION_OVERRIDE_OVERRIDE_DATE_EARNED_REL_ENTRY_VALUE IS '0001/01/01 00:00:00' (date)
DEFAULT FOR LAPP_PENSION_OVERRIDE_override_pensionable_hours_REL_ENTRY_VALUE IS  -1
DEFAULT FOR PAY_EARN_PERIOD_START  is '0001/01/01 00:00:00' (date)
DEFAULT FOR PAY_EARN_PERIOD_END is '4712/12/31 00:00:00' (date)  
DEFAULT FOR ASG_HR_ASG_ID IS 0
DEFAULT FOR SC_LAPP_PENSION_EE_UNDER_YMPE_REL_NOCB_PTD IS 0
DEFAULT FOR SC_LAPP_PENSION_EE_OVER_YMPE_REL_NOCB_PTD IS 0
DEFAULT FOR SC_LAPP_CALCULATED_PENSIONABLE_EARNINGS_REL_NOCB_PTD IS 0
DEFAULT FOR SC_LAPP_CALCULATED_PENSIONABLE_EARNINGS_REL_NOCB_RUN IS 0
DEFAULT FOR LAPP_EE_REL_NOCB_PTD IS 0
DEFAULT FOR LAPP_ER_REL_NOCB_PTD IS 0
DEFAULT FOR SC_LAPP_PENSION_ER_UNDER_YMPE_REL_NOCB_PTD IS 0
DEFAULT FOR SC_LAPP_PENSION_ER_OVER_YMPE_REL_NOCB_PTD IS 0
DEFAULT FOR SC_LAPP_EE_BY_ER_UNDER_YMPE_REL_NOCB_PTD IS 0
DEFAULT FOR SC_LAPP_EE_BY_ER_OVER_YMPE_REL_NOCB_PTD IS 0
DEFAULT FOR LAPP_EE_BY_ER_REL_NOCB_PTD IS 0
DEFAULT FOR SC_LAPP_PENSION_SERVICE_REL_NOCB_PTD IS 0
DEFAULT FOR SC_UNPAID_ABSENCE_HOURS_FOR_LAPP_REL_NOCB_PTD IS 0
DEFAULT FOR SC_UNPAID_ABSENCE_HOURS_FOR_LAPP_REL_NOCB_RUN IS 0
DEFAULT FOR SC_LAPP_PENSIONABLE_HOURS_REL_NOCB_PTD IS 0
DEFAULT FOR SC_LTD_EARNINGS_FOR_LAPP_ASG_RUN IS 0
DEFAULT FOR SC_UNPAID_ABSENCE_EARNINGS_FOR_LAPP_ASG_RUN IS 0 
DEFAULT FOR SC_LTD_HOURS_FOR_LAPP_REL_NOCB_PTD IS 0
DEFAULT FOR LAPP_EE_BY_ER_REL_YTD IS 0



DEFAULT FOR SC_LAPP_PENSION_EE_UNDER_YMPE_INTERIM_REL_NOCB_PTD IS 0 
DEFAULT FOR SC_LAPP_PENSION_EE_OVER_YMPE_INTERIM_REL_NOCB_PTD IS 0 
DEFAULT FOR SC_LAPP_PENSION_ER_UNDER_YMPE_INTERIM_REL_NOCB_PTD IS 0 
DEFAULT FOR SC_LAPP_PENSION_ER_OVER_YMPE_INTERIM_REL_NOCB_PTD IS 0 
DEFAULT FOR SC_LAPP_EE_BY_ER_UNDER_YMPE_INTERIM_REL_NOCB_PTD IS 0 
DEFAULT FOR SC_LAPP_EE_BY_ER_OVER_YMPE_INTERIM_REL_NOCB_PTD IS 0

DEFAULT FOR SC_EXCLUDE_ELIGIBLE_EARNINGS_FROM_PENSION_ASG_RUN IS 0

DEFAULT FOR EXCLUDE_ELIGIBLE_EARNINGS_FROM_PENSION_EXCLUDE_LAPP_EARNINGS_ASG_ENTRY_VALUE IS 0

DEFAULT FOR SC_EXCLUDE_ELIGIBLE_EARNINGS_FROM_PENSION_REL_RUN IS 0

DEFAULT FOR SC_LAPP_PENSIONABLE_HOURS_REL_NOCB_RUN IS 0
DEFAULT FOR SC_LTD_HOURS_FOR_LAPP_REL_NOCB_RUN  IS 0
DEFAULT FOR SC_LTD_HOURS_FOR_LAPP_ASG_RUN  IS 0
default for LAPP_PENSION_OVERRIDE_FUTURE_1_REL_ENTRY_VALUE is 0


INPUTS ARE Prorate_Start (DATE)

Formula_Name = '[LAPP_EE_PRESTAT_CALCULATOR]'
element_name = ELEMENT_ELEMENT_NAME
ee_context_id = GET_CONTEXT(ELEMENT_ENTRY_ID,0)
Dedn_Amt = 0
Stop_Entry = 'Y'
To_Total_Owed=0
Mesg =' ' 
To_Arrears = 0
Not_Taken = 0


l_YMPE_Period =0 
l_YMPE = 0
l_MIN_PERIODIC_PENSIONABLE_EARNINGS = 0
l_PERIODIC_PENSIONABLE_EARNINGS_PTD = 0


ee_context_id                 = GET_CONTEXT(ELEMENT_ENTRY_ID,0)
l_person_id                   = GET_CONTEXT(PERSON_ID,0)
l_calc_breakdown_id           = GET_CONTEXT(CALC_BREAKDOWN_ID,-1)
l_tru_id                      = GET_CONTEXT(TAX_UNIT_ID,-1)
l_payroll_rel_action_id       = GET_CONTEXT(PAYROLL_REL_ACTION_ID,-1)
l_payroll_rel_id              = GET_CONTEXT(PAYROLL_RELATIONSHIP_ID,-1)
l_EE_contibution              = 0
l_pension_EE                  = 0
l_overage_YMPE_LTD            = 0
l_over_YMPE_LTD_EE_ER         = 0
l_under_YMPE_LTD_EE_ER        = 0
l_pension_LTD_EE_ER               = 0
l_under_YMPE_ER_Rate          = 0
l_under_YMPE_ER               = 0
l_over_YMPE_ER_Rate           = 0
l_Overage_YMPE_ER             = 0
l_over_YMPE_Rate              = 0
l_over_YMPE_ER                = 0
l_pension_ER                  = 0
l_total_under_YMPE            = 0
l_total_over_YMPE             = 0
l_total_under_YMPE_ER         = 0
l_total_over_YMPE_ER          = 0
l_LAPP_EE_ER_REL_PTD          = 0
l_calculated_pensionable_earnings = 0
l_pensioner_flag= LAPP_EE_PENSIONER_FLAG_REL_ENTRY_VALUE  
l_35_years_flag = LAPP_EE_THIRTY_FIVE_YEARS_FLAG_REL_ENTRY_VALUE
l_pension_limit_Year = 0
l_Pay_Check_Limit_period = 0 
l_PERIODIC_PENSIONABLE_EARNINGS_PTD= 0 
l_PERIODIC_PENSIONABLE_EARNINGS_RUN=0 
l_LAPP_LTD_PTD= 0 
l_LAPP_LTD_RUN=0
l_MIN_PERIODIC_PENSIONABLE_EARNINGS= 0 
l_LAPP_EE_ASG_RUN=10 
l_LAPP_EE_REL_RUN=11
l_YMPE = 0
l_YMPE_Period= 0 
l_under_YMPE_Rate= 0
l_under_YMPE  = 0
l_LAPP_EE_ASG_YTD = 0
l_LAPP_ER_ASG_YTD = 0
l_LAPP_EE_REL_YTD = 0
l_LAPP_ER_REL_YTD = 0
l_LAPP_EE_REL_PTD=0
l_LAPP_ER_REL_PTD = 0 
l_under_YMPE_PTD_EE=0
l_over_YMPE_PTD_EE=0
l_under_YMPE_PTD_ER=0
l_over_YMPE_PTD_ER=0
l_total_under_YMPE_LTD_EE_ER=0
l_total_over_YMPE_LTD_EE_ER=0
l_under_YMPE_PTD_EE_ER =0
l_over_YMPE_PTD_EE_ER = 0
l_SC_UNPAID_ABSENCE_HOURS = 0
l_SC_UNPAID_ABSENCE_EARNINGS_PTD= 0
l_EE_pension_limit_Year=0
l_ER_pension_limit_Year=0
l_Overage_YMPE = 0
l_over_YMPE_Rate = 0
l_over_YMPE = 0
l_run_value=0
PENSION_SERVICE=0
NUMBER_PER_FISCAL_YEAR =0
l_hours_salary_basis='X'
l_job_name='X'
l_bargaining_unit='X'
l_debug_flag = 'Y'
ee_context_id    = GET_CONTEXT(ELEMENT_ENTRY_ID,0)
l_person_id      = GET_CONTEXT(PERSON_ID,0)
l_hr_term_id = GET_CONTEXT(PAYROLL_TERM_ID,0)
l_EE_contibution = 0
l_hours_salary_basis='X'
l_debug_flag = 'Y'
l_next_pay_start_date='4712-12-31 00:00:00'
l_prev_pay_start_date='4712-12-31 00:00:00'
l_current_pay_start_date='4712-12-31 00:00:00'
L_PAY_EARN_PERIOD_NAME = PAY_EARN_PERIOD_NAME
l_partial_PE =0
l_partial_LTD =0
l_partial_YMPE_LTD =0
l_pen_service_ptd=0
l_comb_pensionable_earnings_ptd=0
l_pen_comb_tot_under_ympe_ptd =0
l_pen_comb_tot_over_ympe_ptd = 0
l_ee_proportion = 0
l_ee_er_proportion =0
l_pen_comb_tot_under_ympe=0
l_pen_comb_under_ympe = 0
l_pen_comb_tot_over_ympe=0
l_pen_comb_over_ympe = 0
l_pen_ee_under_ympe = 0
l_pen_ee_over_ympe  = 0  
l_pen_ee_er_under_ympe = 0
l_pen_ee_er_over_ympe  = 0
l_pen_er_tot_under_ympe =0
l_pen_er_under_ympe = 0
l_pen_er_tot_over_ympe =0
l_pen_er_over_ympe = 0
l_unpaid_proportion=0
l_unpaid_proportion1 = 0 /* added by Arun 13Jan2022 */
l_pen_comb_tot_under_ympe_earn=0
l_SC_UNPAID_ABSENCE_EARNINGS_RUN = 0 
l_cal_pensionable_earnings_PTD = 0
l_effective_date = GET_CONTEXT(EFFECTIVE_DATE,'1951/01/01 00:00:00'(date)) 
l_TRU_PRI_ID = 0
l_normal_hours =0
l_SC_LAPP_PENSIONABLE_EARNINGS_ASG_PTD=0
l_reduced_pen_hours_asg_run=0
l_reduced_pen_earnings_asg_run=0
l_reduced_pen_LTD_asg_run=0
l_reduced_pen_earnings_run =0
l_reduced_ltd_hours_asg_run=0
l_annual_normal_hours =0
l_SC_LAPP_PENSIONABLE_HOURS_PTD=0
l_check_pension_hours ='N'
TOTAL_PENSION_SERVICE=0
l_NON_ELIGIBLE_PENSION_EARN=0
l_NON_ELIGIBLE_PENSION_HOURS=0
l_LTD_HOURS_FOR_LAPP_REL_NOCB_PTD=0
l_LAPP_EE_by_ER_REL_YTD=0
l_SC_LAPP_PENSIONABLE_HOURS_RUN =0
l_SC_LTD_HOURS_FOR_LAPP_REL_NOCB_RUN=0
l_sec_asg_count =0
l_sec_asg_check ='X'
l_wsa_number=0
l_wsa_pension_hrs=0



/*LAPP Pension Override Element Defaults*/
l_lapp_pension_override_pensioner_flag                    = LAPP_PENSION_OVERRIDE_PENSIONER_FLAG_REL_ENTRY_VALUE
l_lapp_pension_override_pension_eligibility               = LAPP_PENSION_OVERRIDE_PENSION_ELIGIBILITY_REL_ENTRY_VALUE
l_lapp_pension_override_thirty_five_years_flag            = LAPP_PENSION_OVERRIDE_THIRTY_FIVE_YEARS_FLAG_REL_ENTRY_VALUE
l_lapp_pension_override_override_lapp_EE_OVER_YMPE        = LAPP_PENSION_OVERRIDE_OVERRIDE_LAPP_EE_OVER_YMPE_REL_ENTRY_VALUE
l_lapp_pension_override_override_lapp_EE_UNDER_YMPE       = LAPP_PENSION_OVERRIDE_OVERRIDE_LAPP_EE_UNDER_YMPE_REL_ENTRY_VALUE
l_lapp_pension_override_override_lapp_EE                  = LAPP_PENSION_OVERRIDE_OVERRIDE_LAPP_EE_REL_ENTRY_VALUE 
l_lapp_pension_override_override_lapp_EE_by_ER_OVER_YMPE  = LAPP_PENSION_OVERRIDE_OVERRIDE_LAPP_EE_BY_ER_OVER_YMPE_REL_ENTRY_VALUE 
l_lapp_pension_override_override_lapp_EE_by_ER_UNDER_YMPE = LAPP_PENSION_OVERRIDE_OVERRIDE_LAPP_EE_BY_ER_UNDER_YMPE_REL_ENTRY_VALUE 
l_lapp_pension_override_override_lapp_service             = LAPP_PENSION_OVERRIDE_OVERRIDE_PENSION_SERVICE_REL_ENTRY_VALUE 
l_lapp_pension_override_override_lapp_EE_by_ER            = LAPP_PENSION_OVERRIDE_OVERRIDE_LAPP_EE_ON_ER_REL_ENTRY_VALUE 
l_lapp_pension_override_override_lapp_ER_OVER_YMPE        = LAPP_PENSION_OVERRIDE_OVERRIDE_LAPP_ER_OVER_YMPE_REL_ENTRY_VALUE 
l_lapp_pension_override_override_lapp_ER_UNDER_YMPE       = LAPP_PENSION_OVERRIDE_OVERRIDE_LAPP_ER_UNDER_YMPE_REL_ENTRY_VALUE 
l_lapp_pension_override_override_lapp_ER                  = LAPP_PENSION_OVERRIDE_OVERRIDE_LAPP_ER_REL_ENTRY_VALUE  
l_lapp_pension_override_override_pensionable_earnings     = LAPP_PENSION_OVERRIDE_OVERRIDE_PENSIONABLE_EARNINGS_REL_ENTRY_VALUE 
l_lapp_pension_override_override_date_earned              = LAPP_PENSION_OVERRIDE_OVERRIDE_DATE_EARNED_REL_ENTRY_VALUE 
l_lapp_pension_override_override_pensionable_hours        = LAPP_PENSION_OVERRIDE_override_pensionable_hours_REL_ENTRY_VALUE  

l_override_flag 					 					  = 'N'

IF (Prorate_Start WAS DEFAULTED) THEN
(
  EE_ID = TO_CHAR(ee_context_id)
)
ELSE
(
  EE_ID = TO_CHAR(ee_context_id) + TO_CHAR(Prorate_Start,'DDMMYYYY')
)
dummy = ESS_LOG_WRITE(Formula_Name||' ee_context_id = '||TO_CHAR(ee_context_id))
dummy = ESS_LOG_WRITE(Formula_Name||' EE_ID = '||EE_ID)

IF EE_ID = '0' THEN
(  
  dummy = ESS_LOG_WRITE(Formula_Name||' Element Entry Id context not set')
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
    Eligible_Compensation = LAPP_EE_ELIGIBLE_COMP_ASG_RUN
    Arrears_Balance = LAPP_EE_ARREAR_ASG_ITD
    Amount_Accrued = LAPP_EE_ACCRUED_ASG_ITD
  )
  ELSE IF (Attachment_Level = 'AP' or Attachment_Level = 'PT') THEN
  (  
    /* Terms Level */
    Eligible_Compensation = LAPP_EE_ELIGIBLE_COMP_TRM_RUN
    Arrears_Balance = LAPP_EE_ARREAR_TRM_ITD
    Amount_Accrued = LAPP_EE_ACCRUED_TRM_ITD
  )
  ELSE IF (Attachment_Level = 'PR') THEN
  ( 
    /* Relationship Level */
    Eligible_Compensation = LAPP_EE_ELIGIBLE_COMP_REL_TU_RUN
    Arrears_Balance = LAPP_EE_ARREAR_REL_ITD
    Amount_Accrued = LAPP_EE_ACCRUED_REL_ITD
  )

  dummy = ESS_LOG_WRITE(Formula_Name||' Gross_Earnings = '||TO_CHAR(Gross_Earnings))
  dummy = ESS_LOG_WRITE(Formula_Name||' Gross_Earning NOCB = '||TO_CHAR(Gross_Earnings_NOCB))
  dummy = ESS_LOG_WRITE(Formula_Name||' Net_Earnings = '||TO_CHAR(Net_Earnings))
  dummy = ESS_LOG_WRITE(Formula_Name||' Net_Earning NOCB = '||TO_CHAR(Net_Earnings_NOCB))
  dummy = ESS_LOG_WRITE(Formula_Name||' Gross_Pay = '||TO_CHAR(Gross_Pay))
  dummy = ESS_LOG_WRITE(Formula_Name||' Gross_Pay_nocb= '||TO_CHAR(Gross_Pay_nocb))
  dummy = ESS_LOG_WRITE(Formula_Name||' Eligible_Compensation = '||TO_CHAR(Eligible_Compensation))
  dummy = ESS_LOG_WRITE(Formula_Name||' Eligible_Compensation_NOCB = '||TO_CHAR(Eligible_Compensation_NOCB)) 
  dummy = ESS_LOG_WRITE(Formula_Name||' Arrears_Balance = '||TO_CHAR(Arrears_Balance))
  dummy = ESS_LOG_WRITE(Formula_Name||' Amount_Accrued = '||TO_CHAR(Amount_Accrued))
  dummy = ESS_LOG_WRITE(Formula_Name||' EE_ID = '||EE_ID)

/* V1.0 Begin*/
/* Added logic to process 'LAPP EE','LAPP ER' and 'LAPP EE by ER' Elements*/
/*Checking if default overrides exists in LAPP Pension Override Element*/
l_year = to_char(PAY_EARN_REGULAR_PROCESS_DATE,'YYYY')
 dummy = ESS_LOG_WRITE(Formula_Name||' l_year = '||l_year)


l_payroll_name = PAYROLL_NAME
dummy = ESS_LOG_WRITE(Formula_Name||' l_payroll_name = '||l_payroll_name)
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
     (ISNULL(l_lapp_pension_override_override_lapp_EE_OVER_YMPE)='Y')        AND 
      l_lapp_pension_override_override_lapp_EE_OVER_YMPE<> -1                  AND
     (ISNULL(l_lapp_pension_override_override_lapp_EE_UNDER_YMPE)='Y')       AND 
      l_lapp_pension_override_override_lapp_EE_UNDER_YMPE<> -1               AND 	 
     (ISNULL(l_lapp_pension_override_override_lapp_EE)='Y')                  AND 
      l_lapp_pension_override_override_lapp_EE<> -1                            AND	 
     (ISNULL(l_lapp_pension_override_override_lapp_EE_by_ER_OVER_YMPE)='Y')  AND
	  l_lapp_pension_override_override_lapp_EE_by_ER_OVER_YMPE<> -1           AND
     (ISNULL(l_lapp_pension_override_override_lapp_EE_by_ER_UNDER_YMPE)='Y') AND
	  l_lapp_pension_override_override_lapp_EE_by_ER_UNDER_YMPE<> -1           AND
     (ISNULL(l_lapp_pension_override_override_lapp_service)='Y')             AND 
      l_lapp_pension_override_override_lapp_service<> -1	                     AND
     (ISNULL(l_lapp_pension_override_override_lapp_EE_by_ER)='Y')            AND
      l_lapp_pension_override_override_lapp_EE_by_ER<> -1	                     AND 
     (ISNULL(l_lapp_pension_override_override_lapp_ER_OVER_YMPE)='Y')        AND
      l_lapp_pension_override_override_lapp_ER_OVER_YMPE<> -1                  AND
     (ISNULL(l_lapp_pension_override_override_lapp_ER_UNDER_YMPE)='Y')       AND  
      l_lapp_pension_override_override_lapp_ER_UNDER_YMPE<> -1	             AND 
     (ISNULL(l_lapp_pension_override_override_lapp_ER)='Y')                  AND
      l_lapp_pension_override_override_lapp_ER<> -1	                         AND
     (ISNULL(l_lapp_pension_override_override_pensionable_earnings)='Y')     AND 
      l_lapp_pension_override_override_pensionable_earnings<> -1	         
    )
THEN 
(	
    l_log = ESS_LOG_WRITE(Formula_Name|| 'Calling LAPPEE Cal FFF  Case1' )
	
	l_override_flag 					 = 'Y'
	
    l_pension_EE                         = l_lapp_pension_override_override_lapp_EE
	l_over_YMPE                          = l_lapp_pension_override_override_lapp_EE_OVER_YMPE
	l_under_YMPE                         = l_lapp_pension_override_override_lapp_EE_UNDER_YMPE
	l_MIN_PERIODIC_PENSIONABLE_EARNINGS  = l_lapp_pension_override_override_pensionable_earnings
	l_under_YMPE_ER                      = l_lapp_pension_override_override_lapp_ER_UNDER_YMPE
	l_over_YMPE_ER                       = l_lapp_pension_override_override_lapp_ER_OVER_YMPE 
	l_pension_ER                         = l_lapp_pension_override_override_lapp_ER
	l_under_YMPE_LTD_EE_ER               = l_lapp_pension_override_override_lapp_EE_by_ER_UNDER_YMPE 
	l_over_YMPE_LTD_EE_ER                = l_lapp_pension_override_override_lapp_EE_by_ER_OVER_YMPE 
	l_Pension_LTD_EE_ER                  = l_lapp_pension_override_override_lapp_EE_by_ER
    PENSION_SERVICE                      = l_lapp_pension_override_override_lapp_service	
	l_SC_LAPP_PENSIONABLE_HOURS_PTD		 = l_lapp_pension_override_override_pensionable_hours
)

ELSE 
(
IF ( ((ISNULL(l_pensioner_flag)='N') OR 
      (l_pensioner_flag<>1))             
	 )
THEN
(
l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_calc_breakdown_id1:'||to_char(l_calc_breakdown_id))
l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_payroll_rel_action_id1:'||to_char(l_payroll_rel_action_id))
l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pensioner_flag:'||to_char(l_pensioner_flag))
l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_35_years_flag:'||to_char(l_35_years_flag))

l_wsa_name = 'SC_WSA_LAPP_EARNINGS_'||TO_CHAR(l_payroll_rel_id)
l_wsa_number=0

IF WSA_EXISTS(l_wsa_name)
THEN 
(
l_wsa_number= WSA_GET( l_wsa_name,0)

)

l_wsa_LTD_name = 'SC_WSA_LTD_EARNINGS_'||TO_CHAR(l_payroll_rel_id)
l_wsa_LTD=0

IF WSA_EXISTS(l_wsa_LTD_name)
THEN 
(
l_wsa_LTD= WSA_GET( l_wsa_LTD_name,0)

)


l_wsa_pension_hours = 'SC_WSA_PENSIONABLE_HOURS_'||TO_CHAR(l_payroll_rel_id)

l_wsa_pension_hrs=0

IF WSA_EXISTS(l_wsa_pension_hours)
THEN 
(
l_wsa_pension_hrs= WSA_GET( l_wsa_pension_hours,0)

)


l_wsa_ltd_hours = 'SC_LTD_HOURS_'||TO_CHAR(l_payroll_rel_id)
l_wsa_ltd_number_hours=0

IF WSA_EXISTS(l_wsa_ltd_hours)
THEN 
(
l_wsa_ltd_number_hours= WSA_GET( l_wsa_ltd_hours,0)

)



l_log = ESS_LOG_WRITE(Formula_Name|| 'l_wsa_number' || to_char(l_wsa_number))

l_log = ESS_LOG_WRITE(Formula_Name|| 'l_wsa_LTD' || to_char(l_wsa_LTD))

l_log = ESS_LOG_WRITE(Formula_Name|| 'l_wsa_pension_hrs' || to_char(l_wsa_pension_hrs))

l_log = ESS_LOG_WRITE(Formula_Name|| 'l_wsa_ltd_number_hours' || to_char(l_wsa_ltd_number_hours))




i = 1 
	WHILE (RUN_INCLUDED_PAYROLL_ASGS.EXISTS(i)) LOOP 
	( 
		IF l_debug_flag = 'Y' THEN
			(
				l_log = ESS_LOG_WRITE(Formula_Name|| 'Inside While Loop RUN_INCLUDED_PAYROLL_ASGS[i]: ' || to_char(RUN_INCLUDED_PAYROLL_ASGS[i]))
			)
			
		CHANGE_CONTEXTS(PAYROLL_ASSIGNMENT_ID = RUN_INCLUDED_PAYROLL_ASGS[i])
		( 
			
			HR_ASGS[i] = ASG_HR_ASG_ID
			hr_asg_id = ASG_HR_ASG_ID
			
			CALL_FORMULA(
                                                'SCBT PAY Apex Pension Service Fast Formula',
                                                HR_ASGS              > 'HR_ASGS',
                                                PAY_EARN_PERIOD_END  >'l_effective_date',
                                                l_asg_primary_flag   < 'l_asg_primary_flag' DEFAULT 'X',
                                                l_FTE                <'l_FTE' DEFAULT 0,
												l_annual_normal_hours       < 'l_normal_hours' DEFAULT 0
                                                )
												
												
												
l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR ASG l_asg_primary_flag'|| ' HR_ASGS[i]: ' || l_asg_primary_flag|| to_char(HR_ASGS[i]))
	
	
l_rel_run=0	
	
/*j=1
 WHILE PER_HIST_ASG_ASSIGNMENT_ID.Exists(j)
    LOOP
    (   
        	
        IF ( PER_HIST_ASG_EFFECTIVE_START_DATE[j] <=PAY_EARN_PERIOD_START AND PER_HIST_ASG_EFFECTIVE_END_DATE[j]>=PAY_EARN_PERIOD_START
           AND PER_HIST_ASG_ASSIGNMENT_TYPE[j] = 'E' AND PER_HIST_ASG_PRIMARY_FLAG[j]='N'
		   AND PER_HIST_ASG_PERSON_ID[j]=l_person_id) 
           
        THEN
        (  
           l_rel_run = SC_EXCLUDE_ELIGIBLE_EARNINGS_FROM_PENSION_REL_RUN
           
		   l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR ASG Check'|| ' l_rel_run: ' || to_char(l_rel_run))		   
	       EXIT
			
		)
		j=j+1
		)	*/
			
			
			l_sec_asg_check =  (GET_VALUE_SET('SC_PAY_LAPP_SEC_ASSIGNMENT_VS'
			                                          ,'|=P_PERSON_ID='''||TO_CHAR(l_person_id)||''''||
													   '|P_END_DATE='''||TO_CHAR(PAY_EARN_PERIOD_END,'YYYY-MM-DD')||''''
												     ))
													 
			IF (ISNULL(l_sec_asg_check)='N')
            THEN
             (
               l_sec_asg_count =0			 
			  )
			ELSE
             (
               l_sec_asg_count=1
             )
			 
			
			l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR l_sec_asg_count' || to_char(l_sec_asg_count))
			
			IF (l_sec_asg_count=0)
			THEN
			(
		    
            l_PERIODIC_PENSIONABLE_EARNINGS_RUN =  SC_LAPP_PENSIONABLE_EARNINGS_ASG_RUN
			)
            ELSE
            (
              l_PERIODIC_PENSIONABLE_EARNINGS_RUN =  l_PERIODIC_PENSIONABLE_EARNINGS_RUN+SC_LAPP_PENSIONABLE_EARNINGS_ASG_RUN			
			
			)
			
			l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR ASG l_PERIODIC_PENSIONABLE_EARNINGS_RUN1' ||  to_char(l_PERIODIC_PENSIONABLE_EARNINGS_RUN))
			
			l_LAPP_LTD_RUN                      =  SC_LTD_EARNINGS_FOR_LAPP_ASG_RUN
			
			l_LAPP_EE_REL_YTD                   =  LAPP_EE_REL_YTD
			l_LAPP_ER_REL_YTD                   =  LAPP_ER_REL_YTD
			l_LAPP_EE_by_ER_REL_YTD             =  LAPP_EE_BY_ER_REL_YTD
			
			l_SC_UNPAID_ABSENCE_HOURS           =  SC_UNPAID_ABSENCE_HOURS_FOR_LAPP_REL_NOCB_PTD 
			
			/*l_SC_UNPAID_ABSENCE_EARNINGS_PTD    =  SC_UNPAID_ABSENCE_EARNINGS_FOR_LAPP_REL_NOCB_PTD*/ 
			
			l_SC_UNPAID_ABSENCE_EARNINGS_RUN    =  SC_UNPAID_ABSENCE_EARNINGS_FOR_LAPP_ASG_RUN
			
		/* Commented Old DBI's for Under and Over YMPE*/
		
			/*l_under_YMPE_PTD_EE                 =  SC_LAPP_PENSION_EE_UNDER_YMPE_REL_NOCB_PTD
			l_over_YMPE_PTD_EE                  =  SC_LAPP_PENSION_EE_OVER_YMPE_REL_NOCB_PTD
			
			l_under_YMPE_PTD_ER                 = SC_LAPP_PENSION_ER_UNDER_YMPE_REL_NOCB_PTD
			l_over_YMPE_PTD_ER                  = SC_LAPP_PENSION_ER_OVER_YMPE_REL_NOCB_PTD
			
			l_under_YMPE_PTD_EE_ER              = SC_LAPP_EE_BY_ER_UNDER_YMPE_REL_NOCB_PTD
			l_over_YMPE_PTD_EE_ER               = SC_LAPP_EE_BY_ER_OVER_YMPE_REL_NOCB_PTD*/
			
			l_under_YMPE_PTD_EE                 =  SC_LAPP_PENSION_EE_UNDER_YMPE_INTERIM_REL_NOCB_PTD
			l_over_YMPE_PTD_EE                  =  SC_LAPP_PENSION_EE_OVER_YMPE_INTERIM_REL_NOCB_PTD
			
			l_under_YMPE_PTD_ER                 = SC_LAPP_PENSION_ER_UNDER_YMPE_INTERIM_REL_NOCB_PTD
			l_over_YMPE_PTD_ER                  = SC_LAPP_PENSION_ER_OVER_YMPE_INTERIM_REL_NOCB_PTD
			
			l_under_YMPE_PTD_EE_ER              = SC_LAPP_EE_BY_ER_UNDER_YMPE_INTERIM_REL_NOCB_PTD
			l_over_YMPE_PTD_EE_ER               = SC_LAPP_EE_BY_ER_OVER_YMPE_INTERIM_REL_NOCB_PTD
			
			
			l_LAPP_EE_ASG_YTD                   =  LAPP_EE_ASG_YTD
			l_LAPP_ER_ASG_YTD                   =  LAPP_ER_ASG_YTD
			
			l_pen_service_ptd                   =  SC_LAPP_PENSION_SERVICE_REL_NOCB_PTD
			
			l_cal_pensionable_earnings_PTD      = SC_LAPP_CALCULATED_PENSIONABLE_EARNINGS_REL_NOCB_PTD
			
			l_SC_LTD_HOURS_FOR_LAPP_REL_NOCB_PTD =SC_LTD_HOURS_FOR_LAPP_REL_NOCB_PTD
			
			l_SC_LAPP_PENSIONABLE_HOURS_RUN  = SC_LAPP_PENSIONABLE_HOURS_REL_NOCB_RUN
			
			l_SC_LTD_HOURS_FOR_LAPP_REL_NOCB_RUN = SC_LTD_HOURS_FOR_LAPP_REL_NOCB_RUN
			
			l_pen_hours_asg_run= SC_LAPP_PENSIONABLE_HOURS_ASG_RUN
			l_pen_earnings_run= SC_LAPP_PENSIONABLE_EARNINGS_ASG_RUN
			IF l_asg_primary_flag='N'
			THEN
			(
			  l_reduced_pen_hours_asg_run= SC_LAPP_PENSIONABLE_HOURS_ASG_RUN
			 ) 
			ELSE
			(
			    l_reduced_pen_hours_asg_run=l_wsa_pension_hrs
				
			)	
			
			IF (l_sec_asg_count=0)
			THEN
			(
			
			l_SC_LAPP_PENSIONABLE_HOURS_PTD     = SC_LAPP_PENSIONABLE_HOURS_REL_NOCB_PTD - l_reduced_pen_hours_asg_run
			l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR '|| ' l_SC_LAPP_PENSIONABLE_HOURS_PTD IF: ' || to_char(l_SC_LAPP_PENSIONABLE_HOURS_PTD))
			)
			ELSE /* Update LAPP EE Pension Enhancement*/
			(
			IF(l_pen_hours_asg_run>0) THEN
				(
				l_SC_LAPP_PENSIONABLE_HOURS_PTD     = SC_LAPP_PENSIONABLE_HOURS_REL_NOCB_PTD-l_reduced_pen_hours_asg_run
				)
				ELSE
				(
				l_SC_LAPP_PENSIONABLE_HOURS_PTD     = l_reduced_pen_hours_asg_run
				)
				l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR '|| ' l_SC_LAPP_PENSIONABLE_HOURS_PTD ELSE: ' || to_char(l_SC_LAPP_PENSIONABLE_HOURS_PTD))
			) 
			
			IF l_asg_primary_flag='N'
			THEN
			(
			  l_reduced_ltd_hours_asg_run= SC_LTD_HOURS_FOR_LAPP_ASG_RUN
			 ) 
			ELSE
			(
			    l_reduced_ltd_hours_asg_run=l_wsa_ltd_number_hours
				
			)	
			
			IF (l_sec_asg_count=0)
			THEN
			(
			
			l_SC_LTD_HOURS_FOR_LAPP_REL_NOCB_PTD     = SC_LTD_HOURS_FOR_LAPP_REL_NOCB_PTD - l_reduced_ltd_hours_asg_run
			)
			ELSE
			(
			 l_SC_LTD_HOURS_FOR_LAPP_REL_NOCB_PTD     = SC_LTD_HOURS_FOR_LAPP_REL_NOCB_PTD
			) 
					
			
			IF l_asg_primary_flag='N'
			THEN
			(
			  l_reduced_pen_LTD_asg_run= SC_LTD_EARNINGS_FOR_LAPP_ASG_RUN
			 ) 
			ELSE
			(
			  l_reduced_pen_LTD_asg_run=l_wsa_LTD
				
			)
			
			
			IF (l_sec_asg_count=0)
			THEN
			(
			l_LAPP_LTD_PTD =  SC_LTD_EARNINGS_FOR_LAPP_REL_NOCB_PTD-l_reduced_pen_LTD_asg_run
			)
			ELSE
			(
			 l_LAPP_LTD_PTD =  SC_LTD_EARNINGS_FOR_LAPP_REL_NOCB_PTD 
			
			)
			
			IF l_asg_primary_flag='N'
			THEN
			(
			  l_reduced_pen_earnings_run= SC_LAPP_PENSIONABLE_EARNINGS_ASG_RUN
			  
			 ) 
			ELSE
			(
			  l_reduced_pen_earnings_run= l_wsa_number /*SC_EXCLUDE_ELIGIBLE_EARNINGS_FROM_PENSION_REL_RUN  /*EXCLUDE_ELIGIBLE_EARNINGS_FROM_PENSION_EXCLUDE_LAPP_EARNINGS_ASG_ENTRY_VALUE /*SC_EXCLUDE_ELIGIBLE_EARNINGS_FROM_PENSION_ASG_RUN*/
				
			)
			
			IF (l_sec_asg_count=0)
			THEN
			(
			
			l_PERIODIC_PENSIONABLE_EARNINGS_PTD     =  SC_LAPP_PENSIONABLE_EARNINGS_REL_NOCB_PTD-l_reduced_pen_earnings_run
			)
			ELSE /* Update LAPP EE Pension Enhancement*/
			(
			 l_PERIODIC_PENSIONABLE_EARNINGS_PTD     =  SC_LAPP_PENSIONABLE_EARNINGS_REL_NOCB_PTD

				IF(l_pen_earnings_run>0)
				THEN
				(
				l_PERIODIC_PENSIONABLE_EARNINGS_PTD     = SC_LAPP_PENSIONABLE_EARNINGS_REL_NOCB_PTD-l_reduced_pen_earnings_run
				)
				ELSE
				(
				l_PERIODIC_PENSIONABLE_EARNINGS_PTD     = l_reduced_pen_earnings_run
				)
			
				l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR '|| ' l_PERIODIC_PENSIONABLE_EARNINGS_PTD ELSE: ' || to_char(l_PERIODIC_PENSIONABLE_EARNINGS_PTD))
			 
			)
			
			/* Update LAPP EE Pension Enhancement*/
			
			IF (l_sec_asg_count=0)
			THEN
			(
			
			l_PERIODIC_PENSIONABLE_EARNINGS_PTD_1    =  SC_LAPP_PENSIONABLE_EARNINGS_REL_NOCB_PTD-l_reduced_pen_earnings_run
			)
			ELSE
			(
			 l_PERIODIC_PENSIONABLE_EARNINGS_PTD_1     =  SC_LAPP_PENSIONABLE_EARNINGS_REL_NOCB_PTD
			 )
			
			
			
			l_normal_hours=0									
					

            IF (
				l_asg_primary_flag='Y' AND l_annual_normal_hours<>0  AND (l_SC_LAPP_PENSIONABLE_HOURS_PTD+l_SC_LTD_HOURS_FOR_LAPP_REL_NOCB_PTD) <> 0 AND l_check_pension_hours='N'/*l_FTE<>0 /* AND (l_partial_LTD<>0 OR l_pension_EE<>0) */ /* Commented by Arun */
				)
            THEN 
            (
                        /*PENSION_SERVICE = ROUND((l_FTE/L_PAY_PERIODS_PER_YEAR),4)*/
						
						l_normal_hours = l_annual_normal_hours / PAY_PERIODS_PER_YEAR
						
						/*
						 l_PENSIONABLE_HOURS_YTD = l_SC_LAPP_PENSIONABLE_HOURS_YTD + l_SC_LTD_HOURS_FOR_LAPP_REL_NOCB_YTD
						 
						 
						 IF 	l_PENSIONABLE_HOURS_YTD >= l_annual_normal_hours
  THEN
     (l_pensionable_hours=0
	  
	 
	  )
  else if 	l_PENSIONABLE_HOURS_YTD+l_SC_LAPP_PENSIONABLE_HOURS_RUN+l_SC_LTD_HOURS_FOR_LAPP_REL_NOCB_RUN <= l_annual_normal_hours
  then 
	 l_pensionable_hours = l_SC_LAPP_PENSIONABLE_HOURS_RUN+l_SC_LTD_HOURS_FOR_LAPP_REL_NOCB_RUN
  else 	 
	( 
	l_pensionable_hours= GREATEST((l_annual_normal_hours-(l_PENSIONABLE_HOURS_YTD+f+l_SC_LTD_HOURS_FOR_LAPP_REL_NOCB_RUN)),0)
	
	)
			
PENSION_SERVICE = ((l_pensionable_hours)/l_normal_hours)/L_PAY_PERIODS_PER_YEAR


						
						
						l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR '|| ' l_SC_LTD_HOURS_FOR_LAPP_REL_NOCB_PTD IF: ' || to_char(l_SC_LTD_HOURS_FOR_LAPP_REL_NOCB_PTD))
						l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR '|| ' PENSION_SERVICE IF: ' || to_char(PENSION_SERVICE))
						
						l_check_pension_hours='Y' 
						
						l_SC_LAPP_PENSIONABLE_HOURS_PTD=l_pensionable_hours			
						
						*/
						
						
						TOTAL_PENSION_SERVICE = ((l_SC_LAPP_PENSIONABLE_HOURS_PTD+l_SC_LTD_HOURS_FOR_LAPP_REL_NOCB_PTD)/l_normal_hours)/L_PAY_PERIODS_PER_YEAR
						PENSION_SERVICE = ROUND(GREATEST (TOTAL_PENSION_SERVICE-l_pen_service_ptd,0),5)
						
						l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR '|| ' l_SC_LTD_HOURS_FOR_LAPP_REL_NOCB_PTD IF: ' || to_char(l_SC_LTD_HOURS_FOR_LAPP_REL_NOCB_PTD))
						l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR '|| ' l_SC_LAPP_PENSIONABLE_HOURS_PTD IF: ' || to_char(l_SC_LAPP_PENSIONABLE_HOURS_PTD))
						l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR '|| ' l_annual_normal_hours IF: ' || to_char(l_annual_normal_hours))
						l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR '|| ' L_PAY_PERIODS_PER_YEAR IF: ' || to_char(L_PAY_PERIODS_PER_YEAR))
						l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR '|| ' l_normal_hours IF: ' || to_char(l_normal_hours))
						l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR '|| ' PENSION_SERVICE IF: ' || to_char(PENSION_SERVICE))
						
						l_check_pension_hours='Y' 
						
						/*IF l_sec_asg_count =0
						THEN
						(  
						  l_SC_LAPP_PENSIONABLE_HOURS_PTD =l_SC_LAPP_PENSIONABLE_HOURS_PTD+l_SC_LTD_HOURS_FOR_LAPP_REL_NOCB_PTD
						 )
						ELSE
						(
						l_SC_LAPP_PENSIONABLE_HOURS_PTD=l_SC_LAPP_PENSIONABLE_HOURS_RUN+l_SC_LTD_HOURS_FOR_LAPP_REL_NOCB_RUN
						)*/
						
						l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR '|| ' l_SC_LAPP_PENSIONABLE_HOURS_RUN IF: ' || to_char(l_SC_LAPP_PENSIONABLE_HOURS_RUN))
						l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR '|| ' l_SC_LTD_HOURS_FOR_LAPP_REL_NOCB_RUN IF: ' || to_char(l_SC_LTD_HOURS_FOR_LAPP_REL_NOCB_RUN))
						
						
						
            )									
			
			
			l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR '|| ' l_wsa_number: ' || to_char(l_wsa_number))
			
			l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR'|| ' l_reduced_pen_hours_asg_run: ' || to_char(l_reduced_pen_hours_asg_run))
			
			l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR'|| ' l_reduced_pen_LTD_asg_run: ' || to_char(l_reduced_pen_LTD_asg_run))
			l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR'|| ' l_reduced_pen_earnings_run: ' || to_char(l_reduced_pen_earnings_run))
			l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR'|| ' l_reduced_ltd_hours_asg_run: ' || to_char(l_reduced_ltd_hours_asg_run))
			
					
			IF l_debug_flag = 'Y' THEN
			(
				l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR ASG Check'|| ' HR_ASGS[i]: ' || to_char(HR_ASGS[i]))
			)
		) 
     
IF l_asg_primary_flag<>'N'
THEN
	
(
	
IF (l_PERIODIC_PENSIONABLE_EARNINGS_RUN<>0 OR l_LAPP_LTD_RUN<>0)
THEN

(
	


  l_pension_limit_Year     = TO_NUMBER(GET_TABLE_VALUE('SCBT_PAY_FF_DEFAULTS', 'Limit','LAPP PENSION ANNUAL CONTRIBUTION EARNINGS LIMIT'))
  
  l_EE_pension_limit_Year  = TO_NUMBER(GET_TABLE_VALUE('SCBT_PAY_FF_DEFAULTS', 'Limit','LAPP PENSION ANNUAL EE CONTRIBUTION LIMIT','9999'))
  
  l_ER_pension_limit_Year  = TO_NUMBER(GET_TABLE_VALUE('SCBT_PAY_FF_DEFAULTS', 'Limit','LAPP Pension Annual ER Contribution Limit','9999'))

  l_Pay_Check_Limit_period = l_pension_limit_Year / L_PAY_PERIODS_PER_YEAR  
 
	     
  l_YMPE = TO_NUMBER(GET_VALUE_SET('SC_PAY_CAL_VALUE_DEF_PENSION_EARNINGS_VS','|=P_EFF_DATE='''
					                                 ||TO_CHAR(l_effective_date,'YYYY-MM-DD')||''''
												     ))	 
	l_under_YMPE_Rate = TO_NUMBER(GET_TABLE_VALUE('SCBT_PAY_FF_DEFAULTS', 'Rate','LAPP EE UNDER YMPE RATE'))												
	l_under_YMPE_ER_Rate = TO_NUMBER(GET_TABLE_VALUE('SCBT_PAY_FF_DEFAULTS', 'Rate','LAPP ER UNDER YMPE RATE'))
	l_over_YMPE_Rate = TO_NUMBER(GET_TABLE_VALUE('SCBT_PAY_FF_DEFAULTS', 'Rate','LAPP EE OVER YMPE RATE'))
	l_over_YMPE_ER_Rate = TO_NUMBER(GET_TABLE_VALUE('SCBT_PAY_FF_DEFAULTS', 'Rate','LAPP ER OVER YMPE RATE'))
													
  
  l_MIN_PERIODIC_PENSIONABLE_EARNINGS = LEAST (l_PERIODIC_PENSIONABLE_EARNINGS_PTD, l_Pay_Check_Limit_period)
  
  
  /* Update LAPP EE Pension Enhancement*/
  
  l_MIN_PERIODIC_PENSIONABLE_EARNINGS_1 = LEAST (l_PERIODIC_PENSIONABLE_EARNINGS_PTD_1, l_Pay_Check_Limit_period)

  l_comb_pensionable_earnings_ptd = LEAST (l_MIN_PERIODIC_PENSIONABLE_EARNINGS_1+l_LAPP_LTD_PTD+0, l_Pay_Check_Limit_period)  /*Replaced l_SC_UNPAID_ABSENCE_EARNINGS_PTD with 0 by Arun on 05Jan2022 */
  
   /*
   
    l_MIN_PERIODIC_PENSIONABLE_EARNINGS_YTD=  l_MIN_PERIODIC_PENSIONABLE_EARNINGS_YTD+l_comb_pensionable_earnings_ptd 

  IF 	l_MIN_PERIODIC_PENSIONABLE_EARNINGS_YTD >= l_annual_limit
  THEN
     (l_comb_pensionable_earnings_ptd=0
	  
	 
	  )
  else if 	l_MIN_PERIODIC_PENSIONABLE_EARNINGS_YTD+l_comb_pensionable_earnings_ptd <= l_annual_limit
  then 
	 l_comb_pensionable_earnings_ptd = l_comb_pensionable_earnings_ptd
  else 	 
	( 
	l_comb_pensionable_earnings_ptd= GREATEST((l_annual_limit-(l_MIN_PERIODIC_PENSIONABLE_EARNINGS_YTD+l_comb_pensionable_earnings_ptd)),0)
	
	)
	
	l_MIN_PERIODIC_PENSIONABLE_EARNINGS = GREATEST(l_comb_pensionable_earnings_ptd
												- l_PERIODIC_PENSIONABLE_EARNINGS_PTD - l_LAPP_LTD_PTD 
												+ l_PERIODIC_PENSIONABLE_EARNINGS_RUN + l_LAPP_LTD_RUN
											   , 0) /* Modified by Arun 
    

  */
  
  
  l_pen_comb_tot_under_ympe_ptd = l_under_YMPE_PTD_EE + l_under_YMPE_PTD_EE_ER
  l_pen_comb_tot_over_ympe_ptd = l_over_YMPE_PTD_EE + l_over_YMPE_PTD_EE_ER
  
/*---- Start YMPE----*/ 
  l_YMPE_Period = l_YMPE / L_PAY_PERIODS_PER_YEAR
  
  
  IF ( l_PERIODIC_PENSIONABLE_EARNINGS_RUN + l_LAPP_LTD_RUN ) > 0
  THEN
(
            l_ee_proportion = l_PERIODIC_PENSIONABLE_EARNINGS_RUN / ( l_PERIODIC_PENSIONABLE_EARNINGS_RUN + l_LAPP_LTD_RUN + 0 )  /*Replaced l_SC_UNPAID_ABSENCE_EARNINGS_RUN with 0 by Arun on 05Jan2022 */
            l_ee_er_proportion = l_LAPP_LTD_RUN / ( l_PERIODIC_PENSIONABLE_EARNINGS_RUN + l_LAPP_LTD_RUN + 0 )  /*Replaced l_SC_UNPAID_ABSENCE_EARNINGS_RUN with 0 by Arun on 05Jan2022 */
			
		/*Unpaid Absences for Executives */
             CALL_FORMULA(
                          'SC PAY Job Name Fast Formula',
	                      hr_asg_id            > 'l_assignment_id',
	                      PAY_EARN_PERIOD_END  >'l_period_end_date',
	                      l_job_name           < 'l_job_name' DEFAULT 'X',
				          l_bargaining_unit    < 'l_bargaining_unit' DEFAULT 'X'
			             )
				   
			/*l_unpaid_proportion1 = l_SC_UNPAID_ABSENCE_EARNINGS_RUN/( l_PERIODIC_PENSIONABLE_EARNINGS_RUN + l_LAPP_LTD_RUN+l_SC_UNPAID_ABSENCE_EARNINGS_RUN )  *//*Commented June 30th */
			
			l_unpaid_proportion1=0
			
			
			
			/*
			IF (l_bargaining_unit='Classified Management'  OR 
	            l_bargaining_unit='Library Management')
            THEN 				
			(
				l_unpaid_proportion = l_unpaid_proportion1
			 ) 
			ELSE
			(
				l_unpaid_proportion=0
			)
			 -- Commented on 05Jan2022 by Vishal as no contribution on unpaid absences for executives as well */
			
			IF l_bargaining_unit ='IAFF'
			THEN
			(
			    l_ee_proportion= (100/100)-l_unpaid_proportion1
				l_ee_er_proportion=0
			 )	
				
)
ELSE
(
            l_ee_proportion = 0
            l_ee_er_proportion = 0
			l_unpaid_proportion = 0
)


/*Employee and EE by ER*/
IF l_comb_pensionable_earnings_ptd <= l_YMPE_Period
then
(
            l_pen_comb_tot_under_ympe = l_comb_pensionable_earnings_ptd *l_under_YMPE_Rate/100
            l_pen_comb_under_ympe = GREATEST(l_pen_comb_tot_under_ympe - l_pen_comb_tot_under_ympe_ptd, 0)
			
			l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  Under l_pen_comb_under_ympe:'||to_char(l_pen_comb_under_ympe))
)
ELSE
(
            l_pen_comb_tot_under_ympe_earn = LEAST(l_comb_pensionable_earnings_ptd, l_YMPE_Period)
            l_pen_comb_tot_under_ympe = l_pen_comb_tot_under_ympe_earn * l_under_YMPE_Rate/100
            l_pen_comb_under_ympe = GREATEST(l_pen_comb_tot_under_ympe - l_pen_comb_tot_under_ympe_ptd, 0)
            
			
            l_pen_comb_tot_over_ympe = GREATEST(l_comb_pensionable_earnings_ptd - l_pen_comb_tot_under_ympe_earn, 0)*l_over_YMPE_Rate/100
            l_pen_comb_over_ympe = GREATEST(l_pen_comb_tot_over_ympe - l_pen_comb_tot_over_ympe_ptd, 0)    
)

l_pen_ee_under_ympe              = l_pen_comb_under_ympe * (l_ee_proportion+l_unpaid_proportion)               /*(l_ee_proportion+l_unpaid_proportion)*/
l_pen_ee_over_ympe               = l_pen_comb_over_ympe * (l_ee_proportion+l_unpaid_proportion)   /* (l_ee_proportion+l_unpaid_proportion)*/
l_pen_ee_er_under_ympe           = l_pen_comb_under_ympe * l_ee_er_proportion
l_pen_ee_er_over_ympe            = l_pen_comb_over_ympe * l_ee_er_proportion

l_over_YMPE  = l_pen_ee_over_ympe
l_under_YMPE = l_pen_ee_under_ympe

l_under_YMPE_LTD_EE_ER = l_pen_ee_er_under_ympe
l_over_YMPE_LTD_EE_ER  = l_pen_ee_er_over_ympe

 /*Limit Check for l_under_YMPE EE */

   IF ((l_LAPP_EE_REL_YTD+l_LAPP_EE_by_ER_REL_YTD)<= l_EE_pension_limit_Year)
   THEN
     (
  	            
	  l_under_YMPE = GREATEST((LEAST(l_under_YMPE,((l_EE_pension_limit_Year)-(l_LAPP_EE_REL_YTD+l_LAPP_EE_by_ER_REL_YTD)))),0)
  	           
  	  )
  	        
    ELSE
     (
        l_under_YMPE=0
  	            
  	 )
  
   /*Limit Check for l_over_YMPE EE */
   
   IF ((l_under_YMPE+l_LAPP_EE_REL_YTD+l_LAPP_EE_by_ER_REL_YTD)<= l_EE_pension_limit_Year)
   THEN
     (
  	            
	  l_over_YMPE = GREATEST((LEAST(l_over_YMPE,((l_EE_pension_limit_Year)-(l_under_YMPE+l_LAPP_EE_REL_YTD+l_LAPP_EE_by_ER_REL_YTD)))),0)
  	           
  	  )
  	        
    ELSE
     (
        l_over_YMPE=0
  	            
  	 )
   


/*Limit Check for l_under_YMPE_LTD_EE_ER */

   IF ((l_LAPP_EE_REL_YTD+l_LAPP_EE_by_ER_REL_YTD+l_under_YMPE+l_over_YMPE)<= l_EE_pension_limit_Year)
   THEN
     (
  	            
	  l_under_YMPE_LTD_EE_ER = GREATEST((LEAST(l_under_YMPE_LTD_EE_ER,((l_EE_pension_limit_Year)-((l_LAPP_EE_REL_YTD+l_LAPP_EE_by_ER_REL_YTD+l_under_YMPE+l_over_YMPE))))),0)
  	           
  	  )
  	        
    ELSE
     (
        l_under_YMPE_LTD_EE_ER=0
  	            
  	 ) 
	 
  
   /*Limit Check for l_over_YMPE_LTD_EE_ER */
   
   IF ((l_under_YMPE_LTD_EE_ER+l_LAPP_EE_REL_YTD+l_LAPP_EE_by_ER_REL_YTD+l_under_YMPE+l_over_YMPE)<= l_EE_pension_limit_Year)
   THEN
     (
  	            
	  l_over_YMPE_LTD_EE_ER = GREATEST((LEAST(l_over_YMPE_LTD_EE_ER,((l_EE_pension_limit_Year)-(l_under_YMPE_LTD_EE_ER+l_LAPP_EE_REL_YTD+l_LAPP_EE_by_ER_REL_YTD+l_under_YMPE+l_over_YMPE)))),0)
  	           
  	  )
  	        
    ELSE
     (
        l_over_YMPE_LTD_EE_ER=0
  	            
  	 )
   



l_pension_EE = l_under_ympe+ l_over_ympe
l_pension_LTD_EE_ER = l_under_YMPE_LTD_EE_ER + l_over_YMPE_LTD_EE_ER


/* Employer*/
l_er_pensionable_earnings_ptd = l_comb_pensionable_earnings_ptd 

IF l_er_pensionable_earnings_ptd <= l_YMPE_Period
then
(
            l_pen_er_tot_under_ympe = l_er_pensionable_earnings_ptd * l_under_ympe_er_rate/100
            l_pen_er_under_ympe = GREATEST(l_pen_er_tot_under_ympe - l_under_YMPE_PTD_ER, 0)
)
ELSE
(           l_pen_comb_tot_under_ympe_earn = LEAST(l_comb_pensionable_earnings_ptd, l_YMPE_Period)
            l_pen_er_tot_under_ympe = l_pen_comb_tot_under_ympe_earn * l_under_ympe_er_rate/100
            l_pen_er_under_ympe = GREATEST(l_pen_er_tot_under_ympe - l_under_YMPE_PTD_ER, 0)
            
            l_pen_er_tot_over_ympe = GREATEST(l_er_pensionable_earnings_ptd - l_pen_comb_tot_under_ympe_earn, 0) * l_over_ympe_er_rate/100
            l_pen_er_over_ympe = GREATEST(l_pen_er_tot_over_ympe - l_over_YMPE_PTD_ER, 0)    
            
)

l_under_YMPE_ER = l_pen_er_under_ympe
l_over_YMPE_ER  = l_pen_er_over_ympe

/*Limit Check for l_under_YMPE ER */

   IF ((l_LAPP_ER_REL_YTD)<= l_ER_pension_limit_Year)
   THEN
     (
  	            
	  l_under_YMPE_ER = GREATEST((LEAST(l_under_YMPE_ER,((l_ER_pension_limit_Year)-(l_LAPP_ER_REL_YTD)))),0)
  	           
  	  )
  	        
    ELSE
     (
        l_under_YMPE_ER=0
  	            
  	 ) 
  
   /*Limit Check for l_over_YMPE ER */
   
   IF ((l_under_YMPE_ER+l_LAPP_ER_REL_YTD)<= l_ER_pension_limit_Year)
   THEN
     (
  	            
	  l_over_YMPE_ER = GREATEST((LEAST(l_over_YMPE_ER,((l_ER_pension_limit_Year)-(l_under_YMPE_ER+l_LAPP_ER_REL_YTD)))),0)
  	           
  	  )
  	        
    ELSE
     (
        l_over_YMPE_ER=0
  	            
  	 )
  
l_pension_ER = l_under_ympe_er+l_over_ympe_er

l_MIN_PERIODIC_PENSIONABLE_EARNINGS = GREATEST(l_comb_pensionable_earnings_ptd /* + l_SC_UNPAID_ABSENCE_EARNINGS_PTD */ /* Commented on 30May2022 */
												- l_PERIODIC_PENSIONABLE_EARNINGS_PTD - l_LAPP_LTD_PTD /*- l_SC_UNPAID_ABSENCE_EARNINGS_PTD*/ /* Commented on 30May2022 */
												+ l_PERIODIC_PENSIONABLE_EARNINGS_RUN + l_LAPP_LTD_RUN /*+ l_SC_UNPAID_ABSENCE_EARNINGS_RUN*/ /* Commented on 30May2022 */
											   , 0) /* Modified by Arun */

IF l_sec_asg_count =1
THEN
(
	l_MIN_PERIODIC_PENSIONABLE_EARNINGS=l_PERIODIC_PENSIONABLE_EARNINGS_PTD+l_LAPP_LTD_PTD
)	
                                                                            

/*l_MIN_PERIODIC_PENSIONABLE_EARNINGS = l_MIN_PERIODIC_PENSIONABLE_EARNINGS - l_cal_pensionable_earnings_PTD*/

	  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_35_years_flag: '||to_char(l_35_years_flag))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_override_flag: '||l_override_flag)
/* Checking for l_35_years_flag is set to 1*/
IF (l_35_years_flag=1 AND l_override_flag = 'N')
THEN
(
  l_under_ympe             = 0
  l_over_ympe              = 0
  l_under_ympe_er          = 0
  l_over_ympe_er           = 0
  l_under_YMPE_LTD_EE_ER   = 0
  l_over_YMPE_LTD_EE_ER    = 0   
  
  l_pension_EE             = 0
  l_pension_ER             = 0
  l_pension_LTD_EE_ER      = 0
 

)

	
/* V1.0 End */

  IF (l_debug_flag='Y')
  THEN  
  (
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pension_limit_Year: '||to_char(l_pension_limit_Year))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  L_PAY_PERIODS_PER_YEAR: '||to_char(L_PAY_PERIODS_PER_YEAR))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_Pay_Check_Limit_period: '||to_char(l_Pay_Check_Limit_period))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_MIN_PERIODIC_PENSIONABLE_EARNINGS: '||to_char(l_MIN_PERIODIC_PENSIONABLE_EARNINGS))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_YMPE_Period: '||to_char(l_YMPE_Period))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_under_YMPE_Rate: '||to_char(l_under_YMPE_Rate))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_under_YMPE: '||to_char(l_under_YMPE))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_Overage_YMPE: '||to_char(l_Overage_YMPE))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_over_YMPE_Rate: '||to_char(l_over_YMPE_Rate))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_over_YMPE: '||to_char(l_over_YMPE))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pension_EE: '||to_char(l_pension_EE))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_overage_YMPE_LTD: '||to_char(l_overage_YMPE_LTD))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_over_YMPE_LTD_EE_ER: '||to_char(l_over_YMPE_LTD_EE_ER))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_under_YMPE_LTD_EE_ER: '||to_char(l_under_YMPE_LTD_EE_ER))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pension_LTD_EE_ER: '||to_char(l_pension_LTD_EE_ER))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_under_YMPE_ER_Rate: '||to_char(l_under_YMPE_ER_Rate))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_under_YMPE_ER: '||to_char(l_under_YMPE_ER))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_Overage_YMPE_ER: '||to_char(l_Overage_YMPE_ER))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_over_YMPE_ER_Rate: '||to_char(l_over_YMPE_ER_Rate))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_under_YMPE_PTD_EE_ER: '||to_char(l_under_YMPE_PTD_EE_ER))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_over_YMPE_PTD_EE_ER: '||to_char(l_over_YMPE_PTD_EE_ER))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_total_under_YMPE_LTD_EE_ER: '||to_char(l_total_under_YMPE_LTD_EE_ER))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_LAPP_EE_ER_REL_PTD: '||to_char(l_LAPP_EE_ER_REL_PTD))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_over_YMPE_Rate: '||to_char(l_over_YMPE_Rate))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_over_YMPE_ER: '||to_char(l_over_YMPE_ER))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pension_ER: '||to_char(l_pension_ER))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_over_YMPE'||to_char(l_over_YMPE))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_partial_PE'||to_char(l_partial_PE))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_partial_LTD'||to_char(l_partial_LTD))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_PERIODIC_PENSIONABLE_EARNINGS_PTD: '||to_char(l_PERIODIC_PENSIONABLE_EARNINGS_PTD))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_PERIODIC_PENSIONABLE_EARNINGS_RUN: '||to_char(l_PERIODIC_PENSIONABLE_EARNINGS_RUN))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  PENSION_SERVICE: '||to_char(PENSION_SERVICE)) 
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_LAPP_LTD_PTD: '||to_char(l_LAPP_LTD_PTD))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_LAPP_LTD_RUN: '||to_char(l_LAPP_LTD_RUN))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_LAPP_EE_ASG_RUN: '||to_char(l_LAPP_EE_ASG_RUN))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_LAPP_EE_REL_RUN: '||to_char(l_LAPP_EE_REL_RUN))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_calc_breakdown_id: '||to_char(l_calc_breakdown_id))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_PAYROLL_REL_ACTION_ID: '||to_char(l_PAYROLL_REL_ACTION_ID))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_tru_id: '||to_char(l_tru_id))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_payroll_rel_id: '||to_char(l_payroll_rel_id))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_next_pay_start_date: '||(l_next_pay_start_date))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_prev_pay_start_date: '||(l_prev_pay_start_date))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_current_pay_start_date: '||(l_current_pay_start_date))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_effective_date: '||to_char(l_effective_date))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  PAY_EARN_PERIOD_START: '||to_char(PAY_EARN_PERIOD_START))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_EE_pension_limit_Year: '||to_char(l_EE_pension_limit_Year))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_ER_pension_limit_Year: '||to_char(l_ER_pension_limit_Year))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_LAPP_EE_ASG_YTD: '||to_char(l_LAPP_EE_ASG_YTD))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_LAPP_ER_ASG_YTD: '||to_char(l_LAPP_ER_ASG_YTD))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_LAPP_EE_REL_YTD: '||to_char(l_LAPP_EE_REL_YTD))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_LAPP_ER_REL_YTD: '||to_char(l_LAPP_ER_REL_YTD))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_LAPP_EE_REL_PTD: '||to_char(l_LAPP_EE_REL_PTD))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_LAPP_ER_REL_PTD: '||to_char(l_LAPP_ER_REL_PTD))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_SC_UNPAID_ABSENCE_HOURS: '||to_char(l_SC_UNPAID_ABSENCE_HOURS))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_total_under_YMPE: '||to_char(l_total_under_YMPE))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_total_over_YMPE: '||to_char(l_total_over_YMPE))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_under_YMPE_PTD_EE: '||to_char(l_under_YMPE_PTD_EE))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_over_YMPE_PTD_EE: '||to_char(l_over_YMPE_PTD_EE))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_under_YMPE_PTD_ER: '||to_char(l_under_YMPE_PTD_ER))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_over_YMPE_PTD_ER: '||to_char(l_over_YMPE_PTD_ER))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_total_under_YMPE_ER: '||to_char(l_total_under_YMPE_ER))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_total_over_YMPE_ER: '||to_char(l_total_over_YMPE_ER))
    l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_SC_UNPAID_ABSENCE_EARNINGS_RUN: '||to_char(l_SC_UNPAID_ABSENCE_EARNINGS_RUN))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_unpaid_proportion1: '||to_char(l_unpaid_proportion1))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_unpaid_proportion: '||to_char(l_unpaid_proportion))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pen_service_ptd: '||to_char(l_pen_service_ptd))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_comb_pensionable_earnings_ptd: '||to_char(l_comb_pensionable_earnings_ptd))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pen_comb_tot_under_ympe_ptd : '||to_char(l_pen_comb_tot_under_ympe_ptd))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pen_comb_tot_over_ympe_ptd: '||to_char(l_pen_comb_tot_over_ympe_ptd))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_ee_proportion :'||to_char(l_ee_proportion))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_ee_er_proportion: '||to_char(l_ee_er_proportion))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pen_comb_tot_under_ympe: '||to_char(l_pen_comb_tot_under_ympe))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pen_comb_under_ympe : '||to_char(l_pen_comb_under_ympe))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pen_comb_tot_over_ympe: '||to_char(l_pen_comb_tot_over_ympe))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pen_comb_over_ympe: '||to_char(l_pen_comb_over_ympe))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pen_ee_under_ympe : '||to_char(l_pen_ee_under_ympe))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pen_ee_over_ympe   : '||to_char(l_pen_ee_over_ympe))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pen_ee_er_under_ympe : '||to_char(l_pen_ee_er_under_ympe))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pen_er_tot_under_ympe  : '||to_char(l_pen_er_tot_under_ympe))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pen_er_under_ympe  : '||to_char(l_pen_er_under_ympe))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pen_ee_er_over_ympe  : '||to_char(l_pen_ee_er_over_ympe))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pen_er_tot_over_ympe  : '||to_char(l_pen_er_tot_over_ympe))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pen_er_over_ympe  : '||to_char(l_pen_er_over_ympe))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_pen_comb_tot_under_ympe_earn  : '||to_char(l_pen_comb_tot_under_ympe_earn))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_SC_LAPP_PENSIONABLE_HOURS_PTD  : '||to_char(l_SC_LAPP_PENSIONABLE_HOURS_PTD))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_run_value: '||to_char(l_run_value))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_calculated_pensionable_earnings: '||to_char(l_calculated_pensionable_earnings))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_lapp_pension_override_pensioner_flag: '||to_char(l_lapp_pension_override_pensioner_flag))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_lapp_pension_override_pension_eligibility              : '||to_char(l_lapp_pension_override_pension_eligibility              ))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_lapp_pension_override_thirty_five_years_flag           : '||to_char(l_lapp_pension_override_thirty_five_years_flag           ))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_lapp_pension_override_override_lapp_EE_OVER_YMPE       : '||to_char(l_lapp_pension_override_override_lapp_EE_OVER_YMPE       ))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_lapp_pension_override_override_lapp_EE_UNDER_YMPE      : '||to_char(l_lapp_pension_override_override_lapp_EE_UNDER_YMPE      ))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_lapp_pension_override_override_lapp_EE                 : '||to_char(l_lapp_pension_override_override_lapp_EE                 ))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_lapp_pension_override_override_lapp_EE_by_ER_OVER_YMPE : '||to_char(l_lapp_pension_override_override_lapp_EE_by_ER_OVER_YMPE ))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_lapp_pension_override_override_lapp_EE_by_ER_UNDER_YMPE: '||to_char(l_lapp_pension_override_override_lapp_EE_by_ER_UNDER_YMPE))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_lapp_pension_override_override_lapp_service            : '||to_char(l_lapp_pension_override_override_lapp_service            ))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_lapp_pension_override_override_lapp_EE_by_ER           : '||to_char(l_lapp_pension_override_override_lapp_EE_by_ER           ))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_lapp_pension_override_override_lapp_ER_OVER_YMPE       : '||to_char(l_lapp_pension_override_override_lapp_ER_OVER_YMPE       ))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_lapp_pension_override_override_lapp_ER_UNDER_YMPE      : '||to_char(l_lapp_pension_override_override_lapp_ER_UNDER_YMPE      ))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_lapp_pension_override_override_lapp_ER                 : '||to_char(l_lapp_pension_override_override_lapp_ER                 ))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_lapp_pension_override_override_pensionable_earnings    : '||to_char(l_lapp_pension_override_override_pensionable_earnings    ))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  l_lapp_pension_override_override_date_earned             : '||to_char(l_lapp_pension_override_override_date_earned             ))
  )
)  
  
)  
 i = i + 1 
	)  

 ) 
 ) 
  
   
)
  CALL_FORMULA(
    'GLB_DEDN_DUMMY_GUARANTEED_NET',
    Guaranteed_Net < 'Guaranteed_Net' DEFAULT 0
  )

  dummy = ESS_LOG_WRITE(Formula_Name||' Guaranteed_Net = '||TO_CHAR(Guaranteed_Net))  

  CALL_FORMULA(
      'GLB_DEDN_PSTAT_CALC',
      Gross_Earnings > 'Gross_Earnings',
      Gross_Earnings_nocb > 'Gross_Earnings_NOCB',
      Net_Earnings > 'Net_Earnings',
      Net_Earnings_nocb > 'Net_Earnings_NOCB',
      Gross_Pay > 'Gross_Pay',
      Gross_Pay_nocb > 'Gross_Pay_nocb',
      l_pension_EE > 'Eligible_Compensation',
      l_pension_EE > 'Eligible_Compensation_NOCB', 
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
  
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  Dedn_Amt: '||to_char(Dedn_Amt))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  To_Total_Owed: '||to_char(To_Total_Owed))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  To_Arrears: '||to_char(To_Arrears))
  l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  Not_Taken: '||to_char(Not_Taken))


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
          l_log = ESS_LOG_WRITE(Formula_Name|| '  - Array found for PRETAX_PAY_VALUE')
          wsa_pretax_pay_value = WSA_GET('PRETAX_PAY_VALUE',EMPTY_NUMBER_NUMBER)
    IF wsa_pretax_pay_value.EXISTS(ee_context_id) THEN
          ( l_pretax_value = wsa_pretax_pay_value[ee_context_id] 
    l_log = ESS_LOG_WRITE(Formula_Name|| '  -exsits PRETAX_PAY_VALUE=' || to_char(l_pretax_value))
       if (ENTRY_LEVEL='PR' and Gross_Pay <> Gross_Pay_nocb ) then (

    l_pretax_value = dedn_amt + l_pretax_value
    l_log = ESS_LOG_WRITE(Formula_Name|| '  -summary PRETAX_PAY_VALUE' || to_char(l_pretax_value))

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
  l_log = ESS_LOG_WRITE(Formula_Name|| '  - dedn amount=' || to_char(l_pretax_value))  
        WSA_SET('PRETAX_PAY_VALUE',wsa_pretax_pay_value)

        l_tru_id =GET_CONTEXT(TAX_UNIT_ID,0)
  PRETAX_TRU_KEY='PRETAX_TRU_KEY'||'_'||to_char(ee_context_id)
  WSA_SET(PRETAX_TRU_KEY,l_tru_id)
  l_cb_id =GET_CONTEXT(CALC_BREAKDOWN_ID,0)
  PRETAX_CB_KEY='PRETAX_CB_KEY'||'_'||to_char(ee_context_id)
  WSA_SET(PRETAX_CB_KEY,l_cb_id)

        IF (WSA_EXISTS('PRETAX_STOP_ENTRY','TEXT_NUMBER')) THEN
        (
          l_log = ESS_LOG_WRITE(Formula_Name|| ' - Array found for PRETAX_STOP_ENTRY')
          wsa_pretax_stop_entry = WSA_GET('PRETAX_STOP_ENTRY',EMPTY_TEXT_NUMBER)
        )    
        wsa_pretax_stop_entry[ee_context_id] = stop_entry
        WSA_SET('PRETAX_STOP_ENTRY',wsa_pretax_stop_entry)


         /* For PreTax Iteration End */

	l_log = ESS_LOG_WRITE('LAPP_EE_PRESTAT_DEDN_CALCULATOR -  Dedn_Amt: '||to_char(Dedn_Amt))
	
	l_pension_EE = dedn_amt
  /* ------------------------------------------------------------------------
  ** We need to check if Stop_Entry IS populated, AS regardless of what value 
  ** it holds, processing will stop if its returned
  ** ------------------------------------------------------------------------
  */
IF L_MIN_PERIODIC_PENSIONABLE_EARNINGS=0
	THEN
	(
	   
		l_SC_LAPP_PENSIONABLE_HOURS_PTD=0	
        PENSION_SERVICE=0 
        l_NON_ELIGIBLE_PENSION_EARN=0
        l_NON_ELIGIBLE_PENSION_HOURS=0		
	 )
    ELSE
     ( l_SC_LAPP_PENSIONABLE_HOURS_PTD=l_SC_LAPP_PENSIONABLE_HOURS_PTD
	   PENSION_SERVICE=PENSION_SERVICE
	   l_NON_ELIGIBLE_PENSION_EARN=l_wsa_number
	   l_NON_ELIGIBLE_PENSION_HOURS=l_wsa_pension_hrs
     
     )	   

IF l_sec_asg_count=1
THEN
(
   l_NON_ELIGIBLE_PENSION_EARN=0
   l_NON_ELIGIBLE_PENSION_HOURS=0

)
  IF Stop_Entry = 'Y' THEN 
  (
    Mesg = GET_MESG('PAY','PAY_TOTAL_OWED_REACHED', 'ELE_NAME', element_name)
    RETURN Dedn_Amt, Stop_Entry, To_Total_Owed, Mesg, To_Arrears, Not_Taken,l_pension_EE,l_over_YMPE,l_under_YMPE,l_MIN_PERIODIC_PENSIONABLE_EARNINGS,
           PENSION_SERVICE,l_under_YMPE_ER,l_over_YMPE_ER,l_pension_ER,l_under_YMPE_LTD_EE_ER,l_over_YMPE_LTD_EE_ER,l_Pension_LTD_EE_ER,l_SC_LAPP_PENSIONABLE_HOURS_PTD,l_NON_ELIGIBLE_PENSION_EARN,l_NON_ELIGIBLE_PENSION_HOURS
  )
  ELSE
  (
    IF (Mesg <> 'ZZZ') THEN 
	RETURN Dedn_Amt, To_Total_Owed, To_Arrears, Not_Taken, Mesg,l_pension_EE,l_over_YMPE,l_under_YMPE,l_MIN_PERIODIC_PENSIONABLE_EARNINGS,
	       PENSION_SERVICE,l_under_YMPE_ER,l_over_YMPE_ER,l_pension_ER,l_under_YMPE_LTD_EE_ER,l_over_YMPE_LTD_EE_ER,l_Pension_LTD_EE_ER,l_SC_LAPP_PENSIONABLE_HOURS_PTD,l_NON_ELIGIBLE_PENSION_EARN,l_NON_ELIGIBLE_PENSION_HOURS
                         	
    ELSE RETURN Dedn_Amt, To_Total_Owed, To_Arrears, Not_Taken,l_pension_EE,l_over_YMPE,l_under_YMPE,l_MIN_PERIODIC_PENSIONABLE_EARNINGS,
                PENSION_SERVICE,l_under_YMPE_ER,l_over_YMPE_ER,l_pension_ER,l_under_YMPE_LTD_EE_ER,l_over_YMPE_LTD_EE_ER,l_Pension_LTD_EE_ER,l_SC_LAPP_PENSIONABLE_HOURS_PTD,l_NON_ELIGIBLE_PENSION_EARN,l_NON_ELIGIBLE_PENSION_HOURS
  )  