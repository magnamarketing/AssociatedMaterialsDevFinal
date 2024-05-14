/**
*   @author CRMCulture, LLC
*
*/
@isTest
public class TestingUtility {
    /**
    * Construct this class to help you create objects for test classes
    *
    * @author CRMCulture 
    * @version 1.00  
    * @description  Class to assist in creating test data example usage
    * public static testMethod void testMethod1(){
    *   TestingUtility.TestData td = new TestingUtility.TestData();
    *   system.assert(td.Accounts.size() > 0);
    * }
    */
    public class TestData{
        public List<Account> Accounts {get;set;} 
        public List<Contact> Contacts {get;set;}
        public List<Opportunity> Opportunities {get;set;}
        public Map<String,Map<String,Id>> RecordTypeMapping {get;set;}
        public TestData(){
            TriggerHelper.overideAllSettings(true,false);//TURNS ON OVERRIDE TO TURN OFF ALL TRIGGERS 
            //Query for and cache recordtype table to use for all Testing Classes
            //RecordTypeMapping = new Map<String,Map<String,Id>>();
            //for(RecordType rt : [select Id, DeveloperName, sobjectType from RecordType where IsActive = true]){
            //    if(!RecordTypeMapping.containsKey(rt.sObjectType)){
            //        RecordTypeMapping.put(rt.sObjectType, new Map<String,Id>());
            //    }
            //    RecordTypeMapping.get(rt.sObjectType).put(rt.DeveloperName, rt.Id); 
            //} 
            //ALL objects created will have the default RecordType applied 
            Accounts = (List<Account>)TestingUtility.createSObjectList('Account',2,true,true);   
            //Accounts[0].RecordTypeId = RecordTypeMapping.get('Account').get('DevNameOfRecordType'); 
            //Accounts[1].RecordTypeId = RecordTypeMapping.get('Account').get('DevNameOfRecordType');
            insert Accounts;
            TestingUtility.addCachedObjectLookup('Account',Accounts[0].Id);//This will make this account the default for all other object lookups
            Contacts = (List<Contact>)TestingUtility.createSObjectList('Contact',2,true,true);
            Contacts[0].AccountId = Accounts[0].Id;
            Contacts[1].AccountId = Accounts[1].Id;
            Contacts[0].Phone = '555-555-5555';
            Contacts[0].MailingCity = 'Denver';
            Contacts[0].MailingPostalCode = '80203';
            Contacts[0].MailingStreet = '123 Test St.';
            Contacts[1].Phone = '555-555-5555';
            Contacts[1].MailingCity = 'Denver';
            Contacts[1].MailingPostalCode = '80203';
            Contacts[1].MailingStreet = '123 Test St.';
            //Contacts[0].RecordTypeId = RecordTypeMapping.get('Contact').get('DevNameOfRecordType'); 
            //Contacts[1].RecordTypeId = RecordTypeMapping.get('Contact').get('DevNameOfRecordType');
            insert Contacts; 
            TestingUtility.addCachedObjectLookup('Contact',Contacts[0].Id);//This will make this contact the default for all other object lookups
            Opportunities = (List<Opportunity>)TestingUtility.createSObjectList('Opportunity',2,true,true);
            Opportunities[0].AccountId = Accounts[0].Id;
            Opportunities[1].AccountId = Accounts[1].Id;
            //Opportunities[0].RecordTypeId = RecordTypeMapping.get('Opportunity').get('DevNameOfRecordType'); 
            //Opportunities[1].RecordTypeId = RecordTypeMapping.get('Opportunity').get('DevNameOfRecordType');
            insert Opportunities;

            TriggerHelper.overideAllSettings(false,false);//TURNS OFF OVERRIDE FOR TRIGGERS
        }
    }
    public static testMethod void triggerHelperTest(){ 
        Test.startTest();
        System.assert(TriggerHelper.DoExecute('XYZ'), 'Trigger Set To False by default');
        TriggerHelper.TemporaryOveride('XYZ', false);
        System.assert(!TriggerHelper.DoExecute('XYZ'), 'Trigger Not Set To False'); 
        Test.stopTest(); 
    }
    public static testMethod void utilityClassTest(){ 
        Test.startTest(); 
        System.assert(UtilityClass.NewGuid() != UtilityClass.NewGuid(), 'Error creating Unique GUIDS');
        Test.stopTest(); 
    }
    // Key : SobjectAPIName  For ex. Account 
    // Value : Map<String, Schema.SObjectField>, field map (k:fieldname, v:Schema.Sobjectfield)
    public static Profile UserProfile = [Select Id from Profile where Name = 'System Administrator' Order By CreatedDate limit 1];

