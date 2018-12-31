/********************************************************************************************************************
 * @ClassName       : LatestRatesRequest
 * @Description     : Request class for Latest Rates API
 ********************************************************************************************************************/
public with sharing class LatestRatesRequest{ 

    private String base;
    private String symbols;
    public Map<String, String> queryStringParams;
    
    public LatestRatesRequest(String base, String symbols){
        this.base = base;
        this.symbols= symbols;
        
    }

    public void setQueryStringParams(){
        queryStringParams = new Map<String, String>();
        if(String.isNotBlank(base)){
            queryStringParams.put('base', EncodingUtil.urlEncode(base, 'UTF-8'));
        }
        if(String.isNotBlank(symbols)){
            queryStringParams.put('symbols', EncodingUtil.urlEncode(symbols, 'UTF-8'));
        }
        
    }
    
    public String getQueryString(){
        if(queryStringParams != null){
            //Generate the queryString from the queryStringParams Map
            String queryString = '';
            for(String key : queryStringParams.keySet()){
                queryString += key.toLowerCase() + '=' + queryStringParams.get(key) + '&';
            }
            
            return queryString.removeEnd('&');
        }
        return '';
    }
}