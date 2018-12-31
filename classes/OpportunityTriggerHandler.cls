/********************************************************************************************************************
 * @ClassName       : OpportunityTriggerHandler
 * @Description     : Handler class for Opportunity Trigger
********************************************************************************************************************/
public class OpportunityTriggerHandler {
	
    public static Map<Id,Exchange_Rate__c> exchangeRatesIdVsRateMap = new  Map<Id,Exchange_Rate__c>();
    
    /**
     * @Name                : getOpportunityToUpdateOnInsert
     * @Purpose             : Get opportunities to be updated
     * @opportunities		: List of opportunities
     * @return              : List<Opportunity>
     */
    public static List<Opportunity> getOpportunityToUpdateOnInsert(List<Opportunity> opportunities){ 
        
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        
        for(Opportunity opp : opportunities){
        	exchangeRatesIdVsRateMap.put(opp.Exchange_Rate__c, null);
        }
        
        return opportunities;
    }
    
    /**
     * @Name                : getOpportunitiesToUpdate
     * @Purpose             : Get opportunities to be updated
     * @oldOpportunityMap	: Map of old opportunity data
     * @opportunityMap      : Map of new opportunity data
     * @return              : List<Opportunity>
     */
    public static List<Opportunity> getOpportunitiesToUpdate(Map<Id, Opportunity> oldOpportunityMap, Map<Id, Opportunity> opportunityMap){ 
        
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        
        for(ID opportunityId : opportunityMap.keySet()){
            Opportunity opp = opportunityMap.get(opportunityId);
            if(oldOpportunityMap != null 
               && oldOpportunityMap.containsKey(opportunityId) 
               && !oldOpportunityMap.get(opportunityId).StageName.contains('Closed')){
                   exchangeRatesIdVsRateMap.put(opp.Exchange_Rate__c, null);
                   oppToUpdate.add(opp);
             }
        }
        
        return oppToUpdate;
    }
    
    /**
     * @Name                : updateRateDataOnOpportunity
     * @Purpose             : Update Amount fields using selected target currency Rates
     * @opportunities		: List of opportunities to update
     * @return              : void
     */
    public static void updateRateDataOnOpportunity(List<Opportunity> oppToUpdate){
        
        exchangeRatesIdVsRateMap = new Map<Id, Exchange_Rate__c>([select Id, Rate__c 
                                                                 from Exchange_Rate__c
                                                                 where Id in : exchangeRatesIdVsRateMap.keySet()
                                                                 limit 50000]);
        
        for(Opportunity opp : oppToUpdate){
            if(exchangeRatesIdVsRateMap.keySet().contains(opp.Exchange_Rate__c)){
              	opp.Exchange_Rate_Value__c = exchangeRatesIdVsRateMap.get(opp.Exchange_Rate__c).Rate__c;
            }
        }
    }
}