public class AccountHandler {



public static void insertAccount(List<Account> acc){

for(Account a3: acc){

List<Account> acct2 = [Select Id,SLASerialNumber__c from Account where SLASerialNumber__c=:a.SLASerialNumber__c  limit 1];

    
    if(
    (acct2.size()>0))
    {
    
    a.addError('We have duplicate record with this serial number');
    
        
    }
    
    }

}
}
