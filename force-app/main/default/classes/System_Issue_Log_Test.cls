/**
* @author CRMCulture
* @version 1.00
* @description Test functionality
*/
@isTest
public with sharing class System_Issue_Log_Test{
    /**
    * @author CRMCulture
    * @version 1.00
    * @description Test Happy Path of code
    */
    public static testMethod void testMethod1() {
        //Construct most objects and DML in TestingUtility.TestData class
        TestingUtility.TestData td = new TestingUtility.TestData();
        // Use td.Accounts[0]...etc for DML
        //ApexPages.StandardController sc = new ApexPages.StandardController(td.Accounts[0]);
        //SubProjectViewController cn = new SubProjectViewController(sc);
        Test.startTest();
        SystemIssueLogWrapper i = new SystemIssueLogWrapper('SystemIssueLog_Test', 'testMethod1', new List<Id>(), 'Exception');
        System_Issue_Log_Helper.LogException(i,false);
        System_Issue_Log__c newLog = i.getSObject();
        newLog.Record_Ids__C = '001i000001lLPXw,001i000001lLPXw';
        System_Issue_Log_Helper.LogException(new SystemIssueLogWrapper(newLog),false);
        System_Issue_Log_Helper.UpsertExceptions();
        Test.stopTest();//will sync back up with async operations if future/batch called before this
    }
    /**
    * @author CRMCulture
    * @version 1.00
    * @description Test Exceptions To code
    */
    public static testMethod void testMethod2() {
        //Construct most objects and DML in TestingUtility.TestData class
        TestingUtility.TestData td = new TestingUtility.TestData();
        // Use td.Accounts[0]...etc for DML
        //ApexPages.StandardController sc = new ApexPages.StandardController(td.Accounts[0]);
        //SubProjectViewController cn = new SubProjectViewController(sc);
        Test.startTest();
        Lead ld = new Lead();
        List<SystemIssueLogWrapper> logs = new List<SystemIssueLogWrapper>();
        Database.SaveResult sr = Database.insert(ld,false);
        for(Database.Error err : sr.getErrors()){
            SystemIssueLogWrapper i = new SystemIssueLogWrapper('SystemIssueLog_Test', 'testMethod2', new List<Id>(), err);
            logs.add(i);
        }
        try{
            Lead ld1 = new Lead();
            insert ld1;
        }catch(Exception ex){
            SystemIssueLogWrapper i = new SystemIssueLogWrapper('SystemIssueLog_Test', 'testMethod2', new List<Id>(), ex);
            logs.add(i);
        }
        System_Issue_Log_Helper.LogException(logs,false);
        System_Issue_Log_Helper.UpsertExceptions();
        Test.stopTest();//will sync back up with async operations if future/batch called before this
    } 
    /**
    * @author CRMCulture
    * @version 1.00
    * @description Test Exceptions To code
    */
    public static testMethod void testMethod3() {
        //Construct most objects and DML in TestingUtility.TestData class
        TestingUtility.TestData td = new TestingUtility.TestData();
        // Use td.Accounts[0]...etc for DML
        //ApexPages.StandardController sc = new ApexPages.StandardController(td.Accounts[0]);
        //SubProjectViewController cn = new SubProjectViewController(sc);
        Test.startTest();
        SystemIssueLogWrapper i = new SystemIssueLogWrapper('SystemIssueLog_Test', 'testMethod3', new List<Id>(), 'Exception');
        System_Issue_Log_Helper.LogException(i,true);
        Test.stopTest();//will sync back up with async operations if future/batch called before this
    } 
    /**
    * @author CRMCulture
    * @version 1.00
    * @description Test Exceptions To code
    */
    public static testMethod void testMethod4() {
        //Construct most objects and DML in TestingUtility.TestData class
        TestingUtility.TestData td = new TestingUtility.TestData();
        // Use td.Accounts[0]...etc for DML
        //ApexPages.StandardController sc = new ApexPages.StandardController(td.Accounts[0]);
        //SubProjectViewController cn = new SubProjectViewController(sc);
        Test.startTest();
        SystemIssueLogWrapper i = new SystemIssueLogWrapper('SystemIssueLog_Test', 'testMethod4', new List<Id>{'001i000001lLPXw','001i000001lLPXw'}, 'Exception');
        SystemIssueLogWrapper i2 = new SystemIssueLogWrapper('SystemIssueLog_Test', 'testMethod4', new List<Id>(), 'Exception Is different');
        List<SystemIssueLogWrapper> wrappers = new List<SystemIssueLogWrapper>{i,i2};
        System_Issue_Log_Helper.LogException(wrappers,true);
        Test.stopTest();//will sync back up with async operations if future/batch called before this
    } 
    /**
    * @author CRMCulture
    * @version 1.00
    * @description Test Exceptions To code
    */
    public static testMethod void testMethodTestTrigger() {
        //Construct most objects and DML in TestingUtility.TestData class
        TestingUtility.TestData td = new TestingUtility.TestData();
        // Use td.Accounts[0]...etc for DML
        //ApexPages.StandardController sc = new ApexPages.StandardController(td.Accounts[0]);
        //SubProjectViewController cn = new SubProjectViewController(sc);
        Test.startTest();
        SystemIssueLogWrapper i = new SystemIssueLogWrapper('SystemIssueLog_Test', 'testMethod4', new List<Id>{'001i000001lLPXw','001i000001lLPXw'}, 'Exception');
        SystemIssueLogWrapper i2 = new SystemIssueLogWrapper('SystemIssueLog_Test', 'testMethod4', new List<Id>(), 'Exception Is different');
        List<SystemIssueLogWrapper> wrappers = new List<SystemIssueLogWrapper>{i,i2};
        System_Issue_Log_Helper.LogException(wrappers,true);
        List<System_Issue_Log__c> currentLogs = [select Id, Method_Name__c, Class_Name__C from System_Issue_Log__c];
        currentLogs[0].Record_Ids__c = '';
        update currentLogs;
        Delete [select Id from System_Issue_Log__c];

        Test.stopTest();//will sync back up with async operations if future/batch called before this
    } 
}