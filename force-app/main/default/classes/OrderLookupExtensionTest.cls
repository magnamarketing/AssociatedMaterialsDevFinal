/*
Company    : Fujitsu America
Date       : Feb 2010
Author     : Anand Sharma
Description: Test class for visual force page Order Lookup 
History    :              
*/
@isTest
private class OrderLookupExtensionTest {

    static testMethod void testOrderLookupExtension() {
        // Preparing Mock data        	
    	Account acc = new Account(Name ='testAccount', External_Id__c='1234567', Company_Number__c='111', Customer_Number__c='11111', Sub_Account__c='111');
    	insert acc; 
    	
    	Contact con = new Contact(
 			AccountId = acc.Id,
 			Email = 'test@test.com',
 			FirstName = 'Test First Name',
 			LastName = 'Test Last Name',
 			MailingCity = 'Denver',
 			MailingPostalCode = '80203',
 			MailingStreet = '123 Test St.',
 			Phone = '999-999-9999',
 			Title = 'Test Title'
 		);
 		insert con;
    	
    	Case cas = new Case(ContactID =con.Id,Status ='New', Type='Changes', Origin ='Email',Subject='Test Subject' );
    	insert cas;
    	
    	Order__c testOrder = new Order__c(Name = 'Test Order', Customer__c=acc.Id, Order_Date__c=Date.today(), External_Id__c='Test External Id');
    	insert testOrder;
    	
    	
    	ApexPages.StandardController controller = new ApexPages.StandardController(cas);//Setting up Standard controller for Case record.
    	System.currentPageReference().getParameters().put('id', cas.Id);//Setting Case recordId in current page reference.
		OrderLookupExtension orderLookup = new OrderLookupExtension(controller);//Initializing Constructor.
		orderLookup.selectedOrderId=testOrder.Id;//Setting selected order.
		
		//Calling controller methods.
		orderLookup.cancel();
		orderLookup.updateCase();
		orderLookup = new OrderLookupExtension(controller);	
		orderLookup.updateCase();	
    }
}