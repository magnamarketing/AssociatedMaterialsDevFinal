/**
* Contact_AfterInsert  Trigger Handler
*
* @author CRMCulture
* @version 1.00
* @description  Class to handle Trigger handler
* @return void
*/
public class Contact_AfterInsert  extends TriggerHandlerBase {
    /**
    * mainEntry override
    *
    * @author CRMCulture
    * @date 20140701
    * @version 1.00
    * @description mainEntry override
    * @param tp Trigger Parameters construct
    * @return void
    */
    public override void mainEntry(TriggerParameters tp) {
       	ContactHelper.CreateNewPropertyOwner((List<Contact>)tp.newList);
        //Store objects to be updated in this.sObjectsToUpdate
    }
    /**
    * @author CRMCulture
    * @version 1.00, 20140701
    * @description Called for the subsequent times in the same execution context. The trigger handlers can chose
    *               to ignore if they don't need the reentrant feature.
    * @param TriggerParameters The trigger parameters such as the list of records before and after the update.
    */
    //public override void inProgressEntry(TriggerParameters tp) {

    //}
    /**
    * @author CRMCulture
    * @version 1.00, 20140701
    * @description Updates objects at the end
    * @param TriggerParameters The trigger parameters such as the list of records before and after the update.
    */
    /*
        public virtual override void updateObjects() {
		if(sObjectsToUpdate.size() > 0)
			update sObjectsToUpdate.values();
	}
    */
}



//https://crmculture-associatedmaterials.cs16.force.com/communitiesselfreg