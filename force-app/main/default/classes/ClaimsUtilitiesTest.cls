/**
	* @author CRMCulture
	* @author jmarkey
	* @version 1.00
	* @description Describes test class for class ClaimsUtilities
*/

@isTest
public with sharing class ClaimsUtilitiesTest {

    public static testMethod void test_method_1() {
    	// stage test data
		Profile profile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1][0];

		Account a = new Account(
 			AccountNumber = '123456789',
 			Company_Number__c = '123',
 			Customer_Number__c = '1234',
 			External_Id__c = '1234',
       		Name = 'Communities Users',
       		Sub_Account__c = 'non'
        );
 		insert a;

 		Contact c = new Contact(
 			AccountId = a.Id,
 			Email = 'test@test.com',
 			FirstName = 'Test First Name',
 			LastName = 'Test Last Name',
 			MailingCity = 'Denver',
 			MailingPostalCode = '80203',
 			MailingStreet = '123 Test St.',
 			Phone = '999-999-9999',
 			Title = 'Test Title'
 		);
 		insert c;

    	User u = new User(
       		Alias = 'standt',
       		ContactId = c.Id,
       		Email = 'salesforce@crmculture.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestLastName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testUser'+UserInfo.getOrganizationId()+'@testorg.com'

        );
 		insert u;

 		Property_Owner__c po = new Property_Owner__c(
 			CreatedById = u.Id,
 			Email__c = 'salesforce@crmculture.com',
 			Mailing_Address_1__c = '123 Test St.',
 			Mailing_City__c = 'Denver',
 			Mailing_Zip_Postal_Code__c = '80203',
 			OwnerId = u.Id,
 			Phone__c = '999-999-9999'
 		);
 		insert po;

 		Property__c p = new Property__c(
        	Address_1__c = '910 15th St.',
        	City__c = 'Denver',
        	Country__c = 'USA',
        	Property_OwnerId__c = po.Id,
			State__c = 'CO',
			Zip_Postal_Code__c = '80203'
		);
		insert p;

 		Case ca = new Case(
 			AccountId = a.Id,
 			ContactId = c.Id,
			Complaint_Type__c = 'Air Infiltration',
			IsVisibleInSelfService = true,
			Notes__c = 'Test Notes',
			of_Windows_Affected__c = 1,
			Origin = 'Web',
			OwnerId = u.Id,
			Ownership_Type__c = 'Test Ownership Type',
			Priority = 'Medium',
			Property__c = p.Id,
			Property_Owner__c = po.Id,
			RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Warranty_Windows' LIMIT 1][0].Id,
			Serial_Number__c = 'Test Serial Number',
			Status = 'New',
			Status_Sorting__c = 'Hot',
			Subject = 'Test Subject'
 		);
 		insert ca;

 		Opportunity o = new Opportunity(
 			AccountId = a.Id,
 			Amount = 100,
            CloseDate = Date.parse('1/1/2016'),
            CreatedById = u.Id,
            Description = 'Test Description',
            LeadSource = 'Web',
            Name = 'Test Opportunity',
            OwnerId = u.Id,
            StageName = 'Prospecting',
            Type = 'New Business'
        );
 		insert o;

 		Attachment attach = new Attachment(
 			Body = Blob.valueOf('Unit Test Attachment Body'),
 			Name = 'Test Attachment',
 			ParentId = ca.Id
 		);
        insert attach;

        Attachment attach2 = new Attachment(
 			Body = Blob.valueOf('Test Attachment Body'),
 			Name = 'Test Attachment',
 			ParentId = ca.Id
 		);
 		insert attach2;

 		// execute test
		Test.startTest();
		System.runAs(new User(Id=UserInfo.getUserId())) {
			System.runAs(u){
				// test variables
				ClaimsUtilities cu = new ClaimsUtilities();
				System.assert(cu.CurrentAccountId != null);
				System.assert(cu.CurrentContactId != null);
				System.assert(cu.CurrentUserId != null);
				System.assert(cu.UserList.size() > 0);
				System.assert(cu.PropertyOwnerId != null);
				System.assert(cu.PropertyOwnerList.size() > 0);
			}
			// test methods
			ClaimsUtilities.getProperties(p.Property_OwnerId__c);
			ClaimsUtilities.saveProperty(p.Property_OwnerId__c, '910 15th St.', 'Denver', 'CO', 'USA', '80203');
			ClaimsUtilities.saveClaim(p.Property_OwnerId__c, a.Id, c.Id, p.Id, 'Test Subject', 'Test Serial Number', 'Test Notes', 'Test Owner Status', 'Test Original Status', 'Test Transfer Status', 1, 'Seal Failure', 'Hail', 'Top', '1/1/2016', 'Alpine', 'Double Hung', 'Test Siding Color');
			ClaimsUtilities.saveClaim(p.Property_OwnerId__c, a.Id, c.Id, p.Id, 'siding', 'Test Serial Number', 'Test Notes', 'Test Owner Status', 'Test Original Status', 'Test Transfer Status', 1, 'Seal Failure', 'Hail', 'Top', '1/1/2016', 'Alpine', 'Double Hung', 'Test Siding Color');
			ClaimsUtilities.getClaims();
			ClaimsUtilities.getWindowComplaintTypes();
			ClaimsUtilities.getSidingComplaintTypes();
			ClaimsUtilities.getComplaintTypesAreaConcern();
			ClaimsUtilities.getOptionsBrand();
			ClaimsUtilities.getOptionsProductType();
			ClaimsUtilities.updateClaim(ca.Id, ca.Property__c, 'Test Claim Notes', 'Medium', 'Test Claim Serial Number', 'Test Claim Status', 'Test Claim Subject', false, '910 15th St.', 'Denver', 'CO', 'USA', '80203', 1, 'Seal Failure', 'Hail', 'Top', '1/1/2016', 'Alpine', 'Double Hung', 'Test Siding Color');
			ClaimsUtilities.updateClaim(ca.Id, ca.Property__c, 'Test Claim Notes', 'Medium', 'Test Claim Serial Number', 'Test Claim Status', 'Test Claim Subject', true, '910 15th St.', 'Denver', 'CO', 'USA', '80203', 1, 'Seal Failure', 'Hail', 'Top', '1/1/2016', 'Alpine', 'Double Hung', 'Test Siding Color');
			String testAttachment1 = ClaimsUtilities.uploadAttachment(true, ca.Id, po.Id, 'TestAttachentBody', 'Test Attachment', attach.Id);
			String testAttachment2 = ClaimsUtilities.uploadAttachment(true, ca.Id, po.Id, null, 'Test Attachment', attach.Id);
            String testAttachment3 = ClaimsUtilities.uploadAttachment(true, ca.Id, po.Id, null, 'Test Attachment', null);
            String testAttachment4 = ClaimsUtilities.uploadAttachment(false, ca.Id, po.Id, 'TestAttachentBody', 'Test Attachment', attach.Id);
            String testAttachment5 = ClaimsUtilities.uploadAttachment(false, ca.Id, po.Id, null, 'Test Attachment', attach.Id);
            String testAttachment6 = ClaimsUtilities.uploadAttachment(false, ca.Id, po.Id, null, 'Test Attachment', null);
			System.assert(!String.isBlank(testAttachment1));
			System.assert(!String.isBlank(testAttachment2));
			System.assert(!String.isBlank(testAttachment3));
			System.assert(!String.isBlank(testAttachment4));
            System.assert(!String.isBlank(testAttachment5));
            System.assert(!String.isBlank(testAttachment6));
			Attachment testAttach = ClaimsUtilities.getAttachment(attach.Id);
			Attachment testAttach2 = ClaimsUtilities.getAttachment(attach2.Id);
			System.assert(testAttach != null);
			System.assert(testAttach2 != null);
		}
		Test.stopTest();
    }

    public static testMethod void test_method_2() {
    	// execute test
		Test.startTest();
		LoginController lc = new LoginController();
		lc.username = 'test@salesforce.com';
		lc.password = 'Password12345!';
		lc.origin = 'alpine';
		lc.login();
		// assert test
		System.assert(lc.login()!=null);
		Test.stopTest();
    }

    public static testMethod void test_delete_single_attachment() {

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1][0];

        Account a = new Account(
            AccountNumber = '123456789',
            Company_Number__c = '123',
            Customer_Number__c = '1234',
            External_Id__c = '1234',
            Name = 'Communities Users',
            Sub_Account__c = 'non'
        );
        insert a;

        Contact c = new Contact(
            AccountId = a.Id,
            Email = 'test@test.com',
            FirstName = 'Test First Name',
            LastName = 'Test Last Name',
            MailingCity = 'Denver',
            MailingPostalCode = '80203',
            MailingStreet = '123 Test St.',
            Phone = '999-999-9999',
            Title = 'Test Title'
        );
        insert c;

        User u = new User(
            Alias = 'standt',
            ContactId = c.Id,
            Email = 'salesforce@crmculture.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestLastName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testUser'+UserInfo.getOrganizationId()+'@testorg.com'

        );
        insert u;

        Property_Owner__c po = new Property_Owner__c(
            CreatedById = u.Id,
            Email__c = 'salesforce@crmculture.com',
            Mailing_Address_1__c = '123 Test St.',
            Mailing_City__c = 'Denver',
            Mailing_Zip_Postal_Code__c = '80203',
            OwnerId = u.Id,
            Phone__c = '999-999-9999'
        );
        insert po;

        Property__c p = new Property__c(
            Address_1__c = '910 15th St.',
            City__c = 'Denver',
            Country__c = 'USA',
            Property_OwnerId__c = po.Id,
            State__c = 'CO',
            Zip_Postal_Code__c = '80203'
        );
        insert p;

        Case ca = new Case(
            AccountId = a.Id,
            ContactId = c.Id,
            Complaint_Type__c = 'Air Infiltration',
            IsVisibleInSelfService = true,
            Notes__c = 'Test Notes',
            of_Windows_Affected__c = 1,
            Origin = 'Web',
            OwnerId = u.Id,
            Ownership_Type__c = 'Test Ownership Type',
            Priority = 'Medium',
            Property__c = p.Id,
            Property_Owner__c = po.Id,
            RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Warranty_Windows' LIMIT 1][0].Id,
            Serial_Number__c = 'Test Serial Number',
            Status = 'New',
            Status_Sorting__c = 'Hot',
            Subject = 'Test Subject'
        );
        insert ca;

        Attachment attach = new Attachment(
            Body = Blob.valueOf('Unit Test Attachment Body'),
            Name = 'Test Attachment',
            ParentId = ca.Id,
            ownerId = UserInfo.getUserId()
        );
        insert attach;

        System.runAs( u ) {

            Test.startTest();

            Attachment attach2 = new Attachment(
                Body = Blob.valueOf('Unit Test Attachment Body'),
                Name = 'Test Attachment',
                ParentId = ca.Id,
                ownerId = u.id
            );
            insert attach2;

            System.assertEquals( 1, [ SELECT count() FROM Attachment WHERE id =: attach.Id ] );
            System.assertEquals( 1, [ SELECT count() FROM Attachment WHERE id =: attach2.Id ] );

            ClaimsUtilities.deleteAttachment( attach.id );
            ClaimsUtilities.deleteAttachment( attach2.id );

            System.assertEquals( 1, [ SELECT count() FROM Attachment WHERE id =: attach.Id ], 'should not delete unowned attachment' );
            System.assertEquals( 0, [ SELECT count() FROM Attachment WHERE id =: attach2.Id ], 'should delete owned attachment' );

            Test.stopTest();

        }

    }

    public static testMethod void test_delete_multiple_attachments() {

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1][0];

        Account a = new Account(
            AccountNumber = '123456789',
            Company_Number__c = '123',
            Customer_Number__c = '1234',
            External_Id__c = '1234',
            Name = 'Communities Users',
            Sub_Account__c = 'non'
        );
        insert a;

        Contact c = new Contact(
            AccountId = a.Id,
            Email = 'test@test.com',
            FirstName = 'Test First Name',
            LastName = 'Test Last Name',
            MailingCity = 'Denver',
            MailingPostalCode = '80203',
            MailingStreet = '123 Test St.',
            Phone = '999-999-9999',
            Title = 'Test Title'
        );
        insert c;

        User u = new User(
            Alias = 'standt',
            ContactId = c.Id,
            Email = 'salesforce@crmculture.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestLastName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testUser'+UserInfo.getOrganizationId()+'@testorg.com'

        );
        insert u;

        Property_Owner__c po = new Property_Owner__c(
            CreatedById = u.Id,
            Email__c = 'salesforce@crmculture.com',
            Mailing_Address_1__c = '123 Test St.',
            Mailing_City__c = 'Denver',
            Mailing_Zip_Postal_Code__c = '80203',
            OwnerId = u.Id,
            Phone__c = '999-999-9999'
        );
        insert po;

        Property__c p = new Property__c(
            Address_1__c = '910 15th St.',
            City__c = 'Denver',
            Country__c = 'USA',
            Property_OwnerId__c = po.Id,
            State__c = 'CO',
            Zip_Postal_Code__c = '80203'
        );
        insert p;

        Attachment attach = new Attachment(
            Body = Blob.valueOf('Unit Test Attachment Body'),
            Name = 'Test Attachment',
            ParentId = po.Id,
            ownerId = UserInfo.getUserId()
        );
        insert attach;

        System.runAs( u ) {

            Test.startTest();

            Attachment attach2 = new Attachment(
                Body = Blob.valueOf('Unit Test Attachment Body'),
                Name = 'Test Attachment',
                ParentId = po.Id,
                ownerId = u.id
            );
            insert attach2;

            System.assertEquals( 1, [ SELECT count() FROM Attachment WHERE id =: attach.Id ] );
            System.assertEquals( 1, [ SELECT count() FROM Attachment WHERE id =: attach2.Id ] );

            ClaimsUtilities.deleteAttachments( po.Id );

            System.assertEquals( 1, [ SELECT count() FROM Attachment WHERE id =: attach.Id ], 'should not delete unowned attachment' );
            System.assertEquals( 0, [ SELECT count() FROM Attachment WHERE id =: attach2.Id ], 'should delete owned attachment' );

            Test.stopTest();

        }

    }

    public static testMethod void test_Redirect() 
    {
        User u = [SELECT Id FROM User WHERE UserType = 'Guest' LIMIT 1];
        PageReference pageRef;
        
        System.runAs(u)
        {
            Test.startTest();
            
            ClaimsUtilities cu = new ClaimsUtilities();
            pageRef = cu.redirect();

            Test.stopTest();
        }

        System.assertEquals(false, pageRef == null);
    }

}