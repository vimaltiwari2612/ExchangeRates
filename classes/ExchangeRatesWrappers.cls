/********************************************************************************************************************
 * @ClassName       : ExchangeRatesWrappers
 * @Description     : Wrapper class for storing exchange rates related wrappers
********************************************************************************************************************/
public class ExchangeRatesWrappers {
	
    //Wrapper class for Exchange Rates Data Table
	public class ExchangeRatesTableWrapper {
        @AuraEnabled 
        public List<ExchangeRatesWrapper> exchangeRates {get;set;}
        @AuraEnabled
        public List<CurrencyPicklistWrapper> currencyOptions {get; set;}
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public String message {get; set;}
    }
    
    //Wrapper class for Exchange Rates Data
	public class ExchangeRatesWrapper{
       @AuraEnabled 
       public String baseCurrencyCode {get;set;}
       @AuraEnabled 
       public String targetCurrencyCode {get;set;}
       @AuraEnabled 
       public String rate {get;set;}
       
       public ExchangeRatesWrapper(){
           
       }
       
       public ExchangeRatesWrapper(String baseCurrencyCode, String targetCurrencyCode, String rate){
           this.baseCurrencyCode = baseCurrencyCode;
           this.targetCurrencyCode = targetCurrencyCode;
           this.rate = rate;
       }
   	}
    
    //Wrapper class for Currency Picklist
	public class CurrencyPicklistWrapper{ 
    	@AuraEnabled 
        public String code {get; set;}
        @AuraEnabled 
        public Boolean selected {get; set;}
        
        public CurrencyPicklistWrapper(String code){
            this.code = code;
        }   
    }

}