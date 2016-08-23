public class ProjectReportEmailControllerdata {
/***
** ProjectReportEmailControllerdata.
** (VF-page) : ProjectReportEmailController.
** Related to(apex-Class) : ProjectActionItemsFollowup.
** @test : ProjectReportEmailControllerdataTest.
*/

	public String imageURL {get;set;} 
	public List<Project_Action_Item__c> ActionItem {get;set;}
	public String projectManagerName {get;set;} 
	public String noteBody {get;set;} 
  
	public ProjectReportEmailControllerdata(){
		projectManagerName =   apexpages.currentpage().getparameters().get('projectMNAme');
		string ActionItemId =   apexpages.currentpage().getparameters().get('accId');
		noteBody = apexpages.currentpage().getparameters().get('noteBody');
		system.debug(ActionItemId);
			if(ActionItemId !=''){
				List<String> ActionItemvalues = new  List<String>();
				ActionItemvalues =  ActionItemId.split(',');
				system.debug(ActionItemvalues.size());
				system.debug(ActionItemvalues);
				ActionItem = new List<Project_Action_Item__c>();
				if(ActionItemvalues.size()>0){
					ActionItem = [select id,Name,Owner__c,Owner__r.name,Owner__r.email,Project__r.Account__c ,Status__c,Action_Description__c,Commit_Date__c from Project_Action_Item__c Where Id IN:ActionItemvalues];
				}   
				System.debug('ActionItem..'+ActionItem.size());
			}  
			Image_URL__c imc = Image_URL__c.getInstance('Email Template Logo');
            if(imc.StatusGo_Green_Logo__c != null){
                imageURL = imc.StatusGo_Green_Logo__c ;         
            }
    }
}