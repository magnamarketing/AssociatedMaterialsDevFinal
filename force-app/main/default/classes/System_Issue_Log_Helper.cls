/**
* @author CRMCulture
* @version 1.00
* @description This Class is used to help support System_Issue_Log__c
*/
public class System_Issue_Log_Helper {
    public static List<SystemIssueLogWrapper> CachedIssueLogs {get;set;} 
	/**
	* @author CRMCulture
	* @version 1.00
	* @description Add an exception to the Cache 
	*/
	public static void LogException(SystemIssueLogWrapper log, Boolean doPersist) {
        if(CachedIssueLogs == null)CachedIssueLogs = new List<SystemIssueLogWrapper>();
        CachedIssueLogs.add(log);
        if(doPersist){
            UpsertExceptions();
            CachedIssueLogs.clear();
        }
		
	} 
    /**
    * @author CRMCulture
    * @version 1.00
    * @description Add exceptions to the Cache 
    */
    public static void LogException(List<SystemIssueLogWrapper> logs, Boolean doPersist) {
        if(CachedIssueLogs == null)CachedIssueLogs = new List<SystemIssueLogWrapper>();
        CachedIssueLogs.addAll(logs); 
        if(doPersist){
            UpsertExceptions();
            CachedIssueLogs.clear();
        }
    } 
    /**
    * @author CRMCulture
    * @version 1.00
    * @description Persist Exceptions to the database
    */
    public static void UpsertExceptions(){ 
        if(CachedIssueLogs != null){
            try{ 
                List<System_Issue_Log__c> upsertItems = new List<System_Issue_Log__c>();
                for(SystemIssueLogWrapper i : CachedIssueLogs){ 
                    upsertItems.add(i.getSObject());
                }
                if(!upsertItems.isEmpty()){ 
                    Database.upsert(upsertItems, System_Issue_Log__c.Issue_Unique_ID__c, false);
                }
            }catch(Exception ex){
                System.debug('Failed to log issue ');
            }
        }
    }
 
}