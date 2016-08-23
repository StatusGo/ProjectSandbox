@isTest
private class ProjectReportEmailControllerdataTest {
    static testMethod void test1() {
        Account acc = new Account(Name = 'testAccount');
        INSERT acc;
        
        Contact con = new Contact(LastName = 'Test',AccountId = acc.id);
        INSERT con;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='stup@org.com');
        
        Project__c pr = new Project__c(Account__c = acc.id, Project_Manager__c = u.id, Name = 'test', Budget__c = 123.00, Budget_Hours__c = 12.00);
        INSERT pr;

        Project_Schedule__c ps = new Project_Schedule__c(Project__c = pr.Id);
        INSERT ps;

        Project_Schedule_Task__c pst = new Project_Schedule_Task__c(Name = 'test1',Project_Schedule__c = ps.Id);
        INSERT pst;
		
		Project_Action_Item__c pai = new Project_Action_Item__c(Status__c = 'Open', Action_Description__c = 'test', Commit_Date__c = System.today());
		INSERT pai;
		
		Project_Action_Item__c pai1 = new Project_Action_Item__c(Status__c = 'Open', Action_Description__c = 'test', Commit_Date__c = System.today());
		INSERT pai1;
		
		string sactid = pai.id+','+pai1.id;
		
		Image_URL__c img = new Image_URL__c();
		img.name = 'Email Template Logo';
		img.StatusGo_Green_Logo__c ='test@test.com';
		insert img;
        apexpages.currentpage().getparameters().put('projectMNAme','Test');
        apexpages.currentpage().getparameters().put('accId',sactid);

        ProjectReportEmailControllerdata prec = new ProjectReportEmailControllerdata();
        

    }
}