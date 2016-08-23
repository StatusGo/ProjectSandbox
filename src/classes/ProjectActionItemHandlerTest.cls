@isTest
public class ProjectActionItemHandlerTest{
	 testMethod static void ConstructorMethod(){
	 
	 
	 	Project__c pro=new 	Project__c();
		pro.Name='test';
		
		insert pro;
		
		
		 Project_Working_Session__c pws = new Project_Working_Session__c();
		 pws.Project__c =pro.id;
		 insert pws;
		 
		 Project_Action_Item__c pai=new Project_Action_Item__c();
		 pai.Status__c='Open';
		 pai.Commit_Date__c=system.today();
		 pai.Project_Working_Session__c=pws.id;
		 /* pai.Project__c=pro.id; */
		 insert pai;
		 update pai;
		 
		 
	 
	 }


}