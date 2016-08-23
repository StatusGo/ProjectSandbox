/** 
* Class ProjectGlossaryTermsHandler 
* 
* Task Handler for the Task SObject. This class implements the TriggerInterface 
* interface to help ensure the trigger code is bulkified and all in one place. 
*/ 
public with sharing class ProjectGlossaryTermsHandler implements TriggerInterface { 
    
    Map<Id,Project__c> projAccMap;
   
    //Constructor 
    public ProjectGlossaryTermsHandler(){ 
        projAccMap = new map<Id,Project__c>();
    }
   /* 
bulkBefore
*/  
    public void bulkBefore(){ 
        Set<Id> projID = new set<Id>();
		for(Project_Glossary_Term__c proGlo: (List<Project_Glossary_Term__c>)trigger.new){
			if(proGlo.Project__c !=null){
				projID.add(proGlo.Project__c);
					system.debug('projID____________________'+projID);					
			}	
			
		}
			if(projID !=null){
				projAccMap = new map<id,Project__c>([select id,Account__c from Project__c where id=:projID]);
					System.debug('projAccMap____________________'+projAccMap);
				
			}
    }
	
	public void bulkAfter()
	{ } 
   /* 
beforeInsert
*/    
    public void beforeInsert(SObject so){ 
        System.debug('projAccMap..........>>>>'+projAccMap);
			Project_Glossary_Term__c proGt = (Project_Glossary_Term__c)so;
				if(projAccMap.containskey(proGt.Project__c))
					proGt.Account__c = projAccMap.get(proGt.Project__c).Account__c; 
				
				
    } 
   /* 
beforeUpdate
*/	    
    public void beforeUpdate(SObject oldSo, SObject so){    
        System.debug('projAccMap..........>>>>'+projAccMap);
			Project_Glossary_Term__c proGt = (Project_Glossary_Term__c)so;
				if(projAccMap.containskey(proGt.Project__c))
					proGt.Account__c = projAccMap.get(proGt.Project__c).Account__c; 
				
        
    } 
	
    public void beforeDelete(SObject so)
	{ } 
    /** 
    * afterInsert 
    * 
    * This method is called iteratively for each record inserted during an AFTER 
    * trigger. Always put field validation in the 'After' methods in case another trigger 
    * has modified any values. The record is 'read only' by this point. 
    */ 	
    public void afterInsert(SObject so)
	{ } 
    public void afterUpdate(SObject oldSo, SObject so)
	{ } 
    public void afterDelete(SObject so)
	{ } 
    public void afterUndelete(SObject so)
	{ } 

    /** 
    * andFinally 
    * 
    * This method is called once all records have been processed by the trigger. Use this 
    * method to accomplish any final operations such as creation or updates of other records. 
    */ 
    public void andFinally()
	{ } 

}