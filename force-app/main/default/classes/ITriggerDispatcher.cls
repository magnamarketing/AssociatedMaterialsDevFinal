/**
* @author CRMCulture
* @date 20140701
* @version 1.00 
* @return void	
* @description Defines the interface for the trigger dispatching architecture.
*/
public interface ITriggerDispatcher {
	/** 
	* @author CRMCulture
	* @date 20140701
	* @version 1.00 
	* @return void
	* @description Called by the trigger framework to carry out the actions before the bulk operations.
	*/
	void bulkBefore();
	
	/** 
	* @author CRMCulture
	* @date 20140701
	* @version 1.00 
	* @return void
	* @description Called by the trigger framework to carry out the actions after the bulk operations.
	*/
	void bulkAfter();
	
	/** 
	* @author CRMCulture
	* @date 20140701
	* @version 1.00 
	* @return void
	* @description Called by the trigger framework to carry out the actions after completing the bulk operations.
	*/
	void andFinally();
	
	/** 
	* @author CRMCulture
	* @date 20140701
	* @version 1.00 
	* @return void
	* @description Called by the trigger framework to carry out the actions before the records are inserted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that is getting inserted.
	*/
	void beforeInsert(TriggerParameters tp);
	
	/** 
	* @author CRMCulture
	* @date 20140701
	* @version 1.00 
	* @return void
	* @description Called by the trigger framework to carry out the actions before the records are updated. 
	* @param TriggerParameters Contains the trigger parameters which includes the records that is getting updated.
	*/
	void beforeUpdate(TriggerParameters tp);
	
	/** 
	* @author CRMCulture
	* @date 20140701
	* @version 1.00 
	* @return void 
	* @description Called by the trigger framework to carry out the actions before the records are deleted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that is getting deleted.
	*/
	void beforeDelete(TriggerParameters tp);
	
	/** 
	* @author CRMCulture
	* @date 20140701
	* @version 1.00 
	* @return void
	* @description Called by the trigger framework to carry out the actions after the records are inserted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that got inserted.
	*/
	void afterInsert(TriggerParameters tp);
	
	/** 
	* @author CRMCulture
	* @date 20140701
	* @version 1.00 
	* @return void
	* @description Called by the trigger framework to carry out the actions before the records are updated.
	* @param TriggerParameters Contains the trigger parameters which includes the records that got updated.
	*/
	void afterUpdate(TriggerParameters tp);
	
	/** 
	* @author CRMCulture
	* @date 20140701
	* @version 1.00 
	* @return void
	* @description Called by the trigger framework to carry out the actions after the records got deleted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that got deleted.
	*/
	void afterDelete(TriggerParameters tp);
	
	/** 
	* @author CRMCulture
	* @date 20140701
	* @version 1.00 
	* @return void
	* @description Called by the trigger framework to carry out the actions after the records are undeleted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that got undeleted.
	*/
	void afterUnDelete(TriggerParameters tp);
}