    private static final Map<String, Map<String, Schema.SObjectField>> FieldMapCache = new Map<String, Map<String, Schema.SObjectField>>();

    private static final Map<String, Schema.SObjectType> GlobalDescribe = Schema.getGlobalDescribe();

    // Default Country and State
    // When Country and State Picklists are enabled, cannot dynamically resolve which States are within a Country
    public static string DefaultCountry = 'United States';
    public static string DefaultState = 'Colorado';

    // Key: sobject.field
    // Value: first picklist value
    private static final Map<String, String> DefaultPicklistValue = new Map<String, String>();

    // can't map by Schema.sObjectType, use object name String instead
    public static Map<String, set<String>> ExcludedFields = new Map<String, Set<String>>{
        'All' => new Set<String>{'OwnerId', 'LastModifiedById', 'CreatedById', 'LastModifiedDate', 'CreatedDate'},
        'Account' => new Set<String>{'FirstName', 'LastName'},
        'User' => new Set<String>{'IsActive','DelegatedApproverId','CallCenterId','ContactId','DelegatedApproverId','ManagerId','UserRoleId','FederationIdentifier'}
    };

    // include nillable fields
    public static Map<String, set<String>> IncludedFields = new Map<String, Set<String>>();

    /**
    * Create a list of sobjects
    *
    * @author CRMCulture 
    * @version 1.00  
    * @description  Return a list of fully populated sobjects
    * @param objectType - The name of the object example 'Account' 
    * @param numberOfObjects - How many objects to create
    * @param useAlreadyCreatedRelationships - Lookups and master details will attempt to use objects already create in the test environment, will not lookup (incurs soql call)
    * @param createMisslingRelationships - if useAlreadyCreatedRelationships is true and no objects are found it will create a simple object to populate the relationship (incurs dml)
    *                                   if useAlreadyCreateRelationships is false it will always create the relationship object
    * @return List of specified sobjects
    */
    public static List<SObject> createSObjectList(String objectType, Integer numberOfObjects, Boolean useAlreadyCreatedRelationships, Boolean createMissingRelationships) {

        List<SObject> sos = new List<SObject>();
        for( Integer i=0; i<numberOfObjects; i++ )
            sos.add(createSObject(objectType, i, useAlreadyCreatedRelationships, createMissingRelationships));
        return sos;  
    } 
    /**
    * Create a list of sobjects
    *
    * @author CRMCulture 
    * @version 1.00  
    * @description  Return a list of fully populated sobjects (sans relationships)
    * @param objectType - The name of the object example 'Account' 
    * @param numberOfObjects - How many objects to create 
    * @return List of specified sobjects
    */
    public static List<SObject> createSObjectList(String objectType, Integer numberOfObjects ) { 
        return createSObjectList(objectType,numberOfObjects,false,false);  
    }
    /**
    * Create an sobject
    *
    * @author CRMCulture 
    * @version 1.00  
    * @description  Return fully populated sobject
    * @param objectType - The name of the object example 'Account' 
    * @param numberOfObjects - How many objects to create
    * @param useAlreadyCreatedRelationships - Lookups and master details will attempt to use objects already create in the test environment, will not lookup (incurs soql call)
    * @param createMisslingRelationships - if useAlreadyCreatedRelationships is true and no objects are found it will create a simple object to populate the relationship (incurs dml)
    *                                   if useAlreadyCreateRelationships is false it will always create the relationship object
    * @return  sobject
    */
    public static SObject createSObject(String objectType, Boolean useAlreadyCreatedRelationships, Boolean createMissingRelationships) {
        return createSObject(objectType, 1, useAlreadyCreatedRelationships, createMissingRelationships);
    }
    /**
    * Create an sobject
    *
    * @author CRMCulture 
    * @version 1.00  
    * @description  Return fully populated sobject (sans relationship fields)
    * @param objectType - The name of the object example 'Account' 
    * @return  sobject
    */
    public static SObject createSObject(String objectType) {
        return createSObject(objectType,false,false);
    }
    private static SObject createSObject(String objectType, Integer counter, Boolean useAlreadyCreatedRelationships, Boolean createMissingRelationships) {
        //System.debug('Creating ' + objectType);
        Schema.sObjectType token = GlobalDescribe.get(objectType);
        if (token == null) {
            return null;//throw new Exception('Unsupported ObjectType ' + objectType);
        }

        SObject obj = token.newSObject();       

        for (Schema.SObjectField field : fieldMapFor(objectType).values()) {
            setFieldValue(obj, field, counter, useAlreadyCreatedRelationships, createMissingRelationships);
        }

        return obj;
    }
    /**
    *   Returns a field map for a given sobject. 
    *
    *   Note : this method is kept public for Test cases to share the same field map info, without requiring a field desribe.
    *
    *   @param objectType sobject api name for ex. Account
    *   @returns FieldMap [Key:FieldName,Value:Schema.SObjectField]
    */
    public static  Map<String, Schema.SObjectField> fieldMapFor(String objectType) {
        Map<String, Schema.SObjectField> fieldMap = null;
        String normalizedObjectType = objectType.toLowerCase();

        if (FieldMapCache.containsKey(normalizedObjectType)) {
            fieldMap = FieldMapCache.get(normalizedObjectType);
        } else {
            fieldMap = GlobalDescribe.get(objectType).getDescribe().fields.getMap();
            // cache it for next use
            FieldMapCache.put(normalizedObjectType, fieldMap);
        }

        return fieldMap;
    }

