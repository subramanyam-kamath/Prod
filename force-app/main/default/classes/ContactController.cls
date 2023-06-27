public with sharing class ContactController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(Id Accountidntr) {
        return [
            SELECT FirstName, LastName,Title, Email,Phone
            FROM Contact where AccountId=:Accountidntr
            WITH SECURITY_ENFORCED
            ORDER BY LastName
        ];
        }
        
        
          public static List<Contact> getContacts(String Emailadd) {
        return [
            SELECT FirstName, LastName,Title, Email,Phone
            FROM Contact where Accountid=:Emailadd
            WITH SECURITY_ENFORCED
            ORDER BY LastName
        ];
        
        }}