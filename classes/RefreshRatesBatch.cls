/********************************************************************************************************************
 * @ClassName       : RefreshRatesBatch
 * @Description     : Batch To Refresh All Exchange Rates Data
********************************************************************************************************************/
global class RefreshRatesBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{

   List<String> baseCurrencyCodes; 
    
    global RefreshRatesBatch(){
        this(UtilClass.getAllCurrencyCodes());
    } 
    
   global RefreshRatesBatch(List<String> baseCurrencyCodes){
       this.baseCurrencyCodes = baseCurrencyCodes;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
       
       String query='Select Id, Currency_Code__c from Currency__c where Currency_code__c in: baseCurrencyCodes'; 
       return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<Currency__c> scope){
       
       Map<String,String> exchangeRatesNameVsValueMap = new Map<String,String>();
       Map<String,Currency__c> currencyCodeVsDataMap = new Map<String,Currency__c>();

       LatestRatesService ratesService =new LatestRatesService();
       LatestRatesResponse serviceResponse;
       
       List<Currency__c> currencyData = [Select id , Currency_code__c from Currency__c limit 1000];
       for(Currency__c currencyRecord : currencyData){
            currencyCodeVsDataMap.put(currencyRecord.Currency_code__c, currencyRecord);
       }

       for(Currency__c currencyRecord : scope){
           String baseCode = currencyRecord.Currency_Code__c;
           serviceResponse = ratesService.getLatestExchangeRates(baseCode,'');
           if(serviceResponse != null && serviceResponse.rates != null && serviceResponse.rates.size()>0){
               for(String targetCode : serviceResponse.rates.keySet()){
                   exchangeRatesNameVsValueMap.put(baseCode+'-'+targetCode,serviceResponse.rates.get(targetCode));
               } 
           }                        
       }
       
       //List of current rates
       List<Exchange_Rate__c> currenctRates = new List<Exchange_Rate__c>();
       currenctRates = UtilClass.getExchangeRates(new List<String>(currencyCodeVsDataMap.keySet()));
       
       if(exchangeRatesNameVsValueMap.size()>0){
           List<Exchange_Rate__c> ratesToUpdate = new List<Exchange_Rate__c>();
           Map<String, Exchange_Rate__c> currentNameVsRate = new Map<String, Exchange_Rate__c>();
           
           for(Exchange_Rate__c rate: currenctRates){
               currentNameVsRate.put(rate.External_Id__c, rate);
           }
           
           for(String key: exchangeRatesNameVsValueMap.keySet()){
               List<String> keyData = key.split('-');
               Exchange_Rate__c exchangeRate = new Exchange_Rate__c();
               if( (!currentNameVsRate.containsKey(key) || currentNameVsRate.get(key).Rate__c != Double.valueOf(exchangeRatesNameVsValueMap.get(key)))
                    && (currencyCodeVsDataMap.containsKey(keyData[0]) && currencyCodeVsDataMap.containsKey(keyData[1]))){
                   exchangeRate.Base_Currency__c = currencyCodeVsDataMap.get(keyData[0]).Id;
                   exchangeRate.Target_Currency__c = currencyCodeVsDataMap.get(keyData[1]).Id;
                   exchangeRate.External_Id__c = key;
                   exchangeRate.Name = key;
                   exchangeRate.Rate__c = Double.valueOf(exchangeRatesNameVsValueMap.get(key));
                   ratesToUpdate.add(exchangeRate);
               }                    
           }
           if(ratesToUpdate.size() > 0){
               upsert ratesToUpdate External_Id__c; 
           }
    	}
   }
    
    global void finish(Database.BatchableContext BC){
        
        AsyncApexJob apexJob = [Select Id, Status, ExtendedStatus, CreatedBy.Email, CreatedBy.Name from AsyncApexJob where Id =: BC.getJobId()];
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] {apexJob.CreatedBy.Email};
        message.optOutPolicy = 'FILTER';
        
        EmailTemplate successTemplate = UtilClass.getEmailTemplate('Exchange_Rates_Refresh_Successful');
        if(successTemplate != null){
            message.subject = successTemplate.Subject;
            message.plainTextBody = successTemplate.Body;
        }
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.sendEmail(messages);
    }
}