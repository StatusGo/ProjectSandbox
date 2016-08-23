@isTest
public class TestcloneNewProjectScheduleExtn{

     static TestMethod void cloneNewProjectSchedule_UnitTest(){
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
		 ApexPages.CurrentPage().getparameters().put('id',ps.Id);
		 ApexPages.StandardController asp = new ApexPages.StandardController(ps);
		 cloneNewProjectScheduleExtn cnps = new cloneNewProjectScheduleExtn(asp);
		 //cnps.currentProjectScheduleId= ''+ps.Id;
		 cnps.CurrentProjectSchedule = ps;
		 cnps.SelectedProject = ''+pr.id;
		 cnps.selectStatus=true;
		 cnps.selectStartDate=false;
		 cnps.selectOwner=true;
		 cnps.selectDueDate=false;
		 cnps.selectSortOrder=true;
		 cnps.selectActualDate=true;
		 cnps.Cancel();
		 cnps.getavailableProjects();
		 cnps.DeepcloneSchedule();
	 }
}