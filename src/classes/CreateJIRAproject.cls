global class CreateJIRAproject {
    
    WebService static String jiraproject(String prokey,String proname) { 
         String ResponceMessage;
        String username = 'development';
        String password = 'Jharkhand1';
        string ProjectKey = prokey;
        string name = proname;
        string projectTypeKey = 'business';
        string description = 'Example Project description';
        string lead = 'Swati';
        string url = 'http://atlassian.com';
        string assigneeType = 'PROJECT_LEAD';
        
        String jiraURL = 'https://chanchalaa.atlassian.net/rest/api/2/project';
        
          
        //Construct HTTP request and response
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
  
        //Construct Authorization and Content header
        Blob headerValue = Blob.valueOf(username+':'+password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type','application/json'); 
        //Construct Endpoint  
        req.setMethod('POST');
        req.setEndpoint(jiraURL);
         req.setBody('{\"key\": \"'+ProjectKey+'\",\"name\": \"'+name+'\",\"projectTypeKey\": \"'+projectTypeKey+'\",\"description\": \"'+description+'\",\"lead\": \"'+lead+'\",\"url\": \"'+ url+'\",\"assigneeType\": \"'+assigneeType+'\"}');
        req.setTimeout(120000);
          
        try {
            //Send endpoint to JIRA
            res = http.send(req);
            System.debug(res.getBody());
            System.debug(res.getStatuscode()); 
            String jsonString = res.getBody();
            if(res.getStatuscode() == 201){
                return ResponceMessage = 'Prject '+name+' successfully created';
            } 
            
             JSON2Apex parseObj = CreateJIRAproject.parse(jsonString);
             if(parseObj.Errors.projectKey != null){ 
                return parseObj.Errors.projectKey;
             }else if(parseObj.Errors.projectLead != null){
                 return ResponceMessage = parseObj.Errors.projectLead;
                 
             }else if(parseObj.Errors.projectName != null){
                 return ResponceMessage = parseObj.Errors.projectName; 
             }
            
        } catch(System.CalloutException e) {
            System.debug('ERROR:' + e);
            System.debug(res.toString());
        } 
        return null;
    }
    
    public class JSON2Apex {
        public Errors Errors;
        public JSON2Apex(){
            Errors = new Errors();
        }
    }

    public class Errors {
        public String projectKey;
        public String projectLead;
        public String projectName;
    } 
    
    public static JSON2Apex parse(String json) {
        return (JSON2Apex) System.JSON.deserialize(json, JSON2Apex.class);
    }
     
}