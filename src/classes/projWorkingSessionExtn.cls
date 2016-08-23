public class projWorkingSessionExtn {
 
	public Id statusRepID {get;set;} 
    public String imageURL {get;set;} 
    public List<Project_Working_Session__c> listWorkingSessionReport = new List<Project_Working_Session__c>(); 
    public List<Project_Action_Item__c> ActionItem = new List<Project_Action_Item__c>();
    public set<string> actionItemProject = new set<string>();
	public List<String> ActionItemvalues = new  List<String>();
    public projWorkingSessionExtn(){
		statusRepID = ApexPages.CurrentPage().getparameters().get('id');
		string ActionItemId =   apexpages.currentpage().getparameters().get('accId');
			if(ActionItemId !=''){
				
				ActionItemvalues =  ActionItemId.split(',');
				system.debug(ActionItemvalues.size());
				system.debug(ActionItemvalues);
			 
				
			}	 
        Image_URL__c imc = Image_URL__c.getInstance('Email Template Logo');
        if(imc.StatusGo_Green_Logo__c != null){
            imageURL = imc.StatusGo_Green_Logo__c ;         
        }       
    }
    
    public List<Project_Working_Session__c> getlistWorkingSessionReport(){
        listWorkingSessionReport = [SELECT Id, Date__c, Notes__c, Next_Steps__c, Project__c, Participants__c, Summary__c, Project__r.Project_Manager__r.Name FROM Project_Working_Session__c where id =: statusRepID];
            system.debug('listprojStatusReport__________'+listWorkingSessionReport);
            for(Project_Working_Session__c listpro : listWorkingSessionReport){
                actionItemProject.add(listpro.Project__c);
                system.debug('actionItemProject__________'+actionItemProject);              
            }
        return listWorkingSessionReport;
    }
    
    public List<Project_Action_Item__c> getActionItem(){

            date dateForCommit = system.today();
            ActionItem = [SELECT Action_Description__c,Commit_Date__c,Owner__r.Name,Project_Working_Session__c,Project__c,Status__c,SystemModstamp FROM Project_Action_Item__c where Project__c =: actionItemProject AND Id In:ActionItemvalues AND Internal__c = false and Status__c != 'Complete' Order By Commit_Date__c ASC];
                
            system.debug('ActionItem__________'+ActionItem);
            return ActionItem;

    }
}