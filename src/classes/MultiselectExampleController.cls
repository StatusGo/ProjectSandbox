public with sharing class MultiselectExampleController {

    public SelectOption[] selectedContacts { get; set; }
    public SelectOption[] allContacts { get; set; }
    
    public String message { get; set; }
    
    public MultiselectExampleController() {
        selectedContacts = new List<SelectOption>();
        
        List<Contact> contacts = [SELECT Name, Id, email FROM Contact];    
        allContacts = new List<SelectOption>();
        for ( Contact c : contacts ) {
            allContacts.add(new SelectOption(c.Id, c.name));
        }
    }

    public PageReference save() {
        Set<id> selectedContact;
        selectedContact = new Set<id>();
        message = 'Selected Contacts: ';
        Boolean first = true;
        for ( SelectOption so : selectedContacts ) {
            if (!first) {
                message += ', ';
            }
            message += so.getLabel() + ' (' + so.getValue() + ')';
            selectedContact.add(so.getValue());
            first = false;
        }
        
        return null;       
    }
}