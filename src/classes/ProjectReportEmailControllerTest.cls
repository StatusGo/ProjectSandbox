@isTest
private class ProjectReportEmailControllerTest {
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

        Project_Schedule_Task__c pst = new Project_Schedule_Task__c(Name = 'test1',Project_Schedule__c = ps.Id);
        INSERT pst;
		
		Project_Action_Item__c pai = new Project_Action_Item__c(Status__c = 'Open', Action_Description__c = 'test', Commit_Date__c = System.today(),Project__c = pr.id);
		INSERT pai;
		
		Project_Action_Item__c pai1 = new Project_Action_Item__c(Status__c = 'Open', Action_Description__c = 'test', Commit_Date__c = System.today(),Project__c = pr.id);
		INSERT pai1;
		
		string sactid = pai.id+','+pai1.id;
		

        apexpages.currentpage().getparameters().put('id', pr.id);
        apexpages.currentpage().getparameters().put('accId', sactid);
        ProjectReportEmailController prec = new ProjectReportEmailController();		 
			//prec.messageTo = 'test1@user.com';
			prec.messageCC = 'test1@user.com,test2@user.com,test3@user.com,test4@user.com';
			prec.message = 'test1@user.com,test2@user.com,test3@user.com,test4@user.com';
			prec.wrpList[0].selected = true;
			prec.sendEmail();
			//prec.messageTo ='test';
			prec.sendEmail();
			prec.cancel();
			prec.showPopup();
			prec.cancelPopup();
        prec.searchStr = 'Test';
        prec.searchStrTO ='test';
        prec.srchContact();
        prec.srchContact1();
		 prec.saveNclosePopupTO();
			prec.saveNclosePopupCc();
	
		ProjectReportEmailController.wrapProjectData pw = new ProjectReportEmailController.wrapProjectData();
			pw.selected = true;
			pw.relActionItemName ='qwert';
			pw.ownerName = 'qwert';
			pw.Statusc = 'qwert';
			pw.ActionDescription = 'qwert';
			pw.CommitDate = System.today();
			pw.accId = acc.id;
			pw.conId = con.id;
			pw.ccEmail = 'qwert';

	} 

}