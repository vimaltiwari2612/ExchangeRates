trigger ExchangeRatesTrigger on Exchange_Rate__c (after update) {
	ExchangeRatesTriggerHandler.updateOpportunityRecords(Trigger.oldMap, Trigger.newMap);
}