public class JobTriggerHandler  {

    public static void handleAfterInsert(){
        List<ID> newJobIDs = new List<ID>();
        for(Job__c auxJob : (List<Job__c>)Trigger.new){
            newJobIDs.add(auxJob.ID);
        }
        checkForPropertyRelationshipRecords_Future(newJobIDs);
    }

    @future
    public static void checkForPropertyRelationshipRecords_Future(List<ID> newJobIDs){
        List<Job__c> newJobs = [SELECT ID, Poperty__c, Account_Tier_1__c,Account_Tier_2__c, Account_Tier_3__c,
                                Dealer_Contact__c
                                FROM Job__c 
                                WHERE ID in :newJobIDs];
        List<Id> propertyLookupValues = new List<Id>();
        List<Property_Relationship__c> propRelationshipsToInsert = new List<Property_Relationship__c>();
        // 1) First, loop all the Job__c records being inserted, gather a list of the “Property__c” lookup values.
        for(Job__c jobAux : newJobs){
            if(jobAux.Poperty__c != null){
                propertyLookupValues.add(jobAux.Poperty__c);
            }
        }
        // 2) Query all “Property_Relationship__c” records that have the “Property__c” lookup within the List created in step 1.
        List<Property_Relationship__c> relatedPropRelationshipRecords = [SELECT ID,
                                                                                Property__c,
                                                                                Relationship_Type__c,
                                                                                Account_tier_1__c,
                                                                                Account_tier_2__c,
                                                                                Account_tier_3__c
                                                                         FROM Property_Relationship__c
                                                                         WHERE Property__c in :propertyLookupValues];
        // 3) Create a Map<ID,List<Property_Relationship__c>>; Loop all the Property_Relationships from Step 2, 
        // and fill in the Map using the Property__c lookup from the Property_Relationship as key, 
        // and link all matching PropertyRelationships.
        Map<ID,List<Property_Relationship__c>> mapPropertyToPropRelationships = new Map<ID, List<Property_Relationship__c>>();

        for(Property_Relationship__c propRelationshipAux : relatedPropRelationshipRecords){
            if(mapPropertyToPropRelationships.get(propRelationshipAux.Property__c) == null){
                List<Property_Relationship__c> propRelList = new List<Property_Relationship__c>();
                propRelList.add(propRelationshipAux);
                mapPropertyToPropRelationships.put(propRelationshipAux.Property__c,propRelList);
            }else{
                List<Property_Relationship__c> propRelList = mapPropertyToPropRelationships.get(propRelationshipAux.Property__c);
                propRelList.add(propRelationshipAux);
                mapPropertyToPropRelationships.put(propRelationshipAux.Property__c,propRelList);
            }
        }
        // 4) Loop again trough all the Job__c records being inserted, per each Job__c, 
        // find out if there are Property_Relationship records within the map using the Job__c.Property__c lookup as key.
        // If there are, check to see if any of them match the criteria. 
        // If no Property_Relationship is found, or none that are found match the criteria, 
        // a new Property_Relationship should be created as described.
        for(Job__c jobAux : newJobs){
            if(jobAux.Poperty__c != null){
                // Check and see if a correct PropertyRelationship record exists already.
                if(mapPropertyToPropRelationships.get(jobAux.Poperty__c) == null){
                    propRelationshipsToInsert.add(createPropertyRelationship(jobAux));
                }else if(!propertyRelationshipExists(jobAux, mapPropertyToPropRelationships.get(jobAux.Poperty__c))){
                    propRelationshipsToInsert.add(createPropertyRelationship(jobAux));
                }
            }
        }

        insert propRelationshipsToInsert;
    }

    private static Property_Relationship__c createPropertyRelationship(Job__c jobAux){
        Property_Relationship__c auxPropRelationship = new Property_Relationship__c();
        auxPropRelationship.Property__c = jobAux.Poperty__c;
        auxPropRelationship.Relationship_Type__c = 'Dealer';
        auxPropRelationship.Account_Tier_1__c = jobAux.Account_Tier_1__c;
        auxPropRelationship.Account_Tier_2__c = jobAux.Account_Tier_2__c;
        auxPropRelationship.Account_Tier_3__c = jobAux.Account_Tier_3__c;
        auxPropRelationship.Contact__c = jobAux.Dealer_Contact__c;
        return auxPropRelationship;
    }

    private static Boolean propertyRelationshipExists(Job__c jobAux, List<Property_Relationship__c> propRelationships){
        Boolean matchFound = false;
        for(Property_Relationship__c propRelationshipAux : propRelationships){
            if(propRelationshipAux.Relationship_Type__c == 'Dealer' 
                && jobAux.Account_Tier_1__c == propRelationshipAux.Account_Tier_1__c
                && jobAux.Account_Tier_2__c == propRelationshipAux.Account_Tier_2__c
                && jobAux.Account_Tier_3__c == propRelationshipAux.Account_Tier_3__c){
                matchFound = true;
                break;
            }
        }
        return matchFound;
    }

}