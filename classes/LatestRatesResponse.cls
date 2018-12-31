/********************************************************************************************************************
 * @ClassName       : LatestRatesResponse 
 * @Description     : Response class for Latest Rates API
 ********************************************************************************************************************/
public with sharing class LatestRatesResponse {

    public Boolean success;
    public Integer timestamp; 
    public String base; 
    public Map<String, String> rates;
    public Error error;
    
    public class Error{
        public Integer code;
        public String type;
    }
}