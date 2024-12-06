({
	callAllMethods : function(component, event, helper) {
        component.set("v.loading", true);
        helper.echo(component, 'triggerWorkflow', {'alias': component.get("v.alias")}, function(result) {
            window.setTimeout(
                $A.getCallback(function() {
                    helper.echo(component, 'getFilteredWorkflowRuns', {}, function(runId) {
                        component.set("v.runId", runId);
                        helper.echo(component, 'getWorkflowJobs', {'runId': runId}, function(jobId) {
                            component.set("v.jobId", jobId);
                            helper.echo(component, 'getJobDetails', {'jobId': jobId}, function(steps) {
                                component.set("v.steps", JSON.parse(steps));
                                
                                var interv = window.setInterval(
                                    $A.getCallback(function() {
                                        helper.echo(component, 'getJobDetails', {'jobId': jobId}, function(steps) {
                                            component.set("v.steps", JSON.parse(steps));
                                            helper.validateSteps(component, helper);
                                        });
                                    }), 5000
                                ); 
                                component.set("v.interv", interv);
                            });
                        });
                    });
                }), 5000
            );
        });
    }
})