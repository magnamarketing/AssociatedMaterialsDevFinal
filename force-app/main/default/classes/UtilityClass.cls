/**
* @author CRMCulture
* @version 1.00, 20140701
* @description This class has helper methods.
*/

public with sharing class UtilityClass {

	/**
	* @author CRMCulture
	* @version 1.00, 20140701
	* @description Gets the type name of the SObject.
	* @param SObject The SObject for which the name to be obtained.
	* @return String - The type name.
	*/
	public static String getSObjectTypeName(SObject so) {
		return so.getSObjectType().getDescribe().getName();
	}

    private static String kHexChars = '0123456789abcdef';
     /**
     * @author CRMCulture
     * @version 1.00, 20140822
     * @return String
     * @description returns a GUID string - helpful for creating unique temporary ids in settings tables
     */
    public static String NewGuid() {

        String returnValue = '';
        Integer nextByte = 0;

        for (Integer i=0; i<16; i++) {

            if (i==4 || i==6 || i==8 || i==10)
                returnValue += '-';

            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if (i==6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }

            if (i==8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }

        return returnValue;
    }

    private static String getCharAtIndex(String str, Integer index) {

        if (str == null) return null;

        if (str.length() <= 0) return str;

        if (index == str.length()) return null;

        return str.substring(index, index+1);
    }

	/**
	* @author CRMCulture
	* @version 1.10, 20151201
	* @description Clones every field given a list of any object type (objects only need to have id field queried)
	* @param SObject The SObject for which the name to be obtained.
	* @return String - The type name.
	*/
    /*
	public static Map<Id, sObject> cloneObjectsMap(List<sObject> sObjects, Schema.SObjectType objectType){
       // A list of IDs representing the objects to clone
       List<Id> sObjectIds = new List<Id>{};
       // A list of fields for the sObject being cloned
       List<String> sObjectFields = new List<String>{};
       // A list of new cloned sObjects
       Map<Id, sObject> clonedSObjects = new Map<Id, sObject>{};

       // Get all the fields from the selected object type using
       // the get describe method on the object type.
       if(objectType != null){
           sObjectFields.addAll(objectType.getDescribe().fields.getMap().keySet());
       }

       // If there are no objects sent into the method,
       // then return an empty list
       if (sObjects != null && !sObjects.isEmpty() && !sObjectFields.isEmpty()){
           // Strip down the objects to just a list of Ids.
           for (sObject objectInstance: sObjects){
               sObjectIds.add(objectInstance.Id);
           }
           // Using the list of sObject IDs and the object type,
           // we can construct a string based SOQL query   to retrieve the field values of all the objects.
           String allSObjectFieldsQuery = 'SELECT ' + sObjectFields.get(0);
           for (Integer i=1 ; i < sObjectFields.size() ; i++){
               allSObjectFieldsQuery += ', ' + sObjectFields.get(i);
           }
           allSObjectFieldsQuery += ' FROM ' +
                                  objectType.getDescribe().getName() +
                                  ' WHERE ID IN (\'' + sObjectIds.get(0) +
                                  '\'';

           for (Integer i=1 ; i < sObjectIds.size() ; i++){
               allSObjectFieldsQuery += ', \'' + sObjectIds.get(i) + '\'';
           }
           allSObjectFieldsQuery += ')';
           try{
               // Execute the query. For every result returned,
               // use the clone method on the generic sObject
               // and add to the collection of cloned objects
               for (SObject sObjectFromDatabase:  Database.query(allSObjectFieldsQuery)){
                   clonedSObjects.put(sObjectFromDatabase.Id, sObjectFromDatabase.clone(false,true));
               }
           }
           catch (Exception ex){
               System.debug('Clone Object Exception:' + ex.getMessage());
               throw ex;
           }
       }

       // return the cloned sObject collection.
       return clonedSObjects;
   }    */


}