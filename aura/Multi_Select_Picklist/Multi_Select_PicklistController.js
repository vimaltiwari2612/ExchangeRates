({  
    doInit: function(component, event, helper){
     
        //Get selectedValue passed by parent component
        var selectedValues = component.get('v.selectedValue');
        var values = [];
        if(selectedValues && selectedValues != null){
            //Get list of selected values
            values = selectedValues.split(",");
        } 
        //Set info text message as per the selected options
        helper.setInfoText(component, values);
        //Mark options as selected
        helper.setSelectedOnLoad(component, values);
    },   

    togglePicklist : function(component, event, helper) {
        var triggerDiv = component.find("triggerDiv")
		$A.util.toggleClass(triggerDiv, "slds-is-open");
	},
	
	selectvalue : function(component, event, helper) {
        
        var item = event.currentTarget;
        if (item && item.dataset) {
            //Get value of selected item
            var value = item.dataset.text;
            //Get current selection status of the item
            var selected = item.dataset.selected;
        }
        //Call helper method on value selection/un-selection
        helper.onValueSelected(component, value, selected);
        //Get selected values in order to set the info-text
        var values = helper.getSelectedValues(component);
        helper.setInfoText(component, values); 
        //',' separated list of selected values
        var selectedValues = values.join(",");
        //If selected values are not same as the current selection
        if(selectedValues != component.get('v.selectedValue')){
            //Set selectedValue
            component.set('v.selectedValue',selectedValues);
        }           
    },
    
})