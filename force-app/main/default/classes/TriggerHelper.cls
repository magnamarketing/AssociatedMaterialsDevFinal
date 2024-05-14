/**
* @author CRMCulture
* @version 1.00
* @description This Class utilizes the CS_Trigger_Setting__c custom setting to determine if functionality should be executed
*/
public class TriggerHelper {
	private static Boolean OVERRIDE_TRIGGERHELPER = false;
	private static Boolean OVERRIDE_TRIGGERHELPER_VALUE = true;
	public static Map<String,Boolean> CachedTriggerSettings {get;set;} //Used to turn on/off functionality temporarily
	private static void InitializeCache(){
		if(CachedTriggerSettings == null){
			CachedTriggerSettings = new Map<String,Boolean>();
			Map<String,CS_Trigger_Setting__c> trigSettings = CS_Trigger_Setting__c.getall(); 
		    //If field doesn't exist and isn't explicitly set to false fire logic  
			for(CS_Trigger_Setting__c field : trigSettings.values()){
				CachedTriggerSettings.put(field.Name,field.Enabled__c); 
			}  
		} 
	}
	/**
	* @author CRMCulture
	* @version 1.00
	* @param key - the key of the name on the CS_Trigger_Setting__c table
	* @description Determine if functionality should execute from custom setting 
	* @return Boolean if to execute code - defaults true
	*/
	public static Boolean DoExecute(String key){
		if(OVERRIDE_TRIGGERHELPER){return OVERRIDE_TRIGGERHELPER_VALUE;}
		InitializeCache();
		if(CachedTriggerSettings.containsKey(key)){
			return CachedTriggerSettings.get(key);
		}else{ 
			CS_Trigger_Setting__c newCS = new CS_Trigger_Setting__c(Name=key,Enabled__c=true);
			insert newCS;
			CachedTriggerSettings.put(key,true);
			return true;
		} 
	}
	/**
	* @author CRMCulture
	* @version 1.00
	* @param key - the key of the name on the CS_Trigger_Setting__c table
	* @param value - the value to overide the setting with within the execution context
	* @description Override the custom setting value for within the scope of the execution context
	* @return void
	*/
	public static void TemporaryOveride(String key, Boolean value){
		InitializeCache();
		CachedTriggerSettings.put(key,value);
	}
	/**
	* @author CRMCulture
	* @version 1.00
	* @param pTurnOverrideOn - turn overriding all Trigger Setting values on/off
	* @param pValueToOverideWith - when pTurnOverrideOn is true the value to return when DoExecute is called
	* @description Override all custom setting values - USEFUL FOR TESTING UTILITY
	* @return void
	*/
	public static void OverideAllSettings(Boolean pTurnOverrideOn, Boolean pValueToOverideWith){
		OVERRIDE_TRIGGERHELPER = pTurnOverrideOn;
		OVERRIDE_TRIGGERHELPER_VALUE = pValueToOverideWith;
	} 
}