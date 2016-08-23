@isTest
private class ProjectStatusReportEmailControllerTest {
    static testMethod void test1() {
        Account acc = new Account(Name = 'testAccount');
        INSERT acc;
        
        Contact con = new Contact(FirstName = 'Test1', LastName = 'Test',AccountId = acc.id,email = 'test45@user.com');
        INSERT con;
        
        Contact con1 = new Contact(FirstName = 'Test2', LastName = 'Test',AccountId = acc.id,email = 'test451@user.com');
        INSERT con1;
        
        Contact con2 = new Contact(FirstName = 'Test3', LastName = 'Test',AccountId = acc.id,email = 'test452@user.com');
        INSERT con2;
       
        
        Project__c pr = new Project__c(Account__c = acc.id, Name = 'test', Budget__c = 123.00, Budget_Hours__c = 12.00);
        INSERT pr;
        
        Project_Status_Report__c psr = new Project_Status_Report__c(From_Date__c  = Date.TOday(),To_Date__c = Date.TOday(),Project__c = pr.id);
        Insert psr;

        Project_Action_Item__c pai = new Project_Action_Item__c(Status__c = 'Open', Action_Description__c = 'test', Commit_Date__c = System.today(),Project__c = pr.id);
        INSERT pai;
        
        List<SelectOption> soList = new List<SelectOption>();
        soList.add(new SelectOption(con1.Id, con1.Id));
        soList.add(new SelectOption(con2.Id, con2.Id));
        
        apexpages.currentpage().getparameters().put('id' , psr.id);
        ProjectStatusReportEmailController psrec = new ProjectStatusReportEmailController();
        psrec.searchStrTo = 'es';
        psrec.searchStr = 'es';
        psrec.selectedContactsCC = soList;
        psrec.selectedContacts = soList;
        psrec.srchContact1();
        psrec.srchContact();
        psrec.sendEmail();
        psrec.cancel();
        psrec.showPopupTo();
        psrec.showPopupCc();
        psrec.cancelPopup();
        psrec.saveNclosePopupTO();
        psrec.saveNclosePopupCc();
                 
    }
  }