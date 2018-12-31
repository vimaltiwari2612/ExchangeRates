/********************************************************************************************************************
 * @ClassName       : ExchangeRatesController
 * @Description     : Controller class for Exchange Rates Component
********************************************************************************************************************/
public with sharing class ExchangeRatesController {
    
    /**
     * @Name                : fetchAllRates
     * @Purpose             : Get all data for creating Data Table on component
     * @return              : ExchangeRatesWrappers.ExchangeRatesTableWrapper - Data Table Wrapper instance
     */
    @AuraEnabled
 	public static ExchangeRatesWrappers.ExchangeRatesTableWrapper fetchAllRates() {
        
    	ExchangeRatesWrappers.ExchangeRatesTableWrapper tableWrapper =  new ExchangeRatesWrappers.ExchangeRatesTableWrapper(); 
        //Fetch Exchange Rates data using SOQL
        List<Exchange_Rate__c> allRates = UtilClass.getAllExchangeRates();
        tableWrapper.exchangeRates = fetchExchangeRatesWrapper(allRates);
        //Create currency options to display on page
        tableWrapper.currencyOptions = new List<ExchangeRatesWrappers.CurrencyPicklistWrapper>();
        //Add all options to the list of currency options
        tableWrapper.currencyOptions.add(new ExchangeRatesWrappers.CurrencyPicklistWrapper(UtilClass.ALL_OPTIONS));
        tableWrapper.currencyOptions.addAll(getAllCurrencyCodes());
        return tableWrapper; 
    }
    
    /**
     * @Name                : fetchData
     * @Purpose             : Fetch Exchange Rates data using SOQL
     * @currencyCodes		: Comma separated list of currency codes against which to query exchange rates
     * @return              : List<ExchangeRatesWrappers.ExchangeRatesWrapper> - List of Exchange Rates Wrapper
     */
    public static List<ExchangeRatesWrappers.ExchangeRatesWrapper> fetchExchangeRatesWrapper(List<Exchange_Rate__c> ratesList) {
        //List to return
  		List<ExchangeRatesWrappers.ExchangeRatesWrapper> exchangeRatesWrapperList = new List<ExchangeRatesWrappers.ExchangeRatesWrapper>();
        for(Exchange_Rate__c er: ratesList){
        	ExchangeRatesWrappers.ExchangeRatesWrapper erw = new ExchangeRatesWrappers.ExchangeRatesWrapper(er.Base_Currency__r.Currency_code__c,
                        																					er.Target_Currency__r.Currency_code__c,
                     																						String.valueOf(er.Rate__c));
            exchangeRatesWrapperList.add(erw);
         }
     
        return exchangeRatesWrapperList; 
     } 
    
    /**
     * @Name                : refreshRates
     * @Purpose             : Call API and get refreshed ratess, update them and return to be shown on UI
     * @selectedCurrency	: Comma separated list of currency codes against which to call API and get data
     * @return              : ExchangeRatesWrappers.ExchangeRatesTableWrapper - Instance of Data table wrapper
     */
	@AuraEnabled
 	public static ExchangeRatesWrappers.ExchangeRatesTableWrapper refreshRates(String selectedCurrency) {
        
        //variable sets to true if number of selected base currencies are more than the CALLOUT_LIMIT value
        Boolean isCalloutLimitExceeded = false;
        Boolean batchAlreadyRunning = false;

		List<String> errorBaseCurrencyCodes = new List<String>();
        List<String> currencyCodes = new List<String>();  
        Map<String,String> exchangeRatesNameVsValueMap = new Map<String,String>();
        Map<String,Currency__c> currencyCodeVsDataMap = new Map<String,Currency__c>();
                
        //creating the response wrapper;
        ExchangeRatesWrappers.ExchangeRatesTableWrapper tableWrapper =  new ExchangeRatesWrappers.ExchangeRatesTableWrapper(); 
        
        List<Currency__c> currencyData = [Select id , Currency_code__c from Currency__c limit 1000];
        for(Currency__c currencyRecord : currencyData){
            currencyCodeVsDataMap.put(currencyRecord.Currency_code__c, currencyRecord);
        }
        if(selectedCurrency!=null && selectedCurrency!=''){
            if(selectedCurrency == UtilClass.ALL_OPTIONS){
                List<ExchangeRatesWrappers.CurrencyPicklistWrapper> allCurrencyCodeWrapper = getAllCurrencyCodes();
                for(ExchangeRatesWrappers.CurrencyPicklistWrapper wrapperItem : allCurrencyCodeWrapper){
                   	currencyCodes.add(wrapperItem.code);
                }
            } else{
                currencyCodes = selectedCurrency.split(',');
            }
            if(currencyCodes.size() > 0 && currencyCodes.size() < UtilClass.CALLOUT_LIMIT){
                LatestRatesService ratesService =new LatestRatesService();
                LatestRatesResponse serviceResponse;
                for(String baseCode : currencyCodes){
                    serviceResponse = ratesService.getLatestExchangeRates(baseCode,'');
                    if(serviceResponse != null){
                        if(serviceResponse.rates == null || serviceResponse.rates.size()==0){
                            errorBaseCurrencyCodes.add(baseCode);
                        }else{
                            for(String targetCode : serviceResponse.rates.keySet()){
                                exchangeRatesNameVsValueMap.put(baseCode+'-'+targetCode,serviceResponse.rates.get(targetCode));
                            }  
                        } 
                    }                   
                }                
            } else{
                isCalloutLimitExceeded = true;
                batchAlreadyRunning = isBatchAlreadyRunning();
                if(!batchAlreadyRunning){
                    Database.executeBatch(new RefreshRatesBatch(currencyCodes),UtilClass.BATCH_SIZE);  
                }
            }
        } 
        //List of current rates
        List<Exchange_Rate__c> currenctRates = new List<Exchange_Rate__c>();
        if(!isCalloutLimitExceeded){
            List<Exchange_Rate__c> ratesToUpdate = new List<Exchange_Rate__c>();
            
            currenctRates = UtilClass.getExchangeRates(selectedCurrency);
        	    
            if(exchangeRatesNameVsValueMap.size() > 0){
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
            }
            if(ratesToUpdate.size() > 0){
            	upsert ratesToUpdate External_Id__c; 
            }
            
            if(errorBaseCurrencyCodes != null && errorBaseCurrencyCodes.size() > 0){
                tableWrapper.status = 'Error';
                String errorMessage = Label.Exchange_Rates_Refresh_Error;
                tableWrapper.message = errorMessage != null 
                                       ? errorMessage.replaceAll('@currencyCodes', String.join(errorBaseCurrencyCodes,', '))
                                       : 'Error with ' +String.join(errorBaseCurrencyCodes,', ');
                    
            }else{
                tableWrapper.status = 'Success';
                tableWrapper.message = Label.Exchange_Rates_Refresh_Success;
            }
        } else{
            //when codes are more than CALLOUT_LIMIT, check if the Data refresh is already in progress or not
            if(batchAlreadyRunning){
                tableWrapper.status = 'Info';
                tableWrapper.message= Label.Exchange_Rates_Refresh_In_Progress; 
            } else{
                tableWrapper.status = 'Success';
                tableWrapper.message= Label.Exchange_Rates_Refresh_Queued;
            }
             
        }
        currenctRates = UtilClass.getExchangeRates(selectedCurrency);
        tableWrapper.exchangeRates = fetchExchangeRatesWrapper(currenctRates);
        	
        return tableWrapper;  
    }
    
    /**
     * @Name                : getAllCurrencyCodes
     * @Purpose             : Get all Currency code values
     * @return              : List<ExchangeRatesWrappers.CurrencyPicklistWrapper> - List of currency picklist wrappers
     */
    private static List<ExchangeRatesWrappers.CurrencyPicklistWrapper> getAllCurrencyCodes(){
        List<ExchangeRatesWrappers.CurrencyPicklistWrapper> allCurrencyCodes = new List<ExchangeRatesWrappers.CurrencyPicklistWrapper>();
        for(String  currencyCode : UtilClass.getAllCurrencyCodes()){
            ExchangeRatesWrappers.CurrencyPicklistWrapper currencyOption = new ExchangeRatesWrappers.CurrencyPicklistWrapper(currencyCode);
            allCurrencyCodes.add(currencyOption);
        }   
        return allCurrencyCodes;
    }
    
     /**
     * @Name                : getBatchStatus
     * @Purpose             : getting status of Batch which is running to update all rates
     * @batchId				: Batch id
     * @return              : status of batch
     */ 
    private static Boolean isBatchAlreadyRunning(){
        DateTime currentDateTime = System.now();
        DateTime threeHrsAgo = currentDateTime.addHours(-3);
        List<AsyncApexJob> apexJobs = [Select Id, Status from AsyncApexJob 
                                      where ApexClass.Name='RefreshRatesBatch' 
                                      and Status IN ('Preparing','Holding','Processing','Queued')
                                      and CreatedDate >=: threeHrsAgo order by CreatedDate desc limit 1]; 
        if(apexJobs != null && apexJobs.size() > 0){
            return true;
        }
        return false;
    }
    
}