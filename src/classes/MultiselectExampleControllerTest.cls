@isTest
private class MultiselectExampleControllerTest {
/***
** testClass for MultiselectExampleController.
*/	
    static testMethod void testMultiselectExampleController() {
		List<Contact> l = new List<Contact>();
			for (Integer i = 0; i < 10; i++) {
				Contact c = new Contact(firstName = 'User'+i, lastName = 'Name'+i);
				l.add(c);
			}
		insert l;      
		MultiselectExampleController c = new MultiselectExampleController();      
		List<Contact> contacts = [SELECT Name, Id FROM Contact];
      
		System.assertEquals(c.selectedContacts.size(), 0);
        System.assertEquals(c.allContacts.size(), contacts.size());       
			c.save();
        
        System.assertEquals(c.message, 'Selected Contacts: ');
			c.selectedContacts.add(new SelectOption(contacts[0].id, contacts[0].name));
			c.selectedContacts.add(new SelectOption(contacts[1].id, contacts[1].name));       
			c.save();
        
        System.assertEquals(c.message, 'Selected Contacts: '+contacts[0].name+' ('+contacts[0].id+'), '+contacts[1].name+' ('+contacts[1].id+')');
    }
}