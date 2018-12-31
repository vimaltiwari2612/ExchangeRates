({
   doInit: function(component, event, helper) {
      component.set('v.columns', [
                   {label: 'Base Currency', fieldName: 'baseCurrencyCode', type: 'Text'},                   
                   {label: 'Target Currency', fieldName: 'targetCurrencyCode', type: 'Text'},
          		   {label: 'Rate', fieldName: 'rate', type: 'Text'}
            ]);
      
      // call the helper function   
      helper.getAllData(component,event, helper);     
   },
 
    getRefreshedRates: function(component, event, helper){
        var selectedCurrency = component.get('v.selectedCurrency');
        helper.refreshRates(component, selectedCurrency); 
        //Close picklist if it is still open
        var multiSelectPicklist = component.find('multiSelect');
        var mainDiv = multiSelectPicklist.find('triggerDiv');
        $A.util.removeClass(mainDiv, 'slds-is-open');
    },
    
    next: function (component, event, helper) {
        helper.next(component, event);
    },
    
    previous: function (component, event, helper) {
        helper.previous(component, event);
    }
 
})