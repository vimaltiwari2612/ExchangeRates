/********************************************************************************************************************
 * @ClassName       : UtilClass
 * @Description     : Class containing Utility Constants and methods
********************************************************************************************************************/
public class UtilClass {
	
    public static final String  ALL_OPTIONS 	= 'All Options';
    public static final Integer CALLOUT_LIMIT 	=  Limits.getLimitCallouts() - 1;
    public static final Integer BATCH_SIZE 	=  50;
    public static Boolean isExchangeRateTriggerRun = false;
    
    /**
     * @Name                : getAllCurrencyCodes
     * @Purpose             : Get all Currency code values
     * @return              : List<String> - List of currency picklist values
     */
    public static List<String> getAllCurrencyCodes(){
        List<String> allCurrencyCodes = new List<String>();
        Schema.DescribeFieldResult fieldResult = Currency__c.Currency_Code__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntries = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry  pickListEntry : pickListEntries){
            String currencyOption = pickListEntry.getValue();
            allCurrencyCodes.add(currencyOption);
        }   
        return allCurrencyCodes;
    }
    
    /**
     * @Name                : getExchangeRates
     * @Purpose             : Get exchange rates corresponding to specified currency codes
     * @return              : List<Exchange_Rate__c> - List of exchange rates
     */
    public static List<Exchange_Rate__c> getExchangeRates(String baseCurrencyCodes){
        List<Exchange_Rate__c> rates = new List<Exchange_Rate__c>();
        if(baseCurrencyCodes == ALL_OPTIONS){
            rates = getAllExchangeRates();
        }else{
            rates = getExchangeRates(baseCurrencyCodes.split(','));
        }
        return rates;
    }
    
    /**
     * @Name                : getExchangeRates
     * @Purpose             : Get exchange rates corresponding to specified currency codes
     * @return              : List<Exchange_Rate__c> - List of exchange rates
     */
    public static List<Exchange_Rate__c> getExchangeRates(List<String> baseCurrencyCodes){
        List<Exchange_Rate__c> rates = new List<Exchange_Rate__c>();
        if(baseCurrencyCodes != null && baseCurrencyCodes.size() > 0){
            
            rates = [SELECT Id,Base_Currency__c,Base_Currency__r.Currency_code__c,Base_Currency__r.Name,Base_Currency__r.Country_Name__c, 
                        		Target_Currency__r.Currency_code__c,Target_Currency__r.Name,Target_Currency__r.Country_Name__c,
                        		Name,Rate__c, External_Id__c
                        		FROM Exchange_Rate__c 
                                WHERE Base_Currency__c != NULL AND Base_Currency__r.Currency_code__c IN: baseCurrencyCodes
                                ORDER BY Base_Currency__r.Currency_Code__c Limit 50000];            
        }
        return rates;
    }
    
    /**
     * @Name                : getAllExchangeRates
     * @Purpose             : Get all exchange rates
     * @return              : List<Exchange_Rate__c> - List of exchange rates
     */
    public static List<Exchange_Rate__c> getAllExchangeRates(){
        List<Exchange_Rate__c> rates = new List<Exchange_Rate__c>();
        rates = [SELECT Id,Base_Currency__r.Currency_code__c,Base_Currency__r.Name,Base_Currency__r.Country_Name__c, 
                    Target_Currency__r.Currency_code__c,Target_Currency__r.Name,Target_Currency__r.Country_Name__c,
                    Name,Rate__c, External_Id__c
                    FROM Exchange_Rate__c ORDER BY Base_Currency__r.Currency_Code__c Limit 50000];
        return rates;
    }
    
    /**
     * @Name                : getEmailTemplate
     * @Purpose             : Get Email template corresponding to the passed Developer name
     * @return              : EmailTemplate
     */
    public static EmailTemplate getEmailTemplate(String templateName){
        List<EmailTemplate> templates = [select Id, Subject, Body from EmailTemplate where DeveloperName =: templateName limit 1];
        if(templates != null && templates.size() > 0){
            return templates[0];
        }
        return null;
    }
}