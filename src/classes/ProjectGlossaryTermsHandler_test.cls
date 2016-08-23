@isTest
public class ProjectGlossaryTermsHandler_test {
    
    private static testMethod  void ProjectGlossaryTermsHandler_UNITest(){

		Account acc = new Account();                
			acc.Name = 'test_NAME';
			insert acc;
       
        Project__c proj = new Project__c();
			proj.Name = 'test_NAME';
			proj.Budget__c = 600.00;
			proj.Budget_Hours__c = 10.00;
			proj.Account__c = acc.Id;
			insert proj;

        Project__c newProj = new Project__c();
			newProj.Name = 'testNAME';
			newProj.Budget__c = 600.00;
			newProj.Budget_Hours__c = 10.00;
			newProj.Account__c = acc.Id;
			insert newProj;
			
        Project_Glossary_Term__c proGT = new Project_Glossary_Term__c();		
			proGT.Term__c = 'test_TERM';
			proGT.Project__c = proj.Id;
			insert proGT;

			proGT.Term__c = 'test_TERM';			
			proGT.Project__c = newProj.Id;
			update proGT;
			
    } 

}