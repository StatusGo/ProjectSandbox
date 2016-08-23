trigger ProjectGlossaryTermsTrigger on Project_Glossary_Term__c (before insert, after insert, before update, after update ) {
	System.debug('trigger got CALLED');
		TriggerFactory.createAndExecuteHandler(ProjectGlossaryTermsHandler.class);
		
	}