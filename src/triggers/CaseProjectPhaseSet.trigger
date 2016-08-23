trigger CaseProjectPhaseSet on Case (after insert) {
    
    List<Case> cases = new List<Case>();
    for(Case c:Trigger.new){
        
        Project__c p = Database.query('SELECT FROM Project__c where Id=:c.Project__c');
    }
    update cases;
}