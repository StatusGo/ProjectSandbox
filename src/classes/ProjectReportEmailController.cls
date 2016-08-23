public class ProjectReportEmailController{    
/***
** ProjectReportEmailController.
** (VF-page) : SendEmailVFPage.
** @test : ProjectReportEmailControllerTest.
*/
    public String searchStr{get;set;}
    public List<contact> conList{get;set;}
    public String searchStrTo{get;set;}
    public List<contact> conList1{get;set;}
    
    public String returnString{get;set;}
    public String projectId{get;set;} 
    public String projectName{get;set;}
    public Project_Action_Item__c ProAction{get;set;}
    public List<Project_Action_Item__c> projectActionList{get;set;}
    public List<wrapProjectData> wrpList{get;set;}
    public EmailTemplate templateId;
    public String statusRepID {get;set;} 
    public List<Project__c> listProject {get;set;}
    public List<Project_Action_Item__c> ActionItem {get;set;}
    public Lead conLookUp {get;set;}
    public Lead conLookUp14 {get;set;}
    public boolean displayPopup {get; set;}     
    public SelectOption[] selectedContacts { get; set; }
    public SelectOption[] selectedContactsCC { get; set; }
    public SelectOption[] allContacts { get; set; }
    public SelectOption[] allContactsCC { get; set; }
    public String message { get; set; }
    public String messageCC { get; set; }
    //public String messageTo { get; set;}
    public String noteBody { get; set;}
    public set<Id> paiId;
    public List<Contact> contactList { get; set; }  
    public String taskWhoId{get;set;}
    public string sendtoID{get;set;}
    public set<id> selectedContactIdSet;
    public set<id> selectedContactIdSetCC;
    
    public ProjectReportEmailController(){
        conLookUp = new Lead();
        
        allContacts = new List<SelectOption>(); 
        allContactsCC = new List<SelectOption>();     
        selectedContacts = new List<SelectOption>();
        selectedContactsCC = new List<SelectOption>();
        selectedContactIdSet = new set<id>();
        selectedContactIdSetCC = new set<id>();
        
        ProAction = new Project_Action_Item__c();
        
        System.debug('searchStr...>>>'+searchStr);        
        System.debug('conList...>>>'+conList); 
        System.debug('searchStrTo...>>>'+searchStrTo);        
        System.debug('conList1...>>>'+conList1); 
        
        contactList = [SELECT Name, Id, email FROM Contact where email!=:null];
        List<Contact> contacts = [SELECT Name, Id, email FROM Contact where email!=:null ORDER BY Name ASC NULLS LAST];
        
        for ( Contact c : contacts ) {
            allContacts.add(new SelectOption(c.Id, c.name));
            allContactsCC.add(new SelectOption(c.Id, c.name));
        }
        System.debug('allContacts...>>>'+allContacts);  
                
            wrpList = new List<wrapProjectData>();
            projectActionList = new List<Project_Action_Item__c>();
            projectId = ApexPages.CurrentPage().getparameters().get('id');
            System.debug('projectId...>>>'+projectId);
            
            if(projectId != null){
                projectName = [select id,name from Project__c where id=:projectId].name;
                System.debug('projectName...'+projectName);
            }
            
        projectActionList = [select id,Name,Owner__c,Owner__r.name,Owner__r.email,Project__r.Account__c, Status__c,Action_Description__c,Commit_Date__c from Project_Action_Item__c where Project__c =: projectId AND Status__c IN('Open','In Progress')];
            System.debug('projectActionList...'+projectActionList);
            

            for(Project_Action_Item__c proj : projectActionList){
                wrapProjectData wpd = new wrapProjectData();
                wpd.relActionItemName = proj.Name;
                wpd.ownerName = proj.Owner__r.name;
                wpd.Statusc = proj.Status__c;
                wpd.ActionDescription = proj.Action_Description__c;
                wpd.CommitDate = proj.Commit_Date__c;
                wpd.accId = proj.Project__r.Account__c;
                wpd.conId = proj.Owner__c;
                wpd.ccEmail = proj.Owner__r.email;
                wpd.pai = proj.Id;
                wrpList.add(wpd);
            }
            System.debug('wrpList...>>>'+wrpList);
        
    }

    public void srchContact1(){
        selectedContactIdSet = new set<id>();
        for ( SelectOption so : selectedContacts ) {
            selectedContactIdSet.add(so.getvalue());
        }
        conList1 = New List<contact>();
        allContacts = new List<SelectOption>();     
        if(searchStrTO.length() > 1){
            String searchStr2 = '%'+searchStrTo+'%';
            if(selectedContactIdSet.size() != 0){
                conList1 = [SELECT Id, name FROM Contact WHERE name LIKE: searchStr2 AND Id NOT IN: selectedContactIdSet];      
                if(conList1.size() == 0){
                    apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Sory, no results returned with matching string..'));
                    return;
                }   
                for ( Contact c : conList1 ) {
                    allContacts.add(new SelectOption(c.Id, c.name));
                }   
            }else{
                conList1 = [SELECT Id, name FROM Contact WHERE name LIKE: searchStr2];      
                if(conList1.size() == 0){
                    apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Sory, no results returned with matching string..'));
                    return;
                }   
                for ( Contact c : conList1 ) {
                    allContacts.add(new SelectOption(c.Id, c.name));
                }
            }           
            
        }
        else{
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter at least two characters..'));
            return;
        }
        
    } 
    
    public void srchContact(){
        selectedContactIdSetCC = new set<id>();
        for ( SelectOption so : selectedContactsCC ) {
            selectedContactIdSetCC.add(so.getvalue());
        }
        conList = New List<contact>();
        allContactsCC = new List<SelectOption>();       
        if(searchStr.length() > 1){
            String searchStr1 = '%'+searchStr+'%';
            if(selectedContactIdSetCC.size() != 0){
                conList = [SELECT Id, name FROM Contact WHERE name LIKE: searchStr1 AND Id NOT IN: selectedContactIdSetCC];
                if(conList.size() == 0){
                    apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Sory, no results returned with matching string..'));
                    return;
                }
                for ( Contact c : conList ) {
                    allContactsCC.add(new SelectOption(c.Id, c.name));
                }
                
            }else{
                conList = [SELECT Id, name FROM Contact WHERE name LIKE: searchStr1];       
                if(conList.size() == 0){
                    apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Sory, no results returned with matching string..'));
                    return;
                }   
                for ( Contact c : conList ) {
                    allContactsCC.add(new SelectOption(c.Id, c.name));
                }
            }

        }
        else{
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter at least two characters..'));
            return;
        }
        
    } 

 
    public Pagereference sendEmail(){ 
    /* try{ */
        /* System.debug('Selected contact>>>>>>>>>>>>>>>>>>...>>>'+conLookUp.Assigned_Salesforce_AE__c);
        if(conLookUp.Assigned_Salesforce_AE__c != null){
             messageTo = [SELECT Id, email FROM Contact where id =: conLookUp.Assigned_Salesforce_AE__c].email;
        }
        System.debug('Selected contact email>>>>>>>>>>>>>>>>>>...>>>'+messageTo); */
/* 
messageTo
*/      
            /* if(messageTo == null || messageTo ==''){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Please enter To Address');
                ApexPages.addMessage(myMsg);
                return null; 
            }else if(!Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}', messageTo)){
                ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,'Plesae enter valid email address');
                ApexPages.addMessage(myMsg1);
                return null;                 
            } */
       
                List<String> MailAddtionAdd = new List<String>();
                List<String> ccAddresses = new List<String>();            

                string AscId = '';
                System.debug('wrpList..'+wrpList);
                listProject = [SELECT Id, Account__c,Account__r.name,Project_Manager__r.Name FROM Project__c where id =: projectId ];
                date dateForCommit = system.today();
                string projectManagerName= '';
                string Subject= '';
           
                for(Project__c pr : listProject){
                    if(pr.Project_Manager__r.Name !=null && pr.Project_Manager__r.Name !=''){
                        projectManagerName = pr.Project_Manager__r.Name;
                        if(pr.Account__r.name!=null)
                        Subject = pr.Account__r.name;
                    }
                } 
                Boolean first = true; 
                list<wrapProjectData> wrplistData  =new list<wrapProjectData>();
                for(wrapProjectData wrpl : wrpList){ 
                    System.debug('selected...>>'+wrpl.selected);
                    if(wrpl.selected == true){
                        wrplistData.add(wrpl);
                        if (!first) {   
                            AscId += ',';
                        }                       
                        AscId += wrpl.pai;
                      first = false;
                    }
                }
                
                if(wrplistData.size()==0){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Please select an Action Item.');
                    ApexPages.addMessage(myMsg);
                    return null;
                    
                }
                
                List<String> ActionItemvalues = new  List<String>();
                ActionItemvalues =  AscId.split(',');
                List<Project_Action_Item__c> ActionItem = new List<Project_Action_Item__c>();
                if(ActionItemvalues.size()>0){
                    ActionItem = [select id,Name,Owner__c,Owner__r.name,Owner__r.email,Project__r.Account__c ,Status__c,Action_Description__c,Commit_Date__c from Project_Action_Item__c Where Id IN:ActionItemvalues];
                }
                String paiStatus = '';
                String paiOwnName = '';
                String paiDescription = '';
                String paiComtDt = '';
                
                for(Project_Action_Item__c pai : ActionItem){
                    paiStatus += pai.Status__c + '\n';
                    paiOwnName += pai.Owner__r.name + '\n';
                    paiDescription += pai.Action_Description__c + '\n';
                    paiComtDt += pai.Commit_Date__c + '\n';
                }
                String paiDetai = 'Action Items Detail:\n'+'Status \n'+paiStatus+'\nOwner \n'+paiOwnName+'\nDescription \n'+paiDescription+'\nCommit Date \n'+paiComtDt;
                
                
                
                PageReference pageRef = page.ProjectActionItemsFollowUp;
                    pageRef.getParameters().put('projectMNAme',projectManagerName);
                    pageRef.getParameters().put('accId',AscId);                 
                    pageRef.getParameters().put('noteBody',noteBody);
                    blob body;
                
                if (Test.IsRunningTest()){
                    body=Blob.valueOf('UNIT.TEST');
                }
                else{
                    body = pageRef.getContent();
                }
            
                String htmlBody = body.toString();
                if(message != null && message != ''){  
                    MailAddtionAdd = message.split(','); 
                }
             
                //MailAddtionAdd.add(messageTo);
                
                //MailAddtionAdd.add(messageToadd);
                
                system.debug('>>>>>>>>>MailAddtionAdd'+MailAddtionAdd);
                if(messageCC != null && messageCC != ''){ 
                    ccAddresses = messageCC.split(',');
                } 
                system.debug('>>>>>>>>>ccAddresses'+ccAddresses);
            
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(MailAddtionAdd.size()>0){
                    email.setToAddresses(MailAddtionAdd);
                }
                if(ccAddresses.size()>0){
                   email.setccAddresses(ccAddresses);
                }
                string psSubject;
                if(Subject!=''){
                psSubject = 'Status:Go | '+ Subject +' Action Items Follow up';
                }
                else{
                psSubject='Status:Go | '+'Action Items Follow up';
                }
            
                //////////////////////////////////////////////////////////////////////        
                email.setSubject(psSubject);   
                email.setHtmlBody(htmlBody);
                try{
                   List<Messaging.SendEmailResult>  results =   Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
                    if(results.size()>0){
                        String descData='';
                        
                        returnString = 'E-mail has been sent.';
                        Task task=new Task();
/**Contact as WhoId*/       task.WhoId = taskWhoId;     
/* Project as WhatId*/      task.WhatId = projectId;    
                            task.Subject = psSubject;
                            task.Status = 'Completed';
                            task.ActivityDate = system.today();
                            task.Priority = 'Normal';
                            
                            task.Description = 'Project Manager: '+ projectManagerName +'\n'+'To: '+message+'\n'+'CC: ' + messageCC+'\n'+'Notes :' + noteBody+'\n'+'Subject :' + psSubject+'\n\n'+paiDetai ;
                        insert task; 

                    } else {
                        returnString = 'E-mail has been faild.';
                        
                    }

                    System.debug('sendtoID'+sendtoID);                  
                   
                }catch(Exception e){
                    ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid email address!');
                    ApexPages.addMessage(myMsg1);
                    return null; 
                    
                }
        return null;
        
          
    }
        
    public Pagereference cancel(){
        if(projectId!=null){
        pageReference page = new Pagereference('/'+projectId);
        return page;
        }
        return null;
    }
    
    public void showPopup() {        
        displayPopup = true;    
    }
    public void cancelPopup() {        
        displayPopup = false; 
                
    }
    
    public void showPopupTo() { 
        conList1 = New List<contact>();
                
            if(selectedContactIdSet.size() != 0){
                conList1 = [SELECT Id, name FROM Contact WHERE Id NOT IN: selectedContactIdSet];
                allContacts = new List<SelectOption>();
                for ( Contact c : conList1 ) {
                    allContacts.add(new SelectOption(c.Id, c.name));
                }   
            }           
            
        searchStrTO ='';
        displayPopup = true;    
    }
    public void showPopupCc() { 
        conList = New List<contact>();
                
            if(selectedContactIdSetCC.size() != 0){
                conList = [SELECT Id, name FROM Contact WHERE Id NOT IN: selectedContactIdSetCC];
                allContactsCC = new List<SelectOption>();
                for ( Contact c : conList ) {
                    allContactsCC.add(new SelectOption(c.Id, c.name));
                }   
            }           
            
        searchStr ='';
        displayPopup = true;    
    }
    public void saveNclosePopupTO() {        
        message = '';
        selectedContactIdSet = new set<id>();
        for ( SelectOption so : selectedContacts ) {
            selectedContactIdSet.add(so.getvalue());
        }

        list<contact> con = [SELECT Name, Id, email FROM Contact where email!=:null AND id in:selectedContactIdSet];
        Boolean first = true;
        for ( contact c: con) {
            if (!first) {
                message += ', ';
            }
            message += c.email;
            first = false;
        }
        displayPopup = false;    
    }
    public void saveNclosePopupCc() {        
        messageCC='';
        selectedContactIdSetCC = new set<id>();
        for ( SelectOption so : selectedContactsCC ) {
            selectedContactIdSetCC.add(so.getvalue());
        }
        list<contact> con = [SELECT Name, Id, email FROM Contact where email!=:null AND id in:selectedContactIdSetCC];
        Boolean first = true;
        for ( contact c: con) {
            if (!first) {
                messageCC += ', ';
            }
            messageCC += c.email;
            first = false;
        }
        displayPopup = false;    
    }
    
    public class wrapProjectData{
        public Boolean selected {get; set;}
        public String relActionItemName{get; set;}
        public String ownerName{get; set;}
        public String Statusc{get; set;}
        public String ActionDescription{get; set;}
        public Date CommitDate{get; set;}
        public Id accId{get; set;}
        public Id conId{get; set;}
        public String ccEmail{get; set;}
        public Id pai{get;set;}
        public wrapProjectData(){
        selected = false;
        }
    }

}