/**
Company    : Fujitsu America
Date       : Mar 2010
Author     : Anand Sharma
Description: Helper Class for populate delivery Dates value into Accounts. 
History    :              
*/
public with sharing class OrderHelper {
	//Property 
	//Hold Days as key and index as value
	private static Map<String , Integer> mapDateIndex{
		get{
			if(mapDateIndex == null){
				mapDateIndex = new Map<String, Integer>();
				mapDateIndex.put('MON',1);
				mapDateIndex.put('TUE',2);
				mapDateIndex.put('WED',3);
				mapDateIndex.put('THU',4);
				mapDateIndex.put('FRI',5); 
			}
			return mapDateIndex;						
		}
		set;
	} 
	//Hold index as key and days as value
	private static Map<Integer , String> mapDate{
		get{
			if(mapDate == null){
				mapDate = new Map<Integer , String>();
				mapDate.put(1,'MON');
				mapDate.put(2,'TUE');
				mapDate.put(3,'WED');
				mapDate.put(4,'THU');
				mapDate.put(5, 'FRI');
			}
			return mapDate;						
		}
		set;
	}

	 
	//Populate the Delivery date into account
	public static List<Account> PopulateDeliveryDate(List<Account> lstAccount){
		// temparory variable used in calculation
		List<Account> templstAccount = new List<Account>();		
		String strDeliveryDay ='';
		String strAltDeliveryDay ='';
		Integer intOffsetValue;
		Integer intAltOffsetValue;
		
		for(Account acct: lstAccount){
			//reset Delivery Day and Alt Delivery Day value 
			strDeliveryDay ='';
			strAltDeliveryDay ='';
			// assign Delivery Day off set value and Alt Delivery Day off set value to variable
			if(acct.Delivery_Day_Offset__c != null){
				intOffsetValue =  acct.Delivery_Day_Offset__c.intValue();
				// Check for every ship day
				if(acct.Ship_Monday__c){
					strDeliveryDay =  strDeliveryDay + getDeliveryDayUsingOffset('MON', intOffsetValue) + '; ';
				}
				if(acct.Ship_Tuesday__c){
					strDeliveryDay =  strDeliveryDay + getDeliveryDayUsingOffset('TUE', intOffsetValue) + '; ';
				}
				if(acct.Ship_Wednesday__c){
					strDeliveryDay =  strDeliveryDay + getDeliveryDayUsingOffset('WED', intOffsetValue) + '; ';
				}
				if(acct.Ship_Thursday__c){
					strDeliveryDay =  strDeliveryDay + getDeliveryDayUsingOffset('THU', intOffsetValue) + '; ';
				}
				if(acct.Ship_Friday__c){
					strDeliveryDay =  strDeliveryDay + getDeliveryDayUsingOffset('FRI', intOffsetValue) + '; ';
				}
				if(acct.Ship_Saturday__c){
					strDeliveryDay =  strDeliveryDay + getDeliveryDayUsingOffset('MON', intOffsetValue) + '; ';
				}
				if(acct.Ship_Sunday__c){
					strDeliveryDay =  strDeliveryDay + getDeliveryDayUsingOffset('MON', intOffsetValue) + '; ';
				}
				// remove the ';' from the end 
				if(strDeliveryDay.endsWith('; ')){
					strDeliveryDay = strDeliveryDay.substring(0, strDeliveryDay.length()-1);
				}
				//assign Delivery day variable value to the account Delivery day field 
				acct.Delivery_Day__c = strDeliveryDay;				
			}else{
				//assign Delivery day variable value to the account Delivery day field 
				acct.Delivery_Day__c = null;	
			} 
			
			if(acct.Alt_Delivery_Day_Offset__c != null){
				intAltOffsetValue = acct.Alt_Delivery_Day_Offset__c.intValue();
				// Check for every Alt ship day			
				if(acct.Alt_Ship_Monday__c){
					strAltDeliveryDay =  strAltDeliveryDay + getDeliveryDayUsingOffset('MON',intAltOffsetValue) + '; ';
				}
				if(acct.Alt_Ship_Tuesday__c){
					strAltDeliveryDay =  strAltDeliveryDay + getDeliveryDayUsingOffset('TUE',intAltOffsetValue) + '; ';
				}
				if(acct.Alt_Ship_Wednesday__c){
					strAltDeliveryDay =  strAltDeliveryDay + getDeliveryDayUsingOffset('WED',intAltOffsetValue) + '; ';
				}
				if(acct.Alt_Ship_Thursday__c){
					strAltDeliveryDay =  strAltDeliveryDay + getDeliveryDayUsingOffset('THU',intAltOffsetValue) + '; ';
				}
				if(acct.Alt_Ship_Friday__c){
					strAltDeliveryDay =  strAltDeliveryDay + getDeliveryDayUsingOffset('FRI',intAltOffsetValue) + '; ';
				}
				if(acct.Alt_Ship_Saturday__c){
					strAltDeliveryDay =  strAltDeliveryDay + getDeliveryDayUsingOffset('MON',intAltOffsetValue) + '; ';
				}
				if(acct.Alt_Ship_Sunday__c){
					strAltDeliveryDay =  strAltDeliveryDay + getDeliveryDayUsingOffset('MON',intAltOffsetValue) + '; ';
				}
				// remove the ';' from the end 
				if(strAltDeliveryDay.endsWith('; ')){
					strAltDeliveryDay = strAltDeliveryDay.substring(0, strAltDeliveryDay.length()-1);
				}
				//assign Alt Delivery day variable value to the account Alt Delivery day field 
				acct.Alt_Delivery_Day__c = strAltDeliveryDay;
			}else {
				//assign Alt Delivery day variable value to the account Alt Delivery day field 
				acct.Alt_Delivery_Day__c = null;
			}		
		}
		return templstAccount;	
	}
	//fetch the ship day after adding offset into the days.
	private static String getDeliveryDayUsingOffset(String strDay, Integer intOffSet){
		String strReturn ='';
		Integer intIndex = mapDateIndex.get(strDay);		
		for(Integer i = 1; i <= intOffSet; i++){
			intIndex++;
			if(intIndex > 5){
				intIndex = 1;
			}
		}		
		strReturn = mapDate.get(intIndex);
		
		return strReturn;
	}	
}