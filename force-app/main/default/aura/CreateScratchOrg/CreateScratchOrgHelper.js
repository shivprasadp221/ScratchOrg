({
	"echo" : function(cmp, methodName, params, onsuccess) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = cmp.get("c."+methodName);
        action.setParams(params);

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                onsuccess(response.getReturnValue());

                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        alert(errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        // optionally set storable, abortable, background flag here

        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    },
    
    validateSteps : function(component, helper) {
        let steps = component.get("v.steps");
        if(steps.length >= 7 && steps[steps.length-1].status=="completed") {
            window.clearInterval(component.get("v.interv"));
            if(steps[steps.length-1].conclusion=='success') {
                helper.echo(component, 'getJobLogs', {'jobId': component.get("v.jobId")}, function(result) {
	            	helper.downloadLogs(component, result);
                });
            } else {
                console.log(steps[steps.length-1]);
                alert(steps[steps.length-1]);
            }
        }
    },
    
    downloadLogs : function(component, endpoint) {
        fetch(endpoint, {
            method: 'GET',
            headers: {
                'Accept': 'application/vnd.github.v3+json',  // GitHub-specific header
            }
        })
        .then(response => {
            // Check if response status is 200 (OK)
            if (response.status === 200) {
                return response.text();  // Return the response body as text
            } else {
                // Throw an error if the status is not 200
                throw new Error("Failed to fetch logs. Status code: " + response.status);
            }
        })
        .then(data => {
            // Process the data if response is successful
            var parts = data.split('@@@');
            if (parts.length > 1) {
               component.set("v.finalResult",  parts[3]); 
            	component.set("v.completed", true);// Return the second part of the response
            }
            
        })
        .catch(error => {
            // Handle errors (invalid response or network issues)
            component.set("v.errorMessage", error.message || "Unknown error");
        })
          .finally(() => {
            // Set loading to false after the fetch process is done
            component.set("v.loading", false);
        });
	}
})