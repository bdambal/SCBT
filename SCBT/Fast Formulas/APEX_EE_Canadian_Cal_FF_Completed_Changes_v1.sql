/*
+======================================================================+
|                Copyright (c) 2012 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

Version  Author      Date        Description
-------  ----------  ----------- ----------------------------------------------------
0.1      atran       19-Nov-2012 Created.
0.2      bseberge    07-Dec-2012 Registration Number
0.3      bseberge    20-Feb-2013 Change Province error message, add reporting type dbi
0.4      bseberge    05-Mar-2013 If reporting type is NONE, replace with processed reporting
                                 type else replace it with T4_RL1 see bug 16418600
0.5      bseberge    21-Jun-2103 Modularize code
0.6      shankakk    18-Jan-2019 Added code for RRSP calculation
0.7      gkpuppal    04-APR-2020 31105528 added wsa variable to store secondary classification
0.7      gkpuppal    06-MAY-2021 32729681 added logic to support no periodic earning
0.8      gkpuppal    05-JUL-2021 33062598 - NON PERIODIC EARNINGS FIX FOR MULTIPLE PRETAX ELEMENTS
0.9      gkpuppal    26-Aug-2021 33215210 - Returning flags to Result element
--------------------------------------------------------------------------------------*/

/**************************************************************************************
* $Header:                                                                            *
* Formula Name : _PRETAX_DEDN_CA_CALCULATOR                                           *
* Description  : To determine Canada reporting type, province and                     *
*                registration number                                                  *
*                                                                                     *
***************************************************************************************/

ALIAS APEX_SUP_PENSION_EE_ELIGIBLE_COMP_REL_NOCB_RUN AS Eligible_Compensation_NOCB

DEFAULT FOR Eligible_Compensation_NOCB IS 0
DEFAULT FOR HRX_CA_RRSP_LIMIT_OVERRIDE IS -1
DEFAULT FOR pay_value  IS 0
DEFAULT FOR accrued    IS 0
DEFAULT FOR arrear     IS 0
DEFAULT FOR not_taken  IS 0
DEFAULT FOR APEX_SUP_PENSION_EE_SECONDARY_CLASSIFICATION IS 'NA'
DEFAULT FOR SUPPLEMENTAL_EARNINGS_REL_TU_RUN IS 0
DEFAULT FOR  wsa_non_periodic_amount_deducted IS EMPTY_NUMBER_TEXT

/*Customization Start */
DEFAULT FOR pension_service  IS 0
DEFAULT FOR pensionable_earnings  IS 0
DEFAULT FOR pensionable_hours  IS 0
DEFAULT FOR FUTURE_M1 IS 0
DEFAULT FOR FUTURE_M2 IS 0

/*Customization End */

INPUTS ARE pay_value (NUMBER),
           accrued   (NUMBER),
           arrear    (NUMBER),
           not_taken (NUMBER),
/*Customization Start */		   
		   pension_service (NUMBER),
		   pensionable_earnings (NUMBER),
		   pensionable_hours (NUMBER),
		   FUTURE_M1 (NUMBER),
		   FUTURE_M2 (NUMBER)
		   
/*Customization End */		   

Formula_Name = '[APEX_SUP_PENSION_EE_PRETAX_DEDN_CA_CALCULATOR]'
l_enforce_rrsp_limit_flag     = 'N'
l_rrsp_er_match_flag          = 'N'
l_rrsp_limit_amt              =  0
PRETAX_APPLY_TO_NONPERIODIC    = 'N'
CLEAR_ARREARS = 'N'
PARTIAL_FLAG='N'
l_non_periodic_earnings = 0
ITER_METHOD = 'UNDEFINED'
ITER_FLAG = 'N'
l_non_periodic_earnings_before_adj = 0
l_not_taken_till_now = 0		

l_log = PAY_INTERNAL_LOG_WRITE('Executing formula '|| Formula_Name)

