/**
Company    : Fujitsu America
Date       : Mar 2010
Author     : Anand Sharma
Description: Populate delivery Dates and delivery Dates of the account object. 
History    :              
*/
trigger PopulateDeliveryDates on Account (before insert, before update) {

    System.debug('in PopulateDeliveryDate trigger');
    
    List<Account> lstAccount = new List<Account>();
    if(Trigger.isInsert) {
        System.debug('in isinsert section...');
        for(Account acct : Trigger.new) {
            lstAccount.add(acct);
        }
    }
    
    if(Trigger.isUpdate) {
        System.debug('in isupdate section...');
        //Including only those records that have changed field values on shipment information
        for(Integer i=0; i<Trigger.old.size(); i++) {
            if((Trigger.old[i].Ship_Monday__c != Trigger.new[i].Ship_Monday__c) ||
            (Trigger.old[i].Ship_Tuesday__c != Trigger.new[i].Ship_Tuesday__c) ||
            (Trigger.old[i].Ship_Wednesday__c != Trigger.new[i].Ship_Wednesday__c) || 
            (Trigger.old[i].Ship_Thursday__c != Trigger.new[i].Ship_Thursday__c) ||
            (Trigger.old[i].Ship_Friday__c != Trigger.new[i].Ship_Friday__c) ||
            (Trigger.old[i].Ship_Saturday__c != Trigger.new[i].Ship_Saturday__c) ||
            (Trigger.old[i].Ship_Sunday__c != Trigger.new[i].Ship_Sunday__c) ||            
            (Trigger.old[i].Alt_Ship_Monday__c != Trigger.new[i].Alt_Ship_Monday__c) ||
            (Trigger.old[i].Alt_Ship_Tuesday__c != Trigger.new[i].Alt_Ship_Tuesday__c) ||
            (Trigger.old[i].Alt_Ship_Wednesday__c != Trigger.new[i].Alt_Ship_Wednesday__c) || 
            (Trigger.old[i].Alt_Ship_Thursday__c != Trigger.new[i].Alt_Ship_Thursday__c) ||
            (Trigger.old[i].Alt_Ship_Friday__c != Trigger.new[i].Alt_Ship_Friday__c) ||
            (Trigger.old[i].Alt_Ship_Saturday__c != Trigger.new[i].Alt_Ship_Saturday__c) ||
            (Trigger.old[i].Alt_Ship_Sunday__c != Trigger.new[i].Alt_Ship_Sunday__c) ||
            (Trigger.old[i].Alt_Delivery_Day_Offset__c != Trigger.new[i].Alt_Delivery_Day_Offset__c) ||
            (Trigger.old[i].Delivery_Day_Offset__c != Trigger.new[i].Delivery_Day_Offset__c)
            ){
                lstAccount.add(Trigger.new[i]);
            }
        }
    }
    
    System.debug('upsert Account count is ' + lstAccount.size());
    if(lstAccount.size() > 0) {
        //CallMethod for upsert record;
        OrderHelper.PopulateDeliveryDate(lstAccount);        
    }
    /**/
}