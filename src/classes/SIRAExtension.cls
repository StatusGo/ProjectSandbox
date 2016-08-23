public with sharing class SIRAExtension {

    public List<Case> cases{get;set;}
    public List<SIRA_Time_Entry__c> timeEntries{get;set;}
    public String ticketId{get;set;}
    public String entryId{get;set;}
    public Boolean editMode{get;set;}
    public String sectionName{get;set;}
    public SIRA_Time_Entry__c tEntry{get;set;}
    public String userID;
    public List<User> users{get;set;}
    public List<SelectOption> options;
    
    public SIRAExtension(ApexPages.StandardController controller) {
        //get my timesheets
        userID=UserInfo.getUserId();
        GetCases();
    }
    
    public void GetCases(){
        cases=new List<Case>();
        timeEntries=new List<SIRA_Time_Entry__c>();
        String q='SELECT Id, CaseNumber,Status,Estimate__c, Total_Variance__c,Billable_Variance__c, NonBillable_Hours_Logged__c,Billable_Hours_Logged__c,Total_Hours_Logged__c,Contact.Name,Account.Name,Project__c,Project__r.Name FROM Case WHERE OwnerId=:selectedUser AND Total_Hours_Logged__c>0';
        cases=Database.query(q);
    }
    
    public List<SelectOption> getOptions(){
        users = Database.query('SELECT Id, FirstName, LastName FROM User');
        options = new List<SelectOption>();
        for(User u : users){
            options.add(new SelectOption(u.Id,u.FirstName + ' ' + u.LastName));
        }
        system.debug(options);
        return options;
    }
    
    public String selectedUser{
        get{
            if(selectedUser==null)
                selectedUser=userID;
            return selectedUser;
        }
        set;
    }

    public PageReference GetTimeEntries(){
        timeEntries = new List<SIRA_Time_Entry__c>();
        String q='SELECT Id, Date_Worked__c, Name, Hours__c, Minutes__c, Calculated_Time__c, SIRA_Ticket__c, Time_Entry_Role__c,Details__c FROM SIRA_Time_Entry__c WHERE SIRA_Ticket__c=:ticketId AND CreatedById=:selectedUser';
        timeEntries=Database.query(q);
        return null;
    }
    
    public PageReference EditRow(){
        //editMode=true;
        Map<Id,SIRA_Time_Entry__c> entries = new Map<Id,SIRA_Time_Entry__c>();
        entries.putAll(timeEntries);
        tEntry = entries.get(entryId);
        sectionName='Editing Entry - ' + tEntry.Name;
        //system.debug(editMode);
        return null;
    }
    
    public void saveTime(){
        try{
            update tEntry;
            GetTimeEntries();
            closeTime();
        } catch(Exception ex){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            ApexPages.addMessage(msg);
        }
    }
    
    public void closeTime(){editMode=false;}
}