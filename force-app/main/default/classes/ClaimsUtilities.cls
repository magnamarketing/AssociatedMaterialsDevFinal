/**
	* @author CRMCulture
	* @author jmarkey
	* @version 1.00
	* @description Controls data/DML for the ami claims app
*/
global with sharing class ClaimsUtilities {
	// declare variables
	public Id CurrentAccountId {get;set;}
	public Id CurrentContactId {get;set;}
    public String CurrentUserId {get;set;}
    public List<User> UserList {get;set;}
    public Id PropertyOwnerId {get;set;}
    public List<Property_Owner__c> PropertyOwnerList {get;set;}

    // constructor
    public ClaimsUtilities(){
        CurrentUserId = UserInfo.getUserId();
        if(CurrentUserId != null){
            UserList = [SELECT Id, ContactId, Contact.FirstName, Contact.LastName, Contact.Email, AccountId FROM User WHERE Id =: CurrentUserId LIMIT 1];
            if(UserList.size() > 0){
                CurrentContactId = UserList[0].ContactId;
                CurrentAccountId = UserList[0].AccountId;
                PropertyOwnerList = [
                	SELECT Id, First_Name__c, Last_Name__c, Email__c
                	FROM Property_Owner__c
					WHERE Contact__c =: UserList[0].Contact.Id
					LIMIT 1
				];
                if(PropertyOwnerList.size() > 0){
                    PropertyOwnerId = PropertyOwnerList[0].Id;
                }
            }
        }
    }

	// force unauthenticated users to login page
	public PageReference redirect()
	{
		if (UserInfo.getUserType().toUpperCase() == 'GUEST')
		{
			// '/' is bound to the login page
			PageReference redir = new PageReference('/');
			redir.setRedirect(true);
			return redir;
		}
		
		return null;
	}

    @RemoteAction
    global static List<Property__c> getProperties(Id pOwnerId) {
        return [
        	SELECT Id, Property_OwnerId__c, Name, Address_1__c, Address_2__c, Canadian_State__c, City__c, Comment__c, Country__c, Legacy_Property_ID__c, Property_Country_Text__c, Property_Map__c, Property_Type__c, State__c, Zip_Postal_Code__c
			FROM Property__c
			WHERE Property_OwnerId__c =: pOwnerId
			ORDER BY Name DESC
        ];
    }

    @RemoteAction
    global static String saveProperty(Id pOwnerId, String pStreet, String pCity, String pState, String pCountry, String pPostal) {
        Property__c p = new Property__c(
        	Address_1__c = pStreet,
        	City__c = pCity,
        	Country__c = pCountry,
        	Property_OwnerId__c = pOwnerId,
			State__c = pState,
			Zip_Postal_Code__c = pPostal
		);
		insert p;

		return p.Id;
    }

    @RemoteAction
    global static String saveClaim(Id pOwnerId, Id pAccountId, Id pContactId, Id pPropertyId, String pSubject, String pWindowSerial, String pClaimNotes, String pOwenerStatus, String pOriginalStatus, String pTransferStatus, Integer pNumberAffected, String pComplaintTypeWindow, String pComplaintTypeSiding, String pAreaConcern, String pInstallDate, String pBrand, String pProductType, String pSidingColor) {
    	String strDeveloperName = 'Warranty_Windows';
    	if(pSubject.toLowerCase().contains('siding')) {
    		strDeveloperName = 'Warranty_Siding';
    	}
    	RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName =: strDeveloperName LIMIT 1][0];
    	Case c = new Case(
			AccountId = pAccountId,
			Brand__c = pBrand,
			ContactId = pContactId,
			Complaint_Type_Siding_Web_Claim__c = pComplaintTypeSiding,
			Complaint_Type_Windows_Web_Claim__c = pComplaintTypeWindow,
			Installation_Date__c = Date.parse(pInstallDate),
			IsVisibleInSelfService = true,
			Notes__c = pClaimNotes,
			of_Windows_Affected__c = pNumberAffected,
			Origin = 'Web',
			Ownership_Type__c = pOwenerStatus+' '+pOriginalStatus+' '+pTransferStatus,
			Product_Type__c = pProductType,
			Property__c = pPropertyId,
			Property_Owner__c = pOwnerId,
			RecordTypeId = rt.Id,
			Serial_Number__c = pWindowSerial,
			Siding_Color_Name__c = pSidingColor,
			Status_Sorting__c = 'Hot',
			Status = 'New',
			Subject = pSubject,
			Window_Area_of_Concern__c = pAreaConcern
		);
		insert c;

		// move attachemnts from Property_Owner__c to Case, then delete the Property_Owner__c attachments
    	List<Attachment> attachmentList = [SELECT Name, Body FROM Attachment WHERE ParentID =: pOwnerId AND OwnerId =: UserInfo.getUserId()];
    	List<Attachment> tempAttachments = new List<Attachment>{};
    	for(Attachment a : attachmentList) {
    		Attachment b = New Attachment(
				Name = a.Name,
				Body = a.Body
			);
			b.parentID = c.Id;
			tempAttachments.add(b);
    	}
		insert tempAttachments;
		delete attachmentList;

		return c.Id;
    }

    @RemoteAction
    global static void deleteAttachment(Id pAttachmentId) {
        delete [ SELECT Id FROM Attachment WHERE Id =: pAttachmentId AND ownerId =: UserInfo.getUserId() ];
    }

    @RemoteAction
    global static void deleteAttachments(Id pParentId) {
        delete [ SELECT Id FROM Attachment WHERE parentId =: pParentId AND ownerId =: UserInfo.getUserId() ];
    }

    @RemoteAction
    global static List<Case> getClaims() {
        return [
        	SELECT Id, CaseNumber, Serial_Number__c, Status, Description, Notes__c, Priority, Subject, Ownership_Type__c, of_Windows_Affected__c, Property__r.Address_1__c, Complaint_Type_Windows_Web_Claim__c, Complaint_Type_Siding_Web_Claim__c, Window_Area_of_Concern__c, Installation_Date__c, Brand__c, Product_Type__c, Siding_Color_Name__c,
                (SELECT Id, Ship_To_Name__c, Ship_to_Address__c, Comm_Estimated_Ship_Date__c FROM Orders__r ORDER BY Ship_Date__c DESC LIMIT 1)
			FROM Case
			ORDER BY CaseNumber DESC
        ];
    }

    @RemoteAction
    global static List<String> getWindowComplaintTypes() {
		List<String> optionVals = new List<String>();
		Schema.DescribeFieldResult fieldResult = Case.Complaint_Type_Windows_Web_Claim__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for(Schema.PicklistEntry pickListVal : ple) {
			optionVals.add(pickListVal.getLabel());
		}

		return optionVals;
    }

    @RemoteAction
    global static List<String> getSidingComplaintTypes() {
		List<String> optionVals = new List<String>();
		Schema.DescribeFieldResult fieldResult = Case.Complaint_Type_Siding_Web_Claim__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for(Schema.PicklistEntry pickListVal : ple) {
			optionVals.add(pickListVal.getLabel());
		}

		return optionVals;
    }

    @RemoteAction
    global static List<String> getComplaintTypesAreaConcern() {
		List<String> optionVals = new List<String>();
		Schema.DescribeFieldResult fieldResult = Case.Window_Area_of_Concern__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for(Schema.PicklistEntry pickListVal : ple) {
			optionVals.add(pickListVal.getLabel());
		}

		return optionVals;
    }

    @RemoteAction
    global static List<String> getOptionsBrand() {
		List<String> optionVals = new List<String>();
		Schema.DescribeFieldResult fieldResult = Case.Brand__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for(Schema.PicklistEntry pickListVal : ple) {
			optionVals.add(pickListVal.getLabel());
		}

		return optionVals;
    }

    @RemoteAction
    global static List<String> getOptionsProductType() {
		List<String> optionVals = new List<String>();
		Schema.DescribeFieldResult fieldResult = Case.Product_Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for(Schema.PicklistEntry pickListVal : ple) {
			optionVals.add(pickListVal.getLabel());
		}

		return optionVals;
    }

    @RemoteAction
    global static String updateClaim(Id pClaimId, Id pClaimPropertyId, String pClaimNotes, String pClaimPriority, String pClaimSerailNumber, String pClaimStatus, String pClaimSubject, Boolean pUpdatingAddress, String pStreet, String pCity, String pState, String pCountry, String pPostal, Integer pNumberAffected, String pComplaintTypeWindow, String pComplaintTypeSiding, String pAreaConcern, String pInstallDate, String pBrand, String pProductType, String pSidingColor) {
    	Case c = [
    		SELECT Id
    		FROM Case
    		WHERE Id =: pClaimId
    		LIMIT 1
		][0];
		if(c!=null) {
			c.Complaint_Type_Siding_Web_Claim__c = pComplaintTypeSiding;
			c.Complaint_Type_Windows_Web_Claim__c = pComplaintTypeWindow;
			c.Brand__c = pBrand;
			c.Installation_Date__c = Date.parse(pInstallDate);
	        c.Notes__c = pClaimNotes;
			c.of_Windows_Affected__c = pNumberAffected;
			c.Product_Type__c = pProductType;
	        c.Priority = pClaimPriority;
	        c.Serial_Number__c = pClaimSerailNumber;
	        c.Siding_Color_Name__c = pSidingColor;
	        c.Status = pClaimStatus;
	        c.Subject = pClaimSubject;
	        c.Window_Area_of_Concern__c = pAreaConcern;
	        update c;

			if(pUpdatingAddress) {
	        	Property__c p = [SELECT Id FROM Property__c WHERE Id =: pClaimPropertyId];
		        p.Address_1__c = pStreet;
		    	p.City__c = pCity;
		    	p.Country__c = pCountry;
				p.State__c = pState;
				p.Zip_Postal_Code__c = pPostal;
				update p;
	        }
		}

        return c.Id;
    }

    @RemoteAction
    global static List<sObject> hasAttachment(Boolean isUpdate, Id pPropertyOwnerId, Id pClaimId) {
        // because we stage attachments for new claims on the Property_Owner__c record then
        // if this is an update then look at the claim, but if new then look at the property owner
    	if(isUpdate) {
    		return [
	        	SELECT Id, (SELECT Id, Name, OwnerId FROM Attachments WHERE ownerId =: UserInfo.getUserId() ORDER BY Name)
	        	FROM Case
	        	WHERE Case.Id =: pClaimId
	        ];
    	}else {
    		return [
	        	SELECT Id, (SELECT Id, Name, OwnerId FROM Attachments WHERE ownerId =: UserInfo.getUserId() ORDER BY Name)
	        	FROM Property_Owner__c
	        	WHERE Property_Owner__c.Id =: pPropertyOwnerId
	        ];
    	}

    }

	@RemoteAction
    public static String uploadAttachment(Boolean isUpdate, Id pClaimId, Id pPropertyOwnerId, String attachmentBody, String attachmentName, String attachmentId) {
    	// boolean varaible: isUpdate identifies which record to insert/update attachments on: Case (update) Vs. Property_Owner__c (insert) - if isUpdate = true, then update on Case else, insert Property_Owner__c
        if(isUpdate) {
        	if(pClaimId!=null) {
	            Case c = [SELECT Id FROM Case WHERE Id =: pClaimId];
	            if(c!=null) {
	                if(attachmentBody!=null) {
	                    Attachment a = getAttachment(attachmentId);
	                    String newBody = '';
	                    if(a.Body!=null) {
	                        newBody = EncodingUtil.base64Encode(a.Body);
	                    }
	                    newBody += attachmentBody;
	                    a.Body = EncodingUtil.base64Decode(newBody);
	                    if(attachmentId==null) {
	                        a.Name = attachmentName;
	                        a.parentId = c.Id;
	                    }
	                    upsert a;

	                    return a.Id;
	                }else {
	                    return 'Attachment Body was null';
	                }
	            }else {
	                return 'Case could not be found';
	            }
	        }else {
	            return 'Case Id was null';
	        }
        }else {
        	if(pPropertyOwnerId!=null) {
	            Property_Owner__c p = [SELECT Id FROM Property_Owner__c WHERE Id =: pPropertyOwnerId];
	            if(p!=null) {
	                if(attachmentBody!=null) {
	                    Attachment a = getAttachment(attachmentId);
	                    String newBody = '';
	                    if(a.Body!=null) {
	                        newBody = EncodingUtil.base64Encode(a.Body);
	                    }
	                    newBody += attachmentBody;
	                    a.Body = EncodingUtil.base64Decode(newBody);
	                    if(attachmentId==null) {
	                        a.Name = attachmentName;
	                        a.parentId = p.Id;
	                    }
	                    upsert a;

	                    return a.Id;
	                }else {
	                    return 'Attachment Body was null';
	                }
	            }else {
	                return 'Property Owner could not be found';
	            }
	        }else {
	            return 'Property Owner Id was null';
	        }
        }
    }

	public static Attachment getAttachment(Id pAttachmentId) {
        list<Attachment> attachments = [
        	SELECT Id, Body
            FROM Attachment
            WHERE Id =: pAttachmentId
        ];
        if(attachments.isEmpty()) {
            Attachment a = new Attachment();
            return a;
        }else {
            return attachments[0];
        }
    }

}