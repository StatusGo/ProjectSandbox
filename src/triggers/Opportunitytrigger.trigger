trigger Opportunitytrigger on Opportunity (after insert, after update) {
    
   if(Utils.runOnce())    	
    	TriggerFactory.createAndExecuteHandler(OpportunityHandler.class);
   
}