/* Display errors if contexts are not set by Payroll engine */
l_tax_unit_id      = GET_CONTEXT(TAX_UNIT_ID, 0)
l_element_entry_id = GET_CONTEXT(ELEMENT_ENTRY_ID, 0)
l_pay_rel_id = GET_CONTEXT(PAYROLL_REL_ACTION_ID, 0)

/* 31105528 getting element secondary classification */
wsa_element_sec_classification = WSA_GET('ELEMENT_SECONDARY_CLASSFICATION',EMPTY_TEXT_NUMBER)
IF (wsa_element_sec_classification.EXISTS(l_element_entry_id) ) THEN
    ( 
         l_log =PAY_INTERNAL_LOG_WRITE('(CA_ITER)element_sec_classification '||to_char(l_element_entry_id)||' ' ||wsa_element_sec_classification[l_element_entry_id]) 
 )
 ELSE
 (
   wsa_element_sec_classification[l_element_entry_id]  =  APEX_SUP_PENSION_EE_SECONDARY_CLASSIFICATION
   l_log =PAY_INTERNAL_LOG_WRITE('(CA_ITER)element_sec_classification '||to_char(l_element_entry_id)||' ' ||wsa_element_sec_classification[l_element_entry_id]) 
   WSA_SET('ELEMENT_SECONDARY_CLASSFICATION',wsa_element_sec_classification) 
 )


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

/* Get Reporting Type */

CALL_FORMULA('CA_GET_REPORTING_TYPE',
             l_tax_unit_id  > 'p_tax_unit_id',
             REPORTING_TYPE < 'REPORTING_TYPE' DEFAULT 'T4_RL1')

/* Get Canadian Deduction Information */

CALL_FORMULA('CA_DEDN_CALCULATION',
             l_element_entry_id     > 'p_element_entry_id',
             pay_value              > 'p_pay_value',
             accrued                > 'p_accrued',
             arrear                 > 'p_arrear',
             not_taken              > 'p_not_taken',
             RETIREMENT_PLAN_NUMBER < 'RETIREMENT_PLAN_NUMBER' DEFAULT 'UNDEFINED',
             DEDN_AMT               < 'DEDN_AMT'               DEFAULT 0,
             TO_TOTAL_OWED          < 'TO_TOTAL_OWED'          DEFAULT 0,
             TO_ARREARS             < 'TO_ARREARS'             DEFAULT 0,
             NOT_TAKEN              < 'NOT_TAKEN'              DEFAULT 0)


l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||' DEDN_AMT :'||  to_char(DEDN_AMT))
l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||' NOT_TAKEN :'||  to_char(NOT_TAKEN))

/*32729681 added logic to support no periodic earning*/
/*33062598 - NON PERIODIC EARNINGS FIX FOR MULTIPLE PRETAX ELEMENTS*/
CALL_FORMULA('GET_ELEMENT_ENTRY_VALUES',
 'ENTRY_VALUE'               >  'p_mode',
 'Applicable to Non Periodic Earnings'        > 'p_base_input_value_name',
    l_element_entry_id          > 'p_element_entry_id',
 'TEXT'                      > 'P_DATA_TYPE',
    PRETAX_APPLY_TO_NONPERIODIC   < 'OUT_ELE_ENTRY_VALUE' DEFAULT 'N')

 l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||' Applicable to Non Periodic Earnings :'|| PRETAX_APPLY_TO_NONPERIODIC)

