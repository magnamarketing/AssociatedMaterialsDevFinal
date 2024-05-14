/**
 * Contact trigger
 *   
 * @author CRMCulture  
 * @version 1.00 
 * @param Platform after insert, after update, before insert, before update
*/ 
trigger ContactTrigger on Contact (
	before insert,
	before update,
	before delete,
	after insert,
	after update,
	after delete,
	after undelete) {
	TriggerFactory.createTriggerDispatcher(Contact.sObjectType);
}