@isTest
public class ExportProjectcontroller_Test{

     static TestMethod void ExportProjectcontroller_UnitTest(){
		 Project__c pr = new Project__c();
		 pr.Name = 'test';
		 pr.Budget__c = 123.00;
		 pr.Budget_Hours__c = 12.00;
		 insert pr;
		 
		 Project_Schedule__c ps = new Project_Schedule__c();
		 ps.Project__c = pr.Id;
		 insert ps;
		 
		 Project_Schedule_Task__c pst = new Project_Schedule_Task__c();
		 pst.Name = 'test1';
		 pst.Project_Schedule__c = ps.Id;
		 insert pst;

		 Image_URL__c cust = new Image_URL__c();
		 cust.Name = 'Email Template Logo';
		 cust.StatusGo_Green_Logo__c = 'www.statusgonow.com';
		 insert cust;
		 
		 ApexPages.CurrentPage().getparameters().put('id',ps.id);
		 ApexPages.StandardController asp = new ApexPages.StandardController(pst);
		 ExportProjectcontroller cnps = new ExportProjectcontroller(asp);
		 
	 }
}