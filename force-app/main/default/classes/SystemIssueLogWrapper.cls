/**
* @author CRMCulture
* @version 1.00
* @description This Class is a representaiton of a System_Issue_Log__c object
*/
public class SystemIssueLogWrapper{
    public Id IssueId {get;set;}
    public String ClassName {get;set;}
    public String MethodName {get;set;}
    public String Message {get;set;} 
    public List<Id> RecordIds {get;set;}
    public SystemIssueLogWrapper(){ 
        RecordIds = new List<Id>();
    }
    public SystemIssueLogWrapper(String className, String methodName, List<Id> affectedRecords, String message){
        this();
        this.ClassName = className;
        this.MethodName = methodName;
        this.RecordIds.addAll(affectedRecords);
        this.Message = message;
    }
    public SystemIssueLogWrapper(String className, String methodName, List<Id> affectedRecords, Exception ex){
        this(className,methodName,affectedRecords,ex.getMessage() + ' ' + ex.getStackTraceString());
    }
    public SystemIssueLogWrapper(String className, String methodName, List<Id> affectedRecords, Database.Error err){
        this(className,methodName,affectedRecords,err.getMessage() + ' ' + String.valueOf(err.getStatusCode()));
    }
    public SystemIssueLogWrapper(System_Issue_Log__c log){
        this();
        this.IssueId = log.Id; 
        this.ClassName = log.Class_Name__c;
        this.MethodName = log.Method_Name__c;
        this.Message = log.Message__c;
        if(String.isNotBlank(log.Record_Ids__c)){
            List<String> ids =  log.Record_Ids__c.split(',');
            for(String s : ids){
                RecordIds.add(Id.valueOf(s));
            }
        } 
    }

    public String getUniqueId(){
        String uId = (String.isBlank(ClassName) ? '':ClassName) + '|' + (String.isBlank(MethodName) ? '' : MethodName) + '|' + (String.isBlank(Message) ? '' : Message.left(20) );
        if(uId.length() > 255)return uId.Left(255);
        return uId;
    }
    public System_Issue_Log__c getSObject(){
        System_Issue_Log__c newLog = new System_Issue_Log__c();
        if(IssueId != null)newLog = new System_Issue_Log__c(Id=IssueId);
        newLog.Class_Name__c = this.ClassName;
        newLog.Method_Name__c = this.MethodName;
        newLog.Record_Ids__c = String.join(this.RecordIds,',');
        newLog.Message__c = this.Message;
        newLog.Issue_Unique_ID__c = getUniqueId();
        return newLog;
    }
}