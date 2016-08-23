@isTest
private class projStatusReportExtn_Test {
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

        Image_URL__c iu = new Image_URL__c(Name = 'Email Template Logo', StatusGo_Green_Logo__c = 'www.test.com');
        insert iu;

        apexpages.currentpage().getparameters().put('id' , psr.id);
        apexpages.currentpage().getparameters().put('accId',pai.Id);

        projStatusReportExtn psre = new projStatusReportExtn();
        psre.getlistprojStatusReport();
        psre.getActionItem();
    }
}