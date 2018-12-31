/********************************************************************************************************************
 * @ClassName       : LatestRatesAPIProcessor
 * @Description     : API Processor class for Latest Rates API
********************************************************************************************************************/
public with sharing class LatestRatesAPIProcessor {

    public String serviceName {get;set;}
    public LatestRatesRequest latestRatesAPIRequest {get;set;}
    
    public LatestRatesAPIProcessor (){
        
    }
    
    public LatestRatesAPIProcessor (string serviceName, LatestRatesRequest latestRatesAPIRequest){
        this.serviceName = serviceName;
        this.latestRatesAPIRequest = latestRatesAPIRequest;
    }   
    
    public LatestRatesResponse process(){
        
        try{
                
            LatestRatesResponse apiResponse = null;
                      
            //Getting API Configuration(consisting callout details ex. Endpoint, Timeout etc.) based on the Service Name
            API_Configuration__mdt apiConfiguration = getAPIConfiguration(serviceName);
            //Get Query String
            String queryString = latestRatesAPIRequest.getQueryString();
            if(apiConfiguration != null){
                
                String endPointURL = apiConfiguration.Endpoint__c.toLowerCase();
                //Get access key and append to endpoint
                String accessKey = 'access_key='+ apiConfiguration.Access_Key__c;
                endPointURL += ((endPointURL.contains('?') ? '&' : '?') + accessKey);
                //Append the queryString params in the Endpoint URL
                endPointURL += ((endPointURL.contains('?') ? '&' : '?') + queryString);
                //Setting request parameters required for HTTP Callout
                HTTPCalloutProcessor httpCalloutProcessor = new HTTPCalloutProcessor(
                                                            endPointURL, 
                                                            apiConfiguration.Method_Type__c
                                                        );
                
                if(apiConfiguration.Timeout__c != null){
                    httpCalloutProcessor.timeout = Integer.valueOf(apiConfiguration.Timeout__c);
                }
                
                //Making HTTP Callout
                HTTPResponse httpResponse = httpCalloutProcessor.processCallout();
                String responseBody = httpResponse.getBody();
                
                apiResponse = (LatestRatesResponse)JSON.deserialize(responseBody, Type.forName('LatestRatesResponse'));
                
                return apiResponse;
                
            }else{
                throw (new APIException('Configuration Not Found'));
            } 
            
        }catch(Exception ex){
            throw ex;
        }        
    }
    
    public API_Configuration__mdt getAPIConfiguration(String serviceName){
        List<API_Configuration__mdt> apiConfigurations = [SELECT Endpoint__c, Method_Type__c, Timeout__c, Access_Key__c, Service_Name__c
                                                    FROM API_Configuration__mdt WHERE Service_Name__c =: serviceName LIMIT 1];
        return apiConfigurations.size() > 0 ? apiConfigurations[0] : null;
    }
  
}