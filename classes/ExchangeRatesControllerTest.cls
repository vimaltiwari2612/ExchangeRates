/********************************************************************************************************************
 * @ClassName       : ExchangeRatesControllerTest
 * @Description     : Test class of Controller class for Exchange Rates Component
********************************************************************************************************************/
@isTest(seeAllData=false)
private class ExchangeRatesControllerTest {
	
    @testSetup
    private static void setupData(){
        List<Currency__c> toBeInserted = new List<Currency__c>();
        Currency__c inr = new Currency__c();
        inr.country_name__C = 'India';
        inr.currency_code__c = 'INR';
        inr.name = 'Indian Ruppee'; 
        inr.external_id__C = inr.country_name__C +'-'+inr.currency_code__c;
        toBeInserted.add(inr);
        Currency__c USD = new Currency__c();
        USD.country_name__C = 'America';
        USD.currency_code__c = 'USD';
        USD.Name = 'US Dollers';
        USD.external_id__C = USD.country_name__C +'-'+USD.currency_code__c;
        toBeInserted.add(USD);
        Currency__c EUR = new Currency__c();
        EUR.country_name__C = 'Europe';
        EUR.currency_code__c = 'EUR';
        EUR.Name = 'Euro';
        EUR.external_id__C = EUR.country_name__C +'-'+EUR.currency_code__c;
        toBeInserted.add(EUR);
        insert toBeInserted;
        
        List<Exchange_Rate__c> ratesToBeInserted = new List<Exchange_Rate__c>();
        Exchange_rate__c usd_inr = new Exchange_rate__c();
        usd_inr.Base_currency__c = USD.id;
        usd_inr.Target_currency__c = inr.id;
        usd_inr.name ='USD-INR';
        usd_inr.Rate__c =71.258;
        ratesToBeInserted.add(usd_inr);
  		Exchange_rate__c inr_usd = new Exchange_rate__c();
        inr_usd.Base_currency__c = inr.id;
        inr_usd.Target_currency__c = USD.id;
        inr_usd.name ='INR-USD';
        inr_usd.Rate__c =0.01458;
        ratesToBeInserted.add(inr_usd);
        insert ratesToBeInserted;
 
        Account ac= new Account(name='test');
        insert ac;
        
        List<Opportunity> oppToBeInserted = new List<Opportunity>();
        Opportunity testOpportunity1 = new Opportunity(
            StageName = 'Sourcing Demand',
            CloseDate = Date.valueOf('2020-01-01'),
            Account= ac,
   			Exchange_rate__c=usd_inr.id,
            Name = 'Test Opportunity1'
        );
        oppToBeInserted.add(testOpportunity1);
        Opportunity testOpportunity2 = new Opportunity(
            StageName = 'CLosed Won',
            CloseDate = Date.valueOf('2020-01-01'),
            Account = ac,
            Exchange_rate__c=usd_inr.id,
            Name = 'Test Opportunity2'
        );
        oppToBeInserted.add(testOpportunity2);
        insert oppToBeInserted;
        
        //testing update trigger cases
        testOpportunity1.Amount_base__C = 2000;
        update testOpportunity1;
        
         //testing update trigger cases
        usd_inr.Rate__c =73.956;
        update usd_inr;
        
    }
    
    @isTest
    private static void testFetchAllRecords(){
        Test.startTest();
        ExchangeRatesWrappers.ExchangeRatesTableWrapper tableWrapper = ExchangeRatesController.fetchAllRates();
        System.assert(tableWrapper!=null);
        Test.stopTest();
    }
    
    @isTest
    private static void testFailureResponseFromAPI(){
        Test.startTest();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		ExchangeRatesWrappers.ExchangeRatesTableWrapper tableWrapper = ExchangeRatesController.refreshRates('USD');
        System.assert(tableWrapper!=null);
        Test.stopTest();
    }
    
    @isTest
    private static void testSuccessResponseFromAPI(){
     	Test.startTest();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		ExchangeRatesWrappers.ExchangeRatesTableWrapper tableWrapper = ExchangeRatesController.refreshRates('EUR');
        System.assert(tableWrapper!=null);
        LatestRatesService latestRatesService = new LatestRatesService();
        Test.stopTest();
    }  
      
    @isTest
    private static void testRefreshAllRates(){
     	Test.startTest();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		ExchangeRatesWrappers.ExchangeRatesTableWrapper tableWrapper = ExchangeRatesController.refreshRates(UtilClass.ALL_OPTIONS);
        tableWrapper = ExchangeRatesController.refreshRates(UtilClass.ALL_OPTIONS);
        System.assert(tableWrapper!=null);
        Test.stopTest();
    }  
}