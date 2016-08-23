public class cloneNewProjectScheduleExtn{
    public String currentProjectScheduleId{get;set;}
    public Project_Schedule__c CurrentProjectSchedule{get;set;}
    public string SelectedProject{get;set;}
    public Boolean selectStatus{get;set;} 
    public Boolean selectStartDate{get;set;} 
    public Boolean selectOwner{get;set;} 
    public Boolean selectDueDate{get;set;} 
    public Boolean selectSortOrder{get;set;} 
    public Boolean selectActualDate{get;set;} 
    public Boolean IsCloneToPracticeNULL{get;set;} 
    public List<Project__c> ProjectList = new List<Project__c>();
     
    public cloneNewProjectScheduleExtn(ApexPages.StandardController controller){
        IsCloneToPracticeNULL =false;
        currentProjectScheduleId=ApexPages.CurrentPage().getparameters().get('id');
        CurrentProjectSchedule = [select id,Project__r.Name from Project_Schedule__c where Id=:currentProjectScheduleId];
        
    }
     public pageReference Cancel(){
            if(currentProjectScheduleId != null){
                PageReference orderPage = new PageReference('/' + currentProjectScheduleId);
                orderPage.setRedirect(true);
                return orderPage;               
            }
            return null;
    }
    public List<SelectOption> getavailableProjects(){
        List<SelectOption> options = new List<SelectOption>();
        ProjectList = [select id, Name from Project__c ORDER BY Name ASC LIMIT 1000];
        options.add(new SelectOption('', '-- None --'));
        for(Project__c pro:ProjectList)
        {
            options .add(new SelectOption(pro.Id, pro.Name));
        }
        System.debug('options.....'+options);
        return options;
    }
    public void errorrender(){
        
        if (SelectedProject!=null && SelectedProject != ''){
            IsCloneToPracticeNULL = false;
        }
        System.debug(IsCloneToPracticeNULL);
        System.debug(SelectedProject);
    }
    public pageReference DeepcloneSchedule() {
        System.debug(SelectedProject);
        try{
            if (SelectedProject==null || SelectedProject == ''){
            IsCloneToPracticeNULL = true;
           return null;
        }if(!selectStatus && !selectStartDate && !selectOwner && !selectDueDate && !selectSortOrder && !selectActualDate){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select at least one field'));
            return null;
        }
            
        List<Project_Schedule_Task__c> pstList = [Select id,Name,Status__c,Phase__c,Start_Date__c,Sort_Order__c,Owner__c,Due_Date__c,Completed_Date__c from Project_Schedule_Task__c Where Project_Schedule__c=:currentProjectScheduleId];
        System.debug('.....>>>pstList'+pstList);
        List<Project_Schedule_Task__c> ProjectScheduleTaskList = new List<Project_Schedule_Task__c>();
        
        Project_Schedule__c ps;     
        ps = new Project_Schedule__c();
        ps.Project__c = SelectedProject;
        insert ps;
        
        Project_Schedule_Task__c projectst;
        for(Project_Schedule_Task__c pst : pstList){
            projectst = new Project_Schedule_Task__c();
            projectst.Name = pst.Name;
            if(selectStatus==true){
                projectst.Status__c = pst.Status__c;
            }if(selectStartDate==true){
                projectst.Start_Date__c = pst.Start_Date__c;
            }if(selectOwner==true){
                projectst.Owner__c = pst.Owner__c;
            }if(selectDueDate==true){
                projectst.Due_Date__c = pst.Due_Date__c;
            }if(selectSortOrder==true){
                projectst.Sort_Order__c = pst.Sort_Order__c;
            }if(selectActualDate==true){
                projectst.Completed_Date__c = pst.Completed_Date__c;
            }
            projectst.Phase__c = pst.Phase__c;
            projectst.Project_Schedule__c = ps.Id;
            ProjectScheduleTaskList.add(projectst);
        }if(ProjectScheduleTaskList.size()>0){
            insert ProjectScheduleTaskList;
            System.debug('.....>>>ProjectScheduleTaskList: '+ProjectScheduleTaskList);
        }
        PageReference orderPage = new PageReference('/' +ps.Id);
        orderPage.setRedirect(true);
        return orderPage;    
        }catch(DMLException e){
          system.debug(e.getmessage());
           system.debug(e.getLineNumber());
        }
        return null;
    }
}