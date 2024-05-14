/**
* @author CRMCulture
* @author ksears
* @version 1.00
* @description This Class
*/
public with sharing class ContactHelper {
    /**
    * @author CRMCulture
    * @author ksears
    * @version 1.00
    * @description Constructor
    */
    public static void CreateNewPropertyOwner(List<Contact> newContacts) {
        List<Property_Owner__c> owners = new List<Property_Owner__c>();
        for(Contact c : newContacts){
            Property_Owner__c p = new Property_Owner__c();
            p.Contact__c = c.Id;
            p.Owner_Level__c = '1st';
            p.Email__c = c.Email;
            p.Phone__c = c.Phone;
            p.Mobile_Phone__c = c.MobilePhone;
            p.First_Name__c = c.FirstName;
            p.Last_Name__c = c.LastName;
            p.Mailing_Address_1__c = '.';
            p.Mailing_City__c = '.';
            p.Mailing_Zip_Postal_Code__c = '.';
            owners.add(p);
        }
        insert owners;
    }

}