@isTest
public class AccountProcessorTest{

 public static void testAccountProcessor(){

Account acct = new account (Name='Test');

insert acct;

Contact cnt = new Contact (Lastname='Test', accountid=acct.id);

insert cnt;

Account[] accts = [Select Id, Number_Of_Contacts__c from Account where Id =:acct.id];

List<Id> records = new List<Id>();


for(account acct2 : accts){
    records.add(acct2.id);
}


Test.startTest();

 AccountProcessor.countContacts(records);


Test.stopTest();

Account ACC = [select Number_of_Contacts__c from Account where id = :acct.id LIMIT 1];
System.assertequals(2,Integer.valueOf(ACC.Number_of_Contacts__c));


}
}
