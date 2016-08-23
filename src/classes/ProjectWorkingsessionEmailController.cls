public class ProjectWorkingsessionEmailController{    
/***
** ProjectWorkingsessionEmailController.
** (VF-page) : ProjectWorkingsessionEmailPage.

*/
	//public String searchStr{get;set;}
	//public List<contact> conList{get;set;}
	//public List<contact> conList1{get;set;}
	public String searchStrTo{get;set;}
	public String searchStrCC{get;set;}
	
	
    public String returnString{get;set;}
    public String projectwsId{get;set;} 
    public String projectwsName{get;set;}
    public Project_Action_Item__c ProAction{get;set;}
    public List<Project_Action_Item__c> projectActionList{get;set;}
    public List<wrapProjectData> wrpList{get;set;}
    public EmailTemplate templateId;
    public String statusRepID {get;set;} 
    public List<Project_Working_Session__c> listProject {get;set;}
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
    public String noteBody { get; set;}
    public set<Id> paiId;
    //public List<Contact> contactList { get; set; }  
    public String taskWhoId{get;set;}
    public string sendtoID{get;set;}
	public set<id> selectedContactIdSetTo;
	public set<id> selectedContactIdSetCC;
    
    public ProjectWorkingsessionEmailController(){
        conLookUp = new Lead();
        allContacts = new List<SelectOption>();
		selectedContactIdSetTo = new set<id>();
		allContactsCC = new List<SelectOption>();
		selectedContactIdSetCC = new set<id>();
        selectedContacts = new List<SelectOption>();
        selectedContactsCC = new List<SelectOption>();
        ProAction = new Project_Action_Item__c();
        
		//System.debug('searchStr...>>>'+searchStr);        
		//System.debug('conList...>>>'+conList); 
		System.debug('searchStrTo...>>>'+searchStrTo);        
		//System.debug('conList1...>>>'+conList1); 
		
        //contactList = [SELECT Name, Id, email FROM Contact where email!=:null];
        List<Contact> contacts = [SELECT Name, Id, email FROM Contact where email!=:null ORDER BY Name ASC NULLS LAST];
		for ( Contact c : contacts ) {
			allContacts.add(new SelectOption(c.Id, c.name));
			allContactsCC.add(new SelectOption(c.Id, c.name));
        }
        System.debug('allContacts...>>>'+allContacts);	
		        
            wrpList = new List<wrapProjectData>();
            projectActionList = new List<Project_Action_Item__c>();
            projectwsId = ApexPages.CurrentPage().getparameters().get('id');
            System.debug('projectwsId...>>>'+projectwsId);
            
            if(projectwsId != null){
                projectwsName = [select id,name from Project_Working_Session__c where id=:projectwsId].name;
                System.debug('projectwsName...'+projectwsName);
            }
           
        projectActionList = [select id,Name,Owner__c,Owner__r.name,Owner__r.email,Project__r.Account__c, Status__c,Action_Description__c,Commit_Date__c from Project_Action_Item__c where Project_Working_Session__c =: projectwsId AND Status__c IN('Open','In Progress')];
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

	public void srchContactTo(){
		selectedContactIdSetTo = new set<id>();
        for ( SelectOption so : selectedContacts ) {
            selectedContactIdSetTo.add(so.getvalue());
        }
		List<contact> TempConList = New List<contact>();
        allContacts = new List<SelectOption>();		
		if(searchStrTO.length() > 1){
			String searchStrngTo = '%'+searchStrTo+'%';
			if(selectedContactIdSetTo.size() != 0){
				TempConList = [SELECT Id, name FROM Contact WHERE name LIKE: searchStrngTo AND Id NOT IN: selectedContactIdSetTo];		
				if(TempConList.size() == 0){
					apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Sory, no results returned with matching string..'));
					return;
				}	
				for ( Contact c : TempConList ) {
					allContacts.add(new SelectOption(c.Id, c.name));
				}	
			}else{
				TempConList = [SELECT Id, name FROM Contact WHERE name LIKE: searchStrngTo];		
				if(TempConList.size() == 0){
					apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Sory, no results returned with matching string..'));
					return;
				}	
				for ( Contact c : TempConList ) {
					allContacts.add(new SelectOption(c.Id, c.name));
				}
			}			
			
		}
		else{
			apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter at least two characters..'));
			return;
		}
		
	} 

	
	public void srchContactCc(){
		selectedContactIdSetCC = new set<id>();
        for ( SelectOption so : selectedContactsCC ) {
            selectedContactIdSetCC .add(so.getvalue());
        }
		List<contact> TempConList = New List<contact>();
        allContactsCC = new List<SelectOption>();		
		if(searchStrCC.length() > 1){
			String searchStrngCc = '%'+searchStrCC+'%';
			if(selectedContactIdSetCC.size() != 0){
				TempConList = [SELECT Id, name FROM Contact WHERE name LIKE: searchStrngCc AND Id NOT IN: selectedContactIdSetCC];
				if(TempConList.size() == 0){
					apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Sory, no results returned with matching'));
					return;
				}
				for ( Contact c : TempConList ) {
					allContactsCC.add(new SelectOption(c.Id, c.name));
				}
				
			}else{
				TempConList = [SELECT Id, name FROM Contact WHERE name LIKE: searchStrngCc];		
				if(TempConList.size() == 0){
					apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Sory, no results returned with matching string..'));
					return;
				}	
				for ( Contact c : TempConList ) {
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
                listProject = [SELECT Id,Project__r.Account__c,Date__c,Project__r.Account__r.name,Project__r.Project_Manager__r.Name FROM Project_Working_Session__c where id =: projectwsId ];
                date dateForCommit = system.today();
                string projectManagerName= '';
                string Subject= '';
				Date prodate;
				String dateStr='';
                for(Project_Working_Session__c pr : listProject){
                    if(pr.Project__r.Project_Manager__r.Name !=null && pr.Project__r.Project_Manager__r.Name !=''){
                        projectManagerName = pr.Project__r.Project_Manager__r.Name;
					}
						if(pr.Project__r.Account__r.name!=null){
                        Subject = pr.Project__r.Account__r.name;
                    }
					if(pr.Date__c != null){
					prodate=pr.Date__c;
					Integer month  = prodate.month();
					Integer year  = prodate.Year();
					Integer Day = prodate.Day();
					dateStr = ''+month+'/'+Day+'/'+ year;
					}
                } 
                Boolean first = true; 
                list<wrapProjectData> wrplistData  =new list<wrapProjectData>();
                for(wrapProjectData wrpl : wrpList){ 
                    System.debug('selected...>>'+wrpl.selected);
                       wrplistData.add(wrpl);
                        if (!first) {   
                            AscId += ',';
                        }                       
                        AscId += wrpl.pai;
                      first = false;
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
                
                
                
                PageReference pageRef = page.projWorkingSessionEmailTemplatePage;
                   pageRef.getParameters().put('id',projectwsId);
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
				string wssubject;
				
				wssubject = 'Status:Go';
				if(Subject!=''){
				wssubject+=' | '+Subject ;
				}
				wssubject+= ' | '+'Project Working Session Summary';
				if(dateStr!=''){
				wssubject+=' | '+ dateStr;
				}
				
				
                //////////////////////////////////////////////////////////////////////        
                email.setSubject(wssubject);   
                email.setHtmlBody(htmlBody);
                try{
                   List<Messaging.SendEmailResult>  results =   Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
                    if(results.size()>0){
                        String descData='';
                        
                        returnString = 'E-mail has been sent.';
                        Task task=new Task();
/**Contact as WhoId*/       task.WhoId = taskWhoId;     
/* Project as WhatId*/      task.WhatId = projectwsId;    
                            task.Subject = wssubject;
                            task.Status = 'Completed';
                            task.ActivityDate = system.today();
                            task.Priority = 'Normal';
                            
                            task.Description = 'Project Manager: '+ projectManagerName +'\n'+'To: '+message+'\n'+'CC: ' + messageCC+'\n'+'Notes :' + noteBody+'\n'+'Subject :' +wssubject+'\n\n'+paiDetai ;
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
        if(projectwsId!=null){
        pageReference page = new Pagereference('/'+projectwsId);
        return page;
        }
        return null;
    }
    
    public void showPopupTo() {        
		List<contact> TempConList = New List<contact>();	
			if(selectedContactIdSetTo.size() != 0){
				TempConList = [SELECT Id, name FROM Contact WHERE Id NOT IN: selectedContactIdSetTo];			
				allContacts = new List<SelectOption>();
				for ( Contact c : TempConList ) {
					allContacts.add(new SelectOption(c.Id, c.name));
				}	
			}			
		searchStrTO ='';
        displayPopup = true;
    }
	public void showPopupCc() {        
		List<contact> TempConList = New List<contact>();	
			if(selectedContactIdSetCC.size() != 0){
				TempConList = [SELECT Id, name FROM Contact WHERE Id NOT IN: selectedContactIdSetCC];			
				allContactsCC = new List<SelectOption>();
				for ( Contact c : TempConList ) {
					allContactsCC.add(new SelectOption(c.Id, c.name));
				}	
			}			
		searchStrCC ='';
        displayPopup = true;
    }
    public void cancelPopup() {        
        displayPopup = false;    
    }
    
    public void saveNclosePopupTO() {        
        message = '';
        selectedContactIdSetTo = new set<id>();
        for ( SelectOption so : selectedContacts ) {
            selectedContactIdSetTo.add(so.getvalue());
        }

        list<contact> con = [SELECT Name, Id, email FROM Contact where email!=:null AND id in:selectedContactIdSetTo];
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
            selectedContactIdSetCC .add(so.getvalue());
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