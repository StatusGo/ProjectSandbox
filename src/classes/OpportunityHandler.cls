public without sharing class OpportunityHandler
    implements TriggerInterface
{
		public List<Project__c> projectList=new List<Project__c>();
		public list<OpportunityLineItem> opplist = new list<OpportunityLineItem>();
		public Double TotalPriceset=0.0;
		public Double Quantityset=0;
		public Set<Id> oppIds=new Set<Id>();
		public map<String,String> mapsumTP=new map<String,String>();
		public map<String,String> mapsumQua=new map<String,String>();
		public map<Id,Id> mapOppProj=new map<Id,Id>();
		public list<Opportunity> opplistObj = new list<Opportunity>();
// Constructor
    public OpportunityHandler()
    {
    }
    
    public void bulkBefore()
    {
		
      
    }
 
    public void bulkAfter()
    {
		for(Opportunity prl : (List<Opportunity>)Trigger.new){
		oppIds.add(prl.id);
		
		}
		List<Project__c> lstProj=[select id,Opportunity__c from Project__c where Opportunity__c IN:oppIds];
		for(Project__c proj:lstProj){
			mapOppProj.put(proj.Opportunity__c,proj.id);
		}
    AggregateResult[] opplist1 = [SELECT OpportunityId,sum(Quantity)smqu,sum(TotalPrice)smtp FROM OpportunityLineItem where Product2.Include_in_Project_Budget_Calculations__c = true and OpportunityId IN:oppIds group by OpportunityId ];
	 
		 for(AggregateResult oppt : opplist1){
		 system.debug('oppt----'+oppt);
		mapsumTP.put(string.valueOf(oppt.get('OpportunityId')),string.valueOf(oppt.get('smtp')));
		 mapsumQua.put(string.valueOf(oppt.get('OpportunityId')),string.valueOf(oppt.get('smqu')));
	 }
 
	}
	
    public void beforeInsert(SObject so)
    {
		
    }
 
    public void beforeUpdate(SObject oldSo, SObject so)
    {
		
    }
 
    
    public void beforeDelete(SObject so)
    {
       
    }
 
    public void afterInsert(SObject so)
    {
		
    Opportunity opp = (Opportunity)so;
	
		if(mapOppProj.get(opp.id)==null && opp.Project__c == null){
			  if(opp.IsWon){
			   Project__c pro = new Project__c();
			  
			   pro.Name = opp.Project_Title__c;
			   pro.Account__c = opp.AccountId;
			   pro.Opportunity__c=opp.id;
			   if(mapsumTP.containskey(opp.id) && mapsumQua.containskey(opp.id)){ 
			   pro.Budget__c = Double.valueOf(mapsumTP.get(opp.id));
			  pro.Budget_Hours__c =Double.valueOf(mapsumQua.get(opp.id));
			  
			  system.debug('pro----'+pro);
			    }else{
					pro.Budget__c =null;
					 pro.Budget_Hours__c=null;
				} 
			   projectList.add(pro);
			  }
		system.debug('projectList----'+projectList);
		}

    }
 
    public void afterUpdate(SObject oldSo, SObject so)
    {
	Opportunity opp = (Opportunity)so;
	system.debug('opplist----'+opp);
	Project__c pro = new Project__c();
	
		if(mapOppProj.get(opp.id)==null ){
			if(opp.IsWon){
			
			pro.Name = opp.Project_Title__c;
			pro.Account__c = opp.AccountId;
			pro.Opportunity__c=opp.id;
			
			if(mapsumTP.containskey(opp.id) && mapsumQua.containskey(opp.id)){ 
				pro.Budget__c = Double.valueOf(mapsumTP.get(opp.id));
				pro.Budget_Hours__c =Double.valueOf(mapsumQua.get(opp.id));
				system.debug('pro----'+pro);
			}
				else{
					pro.Budget__c =null;
					 pro.Budget_Hours__c=null;
				} 			
				projectList.add(pro);
			}
			  
		system.debug('projectList----'+projectList);
		}
		
		if(opp.Project__c != null){
			if(opp.IsWon){
			pro.id = opp.Project__c;	
			pro.Name = opp.Project_Title__c;
			pro.Account__c = opp.AccountId;
			pro.Opportunity__c=opp.id;
			
		if(mapsumTP.containskey(opp.id) && mapsumQua.containskey(opp.id)){ 
				pro.Budget__c = Double.valueOf(mapsumTP.get(opp.id));
				pro.Budget_Hours__c =Double.valueOf(mapsumQua.get(opp.id));
				system.debug('pro----'+pro);
			} 
			
				projectList.add(pro);
				
			}
			
		}
			
    }

    public void afterDelete(SObject so)
    {
    }
 
    public void afterUndelete(SObject so)
    {
    }
 
   
    public void andFinally()
    {
			system.debug('projectList----'+projectList);
		if(projectList.size()>0){
			upsert  projectList;
			/* Opportunity opp = new Opportunity();
			if(mapOppProj.get(opp.Project__c)!=null) 
				{ 
            opp.Project__c = mapOppProj.get(opp.Project__c);
               } */
			for(Project__c proj :projectList){
				Opportunity opp = new Opportunity();
				opp.id = proj.Opportunity__c;
				opp.Project__c = proj.Id;
				opplistObj.add(opp); 
			}
			 if(opplistObj.size()>0){
				Update opplistObj; 
				
			} 
	
		}
    }
}