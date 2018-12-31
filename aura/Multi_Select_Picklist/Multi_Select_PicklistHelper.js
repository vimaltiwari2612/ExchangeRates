({
    //Method to set info-text as 'N options selected'
	setInfoText: function(component, values) {
		if (values.length == 0) {
			component.set("v.infoText", "No option selected");
		}else if (values.length == 1 && values[0] == 'All Options') {
            //If 'All Options' is selected, show info-text as 'All Options'
        	component.set("v.infoText", 'All Options selected');
		}else if (values.length >= 1) {
			component.set("v.infoText", values.length + " options selected");
		}
	},
	//Method to get selected values in order to show selected and info-text
	getSelectedValues: function(component){
        //Get currency options
		var options = component.get("v.options");
        //Create selected values array
		var values = [];
		options.forEach(function(element) {
            //For each option that is selected, add to the array
			if (element.selected) {
				values.push(element.code);
			}
		});
        //Return selected values
		return values;
	},
    //Method to set selected values on component init
    setSelectedOnLoad: function(component, values){
        //Get picklist values as set by the parent component
        var options = component.get('v.allOptions');
        //Get current list of selected values to show as pills below the picklist
        var selectedValues = component.get('v.selectedValues');
        options.forEach(function(element){
            //If this option is selected
            if(values.indexOf(element.code) != -1){
                //Set selected = true for this option
                element.selected = true;
                if(element.code != 'All Options' && selectedValues.indexOf(element.code) == -1){
                	//If any other option and not already present in list, add
					selectedValues.push(element.name);
				}
            } 
        });
        //Set options list used to display on the UI as the list of options prepared
        component.set('v.options',options);
        //Set selected values list to show pills corresponding to selected options
        component.set('v.selectedValues', selectedValues);
    },
    //Method called on value selection/un-selection
    onValueSelected: function(component, value, selected){
    	//Get options list
    	var options = component.get('v.options');
    	//Get selected values list
        var selectedValues = component.get('v.selectedValues');
        options.forEach(function(element) {
            //Find option with code matching the current value
        	if (element.code == value) {
                //If option is currently selected, toggle to false and vice-versa
            	element.selected = selected == "true" ? false : true;
                //If option is selected now
                if(element.selected == true){
                    //If All Options is selected
					if(element.code == 'All Options'){
						options.forEach(function(option){
							//If 'All Options' is selected, no other value should be selected
                            if(option.code != 'All Options' && option.selected == true){
                                option.selected = false;
                                var indx = selectedValues.indexOf(option.code);
								selectedValues.splice(indx, 1);
                            }
						});
					} else {
                        //If any other option
                        options.forEach(function(option){
                            //If All is selected, un-select all
                        	if(option.code == 'All Options' && option.selected == true){
                            	option.selected = false;
                                return;
                            }
                        });
                        //If not already present in the list, add
                        if(selectedValues.indexOf(element.code) == -1){
                        	selectedValues.push(element.code);   
                        }
					}
				} else{
                    //If option is un-selected
                    if(element.code != 'All Options'){
						//For any other option but All Options
                        var indx = selectedValues.indexOf(value);
                        selectedValues.splice(indx, 1);
                    }
            	}	
            }
        });
        //Set updated options in allOptions list
        component.set('v.options',options);
        //Set updated selectedValues
    	component.set('v.selectedValues', selectedValues);

    },
})