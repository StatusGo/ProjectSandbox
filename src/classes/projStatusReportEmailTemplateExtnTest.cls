@isTest
public class projStatusReportEmailTemplateExtnTest {   

/* 
*   test
*   method for
*   projStatusReportEmailTemplateExtn  
*/
    private static TestMethod  void projStatusReportEmailTemplateExtn_UnitTest(){
    
    
        Image_URL__c setting = new Image_URL__c();
        setting.Name = 'Email Template Logo';
        setting.StatusGo_Green_Logo__c='https://c.cs41.content.force.com/servlet/servlet.ImageServer?id=01555000000DL3m&oid=00D550000006UTr&lastMod=1461139204000'; 
        insert setting;
        
        
        Project__c pro=new Project__c();
        pro.Name='test';
        pro.Budget__c=2300.00;
        pro.Budget_Hours__c=12;
        insert pro; 
        
        Project_Status_Report__c psr=new Project_Status_Report__c();
        psr.From_Date__c=system.today();
        psr.To_Date__c=system.today();
        psr.Next_Steps__c='test';
        psr.Project__c=pro.id; 
        psr.Accomplishments__c='test';
        insert psr;
    
     Project_Action_Item__c pai=new Project_Action_Item__c();
         pai.Status__c='Complete';
         pai.Commit_Date__c=system.today();
          pai.Project__c=pro.id;  
        insert pai;
    
   
    /* ApexPages.currentPage().getParameters().put('Id',pat.Id); */
    projStatusReportEmailTemplateExtn psret = new projStatusReportEmailTemplateExtn();
    psret.getlistprojStatusReport();
    psret.getActionItem();
    
    }  
    
/* 
*   test
*   method for
*   projWorkingSessionEmailTemplateExtn  
*/  

    private static TestMethod  void projWorkingSessionEmailTemplateExtn_UnitTest(){
    
    
        Image_URL__c setting = new Image_URL__c();
        setting.Name = 'Email Template Logo';
        setting.StatusGo_Green_Logo__c='https://c.cs41.content.force.com/servlet/servlet.ImageServer?id=01555000000DL3m&oid=00D550000006UTr&lastMod=1461139204000'; 
        insert setting;
        
        
        Project__c pro=new Project__c();
        pro.Name='test';
        pro.Budget__c=2300.00;
        pro.Budget_Hours__c=12;
        insert pro; 
        
    Project_Working_Session__c proWorkssn=new Project_Working_Session__c();
        proWorkssn.Date__c = system.today();
        proWorkssn.Next_Steps__c = 'testRichTextArea';
        proWorkssn.Project__c = pro.id; 
        proWorkssn.Participants__c = 'testRichTextAreaAgain';
        proWorkssn.Summary__c = 'testRichTextAreaAgainnAgain';
        insert proWorkssn;
    
     Project_Action_Item__c pai=new Project_Action_Item__c();
         pai.Status__c='Complete';
         pai.Commit_Date__c=system.today();
          pai.Project__c=pro.id;  
        insert pai;
    
   
    /* ApexPages.currentPage().getParameters().put('Id',pat.Id); */
    projWorkingSessionEmailTemplateExtn projWork = new projWorkingSessionEmailTemplateExtn();
        projWork.getlistWorkingSessionReport();
        projWork.getActionItem();
    
    }  
    
}