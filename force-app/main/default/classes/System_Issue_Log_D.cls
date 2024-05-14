/**
* @author CRMCulture
* @date 20140701
* @version 1.00
* @description  Class to handle common logic
* @return void
* @description This class extends the TriggerDispatcherBase to provide the dispatching functionality for the trigger actions
*               on the object. The event handlers support allowing and preventing actions for reentrant scenarios.
*               This is controlled by the flag isBeforeXxxxx and isAfterXxxxx member variables. These variables need to be set
*               to true before invoking the handlers and set to false after the invocation of the handlers. Resetting is MUST
*               as otherwise unit tests MAY fail. The actual actions should be placed in the handlers (in a separate class).
*/
public class System_Issue_Log_D extends TriggerDispatcherBase {
    //private static Boolean isBeforeInsertProcessing = false;
 //   private static Boolean isBeforeUpdateProcessing = false;
	//private static Boolean isBeforeDeleteProcessing = false;
 //   private static Boolean isAfterInsertProcessing = false;
 //   private static Boolean isAfterUpdateProcessing = false;
	//private static Boolean isAfterDeleteProcessing = false;
	//private static Boolean isAfterUnDeleteProcessing = false;
    /**
    * @author CRMCulture
    * @version 1.00
    * @return void
    * @description This method is called prior to execution of all before trigger events for this dispatcher. If you want
	*				to load any lookup data or cache the data, then this is the place that you need
	*				to put your code.  (example record type retrival and other SOQL calls)
    */
    public override void bulkBefore(){
    	//Setup static variables to be used within the execution context (store in helper class)
    }
    /**
	* @author CRMCulture
	* @version 1.00
	* @description This method is called prior to execution of an after trigger event.
	*/
    public override void bulkAfter(){

    }
    /**
	* @author CRMCulture
	* @version 1.00
	* @description This method is called at the end of everything
	*/
    public override void andFinally(){
        
    }
    /**
    * @author CRMCulture
    * @date 20140701
    * @version 1.00
    * @return void
    * @description Called by the trigger framework to carry out the actions before the records are inserted. If there is an
    *               existing call running on the same context, the rentrant call will utilize the handler that was created
    *               in the original call.
    * @param TriggerParameters Contains the trigger parameters which includes the records that is getting inserted.
    */
    public override void beforeInsert(TriggerParameters tp) {
      //if(!isBeforeInsertProcessing) {
      //    isBeforeInsertProcessing = true;
      //   // execute(new System_Issue_Log__c_BeforeInsert(), tp, TriggerParameters.TriggerEvent.beforeInsert);
      //    isBeforeInsertProcessing = false;
      //}
      //else execute(null, tp, TriggerParameters.TriggerEvent.beforeInsert);
    }

    /**
    * @author CRMCulture
    * @date 20140701
    * @version 1.00
    * @return void
    * @description Called by the trigger framework to carry out the actions before the records are updated. If there is an
    *               existing call running on the same context, the rentrant call will utilize the handler that was created
    *               in the original call.
    * @param TriggerParameters Contains the trigger parameters which includes the records that is getting updated.
    */
    public override void beforeUpdate(TriggerParameters tp) {
      //if(!isBeforeUpdateProcessing) {
      //    isBeforeUpdateProcessing = true;
      //   // execute(new System_Issue_Log__c_BeforeUpdate(), tp, TriggerParameters.TriggerEvent.beforeUpdate);
      //    isBeforeUpdateProcessing = false;
      //}
      //else execute(null, tp, TriggerParameters.TriggerEvent.beforeUpdate);
    }
	/**
    * @author CRMCulture
    * @date 20140701
    * @version 1.00
    * @return void
    * @description Called by the trigger framework to carry out the actions before the records are deleted. If there is an
    *               existing call running on the same context, the rentrant call will utilize the handler that was created
    *               in the original call.
    * @param TriggerParameters Contains the trigger parameters which includes the records that is getting updated.
    */
    public  override void beforeDelete(TriggerParameters tp) {
      //if(!isBeforeDeleteProcessing) {
      //    isBeforeDeleteProcessing = true;
      //   // execute(new System_Issue_Log__c_BeforeDelete(), tp, TriggerParameters.TriggerEvent.beforeDelete);
      //    isBeforeDeleteProcessing = false;
      //}
      //else execute(null, tp, TriggerParameters.TriggerEvent.beforeDelete);
    }
    /**
    * @author CRMCulture
    * @date 20140701
    * @version 1.00
    * @return void
    * @description Called by the trigger framework to carry out the actions after the record(s) are created. If there is an
    *               existing call running on the same context, the rentrant call will utilize the handler that was created
    *               in the original call.
    * @param TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
    */
    public  override void afterInsert(TriggerParameters tp) {
        //if(!isAfterInsertProcessing) {
        //    isAfterInsertProcessing = true;
        //    //execute(new System_Issue_Log__c_AfterInsert(), tp, TriggerParameters.TriggerEvent.afterInsert);
        //    isAfterInsertProcessing = false;
        //}
        //else execute(null, tp, TriggerParameters.TriggerEvent.afterInsert);
    }

    /**
    * @author CRMCulture
    * @date 20140701
    * @version 1.00
    * @return void
    * @description Called by the trigger framework to carry out the actions after the records are updated. If there is an
    *               existing call running on the same context, the rentrant call will utilize the handler that was created
    *               in the original call.
    * @param TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    */
    public virtual override void afterUpdate(TriggerParameters tp) {
        //if(!isAfterUpdateProcessing) {
        //    isAfterUpdateProcessing = true;
        //    //execute(new System_Issue_Log__c_AfterUpdate(), tp, TriggerParameters.TriggerEvent.afterUpdate);
        //    isAfterUpdateProcessing = false;
        //}
        //else execute(null, tp, TriggerParameters.TriggerEvent.afterUpdate);
    }
    /**
    * @author CRMCulture
    * @date 20140701
    * @version 1.00
    * @return void
    * @description Called by the trigger framework to carry out the actions after the records are deleted. If there is an
    *               existing call running on the same context, the rentrant call will utilize the handler that was created
    *               in the original call.
    * @param TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    */
    public virtual override void afterDelete(TriggerParameters tp) {
        //if(!isAfterDeleteProcessing) {
        //    isAfterDeleteProcessing = true;
        //    //execute(new System_Issue_Log__c_AfterDelete(), tp, TriggerParameters.TriggerEvent.afterDelete);
        //    isAfterDeleteProcessing = false;
        //}
        //else execute(null, tp, TriggerParameters.TriggerEvent.afterDelete);
    }
	/**
    * @author CRMCulture
    * @date 20140701
    * @version 1.00
    * @return void
    * @description Called by the trigger framework to carry out the actions after the records are undeleted. If there is an
    *               existing call running on the same context, the rentrant call will utilize the handler that was created
    *               in the original call.
    * @param TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    */
    public virtual override void afterUnDelete(TriggerParameters tp) {
        //if(!isAfterUnDeleteProcessing) {
        //    isAfterUnDeleteProcessing = true;
        //    //execute(new System_Issue_Log__c_AfterUnDelete(), tp, TriggerParameters.TriggerEvent.afterUnDelete);
        //    isAfterUnDeleteProcessing = false;
        //}
        //else execute(null, tp, TriggerParameters.TriggerEvent.afterUnDelete);
    }
}