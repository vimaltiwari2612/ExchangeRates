/********************************************************************************************************************
 * @ClassName       : LatestRatesService
 * @Description     : This is the Service class for Latest Rates API
********************************************************************************************************************/
public with sharing class LatestRatesService{
    
    //This enum will consist of the list of services which will be used by APIProcessor to get API related details
    //like endpoint, request response classes etc.
    private Enum SERVICENAME{
        GETLATESTRATES
    }

    /**
     * @Name                : getLatestExchangeRates
     * @Purpose             : Get Latest exchange rates from the API
     * @base                : base currency against which the API needs to be called(default = EUR)
     * @symbols             : List of converted currencies required in response(optional)
     * @return              : LatestRatesResponse - Response in the form of wrapper
     */
    public LatestRatesResponse getLatestExchangeRates(String base, String symbols){
    
        //Call the constructor of LatestRatesRequest
        LatestRatesRequest request = new LatestRatesRequest(base, symbols);
        //Set query string parameters
        request.setQueryStringParams(); 
        LatestRatesAPIProcessor api = new LatestRatesAPIProcessor(SERVICENAME.GETLATESTRATES.name(), request);
        LatestRatesResponse response = (LatestRatesResponse)api.process();
        return response;
    }
}