CALL_FORMULA('GET_ELEMENT_ENTRY_VALUES',
 'ENTRY_VALUE'               >  'p_mode',
 'Method'        > 'p_base_input_value_name',
    l_element_entry_id          > 'p_element_entry_id',
 'TEXT'                      > 'P_DATA_TYPE',
    ITER_METHOD   < 'OUT_ELE_ENTRY_VALUE' DEFAULT 'UNDEFINED')

    l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||'  -ITER_METHOD '||ITER_METHOD) 

 IF(ITER_METHOD='UNDEFINED') THEN (
      ITER_FLAG = 'N'
      )
 ELSE(
      ITER_FLAG = 'Y'
      )
 l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||'  -ITER_FLAG '||ITER_FLAG) 

 CALL_FORMULA(
    'GLB_DEDN_WSA',
    'GET' > 'WSA_TYPE',
    to_char(l_element_entry_id) > 'EE_ID',
    /*******************************/
    CLEAR_ARREARS < 'Clear_Arrears' DEFAULT 'N',
    PARTIAL_FLAG < 'Partial_Flag' DEFAULT 'N'  )

    l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||' CLEAR_ARREARS :'|| CLEAR_ARREARS)
    l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||' Take_Partial_Deduction :'|| PARTIAL_FLAG)
    l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||' l_pay_rel_id :'|| to_char(l_pay_rel_id))
    l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||' l_tax_unit_id :'|| to_char(l_tax_unit_id))
 l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||' REPORTING_TYPE :'|| REPORTING_TYPE)


