trigger OpportunityTrigger on Opportunity (before insert, before update) {
    
    List<Opportunity> opportunityToUpdate;
    if(!UtilClass.isExchangeRateTriggerRun){
        if(Trigger.isInsert){
            opportunityToUpdate = OpportunityTriggerHandler.getOpportunityToUpdateOnInsert(Trigger.New);
        }else if(Trigger.isUpdate){
            opportunityToUpdate = OpportunityTriggerHandler.getOpportunitiesToUpdate(Trigger.oldMap, Trigger.newMap);
        }
        OpportunityTriggerHandler.updateRateDataOnOpportunity(opportunityToUpdate);
    }
}