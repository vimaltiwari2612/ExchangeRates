/********************************************************************************************************************
 * @ClassName       : ExchangeRatesTriggerHandler
 * @Description     : Handler class for Exchange Rates Trigger
********************************************************************************************************************/
public class ExchangeRatesTriggerHandler {
      
    /**
     * @Name                : updateOpportunityRecords
     * @Purpose             : Update existing opportunity records with latest rates
     * @newExchangeRatesMap	: Map of updated Exchange rates
     * @return              : void
     */
    public static void updateOpportunityRecords(Map<Id, Exchange_Rate__c> oldExchangeRatesMap, Map<Id, Exchange_Rate__c> newExchangeRatesMap){
        
        List<Exchange_Rate__c> updatedRates = new List<Exchange_Rate__c>();
        for(Id exchangeRateId: newExchangeRatesMap.keySet()){
            if(oldExchangeRatesMap.get(exchangeRateId).Rate__c != newExchangeRatesMap.get(exchangeRateId).Rate__c){
                updatedRates.add(newExchangeRatesMap.get(exchangeRateId));
            }    
        }
        if(updatedRates.size() > 0){
        	List<Opportunity> opportunities = [Select Id, Exchange_Rate__c, Exchange_Rate_Value__c from Opportunity
                                               where Exchange_Rate__c IN: updatedRates
                                               and StageName not in ('Closed Won', 'Closed Lost')
                                               Limit 50000];
            
            if(opportunities != null && opportunities.size() > 0){
                UtilClass.isExchangeRateTriggerRun = true;
                for(Opportunity opp : opportunities){ 
                    opp.Exchange_Rate_Value__c = newExchangeRatesMap.get(opp.Exchange_Rate__c).Rate__c;
                }
                update opportunities;
            }           
        }
    }
}