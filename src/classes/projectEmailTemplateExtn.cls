public class projectEmailTemplateExtn {
    public String statusRepID {get;set;} 
    public String imageURL {get;set;} 
    public List<Project__c> listProject = new List<Project__c>(); 
    public List<Project_Action_Item__c> ActionItem = new List<Project_Action_Item__c>();
    public set<string> actionItemProject = new set<string>();
    public String projectId ;
    
    public projectEmailTemplateExtn(){
        projectId = ApexPages.CurrentPage().getparameters().get('id');
        System.debug('insdide projectEmailTemplateExtn');
        Image_URL__c imc = Image_URL__c.getInstance('Email Template Logo');
        if(imc.StatusGo_Green_Logo__c != null){
            imageURL = imc.StatusGo_Green_Logo__c ;         
        }       
    }
    
    public List<Project__c> getlistProject(){
        listProject = [SELECT Id, Project_Manager__r.Name FROM Project__c where id =: projectId];
            system.debug('listprojStatusReport__________'+listProject);
            
        return listProject;
    }
    
    public List<Project_Action_Item__c> getActionItem(){

            date dateForCommit = system.today();
            ActionItem = [select id,Name,Owner__c,Owner__r.name,Owner__r.email,Project__r.Account__c ,Status__c,Action_Description__c,Commit_Date__c from Project_Action_Item__c where Project__c =: projectId];
                
            system.debug('ActionItem__________'+ActionItem);
            return ActionItem;

    }
    
}