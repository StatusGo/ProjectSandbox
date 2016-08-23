public class StatusGoDreamforceController{
    public Lead LeadObj{get;set;}
    
    public StatusGoDreamforceController(){
        LeadObj = new Lead();
        LeadObj.LeadSource = 'Downloaded Tips and Wisdom';
    }
    public pageReference saveLead(){
    if(leadobj.FirstName == null){
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,'Please enter First Name.');//Same old drama 
    ApexPages.addMessage(myMsg); 
    return null;
    }
     if(leadobj.lastname == null){
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,'Please enter Last Name.');//Same old drama 
    ApexPages.addMessage(myMsg); 
    return null;
    }
     if(leadobj.company == null){
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,'Please enter Company Name.');//Same old drama 
    ApexPages.addMessage(myMsg); 
    return null;
    }
    if(leadobj.email == null){
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,'Please enter Email Address.');//Same old drama 
    ApexPages.addMessage(myMsg); 
    return null;
    }
    insert leadobj;
        List<Campaign> cmpgns = [SELECT Id FROM Campaign WHERE Name = 'Dreamforce 2015'];
        if(!cmpgns.isEmpty()) {
        	Campaign cmpgn = cmpgns.get(0);
        	CampaignMember cmpgnMmbr = new CampaignMember();
        	cmpgnMmbr.CampaignId = cmpgn.Id;
        	cmpgnMmbr.LeadId = leadobj.Id;
        	insert cmpgnMmbr;
        } 
    return page.thanksPage;
    }
}