IF(PRETAX_APPLY_TO_NONPERIODIC = 'Y' and CLEAR_ARREARS ='N' and ITER_FLAG='N')  THEN 
(

   CHANGE_CONTEXTS(STATUTORY_REPORT_TYPE = REPORTING_TYPE)
   (
      if(SUPPLEMENTAL_EARNINGS_REL_TU_RT_RUN was not defaulted) THEN
       (
         l_non_periodic_earnings_before_adj = SUPPLEMENTAL_EARNINGS_REL_TU_RT_RUN 
                                                - CA_LUMP_SUM_REL_TU_RT_RUN 
                                                - CA_SUPPLEMENTAL_ADJUSTMENT_REL_TU_RT_RUN
       )
   )
 
  /* checking if GLB_PRETAX_NON_PERIODIC_PROCESSED already set or not*/
  IF WSA_EXISTS( 'GLB_PRETAX_NON_PERIODIC_PROCESSED' , 'NUMBER' ) THEN
  (
   /*GLB_PRETAX_NON_PERIODIC_PROCESSED checks employee is already processed or not*/
      l_non_periodic_processed_pay_rel       = WSA_GET('GLB_PRETAX_NON_PERIODIC_PROCESSED',0)  

      /*checking if any employe is processed */
    IF (l_non_periodic_processed_pay_rel = l_pay_rel_id ) THEN
    (
      /*GLB_PRETAX_NON_PERIODIC_DED_AMOUNT stores already processed amount*/ 
        wsa_non_periodic_amount_deducted = WSA_GET('GLB_PRETAX_NON_PERIODIC_DED_AMOUNT',EMPTY_NUMBER_TEXT)   
        wsa_non_periodic_amount_not_taken = WSA_GET('GLB_PRETAX_NON_PERIODIC_NOT_TAKEN',EMPTY_NUMBER_TEXT)   
		
		l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||' wsa_non_periodic_processed exists for payrel '||to_char(l_pay_rel_id)) 
      /*checking if for current employe key exists */
          IF (wsa_non_periodic_amount_deducted.EXISTS(to_char(l_pay_rel_id)||'_'||to_char(l_tax_unit_id)||'_'||REPORTING_TYPE)) THEN
          (

              l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||' wsa_non_periodic_amount_deducted exists with amount '||to_char(    wsa_non_periodic_amount_deducted[to_char(l_pay_rel_id)||'_'||to_char(l_tax_unit_id)||'_'||REPORTING_TYPE]))    
			  
			  l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||' wsa_non_periodic_amount_not_taken exists with not taken '||to_char(    wsa_non_periodic_amount_not_taken[to_char(l_pay_rel_id)||'_'||to_char(l_tax_unit_id)||'_'||REPORTING_TYPE]))   
			  
          )
          ELSE
          (
              /*for current employe if key does not exists adding new key */
              l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||' wsa_non_periodic_amount_deducted exists for payrel with different key,adding new key') 
              wsa_non_periodic_amount_deducted[to_char(l_pay_rel_id)||'_'||to_char(l_tax_unit_id)||'_'||REPORTING_TYPE] = 0
              wsa_non_periodic_amount_not_taken[to_char(l_pay_rel_id)||'_'||to_char(l_tax_unit_id)||'_'||REPORTING_TYPE] = 0
		  )

    )
    ELSE
    (
      /*for current employe key does not exists,deleting wsa variable for previous employee and creating it for current employee */
      l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||' wsa_non_periodic_amount_deducted exists for different payrel, deleting existing one and creating new for current Pay rel:'|| to_char(l_pay_rel_id) )
      WSA_DELETE('GLB_PRETAX_NON_PERIODIC_DED_AMOUNT') 
      WSA_DELETE('GLB_PRETAX_NON_PERIODIC_PROCESSED') 
      WSA_DELETE('GLB_PRETAX_NON_PERIODIC_NOT_TAKEN')
      wsa_non_periodic_amount_deducted = WSA_GET('GLB_PRETAX_NON_PERIODIC_DED_AMOUNT',EMPTY_NUMBER_TEXT)
      wsa_non_periodic_amount_deducted[to_char(l_pay_rel_id)||'_'||to_char(l_tax_unit_id)||'_'||REPORTING_TYPE] = 0
      wsa_non_periodic_amount_not_taken = WSA_GET('GLB_PRETAX_NON_PERIODIC_NOT_TAKEN',EMPTY_NUMBER_TEXT)
      wsa_non_periodic_amount_not_taken[to_char(l_pay_rel_id)||'_'||to_char(l_tax_unit_id)||'_'||REPORTING_TYPE] = 0
	)


   )
   ELSE(
            /*First employee processing,wsa variable GLB_PRETAX_NON_PERIODIC_DED_AMOUNT does not exists, creating new variable*/
   l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||' wsa_non_periodic_amount_deducted does not exists,creating new')   

           wsa_non_periodic_amount_deducted = WSA_GET('GLB_PRETAX_NON_PERIODIC_DED_AMOUNT',EMPTY_NUMBER_TEXT)    
           wsa_non_periodic_amount_deducted[to_char(l_pay_rel_id)||'_'||to_char(l_tax_unit_id)||'_'||REPORTING_TYPE] = 0
		   wsa_non_periodic_amount_not_taken = WSA_GET('GLB_PRETAX_NON_PERIODIC_NOT_TAKEN',EMPTY_NUMBER_TEXT)
           wsa_non_periodic_amount_not_taken[to_char(l_pay_rel_id)||'_'||to_char(l_tax_unit_id)||'_'||REPORTING_TYPE] = 0
   )

   l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||' wsa_non_periodic_amount_deducted till now'||to_char(wsa_non_periodic_amount_deducted[to_char(l_pay_rel_id)||'_'||to_char(l_tax_unit_id)||'_'||REPORTING_TYPE]))   
    l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||' wsa_non_periodic_amount_not_taken till now'||to_char(wsa_non_periodic_amount_not_taken[to_char(l_pay_rel_id)||'_'||to_char(l_tax_unit_id)||'_'||REPORTING_TYPE])) 

    if(l_non_periodic_earnings_before_adj > 0) THEN (
    l_non_periodic_earnings = l_non_periodic_earnings_before_adj
           - wsa_non_periodic_amount_deducted[to_char(l_pay_rel_id)||'_'||to_char(l_tax_unit_id)||'_'||REPORTING_TYPE] 
    )
	else (
	l_non_periodic_earnings = 0
	)
	
	l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| 'l_non_periodic_earnings  '  || to_char(l_non_periodic_earnings) )
    l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name|| 'Take_Partial_Deduction  '  || PARTIAL_FLAG )
 
