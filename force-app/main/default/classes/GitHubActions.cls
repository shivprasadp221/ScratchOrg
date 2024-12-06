public class GitHubActions {

    // Method to return the common headers used for each request
    private static Map<String, String> getCommonHeaders() {
        Map<String, String> headers = new Map<String, String>();
        headers.put('Authorization', 'token PUT TOKEN');
        headers.put('Accept', 'application/vnd.github.v3+json');
        return headers;
    }

    // Method to dispatch the workflow (curl 1)
    @AuraEnabled
    public static Integer triggerWorkflow(String alias) {
        String endpoint = 'https://api.github.com/repos/cb-shivprasadpatil/lwc-test/actions/workflows/Snapshot.yml/dispatches';
        String payload = '{"ref":"main", "inputs":{"alias":"'+ alias +'"}}';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        // Set common headers
        Map<String, String> headers = getCommonHeaders();
        for (String key : headers.keySet()) {
            req.setHeader(key, headers.get(key));
        }

        req.setBody(payload);

        Http http = new Http();
        HttpResponse res = http.send(req);

        return res.getStatusCode();
    }
	
    public class WorkflowRunWrapper {
        public List<WorkflowRunsWrapper> workflow_runs{get;set;}
    }
    
    public class WorkflowRunsWrapper {
        public String id{get;set;}
    }
    
    @AuraEnabled
    public static String getFilteredWorkflowRuns() {
        String endpoint = 'https://api.github.com/repos/cb-shivprasadpatil/lwc-test/actions/workflows/Snapshot.yml/runs';

        // Define the query parameters
        String queryParams = '?event=workflow_dispatch&actor=cb-shivprasadpatil&per_page=1';
        
        // Append query parameters to the endpoint
        endpoint += queryParams;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        
        // Set common headers
        Map<String, String> headers = getCommonHeaders();
        for (String key : headers.keySet()) {
            req.setHeader(key, headers.get(key));
        }

        Http http = new Http();
        HttpResponse res = http.send(req);
        if(res.getStatusCode()==200) {
            WorkflowRunWrapper wrapper = (WorkflowRunWrapper)JSON.deserialize(res.getBody(), WorkflowRunWrapper.class);
            return wrapper.workflow_runs[0].id;
        } else {
            throw new GitHubActionsException(res.getBody());
        }
    }
    
    public class WorkflowJobsWrapper {
        public List<WorkflowJobWrapper> jobs{get;set;}
    }
    
    public class WorkflowJobWrapper {
        public String id{get;set;}
    }
	
    // Method to get the jobs for a specific workflow run (curl 3)
    @AuraEnabled
    public static String getWorkflowJobs(String runId) {
        String endpoint = 'https://api.github.com/repos/cb-shivprasadpatil/lwc-test/actions/runs/' + runId + '/jobs';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        
        // Set common headers
        Map<String, String> headers = getCommonHeaders();
        for (String key : headers.keySet()) {
            req.setHeader(key, headers.get(key));
        }

        Http http = new Http();
        HttpResponse res = http.send(req);
		
        if(res.getStatusCode()==200) {
            WorkflowJobsWrapper wrapper = (WorkflowJobsWrapper)JSON.deserialize(res.getBody(), WorkflowJobsWrapper.class);
            return wrapper.jobs[0].id;
        } else {
            throw new GitHubActionsException(res.getBody());
        }
    }
    
    public class GitHubJob {
        public List<Step> steps;
    }
    
    public class Step {
        public String name;
        public String status;
        public String conclusion;
        public String started_at;
        public String completed_at;
    }

    // Method to get job details (curl 4)
   @AuraEnabled
    public static String getJobDetails(String jobId) {
        String endpoint = 'https://api.github.com/repos/cb-shivprasadpatil/lwc-test/actions/jobs/' + jobId;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        
        // Set common headers
        Map<String, String> headers = getCommonHeaders();
        for (String key : headers.keySet()) {
            req.setHeader(key, headers.get(key));
        }

        Http http = new Http();
        HttpResponse res = http.send(req);
		if(res.getStatusCode()==200) {
        	return JSON.serialize(((GitHubJob)JSON.deserialize(res.getBody(), GitHubJob.class)).steps);
        } else {
            throw new GitHubActionsException(res.getBody());
        }
    }

    // Method to get the logs for a job (curl 5)
    @AuraEnabled
    public static String getJobLogs(String jobId) {
        String endpoint = 'https://api.github.com/repos/cb-shivprasadpatil/lwc-test/actions/jobs/' + jobId + '/logs';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        
        // Set common headers
        Map<String, String> headers = getCommonHeaders();
        for (String key : headers.keySet()) {
            req.setHeader(key, headers.get(key));
        }

        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('res.getStatusCode())=='+res.getStatusCode());
		System.debug('res.getBody()=='+res.getHeader('Location'));
        
        return res.getHeader('Location');
    }
    
    private static String downloadLogs(String endpoint) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        
        // Set common headers
        Map<String, String> headers = new Map<String, String>();
        headers.put('Accept', 'application/vnd.github.v3+json');

        Http http = new Http();
        HttpResponse res = http.send(req);
        if(res.getStatusCode()==200) {
            System.debug('=='+res.getBody());
            return extractFinalResult(res);
        } else {
            throw new GitHubActionsException(res.getBody());
        }
    }
    
    private static String extractFinalResult(HttpResponse res) {
        Integer i = 0;
        for(String eachString : res.getBody().split('@@@')){
            if(i==1) {
                return eachString;
            }
            ++i;
        }
        return null;
    }
    
     public class GitHubActionsException extends Exception {}
}