@isTest
private class projectEmailTemplateExtnTest {
    static testMethod void test1() {
        Account acc = new Account(Name = 'testAccount');
        INSERT acc;
        
        Contact con = new Contact(FirstName = 'Test1', LastName = 'Test',AccountId = acc.id,email = 'test45@user.com');
		INSERT con;
        		
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='stup@org.com');

		Lead le = new Lead();
			le.LastName= 'test';
			le.Status= 'Open';
			le.Company= 'testComp';
			le.Assigned_Salesforce_AE__c= con.Id;
			insert le;
		list<contact> conlist = [select id,email from contact where id=:le.Assigned_Salesforce_AE__c];	
        Project__c pr = new Project__c(Account__c = acc.id, Project_Manager__c = u.id, Name = 'test', Budget__c = 123.00, Budget_Hours__c = 12.00);
        INSERT pr;

		Task t = new Task(WhatId = pr.id,Subject= 'Call' ,Status ='Completed');
		insert t;		
		
        Project_Schedule__c ps = new Project_Schedule__c(Project__c = pr.Id);
        INSERT ps;

        
		Project_Action_Item__c pai = new Project_Action_Item__c(Status__c = 'Open', Action_Description__c = 'test', Commit_Date__c = System.today(),Project__c = pr.id);
		INSERT pai;
		
		Image_URL__c IU = new Image_URL__c(Name = 'Email Template Logo');
		insert IU;
		
		
		

        apexpages.currentpage().getparameters().put('id', pr.id);
       
        projectEmailTemplateExtn prec = new projectEmailTemplateExtn();		 
		prec.getlistProject();	
		prec.getActionItem();	
	
		
	} 

}