IF(DEDN_AMT > 0) THEN (
 IF(PARTIAL_FLAG = 'Y') THEN
 (
    /*checking if l_non_periodic_earnings greater than 0  */
   IF(l_non_periodic_earnings > 0) THEN 
   (
            /*if l_non_periodic_earnings greater than 0  and less than DEDN_AMT ,Adjusting the DEDN_AMT value when PARTIAL_FLAG is Y  */   
     IF(DEDN_AMT > l_non_periodic_earnings) THEN
       (
       NOT_TAKEN = NOT_TAKEN + ( DEDN_AMT - l_non_periodic_earnings)
       DEDN_AMT = l_non_periodic_earnings
       )

   )
   ELSE
   (
   /*if l_non_periodic_earnings less than 0  Adjusting the DEDN_AMT to 0 */
      NOT_TAKEN  = NOT_TAKEN +DEDN_AMT
          DEDN_AMT  = 0

      )
 )
 ELSE  
 (
    IF(DEDN_AMT > l_non_periodic_earnings) THEN
    (
          NOT_TAKEN = NOT_TAKEN +DEDN_AMT
          DEDN_AMT  =0
    )
 )
 
)
  ELSE IF(DEDN_AMT < 0) THEN (
  
     IF (l_non_periodic_earnings_before_adj > 0) THEN (
	       l_not_taken_till_now = wsa_non_periodic_amount_not_taken[to_char(l_pay_rel_id)||'_'||to_char(l_tax_unit_id)||'_'||REPORTING_TYPE] 
	       IF(l_not_taken_till_now > 0) THEN (
	          
			  l_non_periodic_earnings = l_non_periodic_earnings - DEDN_AMT
			  
			  IF(l_not_taken_till_now > l_non_periodic_earnings) THEN (
			    		l_not_taken_till_now = l_not_taken_till_now - l_non_periodic_earnings
						DEDN_AMT =  0
						NOT_TAKEN = 0
			    
			  )
			  ELSE(
			        
			        DEDN_AMT = DEDN_AMT + l_not_taken_till_now
					NOT_TAKEN = 0
			  )
		   )
	     
	 )
	 ELSE (
	 
	      DEDN_AMT  = 0
		  NOT_TAKEN = 0
	 )
  
  )
 
  WSA_SET( 'GLB_PRETAX_NON_PERIODIC_PROCESSED' , l_pay_rel_id )
   wsa_non_periodic_amount_deducted[to_char(l_pay_rel_id)||'_'||to_char(l_tax_unit_id)||'_'||REPORTING_TYPE] = wsa_non_periodic_amount_deducted[to_char(l_pay_rel_id)||'_'||to_char(l_tax_unit_id)||'_'||REPORTING_TYPE]  + DEDN_AMT
  /*wsa variables GLB_PRETAX_NON_PERIODIC_PROCESSED,GLB_PRETAX_NON_PERIODIC_DED_AMOUNT set */
  WSA_SET('GLB_PRETAX_NON_PERIODIC_DED_AMOUNT', wsa_non_periodic_amount_deducted) 
  wsa_non_periodic_amount_not_taken[to_char(l_pay_rel_id)||'_'||to_char(l_tax_unit_id)||'_'||REPORTING_TYPE]  = wsa_non_periodic_amount_not_taken[to_char(l_pay_rel_id)||'_'||to_char(l_tax_unit_id)||'_'||REPORTING_TYPE]  + NOT_TAKEN - l_not_taken_till_now
  WSA_SET('GLB_PRETAX_NON_PERIODIC_NOT_TAKEN', wsa_non_periodic_amount_not_taken)  
)

l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||'after logic to support non periodic earning -DEDN_AMT :'||  to_char(DEDN_AMT))
l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||'after logic to support non periodic earning  -NOT_TAKEN :'||  to_char(NOT_TAKEN))

/*END : 32729681 added logic to support no periodic earning*/


/*Get the Enforce RRSP Limit input value from the pretax base element */
CALL_FORMULA('GET_ELEMENT_ENTRY_VALUES',
 'ENTRY_VALUE'               >  'p_mode',
 'Enforce RRSP Limit'        > 'p_base_input_value_name',
    l_element_entry_id          > 'p_element_entry_id',
 'TEXT'                      > 'P_DATA_TYPE',
    l_enforce_rrsp_limit_flag   < 'OUT_ELE_ENTRY_VALUE' DEFAULT 'N')

