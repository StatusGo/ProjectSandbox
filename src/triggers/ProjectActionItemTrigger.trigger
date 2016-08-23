trigger ProjectActionItemTrigger on Project_Action_Item__c (before insert, before update,after insert, after update) {
    TriggerFactory.createAndExecuteHandler(ProjectActionItemHandler.class);
}