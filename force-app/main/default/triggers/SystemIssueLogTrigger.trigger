trigger SystemIssueLogTrigger on System_Issue_Log__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) { 
	TriggerFactory.createTriggerDispatcher(System_Issue_Log__c.sObjectType);
}