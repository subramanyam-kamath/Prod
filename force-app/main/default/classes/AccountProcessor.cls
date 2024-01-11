public class AccountProcessor{

@future
public static void countContacts2(List<Id> recordids){

Account[] accts = [Select Id, Number_Of_Contacts__c from Account where Id IN:recordIds];

List<Account> acct2 = new List<Account>();

for (account acct : accts){

id recordid = acct.id;
List<AggregateResult> contcount = [Select count(id) from Contact where Accountid=:recordid];
acct.Number_Of_Contacts__c= (integer)contcount[0].get('expr0');

acct2.add(acct);
}

update acct2;

//Commentadded35890
//Commentadded590
//Commentadded7
//Commentadded9
//Commentadded10
//commentadded11
//Commentadded12
//commentadded13
//commentadded14
//commentadded15

}
}
