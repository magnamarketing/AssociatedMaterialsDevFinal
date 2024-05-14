//*******************************************************************************
//*  Release Notes:                                                             
//*  1.2b3-Advanced Screenpop with sanitize ANI or other variables             
//*  1.2b4-Adding AdvancedScreenpopClient to do MultiMatch results               
//*        display VF page. Adding a Constructor and SetResults function        
//*        to the SimpliCTIScrpopRuleManager class.                             
//*******************************************************************************
global class SimpliCTIScrpopRuleManager
{


    public Static String cResults{get;set;}
    
    public  Static List<Account> AccountResults{get;set;}
    public  Static List<Contact> ContactResults{get;set;}
    public  Static List<Lead> LeadResults{get;set;}
    public  Static List<Case> CaseResults{get;set;}
    public  Static List<Opportunity> OpportunityResults{get;set;}
    
    public Static Integer AccountSize{get;set;}
    public Static Integer ContactSize{get;set;}
    public Static Integer LeadSize{get;set;}
    public Static Integer CaseSize{get;set;}
    public Static Integer OpportunitySize{get;set;}
    
    public String cParams;


    public SimpliCTIScrpopRuleManager(){
    
    }



    public void initSearch(){
     
        
        Map<String,String> params = ApexPages.currentPage().getParameters();
        if(params.size() > 0) {
            cParams= params.get('params');
        }
        search(cParams);
        
    }

    
    static Boolean isEmpty (List <List <sObject>> oList) {
        if ( oList.size() == 0 ) return true;
        Boolean empty = true;
        for ( List<sObject> subList : oList ) {
            if ( subList.size() > 0 ) {
                empty = false;
            }
        }
        return empty;
    }
    
    static String doSQL(String SQL) {
        // SOSL: 'FIND \'1001\' IN PHONE FIELDS RETURNING Account(ID, Name), Contact(ID, Name)'
        if ( SQL.toUpperCase().startsWith('FIND') ) {
            // serializes into an array of arrays of JSON [[JSON1],[JSON2],...]
            List <List <sObject>> qry = search.query(SQL);
            
            if ( isEmpty(qry) ) {
                return null;
            }
            
            for (List<sObject> param : qry) {
            
               setResults(param); 
            }   
             
             
            return JSON.serialize(qry);  
            
        }
        // SOQL: Select ....
        else {
            // serializes into an array of json: [<JSON>]
            List <sObject> qry = Database.query(SQL);
            
            if ( qry.size() == 0)
                return null;
                
            setResults(qry); 
            
            return JSON.serialize(qry);
        }
    }
    
    
    static void setResults(List <sObject> qry) {
      
            SObjectType sObjectType = qry.getSObjectType();
            
            if(sObjectType == Account.sObjectType)
            {
                 AccountResults= ((List<Account>)qry);
                 AccountSize = AccountResults.size();
                 if(AccountSize < 1)
                 AccountResults = null;
            }
            
            else if(sObjectType == Contact.sObjectType)
            {
                 ContactResults= ((List<Contact>)qry);
                 ContactSize = ContactResults.size();
                 if(ContactSize < 1)
                     ContactResults = null;
            }
            
            else if(sObjectType == Lead.sObjectType)
            {
                 LeadResults= ((List<Lead>)qry);
                 LeadSize = LeadResults.size();
                     if(LeadSize < 1)
                         LeadResults = null;
            }
            
            else if(sObjectType == Case.sObjectType)
            {
                 CaseResults= ((List<Case>)qry);
                 CaseSize = CaseResults.size();
                 if(CaseSize < 1)
                      CaseResults = null;
            }
            
            else if(sObjectType == Opportunity.sObjectType)
            {
                 OpportunityResults= ((List<Opportunity>)qry);
                 OpportunitySize = OpportunityResults.size();
                 if(OpportunitySize < 1)
                      OpportunityResults = null;
            }
            
             
    }
     
 
    
   static String santizeInputValues(String inName, String inValue) {
      String outValue = inValue;
    
     // do custom code here....
     if (inName == '${meta_cv9}') {
 //        if (isEmpty(inValue))  {
                // do nothing... return inValue back..
 //        } else 
   /* ANI Length Check with sanitation on 9 and 1
   if (inValue.length() >= 10) {
            
             if (inValue.trim().startsWith('9')){       
                  outValue = inValue.substring(1);   
                   
             if (outValue.trim().startsWith('1')){       
                  outValue = outValue.substring(1); 
             }
     
                       
         } else if (inValue.trim().startsWith('1')){       
                  outValue = inValue.substring(1); 
         }
        } 
      */  
     }
     
     return outValue;
     }
     
    /**
     * Search using a param sequence
     * @param params: var1=val1,var2=val2,...
     */
    webService static String search (String params) 
    {
    
        AccountResults = null;
        ContactResults = null;
        LeadResults = null;
        CaseResults = null;
        OpportunityResults = null;
        
        AccountSize = 0;
        ContactSize = 0;
        LeadSize = 0;
        CaseSize = 0;
        OpportunitySize = 0;
        
        if (params == null)
         {
             return null;
         }
        
        // TODO: fetch SQL from some SF table
        String[] SQL = new String[6];
        
         //SQL[0] = 'FIND \'${meta_cv9}\' IN PHONE FIELDS RETURNING Account(ID, Name, Site,Phone,OwnerId,Owner.Alias), Contact(ID, Name,AccountId, Account.Name, Account.Site,Phone,OwnerId,Owner.Alias,Email), Lead(ID, Name, Title,Company,Email,Status,OwnerId,Owner.Alias), Case(ID, CaseNumber,Subject,Status,OwnerId,Owner.Alias,CreatedDate), Opportunity(ID, Name, Account.Name, Account.Site,StageName,OwnerId,Owner.Alias,CloseDate) ';
           
           //for test case coverage
             SQL[0] = 'FIND \'${meta_cv1}\' IN PHONE FIELDS RETURNING Contact(ID, Name,AccountId, Account.Name, Account.Site,Phone,OwnerId,Owner.Alias,Email)';
           SQL[1] = 'FIND \'${meta_cv9}\' IN PHONE FIELDS RETURNING Account(ID, Name, Site,Phone,OwnerId,Owner.Alias), Contact(ID, Name,AccountId, Account.Name, Account.Site,Phone,OwnerId,Owner.Alias,Email), Lead(ID, Name, Title,Company,Email,Status,OwnerId,Owner.Alias), Case(ID, CaseNumber,Subject,Status,OwnerId,Owner.Alias,CreatedDate), Opportunity(ID, Name, Account.Name, Account.Site,StageName,OwnerId,Owner.Alias,CloseDate) ';
           SQL[2] = 'Select Id, Name from Contact where Phone = \'${meta_cv9}\' ';
           SQL[3] = 'Select Id, CaseNumber,Subject,Status,OwnerId,Owner.Alias,CreatedDate from Case where CaseNumber = \'${meta_cv9}\' ';
           SQL[4] = 'Select Id from Opportunity where Name = \'${meta_cv9}\' ';
           SQL[5] = 'Select Id, Name from Account where Phone = \'${meta_cv9}\' ';
           //SQL[1] = 'FIND \'${meta_cv6}\' IN PHONE FIELDS RETURNING Contact(ID, Name,AccountId, Account.Name, Account.Site,Phone,OwnerId,Owner.Alias,Email)';
                                 
           //SQL[3] = 'FIND Id, Name in from Contact where Phone = \'${meta_cv9}\' ';
           //SQL[4] = 'FIND Id, Name from Contact where MobilePhone = \'${meta_cv9}\' ';
           //SQL[5] = 'FIND \'${meta_cv9}\' IN PHONE FIELDS RETURNING Account(ID, Name, Site,Phone,OwnerId,Owner.Alias), Contact(ID, Name,AccountId, Account.Name, Account.Site,Phone,OwnerId,Owner.Alias,Email), Lead(ID, Name, Title,Company,Email,Status,OwnerId,Owner.Alias), Case(ID, CaseNumber,Subject,Status,OwnerId,Owner.Alias,CreatedDate), Opportunity(ID, Name, Account.Name, Account.Site,StageName,OwnerId,Owner.Alias,CloseDate) ';

           //SQL[3] = 'Select Id, Name from Contact where Phone = \'${meta_cv9}\' ';
           //SQL[4] = 'Select Id, Name from Contact where MobilePhone = \'${meta_cv9}\' ';
          // SQL[1] = 'Select Id, CaseNumber,Subject,Status,OwnerId,Owner.Alias,CreatedDate from Case where CaseNumber = \'${meta_cv8}\' ';
           //SQL[2] = 'Select Id, Name, Account.Name, Account.Site,StageName,OwnerId,Owner.Alias,CloseDate from Opportunity where Name = \'${meta_cv9}\' ';


        //SQL[1] = 'Select Id, Name, Phone from Contact where Phone = \'${meta_cv9}\' ';
/*        SQL[2] = 'Select AccountId, CaseNumber from Case where SuppliedPhone = \'${ani}\' and Status = \'${status}\' ';
        SQL[3] = 'FIND \'${meta_cv1}\' IN PHONE FIELDS RETURNING Account(ID, Name), Contact(ID, Name)';
        SQL[4] = 'Select Id, Name, Phone from Account where Phone = \'${meta_cv3}\' ';
        SQL[5] = 'Select Id, Name, Phone from Lead where Phone = \'${ani}\' ';
*/
                 
        // extract params: var1=val,va2=val2,...
        List<String> oParams = params.split(',', 0);
        
        for (String param : oParams ) {
            String[] keyVal = param.split('=', -1);
            
            if ( keyVal.size() != 2 ) 
                continue;
                
            String varName   = '${' + keyVal[0] + '}';  // var name ${ani}, ${status},...
            String varVal    = keyVal[1];
            
            //Sanitize input values before replacing
            varVal = santizeInputValues(varName, varVal);
            
            // replace
            for (Integer i = 0 ; i < SQL.size() ; i++ ) {
                SQL[i] = SQL[i].replace(varName, varVal);
            }
        }
        
        /* debug? 
        if ( params.contains('debug=true')) {
            return JSON.serialize(SQL);
        }*/
        
       
        // execute SOQL
        for (String stmt : SQL ) {
            String json = doSQL(stmt);
            if ( json != null ) {
                return json;
            }
        }
        
        
        
        //DEBUG: will return the SQL list if no results are found
        return JSON.serialize(SQL);
    }


}