    private static String getDefaultPicklistValue(SObject obj, Schema.DescribeFieldResult fieldDescribe) {
        String key = obj.getSObjectType() + '.' + fieldDescribe.getName();

        if (!DefaultPicklistValue.containsKey(key)) {
            List<Schema.PicklistEntry> entries = fieldDescribe.getPicklistValues();
            String value = entries.size() > 0 ? entries[0].getValue() : null;
            DefaultPicklistValue.put(key, value);
        }

        return DefaultPicklistValue.get(key);
    }

    private static boolean isExcludedField(Schema.DescribeFieldResult fieldDescribe) {
        return ExcludedFields.get('All').contains(fieldDescribe.getName());
    }

    private static boolean isExcludedField(SObject obj, Schema.DescribeFieldResult fieldDescribe) {
        set<String> fields = ExcludedFields.get(obj.getSObjectType().getDescribe().getName());
        return fields == null ? false : fields.contains(fieldDescribe.getName());
    }

    private static boolean isIncludedField(SObject obj, Schema.DescribeFieldResult fieldDescribe) {
        set<String> fields = includedFields.get(obj.getSObjectType().getDescribe().getName());
        return fields == null ? false : fields.contains(fieldDescribe.getName());
    }

    static boolean isPersonAccountField(Schema.DescribeFieldResult fieldDescribe) {
                Boolean isPersonAccountEnabled = fieldMapFor('Account').get('IsPersonAccount') != null;
                set<string> skipPersonAccountFields = new set<string>{ 'Salutation' };
            
                Boolean CustomPerson = fieldDescribe.isCustom() && fieldDescribe.getName().endsWith('pc');
                Boolean StandardPerson = !fieldDescribe.isCustom() && fieldDescribe.getName().startsWith('Person');

                return CustomPerson || StandardPerson || 
                    (isPersonAccountEnabled && skipPersonAccountFields.contains(fieldDescribe.getName()));
    }

