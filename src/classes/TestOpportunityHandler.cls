@isTest 
private class TestOpportunityHandler{
    private static TestMethod void OpportunityHandler_UnitTest(){

	Account acc = new Account();
	    acc.Name='test1';
		insert acc;
		
	Project__c pro = new Project__c();
		pro.Name='test';
		pro.Account__c=acc.id;
		pro.Name='test';
		pro.Budget__c=100.00;
		pro.Budget_Hours__c=320.00;
		insert pro;
		
	Campaign cap = new Campaign();
		cap.name='test';
		insert cap;
		
	
	Opportunity opp = new Opportunity();
		opp.name='test';
		opp.Project_Title__c='test';
		opp.Type='test';
		opp.CampaignId=cap.id;
		opp.CloseDate=system.today();
		opp.StageName='Closed Won';
		opp.Project__c=pro.id;
	    insert opp;
	
		
	product2 pro2 = new product2();
	    pro2.name='test';
		pro2.Include_in_Project_Budget_Calculations__c=true;
		insert pro2;
		
		
		Id pricebookId = Test.getStandardPricebookId();

//Create your product
Product2 prod = new Product2(
     Name = 'Product X',
     ProductCode = 'Pro-X',
     isActive = true,
	 Include_in_Project_Budget_Calculations__c=true
);
insert prod;

//Create your pricebook entry
PricebookEntry pbEntry = new PricebookEntry(
     Pricebook2Id = pricebookId,
     Product2Id = prod.Id,
     UnitPrice = 100.00,
     IsActive = true
);
insert pbEntry;

//create your opportunity line item.  This assumes you already have an opportunity created, called opp
OpportunityLineItem oli = new OpportunityLineItem(
     OpportunityId = opp.Id,
     Quantity = 5,
	 PricebookEntryId = pbEntry.Id,
     TotalPrice = 123
);
insert oli;
System.debug(oli);
	}
private static TestMethod void OpportunityHandler_UnitTest1(){

	Account acc = new Account();
	    acc.Name='test1';
		insert acc;
		
	Project__c pro = new Project__c();
		pro.Name='test';
		pro.Account__c=acc.id;
		pro.Name='test';
		pro.Budget__c=100.00;
		pro.Budget_Hours__c=320.00;
		insert pro;
		
	Campaign cap = new Campaign();
		cap.name='test';
		insert cap;
		
	
	Opportunity opp = new Opportunity();
		opp.name='test';
		opp.Project_Title__c='test';
		opp.Type='test';
		opp.CampaignId=cap.id;
		opp.CloseDate=system.today();
		opp.StageName='test';
		//opp.Project__c=pro.id;
	    insert opp;
		
	Project__c pro1 = new Project__c();
		pro1.Name='test';
		pro1.Account__c=acc.id;
		pro1.Opportunity__c= opp.id;	
		pro1.Name='test';
		pro1.Budget__c=100.00;
		pro1.Budget_Hours__c=320.00;
		insert pro1;
		
	product2 pro2 = new product2();
	    pro2.name='test';
		pro2.Include_in_Project_Budget_Calculations__c=true;
		insert pro2;
		
		
		Id pricebookId = Test.getStandardPricebookId();

//Create your product
Product2 prod = new Product2(
     Name = 'Product X',
     ProductCode = 'Pro-X',
     isActive = true,
	 Include_in_Project_Budget_Calculations__c=true
);
insert prod;

//Create your pricebook entry
PricebookEntry pbEntry = new PricebookEntry(
     Pricebook2Id = pricebookId,
     Product2Id = prod.Id,
     UnitPrice = 100.00,
     IsActive = true
);
insert pbEntry;

//create your opportunity line item.  This assumes you already have an opportunity created, called opp
OpportunityLineItem oli = new OpportunityLineItem(
     OpportunityId = opp.Id,
     Quantity = 5,
	 PricebookEntryId = pbEntry.Id,
     TotalPrice = 123
);
insert oli;
opp.StageName='Closed Won';
opp.Project__c=pro.id;
update opp;
System.debug(oli);
	}

}