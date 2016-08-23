public class ProjectStatusReportEmailController{    
/***
** ProjectStatusReportEmailController.
** (VF-page) : ProjectStatusReportEmailPage.

*/
    public String searchStr{get;set;}
    public List<contact> conList{get;set;}
    public String searchStrTo{get;set;}
    public List<contact> conList1{get;set;}
    
    public String returnString{get;set;}
    public String projectsrId{get;set;} 
    public String projectsrName{get;set;}
    public Project_Action_Item__c ProAction{get;set;}
    public List<Project_Action_Item__c> projectActionList{get;set;}
    public List<wrapProjectData> wrpList{get;set;}
    public EmailTemplate templateId;
    public String statusRepID {get;set;} 
    public List<Project_Status_Report__c> listProject {get;set;}
    public List<Project_Status_Report__c> listProject1 {get;set;}
    public List<Project_Action_Item__c> ActionItem {get;set;}
    public Lead conLookUp {get;set;}
    public set<string> actionItemProjectid = new set<string>();
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
    
    public ProjectStatusReportEmailController(){
        conLookUp = new Lead();
        
        allContacts = new List<SelectOption>(); 
        allContactsCC = new List<SelectOption>();
        selectedContacts = new List<SelectOption>();
        selectedContactIdSet = new set<id>();
        selectedContactsCC = new List<SelectOption>();
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
            projectsrId = ApexPages.CurrentPage().getparameters().get('id');
            System.debug('projectsrId...>>>'+projectsrId);
            
            if(projectsrId != null){
                projectsrName = [select id,name from Project_Status_Report__c where id=:projectsrId].name;
                System.debug('projectsrName...'+projectsrName);
            }
            listProject1 = [SELECT Id, Project__r.Account__c,Project__r.Account__r.name,Project__r.Project_Manager__r.Name FROM Project_Status_Report__c where id =: projectsrId ];
             
             for(Project_Status_Report__c listpro : listProject1){
                actionItemProjectid.add(listpro.Project__c);
                system.debug('actionItemProjectid__________'+actionItemProjectid);              
            } 
        projectActionList = [select id,Name,Owner__c,Owner__r.name,Owner__r.email,Project__r.Account__c, Status__c,Action_Description__c,Commit_Date__c from Project_Action_Item__c where  Project__c =: actionItemProjectid AND Internal__c =false AND Status__c IN('Open','In Progress')];
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
     List<String> MailAddtionAdd = new List<String>();
                List<String> ccAddresses = new List<String>();            

                string AscId = '';
                System.debug('wrpList..'+wrpList);
                listProject = [SELECT Id,Project__r.Account__c,Project__r.Account__r.name,Project__r.Project_Manager__r.Name,From_Date__c,To_Date__c FROM Project_Status_Report__c where id =: projectsrId ];
                date dateForCommit = system.today();
                string projectManagerName= '';
                string Subject= '';
                Date Fromdate;
                Date Todate;
                String dateStr='';
                String dateStr1='';
           
                for(Project_Status_Report__c pr : listProject){
                    if(pr.Project__r.Project_Manager__r.Name !=null && pr.Project__r.Project_Manager__r.Name !=''){
                        projectManagerName = pr.Project__r.Project_Manager__r.Name;
                        }
                        if(pr.Project__r.Account__r.name!=null ){
                        Subject = pr.Project__r.Account__r.name;
                        }
                        
                    
                    Fromdate = pr.From_Date__c;
                    Integer month  = Fromdate.month();
                    Integer year  = Fromdate.Year();
                    Integer Day = Fromdate.Day();
                    dateStr = ''+month+'/'+Day+'/'+ year;
                    Fromdate=pr.From_Date__c;
                    Todate=pr.To_Date__c;
                    Integer month1  = Todate.month();
                    Integer year1  = Todate.Year();
                    Integer Day1 = Todate.Day();
                    dateStr1 = ''+month+'/'+Day+'/'+ year;
                    
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
                
                
                
                PageReference pageRef = page.ProjectStatusReportEmailTemplatePage;
                   pageRef.getParameters().put('id',projectsrId);
                    pageRef.getParameters().put('accId',AscId);     
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
                psSubject='Status:Go | '+ Subject +' |'+' Project Status Report | '+dateStr+' - '+ dateStr1;
                }
                else{
                psSubject='Status:Go | '+'Project Status Report | '+dateStr+' - '+ dateStr1;    
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
/* Project as WhatId*/      task.WhatId = projectsrId;    
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
        if(projectsrId!=null){
        pageReference page = new Pagereference('/'+projectsrId);
        return page;
        }
        return null;
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
    public void cancelPopup() {        
        displayPopup = false;    
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