    static void setFieldValue(SObject obj, Schema.SObjectField field, Boolean useAlreadyCreatedRelationships, Boolean createMissingRelationships) {
        setFieldValue(obj, field, 0, useAlreadyCreatedRelationships, createMissingRelationships);
    }
    /**
    * Access this map from your test class to have all objects use the object Id you set
    */
    private static Map<String,Id> cachedObjectLookups {get;set;}
    public static void addCachedObjectLookup(String objectTypeName, Id idToUse){
        if(cachedObjectLookups == null){cachedObjectLookups = new Map<String,Id>();}
        cachedObjectLookups.put(objectTypeName,idToUse);
    }

    static void setFieldValue(SObject obj, Schema.SObjectField field, Integer counter, Boolean useAlreadyCreatedRelationships, Boolean createMissingRelationships) {
        if(cachedObjectLookups == null){cachedObjectLookups = new Map<String,Id>();}
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        Boolean cascade = useAlreadyCreatedRelationships || createMissingRelationships;
        if (fieldDescribe.isCreateable() && 
            (
                isIncludedField(obj, fieldDescribe) || 
                (
                    (
                        (!fieldDescribe.isNillable()) || (fieldDescribe.getType() == Schema.DisplayType.Reference && cascade) // always fill references with cascade
                    ) && 
                    !isExcludedField(fieldDescribe) &&
                    !isExcludedField(obj, fieldDescribe) &&
                    !isPersonAccountField(fieldDescribe)
                )
             )
            ) {

            if (fieldDescribe.getName().endsWith('Country')) {
                obj.put(field, DefaultCountry);
            } else if (fieldDescribe.getName().endsWith('State')) {
                obj.put(field, DefaultState);
            } else if (fieldDescribe.getType() == Schema.DisplayType.base64) {
                obj.put(field, blob.valueOf(counter.format()));
            } else if (fieldDescribe.getType() == Schema.DisplayType.Boolean) {
                obj.put(field, false);
                if(fieldDescribe.getName().equalsIgnoreCase('active') || fieldDescribe.getName().equalsIgnoreCase('isactive') 
                    || fieldDescribe.getName().equalsIgnoreCase('active__c') || fieldDescribe.getName().equalsIgnoreCase('isactive__c') ){
                    obj.put(field,true);
                } 
            } else if (fieldDescribe.getType() == Schema.DisplayType.Combobox) {
                obj.put(field, counter.format());
            } else if (fieldDescribe.getType() == Schema.DisplayType.Currency) {
                obj.put(field, counter);
            } else if (fieldDescribe.getType() == Schema.DisplayType.Date) {
                obj.put(field, Date.today());
            } else if (fieldDescribe.getType() == Schema.DisplayType.DateTime) {
                obj.put(field, DateTime.now());
            } else if (fieldDescribe.getType() == Schema.DisplayType.Double) {
                obj.put(field, counter);
            } else if (fieldDescribe.getType() == Schema.DisplayType.Email) {
                obj.put(field, 'test' + counter.format() + '@mailinator.com');
            } else if (fieldDescribe.getType() == Schema.DisplayType.EncryptedString) {
                obj.put(field, 's');
            } else if (fieldDescribe.getType() == Schema.DisplayType.Id) {
                //System.debug('Id field ' + fieldDescribe.getName());
            } else if (fieldDescribe.getType() == Schema.DisplayType.Integer) {
                obj.put(field, counter);
            } else if (fieldDescribe.getType() == Schema.DisplayType.MultiPicklist) {
                obj.put(field, getDefaultPicklistValue(obj, fieldDescribe));
            } else if (fieldDescribe.getType() == Schema.DisplayType.Percent) {
                obj.put(field, counter);
            } else if (fieldDescribe.getType() == Schema.DisplayType.Phone) {
                obj.put(field, '123-456-7890');
            } else if (fieldDescribe.getType() == Schema.DisplayType.Picklist) {
                obj.put(field, getDefaultPicklistValue(obj, fieldDescribe));
            } else if (fieldDescribe.getName() == 'CommunityNickname' && fieldDescribe.getType() == Schema.DisplayType.String) { 
                obj.put(field, 'test'+ string.valueof(math.roundtolong(math.random()*1000000)) ); 
            } else if (fieldDescribe.getName() == 'UserName' && fieldDescribe.getType() == Schema.DisplayType.String) { 
                obj.put(field, 'test'+ string.valueof(Userinfo.getOrganizationId())+ string.valueof(math.roundtolong(math.random()*1000000))+ string.valueof(Datetime.now()).replace('-','').replace(':','').replace(' ','')+'@mailinator.com'); // was a@a.com
            } else if (fieldDescribe.getType() == Schema.DisplayType.String) {
                obj.put(field, counter.format()); 
            } else if (fieldDescribe.getType() == Schema.DisplayType.Reference) {
                String referenceObjectType = fieldDescribe.getReferenceTo()[0].getDescribe().getName();
                try{ 
                    if (referenceObjectType == 'RecordType') {
                        setRecordType(obj);
                    } else if (cascade && referenceObjectType != obj.getSObjectType().getDescribe().getName() && referenceObjectType !='BusinessHours') {
                        // TODO avoid infinite loop for same-type references
                        Boolean foundItem = false; 
                        if(useAlreadyCreatedRelationships){
                            if(cachedObjectLookups.containsKey(referenceObjectType)){//reduce number of SOQL calls
                                obj.put(field,cachedObjectLookups.get(referenceObjectType));
                                foundItem = true;
                            }
                            else{
                                String rSoql = ' select Id from ' + referenceObjectType + ' limit 1'; 
                                List<sObject> referenceQuery = database.query(rsoql);
                                if(referenceQuery.size() > 0){
                                    foundItem = true;
                                    obj.put(field,referenceQuery[0].Id);
                                    cachedObjectLookups.put(referenceObjectType,referenceQuery[0].Id);
                                }
                            }
                        }
                        if(createMissingRelationships && !foundItem){
                            //System.debug('Creating reference to ' + referenceObjectType + ' for field ' + obj.getSObjectType().getDescribe().getName() + '.' + fieldDescribe.getName());
                            SObject referenceObj = createSObject(referenceObjectType);//don't recursively go down rabbit hole with more cascading
                            //System.debug('Inserting ' + reference);
                            insert referenceObj;
                            obj.put(field, referenceObj.Id);
                            cachedObjectLookups.put(referenceObjectType,referenceObj.Id);
                        } 
                    }
                    else if (referenceObjectType == 'Profile') { 
                        obj.put(field,userProfile.Id);
                    }
                }catch(DmlException ex){
                    //System.debug('Failed insert for ' + referenceObjectType + ' ' + ex.getMessage());
                }
            } else if (fieldDescribe.getType() == Schema.DisplayType.TextArea) {
                obj.put(field, counter.format()); 
            } else if (fieldDescribe.getType() == Schema.DisplayType.Time) {
                obj.put(field, Time.newInstance(0, 0, 0, 0)); 
            } else if (fieldDescribe.getType() == Schema.DisplayType.URL) {
                obj.put(field, 'http://test' + counter + '.com'); 
            } else {
                //System.debug('Unhandled field type ' + fieldDescribe.getType());
            }
        }   
    }


    static void setRecordType(SObject obj) {
        List<Schema.RecordTypeInfo> recordTypes = obj.getSObjectType().getDescribe().getRecordTypeInfos();

        if (recordTypes.size() > 1) { // all objects have default Master type
            //System.debug('RecordTypes ' + recordTypes);
            for (Schema.RecordTypeInfo recordType : recordTypes) {
                if (recordType.isAvailable() && recordType.isDefaultRecordTypeMapping()) {
                    obj.put('RecordTypeId', recordType.getRecordTypeId());
                }
            }
        }

    }
}