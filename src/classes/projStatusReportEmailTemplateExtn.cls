public class projStatusReportEmailTemplateExtn {
    public Id statusRepID {get;set;} 
    public String imageURL {get;set;} 
    public List<Project_Status_Report__c> listprojStatusReport = new List<Project_Status_Report__c>(); 
    public List<Project_Action_Item__c> ActionItem = new List<Project_Action_Item__c>();
    public set<string> actionItemProject = new set<string>();

    public projStatusReportEmailTemplateExtn(){
        Image_URL__c imc = Image_URL__c.getInstance('Email Template Logo');
        if(imc.StatusGo_Green_Logo__c != null){
            imageURL = imc.StatusGo_Green_Logo__c ;         
        }       
    }
    
    public List<Project_Status_Report__c> getlistprojStatusReport(){
        listprojStatusReport = [SELECT Id, Accomplishments__c, Notes__c, From_Date__c, Next_Steps__c, To_Date__c ,Project__c, Project__r.Project_Manager__r.Name FROM Project_Status_Report__c where id =: statusRepID];
            system.debug('listprojStatusReport__________'+listprojStatusReport);
            for(Project_Status_Report__c listpro : listprojStatusReport){
                actionItemProject.add(listpro.Project__c);
                system.debug('actionItemProject__________'+actionItemProject);              
            }
        return listprojStatusReport;
    }
    
    public List<Project_Action_Item__c> getActionItem(){

            date dateForCommit = system.today();
            ActionItem = [SELECT Action_Description__c,Commit_Date__c,Owner__r.Name,Project_Working_Session__c,Project__c,Status__c,SystemModstamp FROM Project_Action_Item__c where Project__c =: actionItemProject AND Internal__c = false AND Status__c != 'Complete' Order By Commit_Date__c ASC];
                
            system.debug('ActionItem__________'+ActionItem);
            return ActionItem;

    }
    
}