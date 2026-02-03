 
/*
+======================================================================+
|                Copyright (c) 2012 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+
Version  Author      Date        Description
-------  ----------  ----------- ----------------------------------------------------
0.1      pbussa       28-AUG-2015 Created.
--------------------------------------------------------------------------------------*/
/**************************************************************************************
* $Header:                                                                            *
* Formula Name : _CHG_DEDN_CA_CALCULATOR                                              *
* Description  : To determine Canada province                                         *
*           
Change History:
Version	  Name          Date          Change id#  Description
-----------------------------------------------------------------------------------------------------------------------------------------------------
1.0       Arun        16-Nov-2023		NA		 Added logic to remove ER retro from Pay value
					                                                                            *
***************************************************************************************/

DEFAULT FOR pay_value  IS 0
DEFAULT FOR APEX_ER_CONT_RETRO_ASG_RUN IS 0
DEFAULT FOR APEX_ER_CONT_RETRO_TRM_RUN IS 0
DEFAULT FOR APEX_ER_CONT_RETRO_REL_RUN IS 0

/*Customization Start */
DEFAULT FOR APEX_UNDER_YMPE IS 0
DEFAULT FOR APEX_OVER_YMPE IS 0
/*Customization End */

INPUTS ARE pay_value (NUMBER),
/*Customization Start */		   
		   APEX_UNDER_YMPE (NUMBER),
		   APEX_OVER_YMPE (NUMBER)	   
/*Customization End */

/* local variables */
DEDN_AMT      = pay_value
Formula_Name = '[APEX_ER_CONT_CANADIAN_CALCULATOR]'
retro_er_Run = 0 
retro_er_Run = APEX_ER_CONT_RETRO_REL_RUN

DEDN_AMT      = pay_value - retro_er_Run
l_log = PAY_INTERNAL_LOG_WRITE('Formula _CHG_DEDN_CA_CALCULATOR : Executing Canadian Employer Charges Calculator')

   dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' retro_rel_run = '||TO_CHAR(APEX_ER_CONT_RETRO_REL_RUN))
 dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name||' retro_run = '||TO_CHAR(retro_er_run))
/* Display errors if contexts are not set by Payroll engine */
l_tax_unit_id      = GET_CONTEXT(TAX_UNIT_ID, 0)
l_element_entry_id      = GET_CONTEXT(ELEMENT_ENTRY_ID, 0)

IF (l_tax_unit_id = 0) THEN
(
   /* Display error when there is no TRU */
   l_dummy = PAY_LOG_ERROR('HRX:HRX_CACMN_CONTEXT_NOT_SET','CONTEXT=TAX_UNIT_ID')
)

IF (l_element_entry_id = 0) THEN
(
   /* Display error when there is no Element Entry Id */
   l_dummy = PAY_LOG_ERROR('HRX:HRX_CACMN_CONTEXT_NOT_SET','CONTEXT=ELEMENT_ENTRY_ID')
)

/* Get Province of Employment */
CALL_FORMULA('CA_GET_PROVINCE',
             l_tax_unit_id > 'p_tax_unit_id',
             PROVINCE      < 'PROVINCE' DEFAULT 0)
			 
/* Call CA_GET_EE_ENTRY_VALUE Formula to get the sales tax applicable flags */  
CALL_FORMULA('CA_GET_EE_ENTRY_VALUE',
                'GST'    > 'p_base_input_value_name',
                l_element_entry_id  > 'p_element_entry_id',
                GST_APPLICABLE      < 'OUTPUT_ENTRY_VALUE' DEFAULT 'N')      

CALL_FORMULA('CA_GET_EE_ENTRY_VALUE',
                'PST'    > 'p_base_input_value_name',
                l_element_entry_id  > 'p_element_entry_id',
                PST_APPLICABLE      < 'OUTPUT_ENTRY_VALUE' DEFAULT 'N')

CALL_FORMULA('CA_GET_EE_ENTRY_VALUE',
                'RST'    > 'p_base_input_value_name',
                l_element_entry_id  > 'p_element_entry_id',
                RST_APPLICABLE      < 'OUTPUT_ENTRY_VALUE' DEFAULT 'N')

CALL_FORMULA('CA_GET_EE_ENTRY_VALUE',
                'HST'    > 'p_base_input_value_name',
                l_element_entry_id  > 'p_element_entry_id',
                HST_APPLICABLE      < 'OUTPUT_ENTRY_VALUE' DEFAULT 'N')

CALL_FORMULA('CA_GET_EE_ENTRY_VALUE',
                'PPT'    > 'p_base_input_value_name',
                l_element_entry_id  > 'p_element_entry_id',
                PPT_APPLICABLE      < 'OUTPUT_ENTRY_VALUE' DEFAULT 'N')

CALL_FORMULA('CA_GET_EE_ENTRY_VALUE',
                'Report Sales Tax Separately'    > 'p_base_input_value_name',
                l_element_entry_id               > 'p_element_entry_id',
                REPORT_SALES_TAX_SEPARATELY      < 'OUTPUT_ENTRY_VALUE' DEFAULT 'Y')
				
/* Get the Registration Number input Values from the base element */

CALL_FORMULA('CA_GET_EE_ENTRY_VALUE',
				'Registration Number'   > 'p_base_input_value_name',
				l_element_entry_id      > 'p_element_entry_id',
				RETIREMENT_PLAN_NUMBER  < 'OUTPUT_ENTRY_VALUE' DEFAULT 'UNDEFINED')
	
l_dummy = PAY_INTERNAL_LOG_WRITE('Formula _CHG_DEDN_CA_CALCULATOR : RETIREMENT_PLAN_NUMBER'||RETIREMENT_PLAN_NUMBER)

RETURN
   PROVINCE,
   DEDN_AMT,
   GST_APPLICABLE,
   PST_APPLICABLE,
   HST_APPLICABLE,
   RST_APPLICABLE,
/*Customization Start */   
   APEX_Under_YMPE,
   APEX_Over_YMPE,
/*Customization End */  
   PPT_APPLICABLE,
   REPORT_SALES_TAX_SEPARATELY,
   RETIREMENT_PLAN_NUMBER