l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||' Enforce RRSP Limit value :'|| l_enforce_rrsp_limit_flag)
l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||' Pretax deduction Amount  :'|| to_char(DEDN_AMT))

IF(l_enforce_rrsp_limit_flag ='Y')THEN
(
 IF( HRX_CA_RRSP_LIMIT_OVERRIDE WAS NOT DEFAULTED)THEN
 (
  l_rrsp_limit_amt = HRX_CA_RRSP_LIMIT_OVERRIDE
 )
 ELSE(
  CHANGE_CONTEXTS(PART_NAME = 'HRX_CA_RRSP_LIMIT_CP')
  (
   CALL_FORMULA('CA_GET_DIR_VALUE',
    1 > 'P_BASE',
    l_rrsp_limit_amt  < 'L_VALUE' default 0)
  )
 )
 l_dummy = PAY_INTERNAL_LOG_WRITE(Formula_Name || 'RRSP Limit  : '|| TO_CHAR(l_rrsp_limit_amt))
 IF(l_rrsp_limit_amt > 0)THEN
 (
  CALL_FORMULA('GET_ELEMENT_ENTRY_VALUES',
   'ENTRY_VALUE'           >  'p_mode',
   'Employer Match'      > 'p_base_input_value_name',
   l_element_entry_id      > 'p_element_entry_id',
   'TEXT'                  > 'P_DATA_TYPE',
   l_rrsp_er_match_flag    < 'OUT_ELE_ENTRY_VALUE' DEFAULT 'N')

  l_log = PAY_INTERNAL_LOG_WRITE(Formula_Name ||' Employer Match Required flag :'|| l_rrsp_er_match_flag)

  l_eligible_comp = Eligible_Compensation_NOCB
  IF(l_rrsp_er_match_flag ='Y')THEN
  (
   CALL_FORMULA('CA_RRSP_CALC',
    DEDN_AMT        > 'p_dedn_amt',
    l_eligible_comp            > 'ee_eligible_comp',
    l_rrsp_limit_amt           > 'rrsp_limit_amt',
    DEDN_AMT        < 'p_dedn_amt'  DEFAULT 0,
    RRSP_ER_MATCH_AMT          < 'l_rrsp_er_match_amt' DEFAULT 0)

   l_log = PAY_INTERNAL_LOG_WRITE('Exiting formula   '|| Formula_Name)

   RETURN PROVINCE,
    REPORTING_TYPE,
    RETIREMENT_PLAN_NUMBER,
    DEDN_AMT,
    TO_TOTAL_OWED,
    TO_ARREARS,
    NOT_TAKEN,
    RRSP_ER_MATCH_AMT,
    PRETAX_APPLY_TO_NONPERIODIC,
    CLEAR_ARREARS,
    PARTIAL_FLAG,
 ITER_FLAG
  )ELSE(
   CALL_FORMULA('CA_RRSP_CALC',
    DEDN_AMT        > 'p_dedn_amt',
    l_eligible_comp            > 'ee_eligible_comp',
    l_rrsp_limit_amt           > 'rrsp_limit_amt',
    DEDN_AMT        < 'p_dedn_amt'  DEFAULT 0)

  )
 )
)
l_log = PAY_INTERNAL_LOG_WRITE('Exiting formula   '|| Formula_Name)

APEX_Under_YMPE = FUTURE_M1
APEX_Over_YMPE = FUTURE_M2

RETURN
   PROVINCE,
   REPORTING_TYPE,
   RETIREMENT_PLAN_NUMBER,
   DEDN_AMT,
   TO_TOTAL_OWED,
   TO_ARREARS,
   NOT_TAKEN,
/*Customization Start */   
   PENSION_SERVICE,
   PENSIONABLE_EARNINGS,
   PENSIONABLE_HOURS,
   APEX_Under_YMPE,
   APEX_Over_YMPE,
/*Customization End */      
   PRETAX_APPLY_TO_NONPERIODIC,
   CLEAR_ARREARS,
   PARTIAL_FLAG,
   ITER_FLAG
