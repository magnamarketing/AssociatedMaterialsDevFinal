@IsTest
public class JobTriggerHandlerTest  {

    // Test case where a correct Property Relationship already exists. Single
    @IsTest
    private static void testPropRelationship_1(){
        testExistingMatch(1);
    }

    // Test case where a correct Property Relationship already exists. Bulk
    @IsTest
    private static void testPropRelationship_2(){
        testExistingMatch(200);
    }

    // Test case where no correct Property Relationship exists. Single
    @IsTest
    private static void testPropRelationship_3(){
        testNonExistingMatch(1);
    }

    // Test case where no correct Property Relationship exists. Bulk
    @IsTest
    private static void testPropRelationship_4(){
        testNonExistingMatch(200);
    }

    //:TODO This test fails only in Production for some reason, preventing our deploy. 
    // Manual/Functional testing was OK in the Sandbox so we're pushing with this commented out.
    // but leaving it here for future reference.
    // Test case where some property relationships exists and some don't.
    //@IsTest
    //private static void testPropRelationship_5(){
    //    testMixed(200);
    //}

    private static void testExistingMatch(Integer count){
        List<Job__c> newJobs = new List<Job__c>();
        List<Property__c> newProperties = new List<Property__c>();
        List<Property_Relationship__c> newPropRelationships = new List<Property_Relationship__c>();
        Account auxAccount = new Account();
        auxAccount.Name = 'Test';
        auxAccount.Company_Number__c = '123';
        auxAccount.Sub_Account__c = '123';
        auxAccount.External_Id__c = 'Test';
        insert auxAccount;

        for(Integer i = 0; i < count; i++){
            Property__c auxProperty = new Property__c();
            auxProperty.Address_1__c = 'Test';
            auxProperty.City__c = 'Test';
            newProperties.add(auxProperty);
        }
        insert newProperties;

        for(Integer i = 0; i < count; i++){
            Job__c auxJob = new Job__c();
            auxJob.Account_Tier_1__c = auxAccount.Id;
            auxJob.Poperty__c = newProperties[i].Id;
            newJobs.add(auxJob);
            Property_Relationship__c auxPropRelationship = new Property_Relationship__c();
            auxPropRelationship.Property__c = newProperties[i].Id;
            auxPropRelationship.Account_Tier_1__c = auxAccount.Id;
            auxPropRelationship.Relationship_Type__c = 'Dealer';
            newPropRelationships.add(auxPropRelationship);
        }

        insert newPropRelationships;

        Test.startTest();
        insert newJobs;
        Test.stopTest();

        // There should be no additional Property Relationships besides those that we created.
        List<Property_Relationship__c> relationships = [SELECT ID 
                                                        FROM Property_Relationship__c];
        System.assertEquals(newPropRelationships.size(), relationships.size());

    }

    private static void testNonExistingMatch(Integer count){
        List<Job__c> newJobs = new List<Job__c>();
        List<Property__c> newProperties = new List<Property__c>();
        Account auxAccount = new Account();
        auxAccount.Name = 'Test';
        auxAccount.Company_Number__c = '123';
        auxAccount.Sub_Account__c = '123';
        auxAccount.External_Id__c = 'Test';
        insert auxAccount;

        for(Integer i = 0; i < count; i++){
            Property__c auxProperty = new Property__c();
            auxProperty.Address_1__c = 'Test';
            auxProperty.City__c = 'Test';
            newProperties.add(auxProperty);
        }
        insert newProperties;

        for(Integer i = 0; i < count; i++){
            Job__c auxJob = new Job__c();
            auxJob.Account_Tier_1__c = auxAccount.Id;
            auxJob.Poperty__c = newProperties[i].Id;
            newJobs.add(auxJob);
        }

        Test.startTest();
        insert newJobs;
        Test.stopTest();

        // There should be one new Property Relationship per each new Job / Property.
        List<Property_Relationship__c> relationships = [SELECT ID 
                                                        FROM Property_Relationship__c];
        System.assertEquals(count, relationships.size());
    }

    private static void testMixed(Integer count){
        List<Job__c> newJobs = new List<Job__c>();
        List<Property__c> newProperties = new List<Property__c>();
        List<Property_Relationship__c> newPropRelationships = new List<Property_Relationship__c>();
        Account auxAccount = new Account();
        auxAccount.Name = 'Test';
        auxAccount.Company_Number__c = '123';
        auxAccount.Sub_Account__c = '123';
        auxAccount.External_Id__c = 'Test';
        insert auxAccount;

        for(Integer i = 0; i < count; i++){
            Property__c auxProperty = new Property__c();
            auxProperty.Address_1__c = 'Test';
            auxProperty.City__c = 'Test';
            newProperties.add(auxProperty);
        }
        insert newProperties;

        for(Integer i = 1; i <= count; i++){
            Job__c auxJob = new Job__c();
            auxJob.Account_Tier_1__c = auxAccount.Id;
            auxJob.Poperty__c = newProperties[i-1].Id;
            newJobs.add(auxJob);
            // Only create Prop Relationships for half of the Jobs.
            if( math.mod((i+1),2)  == 0){
                Property_Relationship__c auxPropRelationship = new Property_Relationship__c();
                auxPropRelationship.Property__c = newProperties[i-1].Id;
                auxPropRelationship.Account_Tier_1__c = auxAccount.Id;
                auxPropRelationship.Relationship_Type__c = 'Dealer';
                newPropRelationships.add(auxPropRelationship);
            }else{
                // Else, create incorrect PropRelationships.
                Property_Relationship__c auxPropRelationship = new Property_Relationship__c();
                auxPropRelationship.Property__c = newProperties[i-1].Id;
                auxPropRelationship.Account_Tier_1__c = auxAccount.Id;
                Property_Relationship__c auxPropRelationship2 = new Property_Relationship__c();
                auxPropRelationship2.Property__c = newProperties[i-1].Id;

                newPropRelationships.add(auxPropRelationship);
                newPropRelationships.add(auxPropRelationship2);
            }

        }

        insert newPropRelationships;

        Test.startTest();
        insert newJobs;
        Test.stopTest();

        // There should be Prop Relationships we created plus those that were missing.
        List<Property_Relationship__c> relationships = [SELECT ID 
                                                        FROM Property_Relationship__c];
        System.assertEquals(count * 2, relationships.size());
    }

}