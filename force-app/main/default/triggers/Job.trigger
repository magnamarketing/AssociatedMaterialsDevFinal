trigger Job on Job__c (after insert)  {

    if(Trigger.isAfter && Trigger.isInsert){
        JobTriggerHandler.handleAfterInsert();
    }

}