/**
Company    : Fujitsu America
Date       : Mar 2010
Author     : Anand Sharma
Description: Test Class for the Populate delivery Dates Trigger. 
History    :              
*/

@isTest
private class PopulateDeliveryDates_Test {

	static testMethod void PopulateDeliveryDates_Test(){
		
		//Create Account data
		List<Account> lstAccount = new List<Account>();
		Account acc = new Account();
		for(Integer i=0; i<200; i++){
			acc = new Account(Name ='TestAccount'+i, External_Id__c ='1234'+i, AccountNumber='12345', Company_Number__c='123', Customer_Number__c='12'+i, Sub_Account__c ='abc');
			acc.Alt_Delivery_Day_Offset__c = 2;
			acc.Delivery_Day_Offset__c = 2;
			acc.Ship_Monday__c =true;
			acc.Ship_Tuesday__c =true;
			acc.Ship_Wednesday__c =true;
			acc.Ship_Thursday__c =true;
			acc.Ship_Friday__c =true;
			acc.Ship_Saturday__c =true;
			acc.Ship_Sunday__c =true;
			acc.Alt_Ship_Monday__c =true;
			acc.Alt_Ship_Tuesday__c =true;
			acc.Alt_Ship_Wednesday__c =true;
			acc.Alt_Ship_Thursday__c =true;
			acc.Alt_Ship_Friday__c =true;
			acc.Alt_Ship_Saturday__c =true;
			acc.Alt_Ship_Sunday__c =true;
			lstAccount.add(acc);
		}
		
		//Insert accounts
		insert lstAccount;
		
		// Create record for update account
		for(Account acct :lstAccount){
			acct.Alt_Delivery_Day_Offset__c =3;
			acct.Delivery_Day_Offset__c =3;
		}
		//Update accounts
		update lstAccount;
    }
}