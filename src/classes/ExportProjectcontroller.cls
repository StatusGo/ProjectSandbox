public with sharing class ExportProjectcontroller {
    public Map<String,List<Project_Schedule_Task__c>> phasePSTMap {get;set;}
    public Set<String> phaseName {get;set;}
    public String dateTimeValue {get;set;}
    public String imageURL {get;set;}
    public User U{get;set;}
    public ExportProjectcontroller(ApexPages.StandardController controller){
        String currentProjectScheduleId=ApexPages.CurrentPage().getparameters().get('id');
        phasePSTMap = new Map<String,List<Project_Schedule_Task__c>>(); 
        phaseName = new Set<String>();
        
        Image_URL__c imc = Image_URL__c.getInstance('Email Template Logo');
        if(imc.StatusGo_Green_Logo__c != null){
            imageURL = imc.StatusGo_Green_Logo__c ;         
        }
        
        id id1 = userinfo.getUserId();
        dateTimeValue = System.Now().format('MM/dd/yyyy hh:mm a', 'EST');
			U =[select Name from User where id = :id1];
        List<Project_Schedule_Task__c> pstList = [Select id,Name,Status__c,Phase__c,Start_Date__c,Sort_Order__c,Owner__r.Name,Due_Date__c,Completed_Date__c from Project_Schedule_Task__c Where Project_Schedule__c=:currentProjectScheduleId Order by Phase__c, Sort_Order__c];
        
        List<Project_Schedule_Task__c> proSec;
        for(Project_Schedule_Task__c PT:pstList){
            if(PT.Phase__c==null){
                PT.Phase__c = ' ';
            } 
            if(phasePSTMap.containsKey(PT.Phase__c)){
                phasePSTMap.get(PT.Phase__c).add(PT);
            } else {
                proSec = new List<Project_Schedule_Task__c>();
                proSec.add(PT);
                phasePSTMap.put(PT.Phase__c,proSec);
            }
            phaseName.add(PT.Phase__c);
            
        }
        System.debug('phasePSTMap ::>'+phasePSTMap);
    }   
}