/**
 * Class ProjectActionItemHandler
 *
 * Trigger Handler for the Contact SObject. This class implements the TriggerInterface
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public without sharing class ProjectActionItemHandler
    implements TriggerInterface
{
   
    public map<Id,Id> mappwsproName = new map<Id,Id>();
    // Constructor
    public ProjectActionItemHandler()
    {
      
    }
 
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore()
    {
        
        Set<Id> workingsessionid = new Set<Id>();
        for(Project_Action_Item__c pai : (List<Project_Action_Item__c>)Trigger.new){
            workingsessionid.add(pai.Project_Working_Session__c);
        }
        
        for(Project_Working_Session__c item : [SELECT Id, Project__c FROM Project_Working_Session__c WHERE Id IN:workingsessionid]){
            mappwsproName.put(item.Id,item.Project__c);
        }
    }
 
    public void bulkAfter()
    {
             
    }
 
    public void beforeInsert(SObject so)
    {
        
        Project_Action_Item__c paitem= (Project_Action_Item__c)so;
       system.debug('paitem>>'+paitem);
       system.debug('paitem paitem.Project_Working_Session__r.project__c>>'+mappwsproName.get(paitem.id));
        if(paitem.Project__c==null && paitem.Project_Working_Session__c !=null && mappwsproName.get(paitem.Project_Working_Session__c)!=null) 
        { 
            
            paitem.Project__c = mappwsproName.get(paitem.Project_Working_Session__c);
            
         system.debug('paitem>>'+paitem.Project__c);
        }
    }
 
    public void beforeUpdate(SObject oldSo, SObject so)
    {
        Project_Action_Item__c paitem= (Project_Action_Item__c)so;
       system.debug('paitem>>'+paitem);
        if(paitem.Project__c==null && paitem.Project_Working_Session__c!=null && mappwsproName.get(paitem.Project_Working_Session__c)!=null) 
        { 
            
            paitem.Project__c = mappwsproName.get(paitem.Project_Working_Session__c);
            
         system.debug('paitem>>'+paitem.Project__c);
        }
             
    }
 
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so)
    {
       
    }
 
    public void afterInsert(SObject so)
    { 
    
    }
 
    public void afterUpdate(SObject oldSo, SObject so)
    { 
        
        
    }

    public void afterDelete(SObject so)
    {
    }
 
    public void afterUndelete(SObject so)
    {
    }
 
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally()
    {
        
    }
}