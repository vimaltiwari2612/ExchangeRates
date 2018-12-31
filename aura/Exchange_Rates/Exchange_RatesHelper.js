({
   getAllData: function(component, event, helper) {
 
      // create a server side action
      var action = component.get("c.fetchAllRates");
      // set a call back   
      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              // store the response return value (wrapper class insatance)  
              var result = response.getReturnValue();
              // set the component attributes value with wrapper class properties
              component.set("v.exchangeRates", result.exchangeRates);
              component.set("v.currencyOptions", result.currencyOptions); 
              var pageSize = component.get("v.pageSize");
              component.set("v.totalRecords", component.get("v.exchangeRates").length);
              component.set("v.startPage",0);
              component.set("v.endPage",pageSize-1);
              component.set("v.pageNumber",1);
              component.set("v.totalPages", parseInt(component.get("v.totalRecords")/pageSize) + 1);
              var paginationList = [];
              for(var i=0; i< pageSize; i++){
                  if(component.get("v.exchangeRates").length> i){
                      paginationList.push(component.get("v.exchangeRates")[i]);
                  }
              }
              component.set('v.exchangeRatesPerPage', paginationList);      
              //Initialize the child component on init completion of parent
              var multiSelectComp = component.find('multiSelect');
              multiSelectComp.invokeInit();    
          } else if (state === "ERROR") {
              var errors = response.getError();
              if (errors) {
                  if (errors[0] && errors[0].message) {
                      this.showToast("Error", "Error", "Error message: " + 
                                     errors[0].message);
                  }
              } else {
                  this.showToast("Error", "Error", "Unknown Error");
              }
          }
      });
      // enqueue the action 
      $A.enqueueAction(action);
   },
    
	refreshRates: function(component, selectedCurrency){
		// create a server side action
        var refreshButton = component.find("refreshButton");
        refreshButton.set("v.label","Refreshing Data...");
        component.set('v.refreshInProgress',true);
        var action = component.get("c.refreshRates");
        // set the parameters to method 
        action.setParams({
            "selectedCurrency": selectedCurrency
        });
      	// set a call back   
      	action.setCallback(this, function(response) {
        	var state = response.getState();
        	if (state === "SUCCESS") {
         		// store the response return value (wrapper class insatance)  
                var result = response.getReturnValue();
                refreshButton.set("v.label","Refresh Data");
                component.set("v.exchangeRates", result.exchangeRates);
                var pageSize = component.get("v.pageSize");
                component.set("v.totalRecords", component.get("v.exchangeRates").length);
                component.set("v.startPage",0);
                component.set("v.endPage",pageSize-1);
                component.set("v.pageNumber",1);
                component.set("v.totalPages", parseInt(component.get("v.totalRecords")/pageSize) + 1);
                var paginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.exchangeRates").length> i){
                        paginationList.push(component.get("v.exchangeRates")[i]);       
                    }
                }
                component.set('v.exchangeRatesPerPage', paginationList);
                if(result.status != null){
                    this.showToast(result.status, result.status, result.message);
                }
                /*if(result.message != null){
                    if(result.message == ''){
                        this.showToast("Success", "Success", "Data Refresh is In-Progress. This might take few minutes! "+
                                       "You will receive an Email once it is complete. Please Refresh the page after that to view updated rates.");                
                    }else if(result.message == 'In-Progress'){
                        this.showToast("Info", "Info", "Data Refresh is Already In-Progress."); 
                    }
                    else {
                        this.showToast("Error", "Error", result.message);
                    }
                } else{
                    this.showToast("Success", "Success", "Data Refreshed Successfully!");
                }*/
             component.set('v.refreshInProgress', false);  
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast("Error", "Error", "Error message: " + 
                                            			  errors[0].message);
                    }
                } else {
                    this.showToast("Error", "Error", "Unknown Error");
                }
                component.set('v.refreshInProgress',false);
            }
         
      });
      // enqueue the action 
      $A.enqueueAction(action);
    },
    
     /*
     * Method will be called when user clicks on next button and performs the 
     * calculation to show the next set of records
     */
    next : function(component, event){
        var sObjectList = component.get("v.exchangeRates");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var counter = 0;
        for(var i = end+1; i < end+pageSize+1; i++){
            if(sObjectList.length > i){
                paginationList.push(sObjectList[i]);
            }
            counter++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set("v.pageNumber", component.get("v.pageNumber")+1);
        component.set('v.exchangeRatesPerPage', paginationList);
    },
    
    /*
     * Method will be called when user clicks on previous button and performs the 
     * calculation to show the previous set of records
     */
    previous : function(component, event){
        var sObjectList = component.get("v.exchangeRates");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                paginationList.push(sObjectList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set("v.pageNumber", component.get("v.pageNumber")-1);
        component.set('v.exchangeRatesPerPage', paginationList);
    },
    
    showToast : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "mode": "sticky",
            "type": type
        });
        toastEvent.fire();
	}
})